local useDebug = Config.Debug
local debugAlgo = false
local ultraDebug = false

local function getRankingForCrew(crewName)
    if useDebug and ultraDebug then
        local names = {
        ['TEST1'] = { rank = 6 },
        ['Tofu Delivery'] = { rank = 7 },
        ['Not A real Crew'] = { rank = 1 },
    }
        return names[crewName].rank
    else 
        return GetCrewRanking(crewName)
    end
end

local modifiers = ConfigELO
if not modifiers then
    print('^1!!! SOMETHING IS FUCKED UP WITH YOUR CONFIG SETUP. ELO CONFIG MISSING !!!^0')
end

local function calculateTrueSkillRatingsForCrews(crewRacers)
    if debugAlgo then 
        print('= STARTING ELO CALCULATIONS FOR CREWS =')
        print('crews sent for elo check', json.encode(crewRacers, {indent=true}))
    end
    -- Sort the results based on TotalTime in ascending order
    local tempTable = DeepCopy(crewRacers)
    table.sort(tempTable, function(a, b) return a.averageTime < b.averageTime end)
    -- Initialize position-based weight

    -- Update ratings for each racer
    for i, crew in ipairs(tempTable) do
        local delta = 0 -- Initialize change in rating
        if debugAlgo then print('====', crew.crewName, '====') end

        for j, opponent in ipairs(tempTable) do
            if i ~= j then
                local change = 0
                -- Calculate rank difference with adjusted impact based on win/loss and score difference
                local rankDifference = crew.rank - opponent.rank
                local scoreDifference = math.abs(crew.rank - opponent.rank)
                local scalingFactor = 1 / (1 + scoreDifference) -- Adjust scaling factor based on score difference
                if debugAlgo then print('-- Scaling factor', scalingFactor) end
                if crew.averageTime < opponent.averageTime then
                    if debugAlgo then print('win') end
                    if rankDifference > 0 then                                                              -- if your rank is higher than opponent
                        scoreDifference = scoreDifference * modifiers.winAgainstLowerRankMod *
                        scalingFactor                                                                       -- Lesser impact for higher rank
                    else
                        scoreDifference = scoreDifference *
                        modifiers.winAgainstLowerRankMod                                                    -- Greater impact for lower rank
                    end
                    -- Player beats opponent
                    change = 0.05 + (scoreDifference) -- Adjust scaling factors
                elseif crew.averageTime > opponent.averageTime then
                    if debugAlgo then print('loss') end
                    -- Player loses
                    if rankDifference > 0 then -- if your rank is higher than opponent
                        scoreDifference = scoreDifference * modifiers.lossAgainstHigherRankMod
                    else
                        scoreDifference = scoreDifference * modifiers.lossAgainstLowerRankMod * scalingFactor
                    end
                    -- Player is beaten by opponent
                    change = -1 * scoreDifference -- Adjust scaling factors
                end
                if debugAlgo then print('change', change) end
                -- Update delta
                delta = delta + change
                if debugAlgo then print('New delta:', delta) end
            end
        end
        -- Apply position bonus --
        if #tempTable == 2 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusTwo) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusTwo[positionBonusIdx]
        elseif #tempTable == 3 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusThree) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusThree[positionBonusIdx]
        elseif #tempTable == 4 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusFour) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusFour[positionBonusIdx]
        elseif #tempTable == 5 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusFive) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusFive[positionBonusIdx]
        elseif #tempTable > 5 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusOverFive) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusOverFive[positionBonusIdx]
        end
        if debugAlgo then print('After position bonus', delta) end
        -- Ensure winner's rating doesn't increase excessively
        if i == 1 then
            delta = math.min(delta, 30) -- Cap maximum increase for winner
        end
        -- Ensure loser's rating doesn't decrease excessively
        if i == #tempTable then
            delta = math.max(delta, -20) -- Cap maximum decrease for loser
        end
        -- Apply change in rating
        -- tempTable[i].Ranking = tempTable[i].Ranking + math.ceil(delta)
        -- Store total change in ranking
        tempTable[i].totalChange = math.ceil(delta)
    end

    return tempTable
end

local function calculateCrewPositions(crewTable)
    if debugAlgo then print('= GETTING CREW POSITIONS =') end
    local teams = {}           -- Create a table to store team totals
    local teamPositions = {}   -- Create a table to store team positions
    local teamRacersCount = {} -- Create a table to store the count of racers in each team

    -- Calculate total time for each team and determine team positions
    for _, racer in ipairs(crewTable) do
        if not teams[racer.RacingCrew] then
            teams[racer.RacingCrew] = 0
            teamPositions[racer.RacingCrew] = {
                amountOfRacers = 0,
                averageTime = 0,
                crewName = racer.RacingCrew
            }
            teamRacersCount[racer.RacingCrew] = 0
        end
        teams[racer.RacingCrew] = teams[racer.RacingCrew] + racer.TotalTime
        teamRacersCount[racer.RacingCrew] = teamRacersCount[racer.RacingCrew] + 1
    end

    -- Calculate average total time for each team
    for team, totalTime in pairs(teams) do
        local averageTime = totalTime / teamRacersCount[team]
        teamPositions[team].amountOfRacers = teamRacersCount[team]
        teamPositions[team].averageTime = math.floor(averageTime)
    end

    -- Sort teams by average time (ascending order)
    local sortedTeams = {}
    for _, data in pairs(teamPositions) do
        table.insert(sortedTeams, data)
    end
    table.sort(sortedTeams, function(a, b) return a.averageTime < b.averageTime end)

    -- Assign positions based on the sorted order
    for position, data in ipairs(sortedTeams) do
        data.position = position
        data.rank = getRankingForCrew(data.crewName)
    end

    return calculateTrueSkillRatingsForCrews(sortedTeams)
end

function calculateTrueSkillRatings(results)
    if debugAlgo then 
        print('= STARTING ELO CALCULATIONS =')
        print('ALL results', json.encode(results, {indent=true}))
    end
    -- Sort the results based on TotalTime in ascending order
    local tempTable = DeepCopy(results)

    table.sort(tempTable, function(a, b) return a.TotalTime < b.TotalTime end)
    -- Initialize position-based weight
    local crewTable = {}

    -- Update ratings for each racer
    for i, racer in ipairs(tempTable) do
        local delta = 0 -- Initialize change in rating
        if debugAlgo then print('====', racer.RacerName, '====') end

        if racer.RacingCrew then
            if debugAlgo then print('Racer was in a crew. Adding to crew table') end
            crewTable[#crewTable + 1] = racer
        end

        for j, opponent in ipairs(tempTable) do
            if i ~= j then
                local change = 0
                -- Calculate rank difference with adjusted impact based on win/loss and score difference
                local rankDifference = racer.Ranking - opponent.Ranking
                local scoreDifference = math.abs(racer.Ranking - opponent.Ranking)
                local scalingFactor = 1 / (1 + scoreDifference) -- Adjust scaling factor based on score difference
                if debugAlgo then print('-- Scaling factor', scalingFactor) end
                if racer.TotalTime < opponent.TotalTime then
                    if debugAlgo then print('win') end
                    if rankDifference > 0 then                                                              -- if your rank is higher than opponent
                        scoreDifference = scoreDifference * modifiers.winAgainstLowerRankMod *
                        scalingFactor                                                                       -- Lesser impact for higher rank
                    else
                        scoreDifference = scoreDifference *
                        modifiers.winAgainstLowerRankMod                                                    -- Greater impact for lower rank
                    end
                    -- Player beats opponent
                    change = 0.05 + (scoreDifference) -- Adjust scaling factors
                elseif racer.TotalTime > opponent.TotalTime then
                    if debugAlgo then print('loss') end
                    -- Player loses
                    if rankDifference > 0 then -- if your rank is higher than opponent
                        scoreDifference = scoreDifference * modifiers.lossAgainstHigherRankMod
                    else
                        scoreDifference = scoreDifference * modifiers.lossAgainstLowerRankMod * scalingFactor
                    end
                    -- Player is beaten by opponent
                    change = -1 * scoreDifference -- Adjust scaling factors
                end
                if debugAlgo then print('change', change) end
                -- Update delta
                delta = delta + change
                if debugAlgo then print('New delta:', delta) end
            end
        end
        -- Apply position bonus --
        if #tempTable == 2 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusTwo) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusTwo[positionBonusIdx]
        elseif #tempTable == 3 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusThree) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusThree[positionBonusIdx]
        elseif #tempTable == 4 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusFour) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusFour[positionBonusIdx]
        elseif #tempTable == 5 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusFive) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusFive[positionBonusIdx]
        elseif #tempTable > 5 then
            local positionBonusIdx = math.min(i, #modifiers.positionBonusOverFive) -- Ensure weight index is within bounds
            delta = delta + modifiers.positionBonusOverFive[positionBonusIdx]
        end
        if debugAlgo then print('After position bonus', delta) end
        -- Ensure winner's rating doesn't increase excessively
        if i == 1 then
            delta = math.min(delta, 30) -- Cap maximum increase for winner
        end
        -- Ensure loser's rating doesn't decrease excessively
        if i == #tempTable then
            delta = math.max(delta, -20) -- Cap maximum decrease for loser
        end

        local totalChange = math.ceil(delta)
        if debugAlgo then
            print('Total change:', totalChange)
        end
        tempTable[i].TotalChange = totalChange
    end

    local crewRes = {}
    if #crewTable > 0 then
        crewRes = calculateCrewPositions(crewTable)
    end

    return tempTable, crewRes
end

if useDebug and ultraDebug then -- Example input for testing
    print('DEBUGGING RACINGAPP ELO')
    local results = {
        { TotalTime = 100, RacerName = 'Winner',  Ranking = 0,   RacingCrew = 'TEST1' },
        { TotalTime = 220, RacerName = 'middle1', Ranking = 0 },
        { TotalTime = 230, RacerName = 'middle2', Ranking = 30,  RacingCrew = 'Tofu Delivery' },
        { TotalTime = 240, RacerName = 'middle3', Ranking = 200, RacingCrew = 'Not A real Crew' },
        { TotalTime = 250, RacerName = 'middle4', Ranking = 0,   RacingCrew = 'Not A real Crew' },
        { TotalTime = 900, RacerName = 'Loser',   Ranking = 110, RacingCrew = 'TEST1' },
    }
    -- Calculate TrueSkill ratings
    local res, crewRes = calculateTrueSkillRatings(results)
    -- Print results
    for _, result in ipairs(res) do
        print(result.RacerName, "New Ranking:", result.Ranking, "Total Change:", result.TotalChange)
    end

    -- Crew
    for _, teamData in pairs(crewRes) do
        print('-- ' .. teamData.crewName .. ' -- ')
        print("Position:", teamData.position)
        print("Amount of racers:", teamData.amountOfRacers)
        print("Average time:", teamData.averageTime)
        print("Rank:", teamData.rank)
        print("Change:", teamData.totalChange)
        print()
    end
end
