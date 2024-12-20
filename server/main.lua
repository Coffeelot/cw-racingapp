-----------------------
----   Variables   ----
-----------------------
Tracks = {}
local AvailableRaces = {}
local NotFinished = {}
local UseDebug = Config.Debug
local Timers = {}
local IsFirstUser = false

local DefaultTrackMetadata = {
    description = nil,
    raceType = nil
}

local RaceResults = {}
if Config.Debug then
    RaceResults = {
        ["LR-7666"] = {
            ["Data"] = {
                ["Ghosting"] = false,
                ["SetupRacerName"] = "PAODPOAS2",
                ["BuyIn"] = 0,
                ["Laps"] = 3,
                ["MaxClass"] = "",
                ["GhostingTime"] = 0,
                ["RaceId"] = "LR-7666",
                ["RaceData"] = {
                    ["Ghosting"] = false,
                    ["Started"] = false,
                    ["Waiting"] = false,
                    ["Records"] = {
                        {
                            ["Holder"] = "mamamamamam",
                            ["Time"] = 24262,
                            ["Class"] = "X",
                            ["Vehicle"] = "Osiris FR",
                            ["RaceType"] = "Circuit",
                        },
                        {
                            ["Holder"] = "mamamamamam",
                            ["Time"] = 26305,
                            ["Class"] = "S",
                            ["Vehicle"] = "model not found",
                            ["RaceType"] = "Sprint",
                        },
                    },
                    ["Distance"] = 1045,
                    ["Creator"] = "SYY99260",
                    ["BuyIn"] = 0,
                    ["Racers"] = {},
                    ["GhostingTime"] = 0,
                    ["SetupCitizenId"] = "SYY99260",
                    ["CreatorName"] = "xXxCoolChadxXx69",
                    ["RaceId"] = "LR-7666",
                    ["Access"] = {},
                    ["RaceName"] = "Elysian But fake",
                },
                ["SetupCitizenId"] = "SYY99260"
            },
            ["Result"] = {
                {
                    ["VehicleModel"] = "Euros ZR300",
                    ["RacerName"] = "PAODPOAS2",
                    ["TotalTime"] = 74128,
                    ["CarClass"] = "S",
                    ["BestLap"] = 30404
                }
            }
        },
        ["LR-1123"] = {
            ["Data"] = {
                ["Ghosting"] = false,
                ["SetupRacerName"] = "PAODPOAS2",
                ["BuyIn"] = 0,
                ["Laps"] = 0,
                ["MaxClass"] = "",
                ["GhostingTime"] = 0,
                ["RaceId"] = "LR-1123",
                ["RaceData"] = {
                    ["Ghosting"] = false,
                    ["Started"] = false,
                    ["Waiting"] = false,
                    ["Ranked"] = true,
                    ["Records"] = {
                        {
                            ["Holder"] = "mamamamamam",
                            ["Time"] = 24262,
                            ["Class"] = "X",
                            ["Vehicle"] = "Osiris FR",
                            ["RaceType"] = "Circuit",

                        },
                        {
                            ["Holder"] = "mamamamamam",
                            ["Time"] = 26305,
                            ["Class"] = "S",
                            ["Vehicle"] = "model not found",
                            ["RaceType"] = "Sprint",
                        },
                    },
                    ["Distance"] = 1045,
                    ["Creator"] = "SYY99260",
                    ["BuyIn"] = 0,
                    ["Racers"] = {},
                    ["GhostingTime"] = 0,
                    ["SetupCitizenId"] = "SYY99260",
                    ["CreatorName"] = "xXxCoolChadxXx69",
                    ["RaceId"] = "LR-7666",
                    ["Access"] = {},
                    ["RaceName"] = "Not Elysian",
                },
                ["SetupCitizenId"] = "SYY99260"
            },
            ["Result"] = {
                {
                    ["VehicleModel"] = "A cool car",
                    ["RacerName"] = "YOMOM",
                    ["TotalTime"] = 134128,
                    ["CarClass"] = "A",
                    ["BestLap"] = 1231,
                    ["Ranking"] = 15,
                    ["TotalChange"] = -11
                },
                {
                    ["VehicleModel"] = "Euros ZR300",
                    ["RacerName"] = "PAODPOAS2",
                    ["RacingCrew"] = "Cool Peoples Crew",
                    ["TotalTime"] = 34128,
                    ["CarClass"] = "S",
                    ["BestLap"] = 12353,
                    ["Ranking"] = 10,
                    ["TotalChange"] = 1
                },
            }
        }
    }
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

local function updateRaces()
    local races = RADB.getAllRaceTracks()
    if races[1] ~= nil then
        for _, v in pairs(races) do
            local records = {}
            if v.records ~= nil then
                records = json.decode(v.records)
                if #records == 0 then
                    if UseDebug then
                        print('Only one record')
                    end
                    records = { records }
                    RADB.setTrackRecords(records, v.raceid)
                end
            end
            local metadata

            if v.metadata ~= nil then
                metadata = json.decode(v.metadata)
            else
                if UseDebug then
                    print('Metadata is undefined for track', v.name)
                end
                metadata = deepCopy(DefaultTrackMetadata)
            end

            Tracks[v.raceid] = {
                RaceName = v.name,
                Checkpoints = json.decode(v.checkpoints),
                Records = records,
                Creator = v.creatorid,
                CreatorName = v.creatorname,
                RaceId = v.raceid,
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
end

MySQL.ready(function()
    updateRaces()
end)

local function sortRecordsByTime(Records)
    table.sort(Records, function(a, b) return a.Time < b.Time end)
    return Records
end

local function getAmountOfRacers(RaceId)
    local AmountOfRacers = 0
    local PlayersFinished = 0
    for _, v in pairs(Tracks[RaceId].Racers) do
        if v.Finished then
            PlayersFinished = PlayersFinished + 1
        end
        AmountOfRacers = AmountOfRacers + 1
    end
    return AmountOfRacers, PlayersFinished
end

local function racerHasPreviousRecordInClassAndDirection(records, racerName, carClass, vehicleModel, reversed)
    if UseDebug then
        print('Checking previous records for', racerName)
        print('class', carClass)
        print('model', vehicleModel)
        print('reversed', reversed)
    end
    if records then
        for i, record in pairs(records) do
            local isReversed = record.Reversed
            if UseDebug then
                print('Checking previous records:', record.Holder, record.Class)
                print('Matches name', record.Holder == racerName)
                print('Matches class', record.Class == carClass)
                print('Race was reversed', reversed, 'previous record was reversed', isReversed)
                print('Used model', vehicleModel, 'record has model', record.Vehicle)
            end

            local typeOrModelIsSame = false
            if Config.UseVehicleModelInsteadOfClassForRecords then
                if vehicleModel == record.Vehicle then
                    if UseDebug then print('Player has record with same vehicle model') end
                    typeOrModelIsSame = true
                end
            else
                if record.Class == carClass then
                    if UseDebug then print('Player has record in same class') end
                    typeOrModelIsSame = true
                end
            end

            local directionIsSame = false

            if isReversed == nil then isReversed = false end
            if reversed == nil then reversed = false end
            if isReversed == reversed then
                if UseDebug then print('Player direction was same') end
                directionIsSame = true
            end
            if record.Holder == racerName and directionIsSame and typeOrModelIsSame then
                return record, i
            end
        end
    else
        return false
    end
end

local function getLatestRecordsById(RaceId)
    return Tracks[RaceId].Records or {}
end

local function newRecord(src, RacerName, PlayerTime, RaceData, CarClass, VehicleModel, RaceType, Reversed, VehicleLabel)
    local records = getLatestRecordsById(RaceData.RaceId)
    local PersonalBest, index = nil, nil

    if #records == 0 then
        if UseDebug then
            print('no records have been set yet')
        end
    else
        PersonalBest, index = racerHasPreviousRecordInClassAndDirection(records, RacerName, CarClass, VehicleModel,
            Reversed)
        if UseDebug then
            print('Old PB', PersonalBest.Time, 'Index', index)
        end
    end

    if PersonalBest and PersonalBest.Time > PlayerTime and index then -- if player had a record already
        if UseDebug then
            print('new pb', PlayerTime, RacerName, CarClass, VehicleModel)
        end
        TriggerClientEvent('cw-racingapp:client:notify', src,
            string.format(Lang("new_pb"), RaceData.RaceName, MilliToTime(PlayerTime)), 'success')
        local playerPlacement = {
            Time = PlayerTime,
            Holder = RacerName,
            Class = CarClass,
            Vehicle = VehicleModel,
            VehicleLabel = VehicleLabel,
            RaceType = RaceType,
            Reversed = Reversed
        }
        records[index] = playerPlacement
        records = sortRecordsByTime(records)
        Tracks[RaceData.RaceId].Records = records
        RADB.setTrackRecords(records, RaceData.RaceId)
        return true
    elseif not PersonalBest then
        TriggerClientEvent('cw-racingapp:client:notify', src,
            string.format(Lang("time_added"), RaceData.RaceName, MilliToTime(PlayerTime)), 'success')
        if UseDebug then
            print('racer did not have a previous pb', RacerName)
        end
        if UseDebug then
            print('adding new pb', PlayerTime, RacerName, CarClass, VehicleModel)
        end
        local playerPlacement = {
            Time = PlayerTime,
            Holder = RacerName,
            Class = CarClass,
            Vehicle = VehicleModel,
            RaceType = RaceType,
            Reversed = Reversed
        }
        table.insert(records, playerPlacement)
        records = sortRecordsByTime(records)
        Tracks[RaceData.RaceId].Records = records
        RADB.setTrackRecords(records, RaceData.RaceId)
        return true
    end

    return false
end

local function handleAddMoney(src, moneyType, amount, racerName, textKey)
    if UseDebug then print('Attempting to give', racerName, amount, moneyType) end

    if moneyType == 'racingcrypto' then
        RacingCrypto.addRacerCrypto(racerName, math.floor(tonumber(amount)))
        TriggerClientEvent('cw-racingapp:client:updateUiData', src, 'crypto', RacingCrypto.getRacerCrypto(racerName))

        TriggerClientEvent('cw-racingapp:client:notify', src,
            Lang(textKey or "participation_trophy_crypto") .. math.floor(amount) .. ' ' .. Config.Payments.cryptoType, 'success')
    else
        addMoney(src, moneyType, math.floor(tonumber(amount)))
    end
end

local function handleRemoveMoney(src, moneyType, amount, racerName)
    if UseDebug then print('Attempting to charge', racerName, amount, moneyType) end
    if moneyType == 'racingcrypto' then
        if RacingCrypto.removeCrypto(racerName, amount) then
            TriggerClientEvent('cw-racingapp:client:notify', src,
            Lang("remove_crypto") .. math.floor(amount) .. ' ' .. Config.Payments.cryptoType, 'success')
            TriggerClientEvent('cw-racingapp:client:updateUiData', src, 'crypto', RacingCrypto.getRacerCrypto(racerName))
            
            return true
        end
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("can_not_afford") .. math.floor(amount).. ' '..Config.Payments.cryptoType,
        'error')
    else
        if removeMoney(src, moneyType, math.floor(amount)) then
            if UseDebug then print('^2Payment successful^0') end
            return true
        end
        if UseDebug then print('^1Payment Not successful^0') end
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("can_not_afford") .. ' $' .. math.floor(amount),
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
    elseif racers > 3 then
        total = Config.Splits['more'][position] * pot
        if UseDebug then print('Payout for ', position, total) end
    else
        if UseDebug then print('No one got a payout') end
    end
    if total > 0 then
        handleAddMoney(src, Config.Payments.racing, total, racerName)
    end
end

local function handOutParticipationTrophy(src, position, racerName)
    if Config.Payments.amount[position] then
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

local function resetTrack(trackId, reason)
    if UseDebug then 
        print('^6Resetting track^0', trackId) 
        print('Reason:', reason)
    end
    Tracks[trackId].Racers = {}
    Tracks[trackId].Started = false
    Tracks[trackId].Waiting = false
    Tracks[trackId].MaxClass = nil
    Tracks[trackId].Ghosting = false
    Tracks[trackId].GhostingTime = nil
end

RegisterNetEvent('cw-racingapp:server:finishPlayer',
    function(raceData, totalTime, totalLaps, bestLap, carClass, vehicleModel, ranking, racingCrew)
        local src = source
        local availableKey = GetOpenedRaceKey(raceData.RaceId)
        local racerName = raceData.RacerName
        local playersFinished = 0
        local amountOfRacers = 0
        local reversed = Tracks[raceData.RaceId].Reversed

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

        RaceResults[raceData.RaceId].Result[#RaceResults[raceData.RaceId].Result + 1] = {
            TotalTime = totalTime,
            BestLap = bestLapDef,
            CarClass = carClass,
            VehicleModel = vehicleModel,
            RacerName = racerName,
            Ranking = ranking,
            RacerSource = src,
            RacingCrew = racingCrew
        }
        

        for _, v in pairs(Tracks[raceData.RaceId].Racers) do
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
            print('Place:', playersFinished, Tracks[raceData.RaceId].BuyIn)
        end
        if Tracks[raceData.RaceId].BuyIn > 0 then
            giveSplit(src, amountOfRacers, playersFinished, Tracks[raceData.RaceId].BuyIn, racerName)
        end

        -- Participation amount (global)
        if Config.ParticipationTrophies.enabled and Config.ParticipationTrophies.minimumOfRacers <= amountOfRacers then
            if UseDebug then print('Participation Trophies are enabled') end
            local distance = Tracks[raceData.RaceId].Distance
            if totalLaps > 1 then
                distance = distance * totalLaps
            end
            if distance > Config.ParticipationTrophies.minumumRaceLength then
                if not Config.ParticipationTrophies.requireBuyins or (Config.ParticipationTrophies.requireBuyins and Config.ParticipationTrophies.buyInMinimum >= Tracks[raceData.RaceId].BuyIn) then
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
            print('Race has participation price', Tracks[raceData.RaceId].ParticipationAmount,
                Tracks[raceData.RaceId].ParticipationCurrency)
        end

        -- Participation amount (on this specific race)
        if Tracks[raceData.RaceId].ParticipationAmount and Tracks[raceData.RaceId].ParticipationAmount > 0 then
            local amountToGive = math.floor(Tracks[raceData.RaceId].ParticipationAmount)
            if Config.ParticipationAmounts.positionBonuses[playersFinished] then
                amountToGive = math.floor(amountToGive +
                    amountToGive * Config.ParticipationAmounts.positionBonuses[playersFinished])
            end
            if UseDebug then
                print('Race has participation price set', Tracks[raceData.RaceId].ParticipationAmount,
                    amountToGive, Tracks[raceData.RaceId].ParticipationCurrency)
            end
            handleAddMoney(src, Tracks[raceData.RaceId].ParticipationCurrency, amountToGive, racerName 'participation_trophy_crypto')
        end

        if Tracks[raceData.RaceId].Automated then
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

        local bountyResult = BountyHandler.checkBountyCompletion(racerName, vehicleModel, ranking, raceData.RaceId, carClass, bestLapDef, totalLaps == 0, reversed)
        if bountyResult then
            addMoney(src, Config.Payments.bountyPayout, bountyResult)
            TriggerClientEvent('cw-racingapp:client:notify', src, Lang("bounty_claimed").. tostring(bountyResult), 'success')
        end

        local raceType = 'Sprint'
        if totalLaps > 0 then raceType = 'Circuit' end
        if Tracks[raceData.RaceId].Records ~= nil and next(Tracks[raceData.RaceId].Records) ~= nil then
            local gotNewRecord = newRecord(src, racerName, bestLapDef, raceData, carClass, vehicleModel, raceType, reversed)
            if gotNewRecord then
                if UseDebug then
                    print('Player got a record', bestLapDef)
                end
            else
                if UseDebug then
                    print('Player did not get a record')
                end
            end
        else
            Tracks[raceData.RaceId].Records = { {
                Time = bestLapDef,
                Holder = racerName,
                Class = carClass,
                Vehicle = vehicleModel,
                RaceType = raceType,
                Reversed = reversed
            } }
            RADB.setTrackRecords(Tracks[raceData.RaceId].Records, raceData.RaceId)
            TriggerClientEvent('cw-racingapp:client:notify', src,
                string.format(Lang("race_record"), raceData.RaceName, MilliToTime(bestLapDef)), 'success')
        end
        AvailableRaces[availableKey].RaceData = Tracks[raceData.RaceId]
        for _, racer in pairs(Tracks[raceData.RaceId].Racers) do
            TriggerClientEvent('cw-racingapp:client:playerFinish', racer.RacerSource, raceData.RaceId, playersFinished,
                racerName)
            leftRace(racer.RacerSource)
        end
        if playersFinished == amountOfRacers then
            if amountOfRacers == 1 then
                if UseDebug then print('^3Only one racer. No ELO change^0') end
            elseif amountOfRacers > 0 then
                if AvailableRaces[availableKey].Ranked then
                    if UseDebug then print('Is ranked. Doing Elo check') end
                    if UseDebug then print('^2 Pre elo', json.encode(RaceResults[raceData.RaceId].Result)) end
                    local crewResult
                    RaceResults[raceData.RaceId].Result, crewResult = calculateTrueSkillRatings(RaceResults
                        [raceData.RaceId].Result)

                    if UseDebug then print('^2 Post elo', json.encode(RaceResults[raceData.RaceId].Result)) end
                    handleEloUpdates(RaceResults[raceData.RaceId].Result)
                    if #crewResult > 1 then
                        if UseDebug then print('Enough crews to give ranking') end
                        handleCrewEloUpdates(crewResult)
                    end
                end
            end

            resetTrack(raceData.RaceId, 'Race is over')
            table.remove(AvailableRaces, availableKey)
            NotFinished[raceData.RaceId] = nil
            Tracks[raceData.RaceId].MaxClass = nil
        end
    end)

RegisterNetEvent('cw-racingapp:server:createTrack', function(RaceName, RacerName, Checkpoints)
    local src = source
    if UseDebug then print(src, RacerName, 'is creating a track named', RaceName) end

    if IsPermissioned(RacerName, 'create') then
        if IsNameAvailable(RaceName) then
            TriggerClientEvent('cw-racingapp:client:startRaceEditor', src, RaceName, RacerName, nil, Checkpoints)
        else
            TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_name_exists"), 'error')
        end
    else
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("no_permission"), 'error')
    end
end)

local function isToFarAway(src, RaceId, Reversed)
    if Reversed then
        return Config.JoinDistance <=
            #(GetEntityCoords(GetPlayerPed(src)).xy - vec2(Tracks[RaceId].Checkpoints[#Tracks[RaceId].Checkpoints].coords.x, Tracks[RaceId].Checkpoints[#Tracks[RaceId].Checkpoints].coords.y))
    else
        return Config.JoinDistance <=
            #(GetEntityCoords(GetPlayerPed(src)).xy - vec2(Tracks[RaceId].Checkpoints[1].coords.x, Tracks[RaceId].Checkpoints[1].coords.y))
    end
end

RegisterNetEvent('cw-racingapp:server:joinRace', function(RaceData)
    local src = source
    local playerVehicleEntity = RaceData.PlayerVehicleEntity
    local raceName = RaceData.RaceData.RaceName
    local raceId = GetRaceId(raceName)
    local availableKey = GetOpenedRaceKey(RaceData.RaceId)
    local citizenId = getCitizenId(src)
    local currentRace = GetCurrentRace(citizenId)
    local racerName = RaceData.RacerName
    local racerCrew = RaceData.RacerCrew

    if UseDebug then
        print('======= Joining Race =======')
        print('AvailableKey', availableKey)
        print('PreviousRaceKey', GetOpenedRaceKey(currentRace))
        print('Racer Name:', racerName)
        print('Racer Crew:', racerCrew)
    end

    if isToFarAway(src, raceId, RaceData.Reversed) then
        if RaceData.Reversed then
            TriggerClientEvent('cw-racingapp:client:notCloseEnough', src,
                Tracks[raceId].Checkpoints[#Tracks[raceId].Checkpoints].coords.x,
                Tracks[raceId].Checkpoints[#Tracks[raceId].Checkpoints].coords.y)
        else
            TriggerClientEvent('cw-racingapp:client:notCloseEnough', src, Tracks[raceId].Checkpoints[1].coords.x,
                Tracks[raceId].Checkpoints[1].coords.y)
        end
        return
    end
    if not Tracks[raceId].Started then
        if UseDebug then
            print('Join: BUY IN', RaceData.BuyIn)
        end

        if RaceData.BuyIn > 0 and not hasEnoughMoney(src, Config.Payments.racing, RaceData.BuyIn, racerName) then
            TriggerClientEvent('cw-racingapp:client:notify', src, Lang("not_enough_money"))
        else
            if currentRace ~= nil then
                local AmountOfRacers = 0
                local PreviousRaceKey = GetOpenedRaceKey(currentRace)
                for _, _ in pairs(Tracks[currentRace].Racers) do
                    AmountOfRacers = AmountOfRacers + 1
                end
                Tracks[currentRace].Racers[citizenId] = nil
                if (AmountOfRacers - 1) == 0 then
                    Tracks[currentRace].Racers = {}
                    Tracks[currentRace].Started = false
                    Tracks[currentRace].Waiting = false
                    table.remove(AvailableRaces, PreviousRaceKey)
                    TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_last_person"))
                    TriggerClientEvent('cw-racingapp:client:leaveRace', src, Tracks[currentRace])
                    leftRace(src)
                else
                    AvailableRaces[PreviousRaceKey].RaceData = Tracks[currentRace]
                    TriggerClientEvent('cw-racingapp:client:leaveRace', src, Tracks[currentRace])
                    leftRace(src)
                end
            end

            local AmountOfRacers = 0
            for _, _ in pairs(Tracks[raceId].Racers) do
                AmountOfRacers = AmountOfRacers + 1
            end
            if AmountOfRacers == 0 and not Tracks[raceId].Automated then
                if UseDebug then print('setting creator') end
                Tracks[raceId].SetupCitizenId = citizenId
            end
            if RaceData.BuyIn > 0 then
                if not handleRemoveMoney(src, Config.Payments.racing, RaceData.BuyIn, racerName) then
                    return
                end
            end

            Tracks[raceId].Racers[citizenId] = {
                Checkpoint = 1,
                Lap = 1,
                Finished = false,
                RacerName = racerName,
                RacerCrew = racerCrew,
                Placement = 0,
                PlayerVehicleEntity = playerVehicleEntity,
                RacerSource = src,
                CheckpointTimes = {}
            }
            AvailableRaces[availableKey].RaceData = Tracks[raceId]
            TriggerClientEvent('cw-racingapp:client:joinRace', src, Tracks[raceId], RaceData.Laps, racerName)
            for _, racer in pairs(Tracks[raceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:updateRaceRacers', racer.RacerSource, raceId,
                    Tracks[raceId].Racers)
            end
            if not Tracks[raceId].Automated then
                local creatorsource = getSrcOfPlayerByCitizenId(AvailableRaces[availableKey].SetupCitizenId)
                if creatorsource ~= src then
                    TriggerClientEvent('cw-racingapp:client:notify', creatorsource, Lang("race_someone_joined"))
                end
            end
        end
    else
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_already_started"))
    end
end)

local function assignNewOrganizer(RaceId, src)
    for i, v in pairs(Tracks[RaceId].Racers) do
        if i ~= getCitizenId(src) then
            Tracks[RaceId].SetupCitizenId = i
            TriggerClientEvent('cw-racingapp:client:notify', v.RacerSource, Lang("new_host"))
            for _, racer in pairs(Tracks[RaceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:updateOrganizer', racer.RacerSource, RaceId, i)
            end
            return
        end
    end
end

RegisterNetEvent('cw-racingapp:server:leaveRace', function(RaceData, reason)
    if UseDebug then
        print('Player left race', source)
        print('Reason:', reason)
        print(json.encode(RaceData, { indent = true }))
    end
    local src = source
    local citizenId = getCitizenId(src)
    local racerName = RaceData.RacerName

    local raceId = RaceData.RaceId
    local availableKey = GetOpenedRaceKey(raceId)

    if not Tracks[raceId].Automated then
        local creator = getSrcOfPlayerByCitizenId(AvailableRaces[availableKey].SetupCitizenId)

        if creator then
            TriggerClientEvent('cw-racingapp:client:notify', creator, Lang("race_someone_left"))
        end
    end

    local amountOfRacers = 0
    for _, v in pairs(Tracks[raceId].Racers) do
        if not v.Finished then
            amountOfRacers = amountOfRacers + 1
        end
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
    Tracks[raceId].Racers[citizenId] = nil
    if Tracks[raceId].SetupCitizenId == citizenId then
        assignNewOrganizer(raceId, src)
    end
    if (amountOfRacers - 1) == 0 then
        if not Tracks[raceId].Automated then
            if UseDebug then print(citizenId,' was the last racer. ^3Cancelling race^0') end
            resetTrack(raceId, 'last racer left')
            table.remove(AvailableRaces, availableKey)
            TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_last_person"))
            NotFinished[raceId] = nil
        else
            if UseDebug then print(citizenId,' was the last racer. ^Race was Automated. No cancel.^0') end
        end
    else
        AvailableRaces[availableKey].RaceData = Tracks[raceId]
    end
    TriggerClientEvent('cw-racingapp:client:leaveRace', src, Tracks[raceId])
    leftRace(src)
    for _, racer in pairs(Tracks[raceId].Racers) do
        TriggerClientEvent('cw-racingapp:client:updateRaceRacers', racer.RacerSource, raceId, Tracks[raceId].Racers)
    end
    if RaceData.Ranked and RaceData.Started and RaceData.TotalRacers > 1 and reason then
        if Config.EloPunishments[reason] then
            updateRacerElo(src, racerName, Config.EloPunishments[reason])
        end
    end
end)

local function createTimeoutThread(trackId)
    CreateThread(function()
        local count = 0
        while Tracks[trackId] and Tracks[trackId].Waiting do
            Wait(1000)
            if count < Config.TimeOutTimerInMinutes * 60 then
                count = count + 1
            else
                local availableKey = GetOpenedRaceKey(trackId)
                if UseDebug then print('Available Key', availableKey) end
                if Tracks[trackId].Automated then
                    if UseDebug then print('Track Timed Out. Automated') end
                    local amountOfRacers = getAmountOfRacers(trackId)
                    if amountOfRacers >= Config.AutomatedOptions.minimumParticipants then
                        if UseDebug then print('Enough Racers to start automated') end
                        TriggerEvent('cw-racingapp:server:startRace', trackId)
                    else
                        table.remove(AvailableRaces, availableKey)
                        resetTrack(trackId, 'not enough players to start automated')
                        
                        if amountOfRacers > 0 then
                            for cid, _ in pairs(Tracks[trackId].Racers) do
                                local racerSource = getSrcOfPlayerByCitizenId(cid)
                                if racerSource ~= nil then
                                    TriggerClientEvent('cw-racingapp:client:notify', racerSource, Lang("race_timed_out"),
                                        'error')
                                    TriggerClientEvent('cw-racingapp:client:leaveRace', racerSource, Tracks[trackId])
                                    leftRace(racerSource)
                                end
                            end
                        end
                    end
                else
                    if UseDebug then print('Track Timed Out. NOT automated', trackId) end
                    for cid, _ in pairs(Tracks[trackId].Racers) do
                        local racerSource = getSrcOfPlayerByCitizenId(cid)
                        if racerSource then
                            TriggerClientEvent('cw-racingapp:client:notify', racerSource, Lang("race_timed_out"), 'error')
                            TriggerClientEvent('cw-racingapp:client:leaveRace', racerSource, Tracks[trackId])
                            leftRace(racerSource)
                        end
                    end
                    table.remove(AvailableRaces, availableKey)
                    resetTrack(trackId, 'Timed out, Not automated')
                end
            end
        end
    end)
end

local function setupRace(raceId, laps, racerName, maxClass, ghostingEnabled, ghostingTime, buyIn, ranked, reversed,
                         participationAmount, participationCurrency, firstPerson, automated, silent, src)
    if UseDebug then
        print('Setting up race', json.encode({
            RaceId = raceId,
            Laps = laps,
            RacerName = racerName,
            MaxClass = maxClass,
            GhostingEnabled = ghostingEnabled,
            GhostingTime =
                ghostingTime,
            BuyIn = buyIn,
            Automated = automated,
            Ranked = ranked,
            ParticipationAmount = participationAmount,
            ParticipationCurrency =
                participationCurrency,
            FirstPerson = firstPerson,
            Silent = silent
        }))
    end
    if Tracks[raceId] ~= nil then
        if not Tracks[raceId].Waiting then
            if not Tracks[raceId].Started then
                local setupId = 0
                if src then
                    setupId = getCitizenId(src)
                end

                Tracks[raceId].Waiting = true
                Tracks[raceId].Automated = automated
                Tracks[raceId].NumStarted = Tracks[raceId].NumStarted + 1
                Tracks[raceId].Ghosting = ghostingEnabled
                Tracks[raceId].SetupRacerName = racerName
                Tracks[raceId].GhostingTime = ghostingTime
                Tracks[raceId].BuyIn = buyIn
                Tracks[raceId].Ranked = ranked
                Tracks[raceId].Reversed = reversed
                Tracks[raceId].FirstPerson = firstPerson
                Tracks[raceId].ParticipationAmount = tonumber(participationAmount)
                Tracks[raceId].ParticipationCurrency = participationCurrency

                local allRaceData = {
                    RaceData = Tracks[raceId],
                    Laps = laps,
                    RaceId = raceId,
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
                    ExpirationTime = os.time() + 60 * Config.TimeOutTimerInMinutes,
                }
                AvailableRaces[#AvailableRaces + 1] = allRaceData
                if not automated then
                    TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_created"), 'success')
                    TriggerClientEvent('cw-racingapp:client:readyJoinRace', src, allRaceData)
                end
                RaceResults[raceId] = { Data = allRaceData, Result = {} }
                if Config.NotifyRacers and not silent then
                    TriggerClientEvent('cw-racingapp:client:notifyRacers', -1,
                        'New Race Available')
                end
                createTimeoutThread(raceId)
                return true
            else
                if src then TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_already_started"), 'error') end
                return false
            end
        else
            if src then TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_already_started"), 'error') end
            return false
        end
    else
        if src then TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_doesnt_exist"), 'error') end
        return false
    end
end

RegisterServerCallback('cw-racingapp:server:setupRace', function(source, setupData)
    local src = source
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
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("not_enough_money"))
    else
        return setupRace(setupData.trackId, setupData.laps, setupData.hostName, setupData.maxClass, setupData.ghostingOn,
            setupData.ghostingTime, setupData.buyIn, setupData.ranked, setupData.reversed, setupData.participationMoney,
            setupData.participationCurrency, setupData.firstPerson, false, setupData.silent, src)
    end
end)

RegisterServerCallback('cw-racingapp:server:purchaseCrypto', function(source, cryptoAmount, racerName)
    local src = source
    local moneyAmount = math.floor(cryptoAmount / Config.Options.conversionRate)
    if handleRemoveMoney(src, Config.Payments.crypto, moneyAmount, racerName) then
        handleAddMoney(src, 'racingcrypto', cryptoAmount, racerName, 'purchased_crypto')
    end
end)

-- AUTOMATED RACES SETUP
local function GenerateAutomatedRace()
    local race = Config.AutomatedRaces[math.random(1, #Config.AutomatedRaces)]
    if race == nil or race.trackId == nil then
        if UseDebug then print('Race Id for generated track was nil, your Config might be incorrect') end
        return
    end
    if Tracks[race.trackId] == nil then
        if UseDebug then print('ID' .. race.trackId .. ' does not exist in tracks list') end
        return
    end
    if Tracks[race.trackId].Waiting or Tracks[race.trackId].Started then
        if UseDebug then print('Automation: RaceId is already active') end
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
    setupRace(race.trackId, race.laps, race.racerName, race.maxClass, race.ghostingEnabled, race.ghostingTime, race
        .buyIn, ranked, reversed, race.participationMoney, race.participationCurrency, race.firstPerson, true, false, nil)
end

if Config.AutomatedOptions and Config.AutomatedRaces then
    CreateThread(function()
        if #Config.AutomatedRaces == 0 then
            if UseDebug then print('^3No automated races in list') end
            return
        end
        while true do
            if not UseDebug then Wait(Config.AutomatedOptions.timeBetweenRaces) else Wait(1000) end
            GenerateAutomatedRace()
            Wait(Config.AutomatedOptions.timeBetweenRaces)
        end
    end)
end

RegisterNetEvent('cw-racingapp:server:updateRaceState', function(RaceId, Started, Waiting)
    Tracks[RaceId].Waiting = Waiting
    Tracks[RaceId].Started = Started
end)

local function timer(raceId)
    local NumStartedAtTimerCreation = Tracks[raceId].NumStarted
    if UseDebug then
        print('============== Creating timer for ' ..
            raceId .. ' with numstarted: ' .. NumStartedAtTimerCreation .. ' ==============')
    end
    SetTimeout(Config.RaceResetTimer, function()
        if UseDebug then print('============== Checking timer for ' .. raceId .. ' ==============') end
        if NumStartedAtTimerCreation ~= Tracks[raceId].NumStarted then
            if UseDebug then
                print('============== A new race has been created on this track. Canceling ' ..
                    raceId .. ' ==============')
            end
            return
        end
        if next(Tracks[raceId].Racers) == nil then
            if UseDebug then print('Race is finished. Canceling timer ' .. raceId .. '') end
            return
        end
        if math.abs(GetGameTimer() - Timers[raceId]) < Config.RaceResetTimer then
            Timers[raceId] = GetGameTimer()
            timer(raceId)
        else
            if UseDebug then print('Cleaning up race ' .. raceId) end
            for _, racer in pairs(Tracks[raceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:leaveRace', racer.RacerSource, Tracks[raceId])
                leftRace(racer.RacerSource)
            end
            resetTrack(raceId, 'Idle race')
            NotFinished[raceId] = nil
            local AvailableKey = GetOpenedRaceKey(raceId)
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

RegisterNetEvent('cw-racingapp:server:updateRacerData', function(RaceId, Checkpoint, Lap, Finished, RaceTime)
    local src = source
    local citizenId = getCitizenId(src)
    if Tracks[RaceId].Racers[citizenId] then
        Tracks[RaceId].Racers[citizenId].Checkpoint = Checkpoint
        Tracks[RaceId].Racers[citizenId].Lap = Lap
        Tracks[RaceId].Racers[citizenId].Finished = Finished
        Tracks[RaceId].Racers[citizenId].RaceTime = RaceTime

        Tracks[RaceId].Racers[citizenId].CheckpointTimes[#Tracks[RaceId].Racers[citizenId].CheckpointTimes + 1] = {
            lap =
                Lap,
            checkpoint = Checkpoint,
            time = RaceTime
        }

        for _, racer in pairs(Tracks[RaceId].Racers) do
            TriggerClientEvent('cw-racingapp:client:updateRaceRacerData', racer.RacerSource, RaceId, Tracks[RaceId])
        end
    else
        -- Attemt to make sure script dont break if something goes wrong
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("youre_not_in_the_race"), 'error')
        TriggerClientEvent('cw-racingapp:client:leaveRace', -1, nil)
        leftRace(src)
    end
    if Config.UseResetTimer then updateTimer(RaceId) end
end)

RegisterNetEvent('cw-racingapp:server:startRace', function(RaceId)
    if UseDebug then print(source, 'is starting race', RaceId) end
    local src = source
    local AvailableKey = GetOpenedRaceKey(RaceId)

    if not RaceId then
        if src then TriggerClientEvent('cw-racingapp:client:notify', src, Lang("not_in_race"), 'error') end
        return
    end

    if not AvailableRaces[AvailableKey] then
        if UseDebug then print('Could not find available race', RaceId) end
        return
    end
    
    if not AvailableRaces[AvailableKey].RaceData then
        if UseDebug then print('Could not find available race data', RaceId) end
        return
        
    end
    if AvailableRaces[AvailableKey].RaceData.Started then
        if UseDebug then print('Race was already started', RaceId) end
        if src then TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_already_started"), 'error') end
        return
    end

    AvailableRaces[AvailableKey].RaceData.Started = true
    AvailableRaces[AvailableKey].RaceData.Waiting = false
    local TotalRacers = 0
    for _, _ in pairs(Tracks[RaceId].Racers) do
        TotalRacers = TotalRacers + 1
    end
    if UseDebug then print('Total Racers', TotalRacers) end
    for _, racer in pairs(Tracks[RaceId].Racers) do
        TriggerClientEvent('cw-racingapp:client:raceCountdown', racer.RacerSource, TotalRacers)
        setInRace(racer.RacerSource, RaceId)
    end
    if Config.UseResetTimer then startTimer(RaceId) end
end)

RegisterNetEvent('cw-racingapp:server:saveTrack', function(raceData)
    local src = source
    local citizenId = getCitizenId(src)
    local raceId
    if raceData.RaceId ~= nil then
        raceId = raceData.RaceId
    else
        raceId = GenerateRaceId()
    end
    local checkpoints = {}
    for k, v in pairs(raceData.Checkpoints) do
        checkpoints[k] = {
            offset = v.offset,
            coords = v.coords
        }
    end

    if raceData.IsEdit then
        print('Saving over previous track', raceData.RaceId)
        RADB.setTrackCheckpoints(checkpoints, raceData.RaceId)
        Tracks[raceId].Checkpoints = checkpoints
    else
        Tracks[raceId] = {
            RaceName = raceData.RaceName,
            Checkpoints = checkpoints,
            Records = {},
            Creator = citizenId,
            CreatorName = raceData.RacerName,
            RaceId = raceId,
            Started = false,
            Waiting = false,
            Distance = math.ceil(raceData.RaceDistance),
            Racers = {},
            Metadata = deepCopy(DefaultTrackMetadata),
            Access = {},
            LastLeaderboard = {},
            NumStarted = 0,
        }
        RADB.createTrack(raceData, checkpoints, citizenId, raceId)
    end
end)

RegisterNetEvent('cw-racingapp:server:deleteTrack', function(raceId)
    RADB.deleteTrack(raceId)
    Tracks[raceId] = nil
end)

local function getIndexOfRecord(trackId, record)
    for i, recordData in ipairs(Tracks[trackId].Records) do
        print('checking', i, recordData.Holder)
        if recordData.Holder == record.Holder and recordData.Time == record.Time and recordData.Vehicle == record.Vehicle then
            return i
        end
    end
end

local function removeRecordFromTrack(trackId, record)
    if UseDebug then
       print('All records on this track', json.encode(Tracks[trackId].Records, {indent=true}))
    end
    if Tracks[trackId] and Tracks[trackId].Records then
        local index = getIndexOfRecord(trackId, record)
        if index then
            if UseDebug then
               print('^2Found a match.^0 Removing record at index', index)
            end
            table.remove(Tracks[trackId].Records, index)
            return true
        end
    end
    
    if UseDebug then
        print('^1Did not find a match for record^0')
     end
    return false
end

RegisterNetEvent('cw-racingapp:server:removeRecord', function(trackId, record)
    if UseDebug then print('Removing record', trackId, json.encode(record, {indent=true})) end
    if removeRecordFromTrack(trackId, record) then
        RADB.setTrackRecords(Tracks[trackId].Records, trackId)
    end
end)

RegisterNetEvent('cw-racingapp:server:clearLeaderboard', function(trackId)
    Tracks[trackId].Records = nil
    RADB.clearLeaderboardForTrack(trackId)
end)

RegisterServerCallback('cw-racingapp:server:getRaceResults', function(source)
    return RaceResults
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

function IsNameAvailable(RaceName)
    local retval = true
    for RaceId, _ in pairs(Tracks) do
        if Tracks[RaceId].RaceName == RaceName then
            retval = false
            break
        end
    end
    return retval
end

function GetOpenedRaceKey(RaceId)
    local retval = nil
    for k, v in pairs(AvailableRaces) do
        if v.RaceId == RaceId then
            retval = k
            break
        end
    end
    return retval
end

function GetCurrentRace(MyCitizenId)
    local retval = nil
    for RaceId, _ in pairs(Tracks) do
        for cid, _ in pairs(Tracks[RaceId].Racers) do
            if cid == MyCitizenId then
                retval = RaceId
                break
            end
        end
    end
    return retval
end

function GetRaceId(name)
    for k, v in pairs(Tracks) do
        if v.RaceName == name then
            return k
        end
    end
    return nil
end

function GenerateRaceId()
    local RaceId = "LR-" .. math.random(1111, 9999)
    while Tracks[RaceId] ~= nil do
        RaceId = "LR-" .. math.random(1111, 9999)
    end
    return RaceId
end

function openRacingApp(source)
    if UseDebug then print('opening ui') end

    TriggerClientEvent('cw-racingapp:client:openUi', source)

end

exports('openRacingApp', openRacingApp)

RegisterServerCallback('cw-racingapp:server:cancelRace', function(source, trackId)
    local src = source
    if UseDebug then
        print('Player is canceling race', src, trackId)
    end
    if not trackId or not Tracks[trackId] then return false end

    for _, racer in pairs(Tracks[trackId].Racers) do
        TriggerClientEvent('cw-racingapp:client:notify', racer.RacerSource, Lang("race_canceled"),
        'error')
        TriggerClientEvent('cw-racingapp:client:leaveRace', racer.RacerSource, Tracks[trackId])
        leftRace(racer.RacerSource)
    end
    Wait(500)
    local availableKey = GetOpenedRaceKey(trackId)
    if UseDebug then print('Available Key', availableKey) end
    table.remove(AvailableRaces, availableKey)
    resetTrack(trackId, 'Manually canceled by src '.. tostring(src or 'UNKNOWN'))
    return true
end)


RegisterServerCallback('cw-racingapp:server:getRaces', function(source)
    return AvailableRaces
end)

RegisterServerCallback('cw-racingapp:server:getTracks', function(source)
    return Tracks
end)

RegisterServerCallback('cw-racingapp:server:getTrackData', function(source, raceId)
    return Tracks[raceId] or false
end)

RegisterServerCallback('cw-racingapp:server:getAccess', function(source, raceId)
    local track = Tracks[raceId]
    return track.Access or 'NOTHING'
end)

RegisterNetEvent('cw-racingapp:server:setAccess', function(raceId, access)
    local src = source
    if UseDebug then
        print('source ', src, 'has updated access for', raceId)
        print(json.encode(access))
    end
    local res = RADB.setAccessForTrack(access, raceId)
    if res then
        if res == 1 then
            TriggerClientEvent('cw-racingapp:client:notify', src, Lang("access_updated"), "success")
        end
        Tracks[raceId].Access = access
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
    if UseDebug then print('checking availability for',
            json.encode({ racerName = racerName, sererId = serverId }, { indent = true })) end
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
        TriggerClientEvent('cw-racingapp:client:notify', source, 'Successfully set track ' .. trackId .. ' as ' .. status,
            'success')
        Tracks[trackId].Curated = curated
        return true
    else
        TriggerClientEvent('cw-racingapp:client:notify', source, 'Your input seems to be lacking...', 'error')
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
        TriggerClientEvent('cw-racingapp:client:notify', source,
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
    if UseDebug then print('Race user result:', json.encode(result)) end
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
        TriggerClientEvent('cw-racingapp:client:notify', src, 'User is now set to ' .. readableRevoked, 'success')
        if UseDebug then print('Revoking for citizenid', res.citizenid) end
        local playerSource = getSrcOfPlayerByCitizenId(res.citizenid)
        if playerSource ~= nil then
            if UseDebug then
                print('pinging player', playerSource)
            end
            TriggerClientEvent('cw-racingapp:client:updateRacerNames', tonumber(playerSource))
        end
    else
        TriggerClientEvent('cw-racingapp:client:notify', src, 'Race Name Not Found', 'error')
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
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("could_not_find_person"), "error")
    end
end)

RegisterServerCallback('cw-racingapp:server:purchaseCrypto', function(source, racerName, cryptoAmount)
    local src = source
    if handleRemoveMoney(src, Config.Payments.crypto, cryptoAmount/Config.Options.conversionRate, racerName) then
        handleAddMoney(src, 'racingcrypto', cryptoAmount, racerName, 'purchased_crypto')
        return 'SUCCESS'
    end
    return 'NOT_ENOUGH'
end)

RegisterServerCallback('cw-racingapp:server:sellCrypto', function(source, racerName, cryptoAmount)
    local src = source
    if handleRemoveMoney(src, 'racingcrypto', cryptoAmount, racerName) then
        handleAddMoney(src, Config.Payments.crypto, cryptoAmount/Config.Options.conversionRate, racerName, 'sold_crypto')
        return 'SUCCESS'
    end
    return 'NOT_ENOUGH'
end)

RegisterServerCallback('cw-racingapp:server:transferCrypto', function(source, racerName, cryptoAmount, recipientName)
    local src = source
    local recipient = RADB.getRaceUserByName(recipientName)
    if UseDebug then print('Recipient data', json.encode(recipient, {indent=true})) end
    if not recipient then return 'USER_DOES_NOT_EXIST' end
    local recipientSrc = getSrcOfPlayerByCitizenId(recipient.citizenid)
    if UseDebug then print('Recipient src:', recipientSrc) end
    if RacingCrypto.removeCrypto(racerName,cryptoAmount) then
        TriggerClientEvent('cw-racingapp:client:updateUiData', src, 'crypto', RacingCrypto.getRacerCrypto(racerName))
        RacingCrypto.addRacerCrypto(recipientName, math.floor(cryptoAmount))
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("transfer_succ").. recipientName, 'success')
        if recipientSrc then
            TriggerClientEvent('cw-racingapp:client:updateUiData', tonumber(recipientSrc), 'crypto', RacingCrypto.getRacerCrypto(recipientName))
            TriggerClientEvent('cw-racingapp:client:notify',  tonumber(recipientSrc), Lang("transfer_succ_rec").. racerName, 'success')
        end
        return 'SUCCESS'
    end
    return 'NOT_ENOUGH'
end)

if UseDebug then
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
            TriggerClientEvent('cw-racingapp:client:notify', source,
                "Too many arguments. You probably did not read the command input suggestions.", "error")
            return
        end

        if not Config.Permissions[type:lower()] then
            TriggerClientEvent('cw-racingapp:client:notify', source, "This user type does not exist", "error")
            return
        end

        local citizenid
        local name = args[3]

        if tonumber(id) then
            citizenid = getCitizenId(tonumber(id))
            if UseDebug then print('CitizenId', citizenid) end
            if not citizenid then
                TriggerClientEvent('cw-racingapp:client:notify', source, Lang("id_not_found"), "error")
                return
            end
        else
            citizenid = id
        end

        if #name >= Config.MaxRacerNameLength then
            TriggerClientEvent('cw-racingapp:client:notify', source, Lang("name_too_long"), "error")
            return
        end

        if #name <= Config.MinRacerNameLength then
            TriggerClientEvent('cw-racingapp:client:notify', source, Lang("name_too_short"), "error")
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
                TriggerClientEvent('cw-racingapp:client:notify', source, 'Successfully set track curated as ' .. args[2])
            else
                TriggerClientEvent('cw-racingapp:client:notify', source, 'Your input seems to be lacking...')
            end
        end, true)

    registerCommand('cwdebugracing', 'toggle debug for racing', {}, true, function(source, args)
        UseDebug = not UseDebug
        print('debug is now:', UseDebug)
        TriggerClientEvent('cw-racingapp:client:toggleDebug', source, UseDebug)
    end, true)

    registerCommand('cwracingapplist', 'list racingapp stuff', {}, true, function(source, args)
        print("=========================== ^3TRACKS^0 ===========================")
        print(json.encode(Tracks, {indent=true}))
        print("=========================== ^3AVAILABLE RACES^0 ===========================")
        print(json.encode(AvailableRaces, {indent=true}))
        print("=========================== ^3NOT FINISHED^0 ===========================")
        print(json.encode(NotFinished, {indent=true}))
        print("=========================== ^TIMERS^0 ===========================")
        print(json.encode(Timers, {indent=true}))
    end, true)
end
