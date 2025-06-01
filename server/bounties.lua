Bounties = {}
local UseDebug = Config.Debug

-- Bounty generation function
local function generateBounties()
    local bounties = {}
    local bountyOptions = Config.BountiesOptions

    -- Determine the number of bounties to generate
    local numBounties = math.random(bountyOptions.minAmount, bountyOptions.maxAmount)

    -- Create a deep copy of the Config.Bounties table
    local availableBounties = {}
    for _, bounty in ipairs(Config.Bounties) do
        availableBounties[#availableBounties + 1] = {
            trackId = bounty.trackId,
            maxClass = bounty.maxClass,
            reversed = bounty.reversed,
            timeToBeat = bounty.timeToBeat,
            extraTime = bounty.extraTime,
            price = bounty.price,
            rankRequired = bounty.rankRequired or Config.BountiesOptions.defaultRankRequirement,
            sprint = bounty.sprint,
        }
    end

    if UseDebug then print('Bounty set up:', json.encode(availableBounties[#availableBounties], {indent=true})) end

    -- Generate the bounties
    for i = 1, numBounties do
        if #availableBounties == 0 then
            break
        end

        -- Select a random bounty from the available bounties
        local randomIndex = math.random(1, #availableBounties)
        local selectedBounty = availableBounties[randomIndex]

        local trackName = 'TRACK DOES NOT EXIST IN DATABASE'
        if Tracks[selectedBounty.trackId] then
            trackName = Tracks[selectedBounty.trackId].RaceName
        end

        local bounty = {
            id = "bty_" .. tostring(i),
            trackId = selectedBounty.trackId,
            maxClass = selectedBounty.maxClass,
            reversed = selectedBounty.reversed,
            timeToBeat = selectedBounty.timeToBeat + math.random(0, selectedBounty.extraTime),
            price = selectedBounty.price,
            rankRequired = selectedBounty.rankRequired,
            sprint = selectedBounty.sprint,
            claimed = {
                -- ['CoffeeGod'] = { racerName= 'CoffeeGod', vehicleModel = 'Sultan Classic', time= 31720 },
            },
            trackName = trackName,
        }

        -- Remove the selected bounty from the available bounties
        table.remove(availableBounties, randomIndex)

        table.insert(bounties, bounty)
    end
    TriggerClientEvent('cw-racingapp:client:updateUiData', -1, 'bounties', bounties)
    TriggerClientEvent('cw-racingapp:client:notify', -1, tostring(#bounties)..Lang("bounties_have_been_generated"), 'success')
    Bounties = bounties
end

local function checkBountyCompletion(racerName, vehicleModel, rank, trackId, class, newTime, sprint, reversed)
    if UseDebug then print('^5Checking bounty for^0', racerName) end

    for i, bounty in pairs(Bounties) do
        if bounty.trackId == trackId and bounty.maxClass == class then
            local raceTypeMatches = (bounty.sprint and sprint) or (not bounty.sprint and not sprint) 
            local raceDirectionMatches = (bounty.reversed and reversed) or (not bounty.reversed and not reversed)
            local meetsRankReq = rank >= bounty.rankRequired
            if UseDebug then 
                print('^5Found race that matches. Verifcation results:^0')
                print('Race type matches', raceTypeMatches)
                print('Race direction matches', raceDirectionMatches)
                print('Race rank is beat', meetsRankReq)
            end
            if raceTypeMatches and raceDirectionMatches and meetsRankReq then
                if newTime < bounty.timeToBeat then
                    local claim = bounty.claimed[racerName]
                    if claim then
                        local currentTime = bounty.claimed[racerName].time
                        if newTime < currentTime then
                            if UseDebug then print(racerName, '^2Beat personal bounty time^0') end
                            Bounties[i].claimed[racerName] = { racerName= racerName, vehicleModel = vehicleModel, time= newTime }
                            return math.floor(bounty.price*(Config.BountiesOptions.consecutiveMultiplier or 0.5))
                        end
                    else
                        if UseDebug then print(racerName, '^2Beat the bounty time^0') end
                        Bounties[i].claimed[racerName] =  { racerName= racerName, vehicleModel = vehicleModel, time= newTime }
                        return math.floor(bounty.price)
                    end
                end
            else

            end
            if UseDebug then print(racerName, '^1Did not beat the bounty for^0', trackId, class) end
            break
        end
    end
    return nil
end

BountyHandler = {
    checkBountyCompletion = checkBountyCompletion
}

RegisterNetEvent('cw-racingapp:server:rerollBounties', function()
    generateBounties()
end)

RegisterServerCallback('cw-racingapp:server:getBounties', function(source)
    if UseDebug then print('Getting bounties for', source) end
    return Bounties
end)

-- Generate the initial bounties on first run
Wait(Config.FirstBountiesGenerateStartTime or 10000)
generateBounties()
