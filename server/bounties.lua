Bounties = {}

-- Bounty generation function
function GenerateBounties()
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

    DebugLog('Bounty set up:', json.encode(availableBounties[#availableBounties], {indent=true}))

    -- Generate the bounties
    for i = 1, numBounties do
        if #availableBounties == 0 then
            break
        end

        -- Select a random bounty from the available bounties
        local randomIndex = math.random(1, #availableBounties)
        local selectedBounty = availableBounties[randomIndex]

        if Tracks[selectedBounty.trackId] then
            local trackName = Tracks[selectedBounty.trackId].RaceName

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
        else
            DebugLog('^3Warning:^0 Track ID '..selectedBounty.trackId..' was included in your bounties config but was not found in Tracks cache. Please verify that it is in your database')
        end
    end
    TriggerClientEvent('cw-racingapp:client:updateUiData', -1, 'bounties', bounties)
    TriggerClientEvent('cw-racingapp:client:notify', -1, tostring(#bounties)..Lang("bounties_have_been_generated"), 'success')
    Bounties = bounties
end

local function checkBountyCompletion(racerName, vehicleModel, rank, trackId, class, newTime, sprint, reversed)
    DebugLog('^5Checking bounty for^0', racerName)

    for i, bounty in pairs(Bounties) do
        if bounty.trackId == trackId and bounty.maxClass == class then
            local raceTypeMatches = (bounty.sprint and sprint) or (not bounty.sprint and not sprint)
            local raceDirectionMatches = (bounty.reversed and reversed) or (not bounty.reversed and not reversed)
            local meetsRankReq = rank >= bounty.rankRequired
            DebugLog('^5Found race that matches. Verifcation results:^0', 'Race type matches: '.. tostring(raceTypeMatches),
                'Race direction matches: '.. tostring(raceDirectionMatches), 'Meets rank requirement: '.. tostring(meetsRankReq))
            if raceTypeMatches and raceDirectionMatches and meetsRankReq then
                if newTime < bounty.timeToBeat then
                    local claim = bounty.claimed[racerName]
                    if claim then
                        local currentTime = bounty.claimed[racerName].time
                        if newTime < currentTime then
                            DebugLog(racerName, '^2Beat personal bounty time^0')
                            Bounties[i].claimed[racerName] = { racerName= racerName, vehicleModel = vehicleModel, time= newTime }
                            return math.floor(bounty.price*(Config.BountiesOptions.consecutiveMultiplier or 0.5))
                        end
                    else
                        DebugLog(racerName, '^2Beat the bounty time^0')
                        Bounties[i].claimed[racerName] =  { racerName= racerName, vehicleModel = vehicleModel, time= newTime }
                        return math.floor(bounty.price)
                    end
                end
            end
            DebugLog(racerName, '^1Did not beat the bounty for^0', trackId, class)
            break
        end
    end
    return nil
end

BountyHandler = {
    checkBountyCompletion = checkBountyCompletion
}

RegisterNetEvent('cw-racingapp:server:rerollBounties', function()
    GenerateBounties()
end)

RegisterServerCallback('cw-racingapp:server:getBounties', function(source)
    DebugLog('Getting bounties for', source)
    return Bounties
end)
