if not ConfigDrift.useDriftChallenges then return end

local ActiveChallenges = {}
local DriftChallengeLength = ConfigDrift.driftChallengeSettings.length or 60 -- seconds
local WaitTime = ConfigDrift.driftChallengeSettings.waitTime or 10 -- seconds to wait for joiners


local function generateChallengeId()
    local id = "DC-" .. math.random(1111, 9999)
    while ActiveChallenges[id] ~= nil do
        id = "DC-" .. math.random(1111, 9999)
    end
    return id
end

local function endRace(challengeId)
    if ActiveChallenges[challengeId] then
        if Config.Debug then print('Cleaning up '.. challengeId..' due to inactivity') end
        for _, racer in pairs(ActiveChallenges[challengeId].racers) do
            TriggerClientEvent('cw-racingapp:drift-challenge:client:leave', racer.source)
        end
        ActiveChallenges[challengeId] = nil
    end
end

local function handleTimeout(challengeId)
    SetTimeout(Config.RaceResetTimer, function()
        endRace(challengeId)
    end)
end

RegisterNetEvent('cw-racingapp:drift-challenge:server:leaveChallenge', function(challengeId)
    endRace(challengeId)
end)

RegisterNetEvent('cw-racingapp:drift-challenge:server:setup', function(racerName)
    local src = source
    local challengeId = generateChallengeId()
    if UseDebug then print('Generated drift challenge ID:', challengeId) end

    ActiveChallenges[challengeId] = {
        challengeId = challengeId,
        racers = { { source = src, name = racerName } },
        started = false,
        finished = false,
        scores = {}
    }

    -- Start wait period for other racers
    TriggerClientEvent('cw-racingapp:drift-challenge:client:checkForJoiners', src, challengeId)
    
    -- Start challenge after wait period
    SetTimeout(WaitTime * 1000, function()
        if ActiveChallenges[challengeId] then
            for _, racer in pairs(ActiveChallenges[challengeId].racers) do
                TriggerClientEvent('cw-racingapp:drift-challenge:client:startCountdown', racer.source, challengeId)
            end
        end
    end)

    handleTimeout(challengeId)
end)

RegisterNetEvent('cw-racingapp:drift-challenge:server:invitePlayer', function(targetSrc, challengeId, racerName)
    local src = source
    if UseDebug then print('Player', src, 'is inviting', targetSrc, 'to drift challenge', challengeId) end
    if not ActiveChallenges[challengeId] then return end
    if ActiveChallenges[challengeId].started then return end

    if UseDebug then
        print('Sending drift challenge invite to player', targetSrc, 'for challenge', challengeId)
    end
    TriggerClientEvent('cw-racingapp:drift-challenge:client:receiveInvite', targetSrc, challengeId, racerName)
end)

RegisterNetEvent('cw-racingapp:drift-challenge:server:join', function(challengeId, racerName)
    local src = source
    if not ActiveChallenges[challengeId] then print('No active challenge with ID:', challengeId) return end
    if ActiveChallenges[challengeId].started then return end

    for _, racer in pairs(ActiveChallenges[challengeId].racers) do
        TriggerClientEvent('cw-racingapp:drift-challenge:client:notifyNewJoiner', 
            racer.source, racerName)
    end
    table.insert(ActiveChallenges[challengeId].racers, { 
        source = src,
        name = racerName
    })


end)

RegisterNetEvent('cw-racingapp:drift-challenge:server:updateScore', function(challengeId, score)
    local src = source
    if not ActiveChallenges[challengeId] then return end
    if not ActiveChallenges[challengeId].started then return end
    
    ActiveChallenges[challengeId].scores[src] = score

    -- Broadcast score update to all participants
    for _, racer in pairs(ActiveChallenges[challengeId].racers) do
        TriggerClientEvent('cw-racingapp:drift-challenge:client:updateScores', 
            racer.source, ActiveChallenges[challengeId].scores)
    end
end)

RegisterNetEvent('cw-racingapp:drift-challenge:server:started', function(challengeId)
    if not ActiveChallenges[challengeId] then return end
    ActiveChallenges[challengeId].started = true

    -- Set end timer
    SetTimeout(DriftChallengeLength * 1000, function()
        if ActiveChallenges[challengeId] then
            -- Find winner
            local highestScore = -1
            local winner = nil

            for _, racer in pairs(ActiveChallenges[challengeId].racers) do
                TriggerClientEvent('cw-racingapp:drift-challenge:client:getFinalScore', 
                    racer.source)
            end

            Wait(1000)
            ActiveChallenges[challengeId].finalScores = {}

            -- Build final scores array using racer names and default missing scores to 0
            for _, racer in pairs(ActiveChallenges[challengeId].racers) do
                local src = racer.source
                local score = ActiveChallenges[challengeId].scores[src] or 0
                table.insert(ActiveChallenges[challengeId].finalScores, {
                    RacerSource = src,
                    RacerName = racer.name or "Unknown",
                    DriftScore = score,
                    Finished = true
                })
            end

            -- Sort final scores descending by DriftScore
            table.sort(ActiveChallenges[challengeId].finalScores, function(a, b) return a.DriftScore > b.DriftScore end)

            -- Determine winner/highestScore from sorted results
            if #ActiveChallenges[challengeId].finalScores > 0 then
                highestScore = ActiveChallenges[challengeId].finalScores[1].DriftScore
                winner = ActiveChallenges[challengeId].finalScores[1].RacerSource
            end

            -- Notify all participants with the structured finalScores array
            for _, racer in pairs(ActiveChallenges[challengeId].racers) do
                TriggerClientEvent('cw-racingapp:drift-challenge:client:finish', 
                    racer.source, winner, highestScore,challengeId, ActiveChallenges[challengeId].finalScores)
            end

            ActiveChallenges[challengeId] = nil
        end
    end)
end)