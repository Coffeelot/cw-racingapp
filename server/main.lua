-----------------------
----   Variables   ----
-----------------------
Tracks = {}
Races = {}
UseDebug = Config.Debug
AvailableRaces = {}
NotFinished = {}
Timers = {}
local IsFirstUser = false

local HostingIsAllowed = true
local AutoHostIsAllowed = true

local DefaultTrackMetadata = {
    description = nil,
    raceType = nil,
    noDrift = nil,
}

RaceResults = {}
if Config.Debug then
    -- RaceResults = DebugRaceResults
end

local function leftRace(src)
    local player = Player(src)
    player.state.inRace = false
    player.state.raceId = nil
end

local function setInRace(src, raceId)
    local player = Player(src)
    player.state.inRace = true
    player.state.raceId = raceId
end

local function initiateRaceList()
    local tracks = RADB.getAllRaceTracks()
    if tracks[1] ~= nil then
        for _, v in pairs(tracks) do
            local metadata

            if v.metadata ~= nil then
                metadata = json.decode(v.metadata)
            else
                if UseDebug then
                    print('Metadata is undefined for track', v.name)
                end
                metadata = DeepCopy(DefaultTrackMetadata)
            end

            Tracks[v.raceid] = {
                RaceName = v.name,
                Checkpoints = json.decode(v.checkpoints),
                Creator = v.creatorid,
                CreatorName = v.creatorname,
                TrackId = v.raceid,
                Started = false,
                Waiting = false,
                Distance = v.distance,
                LastLeaderboard = {},
                Racers = {},
                MaxClass = nil,
                Access = json.decode(v.access) or {},
                Curated = v.curated,
                NumStarted = 0,
                Metadata = metadata
            }
        end
    end
    IsFirstUser = RADB.getSizeOfRacerNameTable() == 0
    GenerateBounties()
end

MySQL.ready(function()
    initiateRaceList()
end)

local function getAmountOfRacers(raceId)
    local AmountOfRacers = 0
    local PlayersFinished = 0
    for _, v in pairs(Races[raceId].Racers) do
        if v.Finished then
            PlayersFinished = PlayersFinished + 1
        end
        AmountOfRacers = AmountOfRacers + 1
    end
    return AmountOfRacers, PlayersFinished
end

local function getTrackIdByRaceId(raceId)
    if Races[raceId] then return Races[raceId].TrackId end
end

local function raceWithTrackIdIsActive(trackId)
    for raceId, raceData in pairs(Races) do
        if raceData.TrackId == trackId then
            if UseDebug then print('found hosted race with same id:', json.encode(raceData, {indent=true})) end
            if raceData.Waiting or raceData.active then
                return true
            end
        end
    end
end

local function handleAddMoney(src, moneyType, amount, racerName, textKey)
    if UseDebug then print('Attempting to give', racerName, amount, moneyType) end

    if moneyType == 'racingcrypto' then
        RacingCrypto.addRacerCrypto(racerName, math.floor(tonumber(amount)))
        TriggerClientEvent('cw-racingapp:client:updateUiData', src, 'crypto', RacingCrypto.getRacerCrypto(racerName))

        NotifyHandler( src,
            Lang(textKey or "participation_trophy_crypto") .. math.floor(amount) .. ' ' .. Config.Payments.cryptoType,
            'success')
    else
        addMoney(src, moneyType, math.floor(tonumber(amount)))
    end
end

local function handleRemoveMoney(src, moneyType, amount, racerName)
    if UseDebug then print('Attempting to charge', racerName, amount, moneyType) end
    if moneyType == 'racingcrypto' then
        if RacingCrypto.removeCrypto(racerName, amount) then
            NotifyHandler( src,
                Lang("remove_crypto") .. math.floor(amount) .. ' ' .. Config.Payments.cryptoType, 'success')
            TriggerClientEvent('cw-racingapp:client:updateUiData', src, 'crypto', RacingCrypto.getRacerCrypto(racerName))

            return true
        end
        NotifyHandler( src,
            Lang("can_not_afford") .. math.floor(amount) .. ' ' .. Config.Payments.cryptoType,
            'error')
    else
        if removeMoney(src, moneyType, math.floor(amount)) then
            if UseDebug then print('^2Payment successful^0') end
            return true
        end
        if UseDebug then print('^1Payment Not successful^0') end
        NotifyHandler( src, Lang("can_not_afford") .. ' $' .. math.floor(amount),
            'error')
    end
    return false
end

local function hasEnoughMoney(src, moneyType, amount, racerName)
    if moneyType == 'racingcrypto' then
        return RacingCrypto.hasEnoughCrypto(racerName, amount)
    else
        return canPay(src, moneyType, amount)
    end
end

local function giveSplit(src, racers, position, pot, racerName)
    local total = 0
    if (racers == 2 or racers == 1) and position == 1 then
        total = pot
    elseif racers == 3 and (position == 1 or position == 2) then
        total = Config.Splits['three'][position] * pot
        if UseDebug then print('Payout for ', position, total) end
    elseif racers > 3 and Config.Splits['more'][position] then
        total = Config.Splits['more'][position] * pot
        if UseDebug then print('Payout for ', position, total) end
    else
        if UseDebug then print('Racer finishing at postion', position, ' will not recieve a payout') end
    end
    if total > 0 then
        handleAddMoney(src, Config.Payments.racing, total, racerName)
    end
end

local function handOutParticipationTrophy(src, position, racerName)
    if Config.ParticipationTrophies.amount[position] then
        handleAddMoney(src, Config.Payments.participationPayout, Config.ParticipationTrophies.amount[position], racerName)
    end
end

local function handOutAutomationPayout(src, amount, racerName)
    if Config.Payments.automationPayout then
        handleAddMoney(src, Config.Payments.automationPayout, amount, racerName, 'extra_payout')
    end
end

local function changeRacerName(src, racerName)
    local result = RADB.changeRaceUser(getCitizenId(src), racerName)
    if result then
        TriggerClientEvent('cw-racingapp:client:updateRacerNames', src)
    end
    return result
end

local function getRankingForRacer(racerName)
    if UseDebug then print('Fetching ranking for racer', racerName) end
    return RADB.getRaceUserRankingByName(racerName) or 0
end

local function updateRacerElo(source, racerName, eloChange)
    local currentRank = getRankingForRacer(racerName)
    RADB.updateRacerElo(racerName, eloChange)
    TriggerClientEvent('cw-racingapp:client:updateRanking', source, eloChange, currentRank + eloChange)
end

local function handleEloUpdates(results)
    RADB.updateEloForRaceResult(results)
    for _, racer in ipairs(results) do
        TriggerClientEvent('cw-racingapp:client:updateRanking', racer.RacerSource, racer.TotalChange,
            racer.Ranking + racer.TotalChange)
    end
end

local function resetTrack(raceId, reason)
    if UseDebug then
        print('^6Resetting race^0', raceId)
        print('Reason:', reason)
    end
    Races[raceId].Racers = {}
    Races[raceId].Started = false
    Races[raceId].Waiting = false
    Races[raceId].MaxClass = nil
    Races[raceId].Ghosting = false
    Races[raceId].GhostingTime = nil
end

local function createRaceResultsIfNotExisting(raceId)
    if UseDebug then print('Verifying race result table for ', raceId) end
    local existingResults = RaceResults[raceId]
    if not existingResults then
        if UseDebug then print('Initializing race result', raceId) end
        RaceResults[raceId] = {}
        return true
    end
    if not RaceResults[raceId].Result then
        if UseDebug then print('Initializing result table for', raceId) end
        RaceResults[raceId].Result = {}
    end
end

local function handleDriftPayouts(raceId, raceData)
    if not RaceResults[raceId] or not RaceResults[raceId].Result then return end
    
    -- Sort racers by drift score (highest first)
    local sortedRacers = {}
    for _, racer in pairs(RaceResults[raceId].Result) do
        table.insert(sortedRacers, racer)
    end
    table.sort(sortedRacers, function(a, b) 
        return (tonumber(a.DriftScore) or 0) > (tonumber(b.DriftScore) or 0)
    end)

    local amountOfRacers = #sortedRacers
    if UseDebug then
        print('^3Handling Drift Payouts^0')
        print('Amount of racers:', amountOfRacers)
        print('Buy in:', raceData.BuyIn)
    end

    -- Handle payouts for each position
    for position, racer in ipairs(sortedRacers) do
        local src = racer.RacerSource
        
        -- Handle buy-in split
        if raceData.BuyIn > 0 then
            giveSplit(src, amountOfRacers, position, raceData.BuyIn * amountOfRacers, racer.RacerName)
        end

        -- Handle participation trophies
        if Config.ParticipationTrophies.enabled and Config.ParticipationTrophies.minimumOfRacers <= amountOfRacers then
            if not Config.ParticipationTrophies.requireBuyins or 
               (Config.ParticipationTrophies.requireBuyins and Config.ParticipationTrophies.buyInMinimum >= raceData.BuyIn) then
                handOutParticipationTrophy(src, position, racer.RacerName)
            end
        end

        -- Handle race-specific participation amount
        if raceData.ParticipationAmount and raceData.ParticipationAmount > 0 then
            local amountToGive = math.floor(raceData.ParticipationAmount)
            if Config.ParticipationAmounts.positionBonuses[position] then
                amountToGive = math.floor(amountToGive + 
                    amountToGive * Config.ParticipationAmounts.positionBonuses[position])
            end
            handleAddMoney(src, raceData.ParticipationCurrency, amountToGive, racer.RacerName,
                'participation_trophy_crypto')
        end

        -- Handle automated race payouts
        if raceData.Automated and Config.AutomatedOptions.payouts then
            local payoutData = Config.AutomatedOptions.payouts
            local total = 0
            if payoutData.participation then total = total + payoutData.participation end
            if payoutData.perRacer then
                total = total + payoutData.perRacer * amountOfRacers
            end
            if position == 1 and payoutData.winner then
                total = total + payoutData.winner
            end
            handOutAutomationPayout(src, total, racer.RacerName)
        end
    end
end

function CompleteRace(amountOfRacers, raceData)
    local availableKey = GetOpenedRaceKey(raceData.RaceId)

    local totalLaps = raceData.TotalLaps
    if amountOfRacers == 1 then
        if UseDebug then print('^3Only one racer. No ELO change^0') end
    elseif amountOfRacers > 1 then
        if AvailableRaces[availableKey].Ranked then
            if UseDebug then print('Is ranked. Doing Elo check') end
            if UseDebug then print('^2 Pre elo', json.encode(RaceResults[raceData.RaceId].Result)) end
            local crewResult
            RaceResults[raceData.RaceId].Result, crewResult = calculateTrueSkillRatings(RaceResults
                [raceData.RaceId].Result, raceData.Drift)

            if UseDebug then print('^2 Post elo', json.encode(RaceResults[raceData.RaceId].Result)) end
            handleEloUpdates(RaceResults[raceData.RaceId].Result)
            if #crewResult > 1 then
                if UseDebug then print('Enough crews to give ranking') end
                HandleCrewEloUpdates(crewResult)
            end
        end
        local raceEntryData = {
            raceId = raceData.RaceId,
            trackId = raceData.TrackId,
            results = RaceResults[raceData.RaceId].Result,
            amountOfRacers = amountOfRacers,
            laps = totalLaps,
            hostName = raceData.SetupRacerName,
            maxClass = raceData.MaxClass,
            ghosting = raceData.Ghosting,
            ranked = raceData.Ranked,
            reversed = Races[raceData.RaceId].Reversed,
            firstPerson = raceData.FirstPerson,
            automated = raceData.Automated,
            hidden = raceData.Hidden,
            silent = raceData.Silent,
            buyIn = raceData.BuyIn,
            drift = raceData.Drift
        }
        
        if raceData.Drift then
            handleDriftPayouts(raceData.RaceId, raceData)
        end

        RESDB.addRaceEntry(raceEntryData)
    end

    resetTrack(raceData.RaceId, 'Race is over')
    table.remove(AvailableRaces, availableKey)
    RaceResults[raceData.RaceId].Data.FinishTime = os.time()
    NotFinished[raceData.RaceId] = nil
    Races[raceData.RaceId].MaxClass = nil
end

RegisterNetEvent('cw-racingapp:server:finishPlayer',
    function(raceData, totalTime, totalLaps, bestLap, carClass, vehicleModel, ranking, racingCrew, driftScore)
        local src = source
        local raceId = raceData.RaceId
        local availableKey = GetOpenedRaceKey(raceData.RaceId)
        local racerName = raceData.RacerName
        local playersFinished = 0
        local amountOfRacers = 0
        local reversed = Races[raceData.RaceId].Reversed

        local isDrift = Races[raceData.RaceId].Drift or false

        if UseDebug then
            print('^3=== Finishing Racer: ' .. racerName .. ' ===^0')
            print(isDrift and '^2Race Type: Drift^0' or '^2Race Type: Standard^0')
        end
        
        local bestLapDef
        if totalLaps < 2 then
            if UseDebug then
                print('Sprint or 1 lap')
            end
            bestLapDef = totalTime
        else
            if UseDebug then
                print('2+ laps')
            end
            bestLapDef = bestLap
        end

        createRaceResultsIfNotExisting(raceData.RaceId)
        local raceResult = {
            TotalTime = totalTime,
            BestLap = bestLapDef,
            CarClass = carClass,
            VehicleModel = vehicleModel,
            RacerName = racerName,
            Ranking = ranking,
            RacerSource = src,
            RacingCrew = racingCrew
        }
        table.insert(RaceResults[raceId].Result, raceResult)

        if isDrift then
            if UseDebug then print('Drift score:', driftScore) end
            FinishDriftRacer(src, raceData, driftScore, carClass, vehicleModel, racingCrew, totalTime)
        end

        local amountOfRacersThatLeft = 0
        if NotFinished and NotFinished[raceId] then
            if UseDebug then print('Race had racers that left before completion') end
           amountOfRacersThatLeft = #NotFinished[raceId]
        end

        for _, v in pairs(Races[raceId].Racers) do
            if v.Finished then
                playersFinished = playersFinished + 1
            end
            amountOfRacers = amountOfRacers + 1
        end
        if amountOfRacers > 1 then
            RADB.increaseRaceCount(racerName, playersFinished)
        end
        if UseDebug then
            print('Total: ', totalTime)
            print('Best Lap: ', bestLapDef)
            print('Place:', playersFinished, Races[raceData.RaceId].BuyIn)
        end

        -- only handle direct payouts if not drift
        if not isDrift then
            if Races[raceData.RaceId].BuyIn > 0 then
                giveSplit(src, amountOfRacers, playersFinished,
                    Races[raceData.RaceId].BuyIn * Races[raceData.RaceId].AmountOfRacers, racerName)
            end
    
            -- Participation amount (global)
            if Config.ParticipationTrophies.enabled and Config.ParticipationTrophies.minimumOfRacers <= amountOfRacers then
                if UseDebug then print('Participation Trophies are enabled') end
                local distance = Tracks[raceData.TrackId].Distance
                if totalLaps > 1 then
                    distance = distance * totalLaps
                end
                if distance > Config.ParticipationTrophies.minumumRaceLength then
                    if not Config.ParticipationTrophies.requireBuyins or (Config.ParticipationTrophies.requireBuyins and Config.ParticipationTrophies.buyInMinimum >= Races[raceData.RaceId].BuyIn) then
                        if UseDebug then print('Participation Trophies buy in check passed', src) end
                        if not Config.ParticipationTrophies.requireRanked or (Config.ParticipationTrophies.requireRanked and AvailableRaces[availableKey].Ranked) then
                            if UseDebug then print('Participation Trophies Rank check passed, handing out to', src) end
                            handOutParticipationTrophy(src, playersFinished, racerName)
                        end
                    end
                else
                    if UseDebug then
                        print('Race length was to short: ', distance, ' Minumum required:',
                            Config.ParticipationTrophies.minumumRaceLength)
                    end
                end
            end
            if UseDebug then
                print('Race has participation price', Races[raceData.RaceId].ParticipationAmount,
                    Races[raceData.RaceId].ParticipationCurrency)
            end
    
            -- Participation amount (on this specific race)
            if Races[raceData.RaceId].ParticipationAmount and Races[raceData.RaceId].ParticipationAmount > 0 then
                local amountToGive = math.floor(Races[raceData.RaceId].ParticipationAmount)
                if Config.ParticipationAmounts.positionBonuses[playersFinished] then
                    amountToGive = math.floor(amountToGive +
                        amountToGive * Config.ParticipationAmounts.positionBonuses[playersFinished])
                end
                if UseDebug then
                    print('Race has participation price set', Races[raceData.RaceId].ParticipationAmount,
                        amountToGive, Races[raceData.RaceId].ParticipationCurrency)
                end
                handleAddMoney(src, Races[raceData.RaceId].ParticipationCurrency, amountToGive, racerName,
                    'participation_trophy_crypto')
            end

            if Races[raceData.RaceId].Automated then
                if UseDebug then print('Race Was Automated', src) end
                if Config.AutomatedOptions.payouts then
                    local payoutData = Config.AutomatedOptions.payouts
                    if UseDebug then print('Automation Payouts exist', src) end
                    local total = 0
                    if payoutData.participation then total = total + payoutData.participation end
                    if payoutData.perRacer then
                        total = total + payoutData.perRacer * amountOfRacers
                    end
                    if playersFinished == 1 and payoutData.winner then
                        total = total + payoutData.winner
                    end
                    handOutAutomationPayout(src, total, racerName)
                end
            end
        end

        local bountyResult = BountyHandler.checkBountyCompletion(racerName, vehicleModel, ranking, raceData.TrackId,
            carClass, bestLapDef, totalLaps == 0, reversed)
        if bountyResult then
            addMoney(src, Config.Payments.bountyPayout, bountyResult)
            NotifyHandler( src, Lang("bounty_claimed") .. tostring(bountyResult),
                'success')
        end

        local raceType = 'Sprint'
        if totalLaps > 0 then raceType = 'Circuit' end

        -- PB check 
        local timeData = {
            trackId = raceData.TrackId,
            racerName = racerName,
            carClass = carClass,
            raceType = raceType,
            reversed = reversed,
            vehicleModel = vehicleModel,
            time = bestLapDef,
        }

        local newPb = RESDB.addTrackTime(timeData)
        if newPb then
            NotifyHandler( src,
                string.format(Lang("race_record"), raceData.RaceName, MilliToTime(bestLapDef)), 'success')
        end

        AvailableRaces[availableKey].RaceData = Races[raceData.RaceId]
        for _, racer in pairs(Races[raceData.RaceId].Racers) do
            TriggerClientEvent('cw-racingapp:client:playerFinish', racer.RacerSource, raceData.RaceId, playersFinished,
                racerName)
            leftRace(racer.RacerSource)
        end

        if playersFinished + amountOfRacersThatLeft == amountOfRacers then
            CompleteRace(amountOfRacers, Races[raceData.RaceId])
        end

        if UseDebug then
            print('^2/=/ Finished Racer: ' .. racerName .. ' /=/^0')
        end
    end)

RegisterNetEvent('cw-racingapp:server:createTrack', function(RaceName, RacerName, Checkpoints)
    local src = source
    if UseDebug then print(src, RacerName, 'is creating a track named', RaceName) end

    if IsPermissioned(RacerName, 'create') then
        if IsNameAvailable(RaceName) then
            TriggerClientEvent('cw-racingapp:client:startRaceEditor', src, RaceName, RacerName, nil, Checkpoints)
        else
            NotifyHandler( src, Lang("race_name_exists"), 'error')
        end
    else
        NotifyHandler( src, Lang("no_permission"), 'error')
    end
end)

local function isToFarAway(src, trackId, reversed)
    if reversed then
        return Config.JoinDistance <=
            #(GetEntityCoords(GetPlayerPed(src)).xy - vec2(Tracks[trackId].Checkpoints[#Tracks[trackId].Checkpoints].coords.x, Tracks[trackId].Checkpoints[#Tracks[trackId].Checkpoints].coords.y))
    else
        return Config.JoinDistance <=
            #(GetEntityCoords(GetPlayerPed(src)).xy - vec2(Tracks[trackId].Checkpoints[1].coords.x, Tracks[trackId].Checkpoints[1].coords.y))
    end
end

RegisterNetEvent('cw-racingapp:server:joinRace', function(RaceData)
    local src = source
    local playerVehicleEntity = RaceData.PlayerVehicleEntity
    local raceName = RaceData.RaceName
    local raceId = RaceData.RaceId
    local trackId = RaceData.TrackId
    local availableKey = GetOpenedRaceKey(RaceData.RaceId)
    local citizenId = getCitizenId(src)
    local currentRaceId = GetCurrentRace(citizenId)
    local racerName = RaceData.RacerName
    local racerCrew = RaceData.RacerCrew

    if UseDebug then
        print('======= Joining Race =======')
        print('race id', raceId )
        print('track id', trackId )
        print('AvailableKey', availableKey)
        print('PreviousRaceKey', GetOpenedRaceKey(currentRaceId))
        print('Racer Name:', racerName)
        print('Racer Crew:', racerCrew)
    end

    if isToFarAway(src, trackId, RaceData.Reversed) then
        if RaceData.Reversed then
            TriggerClientEvent('cw-racingapp:client:notCloseEnough', src,
                Tracks[trackId].Checkpoints[#Tracks[trackId].Checkpoints].coords.x,
                Tracks[trackId].Checkpoints[#Tracks[trackId].Checkpoints].coords.y)
        else
            TriggerClientEvent('cw-racingapp:client:notCloseEnough', src, Tracks[trackId].Checkpoints[1].coords.x,
                Tracks[trackId].Checkpoints[1].coords.y)
        end
        return
    end
    if not Races[raceId].Started then
        if UseDebug then
            print('Join: BUY IN', RaceData.BuyIn)
        end

        if RaceData.BuyIn > 0 and not hasEnoughMoney(src, Config.Payments.racing, RaceData.BuyIn, racerName) then
            NotifyHandler( src, Lang("not_enough_money"))
        else
            if currentRaceId ~= nil then
                local amountOfRacers = 0
                local PreviousRaceKey = GetOpenedRaceKey(currentRaceId)
                for _, _ in pairs(Races[currentRaceId].Racers) do
                    amountOfRacers = amountOfRacers + 1
                end
                Races[currentRaceId].Racers[citizenId] = nil
                if (amountOfRacers - 1) == 0 then
                    Races[currentRaceId].Racers = {}
                    Races[currentRaceId].Started = false
                    Races[currentRaceId].Waiting = false
                    table.remove(AvailableRaces, PreviousRaceKey)
                    NotifyHandler( src, Lang("race_last_person"))
                    TriggerClientEvent('cw-racingapp:client:leaveRace', src)
                    leftRace(src)
                else
                    AvailableRaces[PreviousRaceKey].RaceData = Races[currentRaceId]
                    TriggerClientEvent('cw-racingapp:client:leaveRace', src)
                    leftRace(src)
                end
            end

            local amountOfRacers = 0
            for _, _ in pairs(Races[raceId].Racers) do
                amountOfRacers = amountOfRacers + 1
            end
            if amountOfRacers == 0 and not Races[raceId].Automated then
                if UseDebug then print('setting creator') end
                Races[raceId].SetupCitizenId = citizenId
            end
            Races[raceId].AmountOfRacers = amountOfRacers + 1
            if UseDebug then print('Current amount of racers in this race:', amountOfRacers) end
            if RaceData.BuyIn > 0 then
                if not handleRemoveMoney(src, Config.Payments.racing, RaceData.BuyIn, racerName) then
                    return
                end
            end

            Races[raceId].Racers[citizenId] = {
                Checkpoint = 1,
                Lap = 1,
                Finished = false,
                RacerName = racerName,
                RacerCrew = racerCrew,
                Placement = 0,
                PlayerVehicleEntity = playerVehicleEntity,
                RacerSource = src,
                CheckpointTimes = {},
            }
            AvailableRaces[availableKey].RaceData = Races[raceId]
            TriggerClientEvent('cw-racingapp:client:joinRace', src, Races[raceId], Tracks[trackId].Checkpoints, RaceData.Laps, racerName)
            for _, racer in pairs(Races[raceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:updateActiveRacers', racer.RacerSource, raceId,
                    Races[raceId].Racers)
            end
            if not Races[raceId].Automated then
                local creatorsource = getSrcOfPlayerByCitizenId(AvailableRaces[availableKey].SetupCitizenId)
                if creatorsource ~= src then
                    NotifyHandler( creatorsource, Lang("race_someone_joined"))
                end
            end
        end
    else
        NotifyHandler( src, Lang("race_already_started"))
    end
end)

local function assignNewOrganizer(raceId, src)
    for citId, racerData in pairs(Races[raceId].Racers) do
        if citId ~= getCitizenId(src) then
            Races[raceId].SetupCitizenId = citId
            NotifyHandler( racerData.RacerSource, Lang("new_host"))
            for _, racer in pairs(Races[raceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:updateOrganizer', racer.RacerSource, raceId, citId)
            end
            return
        end
    end
end

local function leaveCurrentRace(src)
    TriggerClientEvent('cw-racingapp:server:leaveCurrentRace', src)    
end exports('leaveCurrentRace', leaveCurrentRace)

RegisterNetEvent('cw-racingapp:server:leaveCurrentRace', function(src)
    leaveCurrentRace(src)
end)

RegisterNetEvent('cw-racingapp:server:leaveRace', function(RaceData, reason)
    if UseDebug then
        print('Player left race', source)
        print('Reason:', reason)
        print(json.encode(RaceData, { indent = true }))
    end
    local src = source
    local citizenId = getCitizenId(src)

    if not citizenId then print('ERROR: Could not find identifier for player with src', src) return end

    local racerName = RaceData.RacerName

    local raceId = RaceData.RaceId
    local availableKey = GetOpenedRaceKey(raceId)

    if not Races[raceId].Automated then
        local creator = getSrcOfPlayerByCitizenId(AvailableRaces[availableKey].SetupCitizenId)

        if creator then
            NotifyHandler( creator, Lang("race_someone_left"))
        end
    end

    local amountOfRacers = 0
    local playersFinished = 0
    for _, v in pairs(Races[raceId].Racers) do
        if v.Finished then
            playersFinished = playersFinished + 1
        end
        amountOfRacers = amountOfRacers + 1
    end
    if NotFinished[raceId] ~= nil then
        NotFinished[raceId][#NotFinished[raceId] + 1] = {
            TotalTime = "DNF",
            BestLap = "DNF",
            Holder = racerName
        }
    else
        NotFinished[raceId] = {}
        NotFinished[raceId][#NotFinished[raceId] + 1] = {
            TotalTime = "DNF",
            BestLap = "DNF",
            Holder = racerName
        }
    end
    -- Races[raceId].Racers[citizenId] = nil
    if Races[raceId].SetupCitizenId == citizenId then
        assignNewOrganizer(raceId, src)
    end

    -- Check if last racer
    if (amountOfRacers - 1) == 0 then
        -- Complete race if leaving last
        if not Races[raceId].Automated then
            if UseDebug then print(citizenId, ' was the last racer. ^3Cancelling race^0') end
            resetTrack(raceId, 'last racer left')
            table.remove(AvailableRaces, availableKey)
            NotifyHandler( src, Lang("race_last_person"))
            NotFinished[raceId] = nil
        else
            if UseDebug then print(citizenId, ' was the last racer. ^Race was Automated. No cancel.^0') end
        end
    else
        AvailableRaces[availableKey].RaceData = Races[raceId]
    end
    if playersFinished == amountOfRacers - 1 then
        if UseDebug then print('Last racer to leave') end
        CompleteRace(amountOfRacers, RaceData)
    end

    TriggerClientEvent('cw-racingapp:client:leaveRace', src)
    leftRace(src)

    for _, racer in pairs(Races[raceId].Racers) do
        TriggerClientEvent('cw-racingapp:client:updateRaceRacers', racer.RacerSource, raceId, Races[raceId].Racers)
    end
    if RaceData.Ranked and RaceData.Started and RaceData.TotalRacers > 1 and reason then
        if Config.EloPunishments[reason] then
            updateRacerElo(src, racerName, Config.EloPunishments[reason])
        end
    end
end)

local function createTimeoutThread(raceId)
    CreateThread(function()
        local count = 0
        while Races[raceId] and Races[raceId].Waiting do
            Wait(1000)
            if count < Config.TimeOutTimerInMinutes * 60 then
                count = count + 1
            else
                local availableKey = GetOpenedRaceKey(raceId)
                if UseDebug then print('Available Key', availableKey) end
                if Races[raceId].Automated then
                    if UseDebug then print('Track Timed Out. Automated') end
                    local amountOfRacers = getAmountOfRacers(raceId)
                    if amountOfRacers >= Config.AutomatedOptions.minimumParticipants then
                        if UseDebug then print('Enough Racers to start automated') end
                        TriggerEvent('cw-racingapp:server:startRace', raceId)
                    else
                        table.remove(AvailableRaces, availableKey)
                        resetTrack(raceId, 'not enough players to start automated')

                        if amountOfRacers > 0 then
                            for cid, _ in pairs(Races[raceId].Racers) do
                                local racerSource = getSrcOfPlayerByCitizenId(cid)
                                if racerSource ~= nil then
                                    NotifyHandler( racerSource, Lang("race_timed_out"),
                                        'error')
                                    TriggerClientEvent('cw-racingapp:client:leaveRace', racerSource)
                                    leftRace(racerSource)
                                end
                            end
                        end
                    end
                else
                    if UseDebug then print('Track Timed Out. NOT automated', raceId) end
                    for cid, _ in pairs(Races[raceId].Racers) do
                        local racerSource = getSrcOfPlayerByCitizenId(cid)
                        if racerSource then
                            NotifyHandler( racerSource, Lang("race_timed_out"), 'error')
                            TriggerClientEvent('cw-racingapp:client:leaveRace', racerSource)
                            leftRace(racerSource)
                        end
                    end
                    table.remove(AvailableRaces, availableKey)
                    resetTrack(raceId, 'Timed out, Not automated')
                end
            end
        end
    end)
end

local function joinRaceByRaceId(raceId, src)
    if src and raceId then
        TriggerClientEvent('cw-racingapp:client:joinRaceByRaceId', src, raceId)
        return true
    else
        print('Attempted to join a race but was lacking input')
        print('raceid:', raceId)
        print('src:', src)
        return false
    end
end exports('joinRaceByRaceId', joinRaceByRaceId)

local function setupRace(setupData, src)
    local trackId = setupData.trackId
    local laps = setupData.laps
    local racerName = setupData.hostName or Config.AutoMatedRacesHostName
    local maxClass = setupData.maxClass
    local ghostingEnabled = setupData.ghostingEnabled
    local ghostingTime = setupData.ghostingTime
    local buyIn = setupData.buyIn
    local ranked = setupData.ranked
    local reversed = setupData.reversed
    local participationAmount = setupData.participationMoney
    local participationCurrency = setupData.participationCurrency
    local firstPerson = setupData.firstPerson
    local automated = setupData.automated
    local hidden = setupData.hidden
    local silent = setupData.silent
    local drift = setupData.drift
                         
    if not HostingIsAllowed then
        if src then NotifyHandler( src, Lang("hosting_not_allowed"), 'error') end
        return
    end

    local raceId = GenerateRaceId()

    if UseDebug then
        print('Setting up race', 'RaceID: '..raceId or 'FAILED TO GENERATE RACE ID', json.encode(setupData))
    end
    
    if not src then
        if UseDebug then
            print('No Source was included. Defaulting to Automated')
        end
        automated = true
    end

    if Tracks[trackId] ~= nil then
        Races[raceId] = {}
        if not Races[raceId].Waiting then
            if not Races[raceId].Started then
                local setupId = 0
                if src then
                    setupId = getCitizenId(src)
                end
                if Tracks[trackId] then
                    Tracks[trackId].NumStarted = Tracks[trackId].NumStarted + 1
                else
                    print('ERROR: Could not find track id', trackId)
                end

                local expirationTime = os.time() + 60 * Config.TimeOutTimerInMinutes

                Races[raceId].RaceId = raceId
                Races[raceId].TrackId = trackId
                Races[raceId].RaceName = Tracks[trackId].RaceName
                Races[raceId].Waiting = true
                Races[raceId].Automated = automated
                Races[raceId].SetupRacerName = racerName
                Races[raceId].MaxClass = maxClass
                Races[raceId].SetupCitizenId = setupId
                Races[raceId].Ghosting = ghostingEnabled
                Races[raceId].GhostingTime = ghostingTime
                Races[raceId].BuyIn = buyIn
                Races[raceId].Ranked = ranked
                Races[raceId].Laps = laps
                Races[raceId].Reversed = reversed
                Races[raceId].FirstPerson = firstPerson
                Races[raceId].Hidden = hidden
                Races[raceId].Drift = drift
                Races[raceId].ParticipationAmount = tonumber(participationAmount)
                Races[raceId].ParticipationCurrency = participationCurrency
                Races[raceId].ExpirationTime = expirationTime
                Races[raceId].Racers = {}

                local allRaceData = {
                    TrackData = Tracks[trackId],
                    RaceData = Races[raceId],
                    Laps = laps,
                    RaceId = raceId,
                    TrackId = trackId,
                    SetupCitizenId = setupId,
                    SetupRacerName = racerName,
                    MaxClass = maxClass,
                    Ghosting = ghostingEnabled,
                    GhostingTime = ghostingTime,
                    BuyIn = buyIn,
                    Ranked = ranked,
                    Reversed = reversed,
                    ParticipationAmount = participationAmount,
                    ParticipationCurrency = participationCurrency,
                    FirstPerson = firstPerson,
                    ExpirationTime = expirationTime,
                    Hidden = hidden,
                    Drift = drift,
                }
                AvailableRaces[#AvailableRaces + 1] = allRaceData
                if not automated then
                    NotifyHandler( src, Lang("race_created"), 'success')
                    TriggerClientEvent('cw-racingapp:client:readyJoinRace', src, allRaceData)
                end

                local cleanedRaceData = {}
                for i, v in pairs(allRaceData) do
                    cleanedRaceData[i] = v
                end
                cleanedRaceData.TrackData = nil

                RaceResults[raceId] = { Data = cleanedRaceData, Result = {} }

                if Config.NotifyRacers and not silent then
                    TriggerClientEvent('cw-racingapp:client:notifyRacers', -1,
                        'New Race Available')
                end
                createTimeoutThread(raceId)
                return raceId
            else
                if src then NotifyHandler( src, Lang("race_already_started"), 'error') end
                return false
            end
        else
            if src then NotifyHandler( src, Lang("race_already_started"), 'error') end
            return false
        end
    else
        if src then NotifyHandler( src, Lang("race_doesnt_exist"), 'error') end
        return false
    end
end exports('setupRace', setupRace)

RegisterServerCallback('cw-racingapp:server:setupRace', function(source, setupData)
    local src = source
    if not Tracks[setupData.trackId] then
       NotifyHandler( src, Lang("no_track_found").. tostring(setupData.trackId), 'error')
    end
    if isToFarAway(src, setupData.trackId, setupData.reversed) then
        if setupData.reversed then
            TriggerClientEvent('cw-racingapp:client:notCloseEnough', src,
                Tracks[setupData.trackId].Checkpoints[#Tracks[setupData.trackId].Checkpoints].coords.x,
                Tracks[setupData.trackId].Checkpoints[#Tracks[setupData.trackId].Checkpoints].coords.y)
        else
            TriggerClientEvent('cw-racingapp:client:notCloseEnough', src,
                Tracks[setupData.trackId].Checkpoints[1].coords.x, Tracks[setupData.trackId].Checkpoints[1].coords.y)
        end
        return false
    end
    if (setupData.buyIn > 0 and not hasEnoughMoney(src, Config.Payments.racing, setupData.buyIn, setupData.hostName)) then
        NotifyHandler( src, Lang("not_enough_money"))
    else
        setupData.automated = false
        return setupRace(setupData, src)
    end
end)

-- AUTOMATED RACES SETUP
local function generateAutomatedRace()
    if not AutoHostIsAllowed then
        if UseDebug then print('Auto hosting is not allowed') end
        return
    end
    local race = Config.AutomatedRaces[math.random(1, #Config.AutomatedRaces)]
    if race == nil or race.trackId == nil then
        if UseDebug then print('Race Id for generated track was nil, your Config might be incorrect') end
        return
    end
    if Tracks[race.trackId] == nil then
        if UseDebug then print('ID' .. race.trackId .. ' does not exist in tracks list') end
        return
    end
    if raceWithTrackIdIsActive(race.trackId) then
        if UseDebug then print('Automation: Race on track is already active, skipping Automated') end
        return
    end
    if UseDebug then print('Creating new Automated Race from', race.trackId) end
    local ranked = race.ranked
    if ranked == nil then
        if UseDebug then print('Automation: ranked was not set. defaulting to ranked = true') end
        ranked = true
    end
    local reversed = race.reversed
    if reversed == nil then
        if UseDebug then print('Automation: rank was not set. defaulting to reversed = false') end
        reversed = false
    end
    race.automated = true

    setupRace(race, nil)
end

RegisterNetEvent('cw-racingapp:server:newAutoHost', function()
    generateAutomatedRace()
end)

if Config.AutomatedOptions and Config.AutomatedRaces then
    CreateThread(function()
        if #Config.AutomatedRaces == 0 then
            if UseDebug then print('^3No automated races in list') end
            return
        end
        while true do
            if not UseDebug then Wait(Config.AutomatedOptions.timeBetweenRaces) else Wait(1000) end
            generateAutomatedRace()
            Wait(Config.AutomatedOptions.timeBetweenRaces)
        end
    end)
end

RegisterNetEvent('cw-racingapp:server:updateRaceState', function(raceId, started, waiting)
    Races[raceId].Waiting = waiting
    Races[raceId].Started = started
end)

local function timer(raceId)
    local trackId = getTrackIdByRaceId(raceId)
    local NumStartedAtTimerCreation = Tracks[trackId].NumStarted
    if UseDebug then
        print('============== Creating timer for ' ..
            raceId .. ' with numstarted: ' .. NumStartedAtTimerCreation .. ' ==============')
    end
    SetTimeout(Config.RaceResetTimer, function()
        if UseDebug then print('============== Checking timer for ' .. raceId .. ' ==============') end
        if NumStartedAtTimerCreation ~= Tracks[trackId].NumStarted then
            if UseDebug then
                print('============== A new race has been created on this track. Canceling ' ..
                    trackId .. ' ==============')
            end
            return
        end
        if next(Races[raceId].Racers) == nil then
            if UseDebug then print('Race is finished. Canceling timer ' .. raceId .. '') end
            return
        end
        if math.abs(GetGameTimer() - Timers[raceId]) < Config.RaceResetTimer then
            Timers[raceId] = GetGameTimer()
            timer(raceId)
        else
            if UseDebug then print('Cleaning up race ' .. raceId) end
            for _, racer in pairs(Races[raceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:leaveRace', racer.RacerSource)
                leftRace(racer.RacerSource)
            end
            resetTrack(raceId, 'Idle race')
            NotFinished[raceId] = nil
            local AvailableKey = GetOpenedRaceKey(trackId)
            if AvailableKey then
                table.remove(AvailableRaces, AvailableKey)
            end
        end
    end)
end

local function startTimer(raceId)
    if UseDebug then print('Starting timer', raceId) end
    Timers[raceId] = GetGameTimer()
    timer(raceId)
end

local function updateTimer(raceId)
    if UseDebug then print('Updating timer', raceId) end
    Timers[raceId] = GetGameTimer()
end

RegisterNetEvent('cw-racingapp:server:updateRacerData', function(raceId, checkpoint, lap, finished, raceTime)
    local src = source
    local citizenId = getCitizenId(src)
    if Races[raceId].Racers[citizenId] then
        Races[raceId].Racers[citizenId].Checkpoint = checkpoint
        Races[raceId].Racers[citizenId].Lap = lap
        Races[raceId].Racers[citizenId].Finished = finished
        Races[raceId].Racers[citizenId].RaceTime = raceTime

        Races[raceId].Racers[citizenId].CheckpointTimes[#Races[raceId].Racers[citizenId].CheckpointTimes + 1] = {
            lap =
                lap,
            checkpoint = checkpoint,
            time = raceTime
        }

        for _, racer in pairs(Races[raceId].Racers) do
            if GetPlayerName(racer.RacerSource) then 
                TriggerClientEvent('cw-racingapp:client:updateRaceRacerData', racer.RacerSource, raceId, citizenId,
                    Races[raceId].Racers[citizenId])
            else
                if UseDebug then 
                    print('^1Could not find player with source^0', racer.RacerSource)
                    print(json.encode(racer, {indent=true})) 
                end
            end
        end
    else
        -- Attemt to make sure script dont break if something goes wrong
        NotifyHandler( src, Lang("youre_not_in_the_race"), 'error')
        TriggerClientEvent('cw-racingapp:client:leaveRace', -1, nil)
        leftRace(src)
    end
    if Config.UseResetTimer then updateTimer(raceId) end
end)

RegisterNetEvent('cw-racingapp:server:startRace', function(raceId)
    if UseDebug then print(source, 'is starting race', raceId) end
    local src = source
    local AvailableKey = GetOpenedRaceKey(raceId)

    if not raceId then
        if src then NotifyHandler( src, Lang("not_in_race"), 'error') end
        return
    end

    if not AvailableRaces[AvailableKey] then
        if UseDebug then print('Could not find available race', raceId) end
        return
    end

    if not AvailableRaces[AvailableKey].RaceData then
        if UseDebug then print('Could not find available race data', raceId) end
        return
    end
    if AvailableRaces[AvailableKey].RaceData.Started then
        if UseDebug then print('Race was already started', raceId) end
        if src then NotifyHandler( src, Lang("race_already_started"), 'error') end
        return
    end

    AvailableRaces[AvailableKey].RaceData.Started = true
    AvailableRaces[AvailableKey].RaceData.Waiting = false
    local TotalRacers = 0
    for _, _ in pairs(Races[raceId].Racers) do
        TotalRacers = TotalRacers + 1
    end
    if UseDebug then print('Total Racers', TotalRacers) end
    for _, racer in pairs(Races[raceId].Racers) do
        TriggerClientEvent('cw-racingapp:client:raceCountdown', racer.RacerSource, TotalRacers)
        setInRace(racer.RacerSource, raceId)
    end
    if Config.UseResetTimer then startTimer(raceId) end
end)

RegisterNetEvent('cw-racingapp:server:saveTrack', function(trackData)
    local src = source
    local citizenId = getCitizenId(src)
    local trackId
    if trackData.TrackId ~= nil then
        trackId = trackData.TrackId
    else
        trackId = GenerateTrackId()
    end
    local checkpoints = {}
    for k, v in pairs(trackData.Checkpoints) do
        checkpoints[k] = {
            offset = v.offset,
            coords = v.coords
        }
    end

    if trackData.IsEdit then
        print('Saving over previous track', trackData.TrackId)
        RADB.setTrackCheckpoints(checkpoints, trackData.TrackId)
        Tracks[trackId].Checkpoints = checkpoints
    else
        Tracks[trackId] = {
            RaceName = trackData.RaceName,
            Checkpoints = checkpoints,
            Creator = citizenId,
            CreatorName = trackData.RacerName,
            TrackId = trackId,
            Started = false,
            Waiting = false,
            Distance = math.ceil(trackData.RaceDistance),
            Racers = {},
            Metadata = DeepCopy(DefaultTrackMetadata),
            Access = {},
            LastLeaderboard = {},
            NumStarted = 0,
        }
        RADB.createTrack(trackData, checkpoints, citizenId, trackId)
    end
end)

RegisterNetEvent('cw-racingapp:server:deleteTrack', function(trackId)
    RADB.deleteTrack(trackId)
    Tracks[trackId] = nil
end)

RegisterNetEvent('cw-racingapp:server:removeRecord', function(record)
    if UseDebug then print('Removing record', json.encode(record, { indent = true })) end
    RESDB.removeTrackRecord(record.id)
end)

RegisterNetEvent('cw-racingapp:server:clearLeaderboard', function(trackId)
    RESDB.clearTrackRecords(trackId)
end)

RegisterServerCallback('cw-racingapp:server:getRaceResults', function(source, amount)
    local limit = amount or 10
    local result = RESDB.getRecentRaces(limit)
    for i, track in ipairs(result) do
        result[i].raceName = Tracks[track.trackId].RaceName
    end
    return result
end)

RegisterServerCallback('cw-racingapp:server:getAllRacers', function(source)
    if UseDebug then print('Fetching all racers') end
    local allRacers = RADB.getAllRacerNames()
    if UseDebug then print("^2Result", json.encode(allRacers)) end
    return allRacers
end)

RegisterServerCallback('cw-racingapp:server:isFirstUser', function(source)
    if UseDebug then print('Is first user:', IsFirstUser) end
    return IsFirstUser
end)

-----------------------
----   Functions   ----
-----------------------

function MilliToTime(milli)
    local milliseconds = milli % 1000;
    milliseconds = tostring(milliseconds)
    local seconds = math.floor((milli / 1000) % 60);
    local minutes = math.floor((milli / (60 * 1000)) % 60);
    if minutes < 10 then
        minutes = "0" .. tostring(minutes);
    else
        minutes = tostring(minutes)
    end
    if seconds < 10 then
        seconds = "0" .. tostring(seconds);
    else
        seconds = tostring(seconds)
    end
    return minutes .. ":" .. seconds .. "." .. milliseconds;
end

function IsPermissioned(racerName, type)
    local auth = RADB.getUserAuth(racerName)
    if not auth then
        if UseDebug then print('Could not find user with this racer Name', racerName) end
        return false
    end
    if UseDebug then print(racerName, 'has auth', auth) end
    return Config.Permissions[auth][type]
end

function IsNameAvailable(trackname)
    local retval = true
    for trackId, _ in pairs(Tracks) do
        if Tracks[trackId].RaceName == trackname then
            retval = false
            break
        end
    end
    return retval
end

function GetOpenedRaceKey(raceId)
    local retval = nil
    for k, v in pairs(AvailableRaces) do
        if v.RaceId == raceId then
            retval = k
            break
        end
    end
    return retval
end

function GetCurrentRace(citizenId)
    for raceId, race in pairs(Races) do
        for cid, _ in pairs(race.Racers) do
            if cid == citizenId then
                return raceId
            end
        end
    end
end

function GetRaceId(name)
    for k, v in pairs(Tracks) do
        if v.RaceName == name then
            return k
        end
    end
    return nil
end

function GenerateTrackId()
    local trackId = "LR-" .. math.random(1000, 9999)
    while Tracks[trackId] ~= nil do
        trackId = "LR-" .. math.random(1000, 9999)
    end
    return trackId
end

function GenerateRaceId()
    local raceId = "RI-" .. math.random(100000, 999999)
    while Races[raceId] ~= nil do
        raceId = "RI-" .. math.random(100000, 999999)
    end
    return raceId
end

function openRacingApp(source)
    if UseDebug then print('opening ui') end

    TriggerClientEvent('cw-racingapp:client:openUi', source)
end

exports('openRacingApp', openRacingApp)

RegisterServerCallback('cw-racingapp:server:cancelRace', function(source, raceId)
    local src = source
    if UseDebug then
        print('Player is canceling race', src, raceId)
    end
    if not raceId or not Races[raceId] then return false end

    for _, racer in pairs(Races[raceId].Racers) do
        NotifyHandler( racer.RacerSource, Lang("race_canceled"),
            'error')
        TriggerClientEvent('cw-racingapp:client:leaveRace', racer.RacerSource, Races[raceId])
        leftRace(racer.RacerSource)
    end
    Wait(500)
    local availableKey = GetOpenedRaceKey(raceId)
    if UseDebug then print('Available Key', availableKey) end
    table.remove(AvailableRaces, availableKey)
    resetTrack(raceId, 'Manually canceled by src ' .. tostring(src or 'UNKNOWN'))
    return true
end)


RegisterServerCallback('cw-racingapp:server:getAvailableRaces', function(source)
    return AvailableRaces
end)

RegisterServerCallback('cw-racingapp:server:getRaceRecordsForTrack', function(source, trackId)
    return RESDB.getAllBestTimesForTrack(trackId)
end)

RegisterServerCallback('cw-racingapp:server:getTracks', function(source)
    return Tracks
end)

RegisterServerCallback('cw-racingapp:server:getTracksTrimmed', function(source)
    local tracksWithoutCheckpoints = DeepCopy(Tracks)
    for i, track in pairs(tracksWithoutCheckpoints) do
        tracksWithoutCheckpoints[i] = track
        tracksWithoutCheckpoints[i].Checkpoints = nil
    end
    return tracksWithoutCheckpoints
end)

local function getTracks()
    return Tracks    
end exports('getTracks', getTracks)

local function getRaces()
    return Races
end exports('getRaces', getRaces)

RegisterServerCallback('cw-racingapp:server:getRaces', function(source)
    return Races
end)

RegisterServerCallback('cw-racingapp:server:getTrackData', function(source, trackId)
    return Tracks[trackId] or false
end)

RegisterServerCallback('cw-racingapp:server:getAccess', function(source, trackId)
    local track = Tracks[trackId]
    return track.Access or 'NOTHING'
end)

RegisterNetEvent('cw-racingapp:server:setAccess', function(trackId, access)
    local src = source
    if UseDebug then
        print('source ', src, 'has updated access for', trackId)
        print(json.encode(access))
    end
    local res = RADB.setAccessForTrack(access, trackId)
    if res then
        if res == 1 then
            NotifyHandler( src, Lang("access_updated"), "success")
        end
        Tracks[trackId].Access = access
    end
end)

RegisterServerCallback('cw-racingapp:server:isAuthorizedToCreateRaces', function(source, trackName, racerName)
    return { permissioned = IsPermissioned(racerName, 'create'), nameAvailable = IsNameAvailable(trackName) }
end)


local function nameIsValid(racerName, citizenId)
    local result = RADB.getRaceUserByName(racerName)
    if result then
        if result.citizenid == citizenId then
            return true
        end
        return false
    else
        return true
    end
end

local function addRacerName(citizenId, racerName, targetSource, auth, creatorCitizenId)
    if not RADB.getRaceUserByName(racerName) then
        IsFirstUser = false
        RADB.createRaceUser(citizenId, racerName, auth, creatorCitizenId)
        Wait(500)
        TriggerClientEvent('cw-racingapp:client:updateRacerNames', tonumber(targetSource))
    end
end

RegisterServerCallback('cw-racingapp:server:getAmountOfTracks', function(source, citizenId)
    if Config.UseNameValidation then
        local tracks = RADB.getTracksByCitizenId(citizenId)
        return #tracks
    else
        return 0
    end
end)

RegisterServerCallback('cw-racingapp:server:nameIsAvailable', function(source, racerName, serverId)
    if UseDebug then
        print('checking availability for',
            json.encode({ racerName = racerName, sererId = serverId }, { indent = true }))
    end
    if Config.UseNameValidation then
        local citizenId = getCitizenId(serverId)
        if nameIsValid(racerName, citizenId) then
            return true
        else
            return false
        end
    else
        return true
    end
end)

local function getActiveRacerName(raceUsers)
    if raceUsers then
        for _, user in pairs(raceUsers) do
            if user.active then return user end
        end
    end
end

RegisterServerCallback('cw-racingapp:server:getRacerNamesByPlayer', function(source, serverId)
    local playerSource = serverId or source

    if UseDebug then print('Getting racer names for serverid', playerSource) end

    local citizenId = getCitizenId(playerSource)
    if UseDebug then print('Racer citizenid', citizenId) end

    local result = RADB.getRaceUsersBelongingToCitizenId(citizenId)
    if UseDebug then print('Racer Names found:', json.encode(result)) end

    if not getActiveRacerName(result) then
        if UseDebug then print('Racer race user no longer exists') end
    end

    return result
end)

RegisterServerCallback('cw-racingapp:server:curateTrack', function(source, trackId, curated)
    local res = RADB.setCurationForTrack(curated, trackId)
    local status = 'curated'
    if curated == 0 then status = 'NOT curated' end
    if res == 1 then
        NotifyHandler( source, 'Successfully set track ' .. trackId .. ' as ' .. status,
            'success')
        Tracks[trackId].Curated = curated
        return true
    else
        NotifyHandler( source, 'Your input seems to be lacking...', 'error')
        return false
    end
end)

local function createRacingName(source, citizenid, racerName, type, purchaseType, targetSource, creatorName)
    if UseDebug then
        print('Creating a racing user. Input:')
        print('citizenid', citizenid)
        print('racerName', racerName)
        print('type', type)
        print('purchaseType', json.encode(purchaseType, { indent = true }))
    end

    local cost = 1000
    if purchaseType and purchaseType.racingUserCosts and purchaseType.racingUserCosts[type] then
        cost = purchaseType.racingUserCosts[type]
    else
        NotifyHandler( source,
            'The user type you entered does not exist, defaulting to $1000', 'error')
    end

    if not handleRemoveMoney(source, purchaseType.moneyType, cost, creatorName) then return false end


    local creatorCitizenId = 'unknown'
    if getCitizenId(source) then creatorCitizenId = getCitizenId(source) end
    addRacerName(citizenid, racerName, targetSource, type, creatorCitizenId)
    return true
end

local function getRacersCreatedByUser(src, citizenId, type)
    if Config.Permissions[type] and Config.Permissions[type].controlAll then
        if UseDebug then print('Fetching racers for a god') end
        return RADB.getAllRaceUsers()
    end
    if UseDebug then print('Fetching racers for a master') end
    return RADB.getRaceUsersBelongingToCitizenId(citizenId)
end

RegisterServerCallback('cw-racingapp:server:getRacersCreatedByUser', function(source, citizenid, type)
    if UseDebug then print('Fetching all racers created by ', citizenid) end
    local result = getRacersCreatedByUser(source, citizenid, type)
    if UseDebug then print('result from fetching racers created by user', citizenid, json.encode(result)) end
    return result
end)

RegisterServerCallback('cw-racingapp:server:changeRacerName', function(source, racerNameInUse)
    if UseDebug then print('Changing Racer Name for src', source, ' to name', racerNameInUse) end
    local result = changeRacerName(source, racerNameInUse)
    if UseDebug then print('Race user result:', result) end
    local ranking = getRankingForRacer(racerNameInUse)
    if UseDebug then print('Ranking:', json.encode(ranking)) end
    return result
end)

RegisterServerCallback('cw-racingapp:server:updateTrackMetadata', function(source, trackId, metadata)
    if not trackId then
        return false
    end
    if UseDebug then print('Updating track', trackId, ' metadata with:', json.encode(metadata, { indent = true })) end
    if RADB.updateTrackMetadata(trackId, metadata) then
        Tracks[trackId].Metadata = metadata
        return true
    end
    return false
end)

RegisterNetEvent('cw-racingapp:server:removeRacerName', function(racerName)
    if UseDebug then print('removing racer with name', racerName) end
    if UseDebug then print('removed by source', source, getCitizenId(source)) end

    local res = RADB.getRaceUserByName(racerName)

    RADB.removeRaceUserByName(racerName)
    Wait(1000)
    local playerSource = getSrcOfPlayerByCitizenId(res.citizenid)
    if playerSource ~= nil then
        if UseDebug then
            print('pinging player', playerSource)
        end
        TriggerClientEvent('cw-racingapp:client:updateRacerNames', tonumber(playerSource))
    end
end)

local function setRevokedRacerName(src, racerName, revoked)
    local res = RADB.getRaceUserByName(racerName)
    if res then
        RADB.setRaceUserRevoked(racerName, revoked)
        local readableRevoked = 'revoked'
        if revoked == 0 then readableRevoked = 'active' end
        NotifyHandler( src, 'User is now set to ' .. readableRevoked, 'success')
        if UseDebug then print('Revoking for citizenid', res.citizenid) end
        local playerSource = getSrcOfPlayerByCitizenId(res.citizenid)
        if playerSource ~= nil then
            if UseDebug then
                print('pinging player', playerSource)
            end
            TriggerClientEvent('cw-racingapp:client:updateRacerNames', tonumber(playerSource))
        end
    else
        NotifyHandler( src, 'Race Name Not Found', 'error')
    end
end

RegisterNetEvent('cw-racingapp:server:setRevokedRacenameStatus', function(racername, revoked)
    if UseDebug then print('revoking racename', racername, revoked) end
    setRevokedRacerName(source, racername, revoked)
end)

RegisterNetEvent('cw-racingapp:server:createRacerName', function(playerId, racerName, type, purchaseType, creatorName)
    if UseDebug then
        print(
            'Creating a user',
            json.encode({ playerId = playerId, racerName = racerName, type = type, purchaseType = purchaseType })
        )
    end
    local citizenId = getCitizenId(tonumber(playerId))
    if citizenId then
        createRacingName(source, citizenId, racerName, type, purchaseType, playerId, creatorName)
    else
        NotifyHandler( source, Lang("could_not_find_person"), "error")
    end
end)

RegisterServerCallback('cw-racingapp:server:purchaseCrypto', function(source, racerName, cryptoAmount)
    local src = source
    local moneyToPay = math.floor((1.0 * cryptoAmount) / Config.Options.conversionRate)
    if UseDebug then
        print('Buying Crypto')
        print('Crypto Amount:', cryptoAmount)
        print('In money:', moneyToPay)
    end
    if handleRemoveMoney(src, Config.Payments.crypto, moneyToPay, racerName) then
        handleAddMoney(src, 'racingcrypto', cryptoAmount, racerName, 'purchased_crypto')
        return 'SUCCESS'
    end
    return 'NOT_ENOUGH'
end)

RegisterServerCallback('cw-racingapp:server:sellCrypto', function(source, racerName, cryptoAmount)
    local src = source
    local money = (1.0 * cryptoAmount) / Config.Options.conversionRate
    local afterFee = math.floor(money - money * Config.Options.sellCharge)
    if UseDebug then
        print('Selling Crypto')
        print('Crypto Amount:', cryptoAmount)
        print('In money:', money)
        print('After fee:', afterFee)
    end
    if handleRemoveMoney(src, 'racingcrypto', cryptoAmount, racerName) then
        handleAddMoney(src, Config.Payments.crypto, afterFee, racerName, 'sold_crypto')
        return 'SUCCESS'
    end
    return 'NOT_ENOUGH'
end)

RegisterServerCallback('cw-racingapp:server:transferCrypto', function(source, racerName, cryptoAmount, recipientName)
    local src = source
    local recipient = RADB.getRaceUserByName(recipientName)
    if UseDebug then print('Recipient data', json.encode(recipient, { indent = true })) end
    if not recipient then return 'USER_DOES_NOT_EXIST' end
    local recipientSrc = getSrcOfPlayerByCitizenId(recipient.citizenid)
    if UseDebug then print('Recipient src:', recipientSrc) end
    if RacingCrypto.removeCrypto(racerName, cryptoAmount) then
        TriggerClientEvent('cw-racingapp:client:updateUiData', src, 'crypto', RacingCrypto.getRacerCrypto(racerName))
        RacingCrypto.addRacerCrypto(recipientName, math.floor(cryptoAmount))
        NotifyHandler( src, Lang("transfer_succ") .. recipientName, 'success')
        if recipientSrc then
            TriggerClientEvent('cw-racingapp:client:updateUiData', tonumber(recipientSrc), 'crypto',
                RacingCrypto.getRacerCrypto(recipientName))
            NotifyHandler( tonumber(recipientSrc),
                Lang("transfer_succ_rec") .. racerName, 'success')
        end
        return 'SUCCESS'
    end
    return 'NOT_ENOUGH'
end)

local function srcHasUserAccess(src, access)
    local raceUser = RADB.getActiveRacerName(getCitizenId(src))
    if not raceUser then 
        NotifyHandler( src, Lang("error_no_user"), 'error')
        return false
    end
    local auth = raceUser.auth

    local hasAuth = Config.Permissions[auth][access]

    if not hasAuth then
        NotifyHandler( src, Lang("not_auth"), 'error')
        return false
    end
    return true
end

RegisterServerCallback('cw-racingapp:server:toggleAutoHost', function(source)
    if not srcHasUserAccess(source,'handleAutoHost') then return end
    
    AutoHostIsAllowed = not AutoHostIsAllowed
    return AutoHostIsAllowed
end)

RegisterServerCallback('cw-racingapp:server:toggleHosting', function(source)
        local raceUser = RADB.getActiveRacerName(getCitizenId(source))
    if not srcHasUserAccess(source, 'handleHosting') then return end

    HostingIsAllowed = not HostingIsAllowed
    return HostingIsAllowed
end)

RegisterServerCallback('cw-racingapp:server:getAdminData', function(source)
    return {
        autoHostIsEnabled = AutoHostIsAllowed,
        hostingIsEnabled = HostingIsAllowed
    }
end)

local function updateRacingUserAuth(data)
    if not Config.Permissions[data.auth] then return end
    local res = RADB.setRaceUserAuth(data.racername, data.auth)
    if res then
        local userSrc = getSrcOfPlayerByCitizenId(data.citizenId)
        if userSrc then
            TriggerClientEvent('cw-racingapp:client:updateRacerNames', userSrc)
        end
        return true
    end
    return false
end

RegisterServerCallback('cw-racingapp:server:setUserAuth', function(source, data)
    if not srcHasUserAccess(source, 'controlAll') then return end

    return updateRacingUserAuth(data)
end)

RegisterServerCallback('cw-racingapp:server:fetchRacerHistory', function(source, racerName)
    return RESDB.getRacerHistory(racerName)
end)

RegisterServerCallback('cw-racingapp:server:getDashboardData', function(source, racerName, racers, daysBack)
    local trackStats = RESDB.getTrackRaceStats(daysBack or Config.Dashboard.defaultDaysBack)
    local racerStats = RESDB.getRacerHistory(racerName)
    local topRacerStats = RESDB.getTopRacerWinnersAndWinLoss(racers, daysBack or Config.Dashboard.defaultDaysBack)
    return { trackStats = trackStats, racerStats = racerStats, topRacerStats = topRacerStats }
end)

if Config.EnableCommands then
    registerCommand('changeraceuserauth', "Change authority on racing user. If used on another player they will need to relog for effect to take place.", {
        { name = 'Racer Name', help = 'Racer name. Put in quotations if multiple words' },
        { name = 'type',       help = 'racer/creator/master/god or whatever you got' },
    }, true, function(source, args)
        if not args[1] or not args[2] then
            print("^1PEBKAC error. Google it.^0")
            return
        end
        local data = {
            racername = args[1],
            auth = args[2],
            citizenId = getCitizenId(source)
        }
        updateRacingUserAuth(data)
    end, true)

    registerCommand('createracinguser', "Create a racing user", {
        { name = 'type',       help = 'racer/creator/master/god' },
        { name = 'identifier', help = 'Server ID' },
        { name = 'Racer Name', help = 'Racer name. Put in quotations if multiple words' }
        }, true, function(source, args)
        local type = args[1]
        local id = tonumber(args[2])
        print(
            '^4Creating a user with input^0',
            json.encode({ playerId = args[2], racerName = args[3], type = args[1] })
        )
        if args[4] then
            print('^1Too many args!')
            NotifyHandler( source,
                "Too many arguments. You probably did not read the command input suggestions.", "error")
            return
        end

        if not Config.Permissions[type:lower()] then
            NotifyHandler( source, "This user type does not exist", "error")
            return
        end

        local citizenid
        local name = args[3]

        if tonumber(id) then
            citizenid = getCitizenId(tonumber(id))
            if UseDebug then print('CitizenId', citizenid) end
            if not citizenid then
                NotifyHandler( source, Lang("id_not_found"), "error")
                return
            end
        else
            citizenid = id
        end

        if #name >= Config.MaxRacerNameLength then
            NotifyHandler( source, Lang("name_too_long"), "error")
            return
        end

        if #name <= Config.MinRacerNameLength then
            NotifyHandler( source, Lang("name_too_short"), "error")
            return
        end

        local tradeType = {
            moneyType = Config.Payments.createRacingUser,
            racingUserCosts = {
                racer = 0,
                creator = 0,
                master = 0,
                god = 0
            },
        }

        createRacingName(source, citizenid, name, type:lower(), tradeType, id)
    end, true)

    registerCommand('remracename', 'Remove Racing Name From Database',
        { { name = 'name', help = 'Racer name. Put in quotations if multiple words' } }, true, function(source, args)
            local name = args[1]
            print('name of racer to delete:', name)
            RADB.removeRaceUserByName(name)
        end, true)

    registerCommand('removeallracetracks', 'Remove the race_tracks table', {}, true, function(source, args)
        RADB.wipeTracksTable()
    end, true)

    registerCommand('racingappcurated', 'Mark/Unmark track as curated',
            { { name = 'trackid', help = 'Track ID (not name). Use quotation marks!!!' }, { name = 'curated', help = 'true/false' } },
        true,
        function(source, args)
            print('Curating track: ', args[1], args[2])
            local curated = 0
            if args[2] == 'true' then
                curated = 1
            end
            local res = MySQL.Sync.execute('UPDATE race_tracks SET curated = ? WHERE raceid = ?', { curated, args[1] })
            if res == 1 then
                Tracks[args[1]].Curated = curated
                NotifyHandler( source, 'Successfully set track curated as ' .. args[2])
            else
                NotifyHandler( source, 'Your input seems to be lacking...')
            end
        end, true)

    registerCommand('cwdebugracing', 'toggle debug for racing', {}, true, function(source, args)
        UseDebug = not UseDebug
        print('debug is now:', UseDebug)
        TriggerClientEvent('cw-racingapp:client:toggleDebug', source, UseDebug)
    end, true)

    registerCommand('cwlisttracks', 'toggle debug for racing', {}, true, function(source, args)
        local tracksWithoutCheckpoints = {}
        for i, track in pairs(Tracks) do
            tracksWithoutCheckpoints[i] = track
            tracksWithoutCheckpoints[i].Checkpoints = nil
        end
        print(json.encode(tracksWithoutCheckpoints, {indent=true}))        
    end, true)

    registerCommand('cwracingapplist', 'list racingapp stuff', {}, true, function(source, args)
        print("=========================== ^3TRACKS^0 ===========================")
        print(json.encode(Tracks, { indent = true }))
        print("=========================== ^3AVAILABLE RACES^0 ===========================")
        print(json.encode(AvailableRaces, { indent = true }))
        print("=========================== ^3NOT FINISHED^0 ===========================")
        print(json.encode(NotFinished, { indent = true }))
        print("=========================== ^TIMERS^0 ===========================")
        print(json.encode(Timers, { indent = true }))
        print("=========================== ^RESULTS^0 ===========================")
        print(json.encode(RaceResults, { indent = true }))
    end, true)
end
