-----------------------
----   Variables   ----
-----------------------
local Tracks = {}
local AvailableRaces = {}
local LastRaces = {}
local NotFinished = {}
local UseDebug = Config.Debug
local Timers = {}
local IsFirstUser = false

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
                    ["OrganizerCID"] = "SYY99260",
                    ["CreatorName"] = "xXxCoolChadxXx69",
                    ["RaceId"] = "LR-7666",
                    ["Access"] = {},
                    ["RaceName"] = "Elysian But fake",
                    ["LastLeaderboard"] = {
                        {
                            ["TotalTime"] = 34128,
                            ["BestLap"] = 34128,
                            ["Holder"] = "PAODPOAS2"
                        }
                    }
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
                    ["OrganizerCID"] = "SYY99260",
                    ["CreatorName"] = "xXxCoolChadxXx69",
                    ["RaceId"] = "LR-7666",
                    ["Access"] = {},
                    ["RaceName"] = "Not Elysian",
                    ["LastLeaderboard"] = {
                        {
                            ["TotalTime"] = 34128,
                            ["BestLap"] = 34128,
                            ["Holder"] = "PAODPOAS2"
                        },
                        {
                            ["TotalTime"] = 34128,
                            ["BestLap"] = 34128,
                            ["Holder"] = "PAODPOAS2"
                        }
                    }
                },
                ["SetupCitizenId"] = "SYY99260"
            },
            ["Result"] = {
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
                {
                    ["VehicleModel"] = "A cool car",
                    ["RacerName"] = "YOMOM",
                    ["TotalTime"] = 134128,
                    ["CarClass"] = "A",
                    ["BestLap"] = 1231,
                    ["Ranking"] = 15,
                    ["TotalChange"] = -11
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
    local races = MySQL.Sync.fetchAll('SELECT * FROM race_tracks', {})
    if races[1] ~= nil then
        for _, v in pairs(races) do
            local Records = {}
            if v.records ~= nil then
                Records = json.decode(v.records)
                if #Records == 0 then
                    if UseDebug then
                        print('Only one record')
                    end
                    MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
                        { json.encode({ Records }), v.raceid })
                    Records = { Records }
                end
            end

            Tracks[v.raceid] = {
                RaceName = v.name,
                Checkpoints = json.decode(v.checkpoints),
                Records = Records,
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
                NumStarted = 0
            }
        end
    end
    IsFirstUser = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM racer_names', {}) == 0
    
end

MySQL.ready(function()
    updateRaces()
end)

local function getAllRacerNames()
    local query = 'SELECT * FROM racer_names'
    if Config.DontShowRankingsUnderZero then
        query = query .. ' WHERE ranking > 0'
    end
    if Config.LimitTopListTo then
        query = query .. ' ORDER BY ranking DESC LIMIT ' .. Config.LimitTopListTo
    end
    local result = MySQL.Sync.fetchAll(query)
    return result
end

local function sortRecordsByTime(Records)
    table.sort(Records, function(a, b) return a.Time < b.Time end)
    return Records
end

-- local function filterLeaderboardsByClass(Leaderboard, class)
--     local filteredLeaderboard = {}
--     for i, Record in pairs(Leaderboard) do
--         if Record.Class == class then
--             table.insert(filteredLeaderboard, Record)
--         end
--     end
--     return sortRecordsByTime(filteredLeaderboard)
-- end

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

local function racerHasPreviousRecordInClassAndDirection(Records, RacerName, CarClass, Reversed)
    if Records then
        for i, Record in pairs(Records) do
            if UseDebug then
                print('Checking previous records:', Record.Holder, Record.Class)
                print('check', Record.Holder == RacerName, Record.Class == CarClass)
            end
            local isReversed = Record.Reversed
            if isReversed == nil then isReversed = false end
            if Record.Holder == RacerName and Record.Class == CarClass and (isReversed == Reversed) then
                return Record, i
            end
        end
    else
        return false
    end
end

local function getLatestRecordsById(RaceId)
    local results = MySQL.Sync.fetchAll('SELECT records FROM race_tracks WHERE raceid = ?', { RaceId })[1]
    if results.records then
        return json.decode(results.records)
    else
        if UseDebug then
            print('found no latest')
        end
        return {}
    end
end

local function newRecord(src, RacerName, PlayerTime, RaceData, CarClass, VehicleModel, RaceType, Reversed)
    local records = getLatestRecordsById(RaceData.RaceId)
    local PersonalBest, index = nil, nil

    if #records == 0 then
        if UseDebug then
            print('no records have been set yet')
        end
    else
        PersonalBest, index = racerHasPreviousRecordInClassAndDirection(records, RacerName, CarClass)
    end

    if PersonalBest and PersonalBest.Time > PlayerTime then
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
            RaceType = RaceType,
            Reversed = Reversed
        }
        records[index] = playerPlacement
        records = sortRecordsByTime(records)
        Tracks[RaceData.RaceId].Records = records
        MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
            { json.encode(records), RaceData.RaceId })
        return true
    elseif not PersonalBest then
        TriggerClientEvent('cw-racingapp:client:notify', src,
            string.format(Lang("time_added"), RaceData.RaceName, MilliToTime(PlayerTime)), 'success')
        if UseDebug then
            print('had no pb')
        end
        if UseDebug then
            print('new pb', PlayerTime, RacerName, CarClass, VehicleModel)
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
        MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
            { json.encode(records), RaceData.RaceId })
        return true
    end

    return false
end

local function giveSplit(src, racers, position, pot)
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
        if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
            exports['qb-phone']:AddCrypto(src, Config.Options.cryptoType, math.floor(total))
            TriggerClientEvent('cw-racingapp:client:notify', source,
                Lang("participation_trophy_crypto") .. math.floor(total) .. ' ' .. Config.Options.cryptoType, 'success')
        else
            addMoney(src, Config.Options.MoneyType, math.floor(total))
        end
    end
end

local function handOutParticipationTrophy(src, position)
    if Config.ParticipationTrophies.amount[position] then
        if Config.ParticipationTrophies.type == 'crypto' and Config.UseRenewedCrypto then
            exports['qb-phone']:AddCrypto(src, Config.ParticipationTrophies.cryptoType,
                Config.ParticipationTrophies.amount[position])
            TriggerClientEvent('cw-racingapp:client:notify', source,
                Lang("participation_trophy_crypto") ..
                Config.ParticipationTrophies.amount[position] .. ' ' .. Config.ParticipationTrophies.cryptoType,
                'success')
        else
            addMoney(src, Config.ParticipationTrophies.type, Config.ParticipationTrophies.amount[position])
            TriggerClientEvent('cw-racingapp:client:notify', source,
                Lang("participation_trophy") .. Config.ParticipationTrophies.amount[position], 'success')
        end
    end
end

local function handOutAutomationPayout(src, amount)
    if Config.Options.MoneyType then
        if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
            exports['qb-phone']:AddCrypto(src, Config.Options.cryptoType, amount)
            TriggerClientEvent('cw-racingapp:client:notify', source,
                Lang("extra_payout") .. ' ' .. amount .. ' ' .. Config.Options.cryptoType, 'success')
        else
            addMoney(src, Config.Options.MoneyType, amount)
            TriggerClientEvent('cw-racingapp:client:notify', source, Lang("extra_payout") .. ' ' .. amount, 'success')
        end
    end
end

local function changeRacerName(src, racerName)
    local auth = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { racerName })[1].auth
    updateRacingUserMetadata(src, racerName, auth)
end

local function getRankingForRacer(src, racername)
    if UseDebug then print('Fetching ranking for racer', racername) end
    local res = MySQL.Sync.fetchAll('SELECT ranking FROM racer_names WHERE racername = ?', { racername })
    if res and res[1] then
        return res[1].ranking
    end
    return 0
end

local function updateRacerNameLastRaced(racerName, Position)
    local query = 'UPDATE racer_names SET races = races + 1 WHERE racername = "' .. racerName .. '"'
    if Position == 1 then
        query = 'UPDATE racer_names SET races = races + 1, wins = wins + 1 WHERE racername = "' .. racerName .. '"'
    end
    MySQL.Async.execute(query)
end

local function updateRacerElo(source, racerName, eloChange)
    local sql = "UPDATE racer_names SET ranking = ranking + " .. eloChange .. " WHERE racername = '" .. racerName .. "'"

    local currentRank = getRankingForRacer(source, racerName)
    MySQL.Async.execute(sql)
    TriggerClientEvent('cw-racingapp:client:updateRanking', source, eloChange, currentRank + eloChange)
end

local function handleEloUpdates(results)
    -- Prepare the SQL statement
    local sql = "UPDATE racer_names SET Ranking = CASE"

    -- Iterate over the racers table to build the SQL statement
    for _, racer in ipairs(results) do
        sql = sql .. " WHEN RacerName = '" .. racer.RacerName .. "' THEN Ranking + " .. racer.TotalChange
    end

    -- Add the default case and close the SQL statement
    sql = sql .. " END WHERE RacerName IN ("

    -- Append the RacerName values to the SQL statement
    for i, racer in ipairs(results) do
        if i > 1 then
            sql = sql .. ", "
        end
        sql = sql .. "'" .. racer.RacerName .. "'"
    end

    -- Close the SQL statement
    sql = sql .. ")"
    MySQL.Async.execute(sql)
    for _, racer in ipairs(results) do
        TriggerClientEvent('cw-racingapp:client:updateRanking', racer.RacerSource, racer.TotalChange,
            racer.Ranking + racer.TotalChange)
    end
end

RegisterNetEvent('cw-racingapp:server:FinishPlayer',
    function(raceData, totalTime, totalLaps, bestLap, carClass, vehicleModel, ranking, racingCrew)
        local src = source
        local availableKey = GetOpenedRaceKey(raceData.RaceId)
        local racerName = raceData.RacerName
        local playersFinished = 0
        local amountOfRacers = 0
        local reversed = Tracks[raceData.RaceId].Reversed

        RaceResults[raceData.RaceId].Result[#RaceResults[raceData.RaceId].Result + 1] = {
            TotalTime = totalTime,
            BestLap = bestLap,
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
            updateRacerNameLastRaced(racerName, playersFinished)
        end
        if UseDebug then
            print('Total: ', totalTime)
            print('Best Lap: ', bestLap)
            print('Place:', playersFinished, Tracks[raceData.RaceId].BuyIn)
        end
        if Tracks[raceData.RaceId].BuyIn > 0 then
            giveSplit(src, amountOfRacers, playersFinished, Tracks[raceData.RaceId].BuyIn)
        end

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
                        handOutParticipationTrophy(src, playersFinished)
                    end
                end
            else
                if UseDebug then print('Race length was to short: ', distance, ' Minumum required:',
                        Config.ParticipationTrophies.minumumRaceLength) end
            end
        end
        if UseDebug then print('Race has participation price', Tracks[raceData.RaceId].ParticipationAmount,
                Tracks[raceData.RaceId].ParticipationCurrency) end

        if Tracks[raceData.RaceId].ParticipationAmount and Tracks[raceData.RaceId].ParticipationAmount > 0 then
            local amountToGive = math.floor(Tracks[raceData.RaceId].ParticipationAmount)
            if Config.ParticipationAmounts.positionBonuses[playersFinished] then
                amountToGive = math.floor(amountToGive +
                amountToGive * Config.ParticipationAmounts.positionBonuses[playersFinished])
            end
            if UseDebug then print('Race has participation price set', Tracks[raceData.RaceId].ParticipationAmount,
                    amountToGive, Tracks[raceData.RaceId].ParticipationCurrency) end
            if Tracks[raceData.RaceId].ParticipationCurrency == 'crypto' and Config.UseRenewedCrypto then
                exports['qb-phone']:AddCrypto(src, Config.Options.cryptoType, amountToGive)
                TriggerClientEvent('cw-racingapp:client:notify', source,
                    Lang("participation_trophy_crypto") ..
                    amountToGive .. ' ' .. Tracks[raceData.RaceId].ParticipationCurrency, 'success')
            else
                addMoney(src, Tracks[raceData.RaceId].ParticipationCurrency, amountToGive)
                TriggerClientEvent('cw-racingapp:client:notify', source, Lang("participation_trophy") .. amountToGive,
                    'success')
            end
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
                handOutAutomationPayout(src, total)
            end
        end

        local BLap
        if totalLaps < 2 then
            if UseDebug then
                print('Sprint or 1 lap')
            end
            BLap = totalTime
        else
            if UseDebug then
                print('2+ laps')
            end
            BLap = bestLap
        end

        if LastRaces[raceData.RaceId] ~= nil then
            LastRaces[raceData.RaceId][#LastRaces[raceData.RaceId] + 1] = {
                TotalTime = totalTime,
                BestLap = BLap,
                Holder = racerName,
                Reversed = reversed
            }
        else
            LastRaces[raceData.RaceId] = {}
            LastRaces[raceData.RaceId][#LastRaces[raceData.RaceId] + 1] = {
                TotalTime = totalTime,
                BestLap = BLap,
                Holder = racerName,
                Reversed = reversed
            }
        end

        local raceType = 'Sprint'
        if totalLaps > 0 then raceType = 'Circuit' end
        if Tracks[raceData.RaceId].Records ~= nil and next(Tracks[raceData.RaceId].Records) ~= nil then
            local gotNewRecord = newRecord(src, racerName, BLap, raceData, carClass, vehicleModel, raceType, reversed)
            if gotNewRecord then
                if UseDebug then
                    print('Player got a record', BLap)
                end
            else
                if UseDebug then
                    print('Player did not get a record')
                end
            end
        else
            Tracks[raceData.RaceId].Records = { {
                Time = BLap,
                Holder = racerName,
                Class = carClass,
                Vehicle = vehicleModel,
                RaceType = raceType,
                Reversed = reversed
            } }
            MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
                { json.encode(Tracks[raceData.RaceId].Records), raceData.RaceId })
            TriggerClientEvent('cw-racingapp:client:notify', src,
                string.format(Lang("race_record"), raceData.RaceName, MilliToTime(BLap)), 'success')
        end
        AvailableRaces[availableKey].RaceData = Tracks[raceData.RaceId]
        for _, racer in pairs(Tracks[raceData.RaceId].Racers) do
            TriggerClientEvent('cw-racingapp:client:PlayerFinish', racer.RacerSource, raceData.RaceId, playersFinished,
                racerName)
            leftRace(racer.RacerSource)
        end
        if playersFinished == amountOfRacers then
            if amountOfRacers == 1 then
                if UseDebug then print('^3Only one racer. No ELO change') end
            else
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
            if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[raceData.RaceId] ~= nil and
                next(NotFinished[raceData.RaceId]) ~= nil then
                for _, v in pairs(NotFinished[raceData.RaceId]) do
                    LastRaces[raceData.RaceId][#LastRaces[raceData.RaceId] + 1] = {
                        TotalTime = v.TotalTime,
                        BestLap = v.BestLap,
                        Holder = v.Holder
                    }
                end
            end
            Tracks[raceData.RaceId].LastLeaderboard = LastRaces[raceData.RaceId]
            Tracks[raceData.RaceId].Racers = {}
            Tracks[raceData.RaceId].Started = false
            Tracks[raceData.RaceId].Waiting = false
            table.remove(AvailableRaces, availableKey)
            LastRaces[raceData.RaceId] = nil
            NotFinished[raceData.RaceId] = nil
            Tracks[raceData.RaceId].MaxClass = nil
        end
    end)

RegisterNetEvent('cw-racingapp:server:CreateLapRace', function(RaceName, RacerName, Checkpoints)
    local src = source

    if IsPermissioned(src, 'create') then
        if IsNameAvailable(RaceName) then
            TriggerClientEvent('cw-racingapp:client:StartRaceEditor', source, RaceName, RacerName, nil, Checkpoints)
        else
            TriggerClientEvent('cw-racingapp:client:notify', source, Lang("race_name_exists"), 'error')
        end
    else
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("no_permission"), 'error')
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

local function hasEnoughMoney(source, cost)
    if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
        if UseDebug then print('Is using crypto and renewed crypto') end
        if exports['qb-phone']:hasEnough(source, Config.Options.cryptoType, math.floor(cost)) then
            return true
        else
            TriggerClientEvent('cw-racingapp:client:notify', source,
                Lang("can_not_afford") .. math.floor(cost) .. ' ' .. Config.Options.cryptoType, 'error')
            return false
        end
    else
        return canPay(source, Config.Options.MoneyType, cost)
    end
end

RegisterNetEvent('cw-racingapp:server:JoinRace', function(RaceData)
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
            TriggerClientEvent('cw-racingapp:client:NotCloseEnough', src,
                Tracks[raceId].Checkpoints[#Tracks[raceId].Checkpoints].coords.x,
                Tracks[raceId].Checkpoints[#Tracks[raceId].Checkpoints].coords.y)
        else
            TriggerClientEvent('cw-racingapp:client:NotCloseEnough', src, Tracks[raceId].Checkpoints[1].coords.x,
                Tracks[raceId].Checkpoints[1].coords.y)
        end
        return
    end
    if not Tracks[raceId].Started then
        if UseDebug then
            print('Join: BUY IN', RaceData.BuyIn)
        end

        if RaceData.BuyIn > 0 and not hasEnoughMoney(src, RaceData.BuyIn) then
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
                    TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Tracks[currentRace])
                    leftRace(src)
                else
                    AvailableRaces[PreviousRaceKey].RaceData = Tracks[currentRace]
                    TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Tracks[currentRace])
                    leftRace(src)
                end
            end

            local AmountOfRacers = 0
            for _, _ in pairs(Tracks[raceId].Racers) do
                AmountOfRacers = AmountOfRacers + 1
            end
            if AmountOfRacers == 0 and not Tracks[raceId].Automated then
                if UseDebug then print('setting creator') end
                Tracks[raceId].OrganizerCID = citizenId
            end
            if RaceData.BuyIn > 0 then
                if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
                    exports['qb-phone']:RemoveCrypto(src, Config.Options.cryptoType, math.floor(RaceData.BuyIn))
                    TriggerClientEvent('cw-racingapp:client:notify', source,
                        Lang("remove_crypto") .. math.floor(RaceData.BuyIn) .. ' ' .. Config.Options.cryptoType,
                        'success')
                else
                    removeMoney(src, Config.Options.MoneyType, RaceData.BuyIn)
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
            TriggerClientEvent('cw-racingapp:client:JoinRace', src, Tracks[raceId], RaceData.Laps, racerName)
            for _, racer in pairs(Tracks[raceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:UpdateRaceRacers', racer.RacerSource, raceId,
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
            Tracks[RaceId].OrganizerCID = i
            TriggerClientEvent('cw-racingapp:client:notify', v.RacerSource, Lang("new_host"))
            for _, racer in pairs(Tracks[RaceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:UpdateOrganizer', racer.RacerSource, RaceId, i)
            end
            return
        end
    end
end

RegisterNetEvent('cw-racingapp:server:LeaveRace', function(RaceData, reason)
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
    for _, _ in pairs(Tracks[raceId].Racers) do
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
    Tracks[raceId].Racers[citizenId] = nil
    if Tracks[raceId].OrganizerCID == citizenId then
        assignNewOrganizer(raceId, src)
    end
    if (amountOfRacers - 1) == 0 then
        if not Tracks[raceId].Automated then
            if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[raceId] ~= nil and next(NotFinished[raceId]) ~=
                nil then
                for _, racer in pairs(NotFinished[raceId]) do
                    if LastRaces[raceId] ~= nil then
                        LastRaces[raceId][#LastRaces[raceId] + 1] = {
                            TotalTime = racer.TotalTime,
                            BestLap = racer.BestLap,
                            Holder = racer.Holder
                        }
                    else
                        LastRaces[raceId] = {}
                        LastRaces[raceId][#LastRaces[raceId] + 1] = {
                            TotalTime = racer.TotalTime,
                            BestLap = racer.BestLap,
                            Holder = racer.Holder
                        }
                    end
                end
            end
            Tracks[raceId].LastLeaderboard = LastRaces[raceId]
            Tracks[raceId].Racers = {}
            Tracks[raceId].Started = false
            Tracks[raceId].Waiting = false
            table.remove(AvailableRaces, availableKey)
            TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_last_person"))
            LastRaces[raceId] = nil
            NotFinished[raceId] = nil
        end
    else
        AvailableRaces[availableKey].RaceData = Tracks[raceId]
    end
    TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Tracks[raceId])
    leftRace(src)
    for _, racer in pairs(Tracks[raceId].Racers) do
        TriggerClientEvent('cw-racingapp:client:UpdateRaceRacers', racer.RacerSource, raceId, Tracks[raceId].Racers)
    end
    if RaceData.Ranked and RaceData.Started and RaceData.TotalRacers > 1 and reason then
        if Config.EloPunishments[reason] then
            updateRacerElo(src, racerName, Config.EloPunishments[reason])
        end
    end
end)

local function createTimeoutThread(RaceId)
    CreateThread(function()
        local count = 0
        while Tracks[RaceId] and Tracks[RaceId].Waiting do
            Wait(1000)
            if count < Config.TimeOutTimerInMinutes * 60 then
                count = count + 1
            else
                local AvailableKey = GetOpenedRaceKey(RaceId)
                if Tracks[RaceId].Automated then
                    if UseDebug then print('Track Timed Out. Automated') end
                    local amountOfRacers = getAmountOfRacers(RaceId)
                    if amountOfRacers > Config.AutomatedOptions.minimumParticipants - 1 then
                        if UseDebug then print('Enough Racers to start automated') end
                        TriggerEvent('cw-racingapp:server:StartRace', RaceId)
                    else
                        if UseDebug then print('NOT Enough Racers to start automated') end
                        if amountOfRacers > 0 then
                            for cid, _ in pairs(Tracks[RaceId].Racers) do
                                local racerSource = getSrcOfPlayerByCitizenId(cid)
                                if racerSource ~= nil then
                                    TriggerClientEvent('cw-racingapp:client:notify', racerSource, Lang("race_timed_out"),
                                        'error')
                                    TriggerClientEvent('cw-racingapp:client:LeaveRace', racerSource, Tracks[RaceId])
                                    leftRace(racerSource)
                                end
                            end
                        end
                        table.remove(AvailableRaces, AvailableKey)
                        Tracks[RaceId].LastLeaderboard = {}
                        Tracks[RaceId].Racers = {}
                        Tracks[RaceId].Started = false
                        Tracks[RaceId].Waiting = false
                        Tracks[RaceId].MaxClass = nil
                        Tracks[RaceId].Ghosting = false
                        Tracks[RaceId].GhostingTime = nil
                        LastRaces[RaceId] = nil
                    end
                else
                    if UseDebug then print('Track Timed Out. NOT automated') end
                    for cid, _ in pairs(Tracks[RaceId].Racers) do
                        local racerSource = getSrcOfPlayerByCitizenId(cid)
                        if racerSource then
                            TriggerClientEvent('cw-racingapp:client:notify', racerSource, Lang("race_timed_out"), 'error')
                            TriggerClientEvent('cw-racingapp:client:LeaveRace', racerSource, Tracks[RaceId])
                            leftRace(racerSource)
                        end
                    end
                    table.remove(AvailableRaces, AvailableKey)
                    Tracks[RaceId].LastLeaderboard = {}
                    Tracks[RaceId].Racers = {}
                    Tracks[RaceId].Started = false
                    Tracks[RaceId].Waiting = false
                    Tracks[RaceId].MaxClass = nil
                    Tracks[RaceId].Ghosting = false
                    Tracks[RaceId].GhostingTime = nil
                    LastRaces[RaceId] = nil
                end
            end
        end
    end)
end

local function setupRace(RaceId, Laps, RacerName, MaxClass, GhostingEnabled, GhostingTime, BuyIn, Ranked, Reversed,
                         ParticipationAmount, ParticipationCurrency, FirstPerson, Automated, src)
    if UseDebug then
        print('Setting up race', json.encode({
            RaceId = RaceId, Laps = Laps, RacerName = RacerName, MaxClass = MaxClass, GhostingEnabled = GhostingEnabled, GhostingTime =
        GhostingTime, BuyIn = BuyIn, Automated = Automated, Ranked = Ranked, ParticipationAmount = ParticipationAmount, ParticipationCurrency =
        ParticipationCurrency, FirstPerson = FirstPerson
        }))
    end
    if Tracks[RaceId] ~= nil then
        if not Tracks[RaceId].Waiting then
            if not Tracks[RaceId].Started then
                local setupId = 0
                if src then
                    setupId = getCitizenId(src)
                end

                Tracks[RaceId].Waiting = true
                Tracks[RaceId].Automated = Automated
                Tracks[RaceId].NumStarted = Tracks[RaceId].NumStarted + 1
                Tracks[RaceId].Ghosting = GhostingEnabled
                Tracks[RaceId].GhostingTime = GhostingTime
                Tracks[RaceId].BuyIn = BuyIn
                Tracks[RaceId].Ranked = Ranked
                Tracks[RaceId].Reversed = Reversed
                Tracks[RaceId].FirstPerson = FirstPerson
                Tracks[RaceId].ParticipationAmount = tonumber(ParticipationAmount)
                Tracks[RaceId].ParticipationCurrency = ParticipationCurrency

                local allRaceData = {
                    RaceData = Tracks[RaceId],
                    Laps = Laps,
                    RaceId = RaceId,
                    SetupCitizenId = setupId,
                    SetupRacerName = RacerName,
                    MaxClass = MaxClass,
                    Ghosting = GhostingEnabled,
                    GhostingTime = GhostingTime,
                    BuyIn = BuyIn,
                    Ranked = Ranked,
                    Reversed = Reversed,
                    ParticipationAmount = ParticipationAmount,
                    ParticipationCurrency = ParticipationCurrency,
                    FirstPerson = FirstPerson,
                    ExpirationTime = os.date("%c", os.time() + 60 * Config.TimeOutTimerInMinutes),
                }
                AvailableRaces[#AvailableRaces + 1] = allRaceData
                if not Automated then
                    TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_created"), 'success')
                    TriggerClientEvent('cw-racingapp:client:ReadyJoinRace', src, allRaceData)
                end
                RaceResults[RaceId] = { Data = allRaceData, Result = {} }
                if Config.NotifyRacers then TriggerClientEvent('cw-racingapp:client:notifyRacers', -1,
                        'New Race Available') end
                createTimeoutThread(RaceId)
                return true
            else
                TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_already_started"), 'error')
                return false
            end
        else
            TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_already_started"), 'error')
            return false
        end
    else
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_doesnt_exist"), 'error')
        return false
    end
end

RegisterServerCallback('cw-racingapp:server:SetupRace', function(source, setupData)
    local src = source
    if isToFarAway(src, setupData.trackId, setupData.reversed) then
        if setupData.reversed then
            TriggerClientEvent('cw-racingapp:client:NotCloseEnough', src,
                Tracks[setupData.trackId].Checkpoints[#Tracks[setupData.trackId].Checkpoints].coords.x,
                Tracks[setupData.trackId].Checkpoints[#Tracks[setupData.trackId].Checkpoints].coords.y)
        else
            TriggerClientEvent('cw-racingapp:client:NotCloseEnough', src,
                Tracks[setupData.trackId].Checkpoints[1].coords.x, Tracks[setupData.trackId].Checkpoints[1].coords.y)
        end
        return false
    end
    if (setupData.buyIn > 0 and not hasEnoughMoney(src, setupData.buyIn)) then
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("not_enough_money"))
    else
        return setupRace(setupData.trackId, setupData.laps, setupData.hostName, setupData.maxClass, setupData.ghostingOn,
            setupData.ghostingTime, setupData.buyIn, setupData.ranked, setupData.reversed, setupData.participationMoney,
            setupData.participationCurrency, setupData.firstPerson, false, src)
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
    if Tracks[race.trackId].Waiting then
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
    .buyIn, ranked, reversed, race.participationMoney, race.participationCurrency, race.firstPerson, true, nil)
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

RegisterNetEvent('cw-racingapp:server:UpdateRaceState', function(RaceId, Started, Waiting)
    Tracks[RaceId].Waiting = Waiting
    Tracks[RaceId].Started = Started
end)

local function timer(raceId)
    local NumStartedAtTimerCreation = Tracks[raceId].NumStarted
    if UseDebug then print('============== Creating timer for ' ..
        raceId .. ' with numstarted: ' .. NumStartedAtTimerCreation .. ' ==============') end
    SetTimeout(Config.RaceResetTimer, function()
        if UseDebug then print('============== Checking timer for ' .. raceId .. ' ==============') end
        if NumStartedAtTimerCreation ~= Tracks[raceId].NumStarted then
            if UseDebug then print('============== A new race has been created on this track. Canceling ' ..
                raceId .. ' ==============') end
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
            if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[raceId] ~= nil and next(NotFinished[raceId]) ~= nil then
                for _, v in pairs(NotFinished[raceId]) do
                    if LastRaces[raceId] ~= nil then
                        LastRaces[raceId][#LastRaces[raceId] + 1] = {
                            TotalTime = v.TotalTime,
                            BestLap = v.BestLap,
                            Holder = v.Holder
                        }
                    else
                        LastRaces[raceId] = {}
                        LastRaces[raceId][#LastRaces[raceId] + 1] = {
                            TotalTime = v.TotalTime,
                            BestLap = v.BestLap,
                            Holder = v.Holder
                        }
                    end
                end
            end
            for _, racer in pairs(Tracks[raceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:LeaveRace', racer.RacerSource, Tracks[raceId])
                leftRace(racer.RacerSource)
            end
            Tracks[raceId].LastLeaderboard = LastRaces[raceId]
            Tracks[raceId].Racers = {}
            Tracks[raceId].Started = false
            Tracks[raceId].Waiting = false
            Tracks[raceId].MaxClass = nil
            LastRaces[raceId] = nil
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

RegisterNetEvent('cw-racingapp:server:UpdateRacerData', function(RaceId, Checkpoint, Lap, Finished, RaceTime)
    local src = source
    local citizenId = getCitizenId(src)
    if Tracks[RaceId].Racers[citizenId] then
        Tracks[RaceId].Racers[citizenId].Checkpoint = Checkpoint
        Tracks[RaceId].Racers[citizenId].Lap = Lap
        Tracks[RaceId].Racers[citizenId].Finished = Finished
        Tracks[RaceId].Racers[citizenId].RaceTime = RaceTime

        Tracks[RaceId].Racers[citizenId].CheckpointTimes[#Tracks[RaceId].Racers[citizenId].CheckpointTimes + 1] = { lap =
        Lap, checkpoint = Checkpoint, time = RaceTime }

        for _, racer in pairs(Tracks[RaceId].Racers) do
            TriggerClientEvent('cw-racingapp:client:UpdateRaceRacerData', racer.RacerSource, RaceId, Tracks[RaceId])
        end
    else
        -- Attemt to make sure script dont break if something goes wrong
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("youre_not_in_the_race"), 'error')
        TriggerClientEvent('cw-racingapp:client:LeaveRace', -1, nil)
        leftRace(src)
    end
    if Config.UseResetTimer then updateTimer(RaceId) end
end)

RegisterNetEvent('cw-racingapp:server:StartRace', function(RaceId)
    local src = source
    local AvailableKey = GetOpenedRaceKey(RaceId)

    if not RaceId then
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("not_in_race"), 'error')
        return
    end

    if AvailableRaces[AvailableKey].RaceData.Started then
        TriggerClientEvent('cw-racingapp:client:notify', src, Lang("race_already_started"), 'error')
        return
    end

    AvailableRaces[AvailableKey].RaceData.Started = true
    AvailableRaces[AvailableKey].RaceData.Waiting = false
    local TotalRacers = 0
    for _, _ in pairs(Tracks[RaceId].Racers) do
        TotalRacers = TotalRacers + 1
    end
    for citizenId, _ in pairs(Tracks[RaceId].Racers) do
        local racerSource = getSrcOfPlayerByCitizenId(citizenId)
        if racerSource ~= nil then
            TriggerClientEvent('cw-racingapp:client:RaceCountdown', racerSource, TotalRacers)
            setInRace(src, RaceId)
        end
    end
    if Config.UseResetTimer then startTimer(RaceId) end
end)

RegisterNetEvent('cw-racingapp:server:SaveTrack', function(raceData)
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
        MySQL.query('UPDATE race_tracks SET checkpoints = ? WHERE raceid = ?',
            { json.encode(checkpoints), raceData.RaceId })
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
            Access = {},
            LastLeaderboard = {},
            NumStarted = 0,
        }
        MySQL.Async.insert(
            'INSERT INTO race_tracks (name, checkpoints, creatorid, creatorname, distance, raceid, curated, access) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            { raceData.RaceName, json.encode(checkpoints), citizenId, raceData.RacerName, raceData.RaceDistance, raceId, 0,
                '{}' })
    end
end)

RegisterNetEvent('cw-racingapp:server:DeleteTrack', function(RaceId)
    print('DELETING ', RaceId)
    Tracks[RaceId] = nil
    local result = MySQL.Sync.fetchAll('SELECT creatorname FROM race_tracks WHERE raceid = ?', { RaceId })[1]
    if result then
        MySQL.query('DELETE FROM race_tracks WHERE raceid = ?', { RaceId })
    end
end)

RegisterNetEvent('cw-racingapp:server:ClearLeaderboard', function(RaceId)
    print('CLEARING LEADERBOARD ', RaceId)
    Tracks[RaceId].Records = nil
    MySQL.query('UPDATE race_tracks SET records = NULL WHERE raceid = ?',
        { RaceId })
end)

RegisterServerCallback('cw-racingapp:server:GetRaceResults', function(source)
    return RaceResults
end)

RegisterServerCallback('cw-racingapp:server:getAllRacers', function(source)
    if UseDebug then print('Fetching all racers') end
    local allRacers = getAllRacerNames()
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

function IsPermissioned(src, type)
    local auth = getRacerData(src).auth
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
    TriggerClientEvent('cw-racingapp:client:openUi', source, getRacerData(source))
end

exports('openRacingApp', openRacingApp)

RegisterServerCallback('cw-racingapp:server:GetRaces', function(source)
    return AvailableRaces
end)

RegisterServerCallback('cw-racingapp:server:GetTracks', function(source)
    return Tracks
end)

RegisterServerCallback('cw-racingapp:server:GetTrackData', function(source, raceId)
    return Tracks[raceId] or false
end)

RegisterServerCallback('cw-racingapp:server:GetAccess', function(source, raceId)
    local res = MySQL.Sync.fetchAll('SELECT access FROM race_tracks WHERE raceid = ?', { raceId })
    if res then
        if res[1] then
            return json.decode(res[1].access)
        else
            return 'NOTHING'
        end
    end
end)

RegisterNetEvent('cw-racingapp:server:SetAccess', function(raceId, access)
    local src = source
    if UseDebug then
        print('source ', src, 'has updated access for', raceId)
        print(json.encode(access))
    end
    local res = MySQL.Sync.execute('UPDATE race_tracks SET access = ? WHERE raceid = ?', { json.encode(access), raceId })
    if res then
        if res == 1 then
            TriggerClientEvent('cw-racingapp:client:notify', src, Lang("access_updated"), "success")
        end
        Tracks[raceId].Access = access
    end
end)

RegisterServerCallback('cw-racingapp:server:IsAuthorizedToCreateRaces', function(source, TrackName)
    return { permissioned = IsPermissioned(source, 'create'), nameAvailable = IsNameAvailable(TrackName) }
end)


local function nameIsValid(racerName, citizenId)
    local result = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { racerName })[1]
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
    if not MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ? AND citizenid = ?', { racerName, citizenId })[1] then
        IsFirstUser = false
        MySQL.Async.insert('INSERT INTO racer_names (citizenid, racername, auth, createdby) VALUES (?, ?, ?, ?)',
            { citizenId, racerName, auth, creatorCitizenId })
    end
    TriggerClientEvent('cw-racingapp:Client:UpdateRacerNames', tonumber(targetSource))
end

RegisterServerCallback('cw-racingapp:server:GetAmountOfTracks', function(source, citizenid)
    if Config.UseNameValidation then
        local tracks = MySQL.Sync.fetchAll('SELECT name FROM race_tracks WHERE creatorid = ?', { citizenid })
        return #tracks
    else
        return 0
    end
end)

RegisterServerCallback('cw-racingapp:server:NameIsAvailable', function(source, racerName, serverId)
    if UseDebug then print('checking availability for', json.encode({racerName = racerName, sererId = serverId}, {indent=true})) end
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

local function racerNameExists(currentName, racerNames)
    if currentName then
        for _, user in pairs(racerNames) do
            if currentName == user.racername then return true end
        end
    else
        return true -- if no name selected then ignore
    end
    return false    -- if we dont find a name we return false
end

RegisterServerCallback('cw-racingapp:server:GetRacerNamesByPlayer', function(source, serverId)
    local playerSource = serverId or source
    
    if UseDebug then print('Getting racer names for serverid', playerSource) end

    local citizenId = getCitizenId(playerSource)
    if UseDebug then print('Racer citizenid', citizenId) end

    local result = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE citizenid = ?', { citizenId })
    if UseDebug then print('Racer Names found:', json.encode(result)) end

    local currentRacerName = getRacerData(playerSource).name

    if not racerNameExists(currentRacerName, result) then
        if UseDebug then print('Racer name selected does no longer exist') end
        updateRacingUserMetadata(playerSource, nil, nil)
    end

    return result
end)

RegisterServerCallback('cw-racingapp:server:curateTrack', function(source, trackId, curated)
    local res = MySQL.Sync.execute('UPDATE race_tracks SET curated = ? WHERE raceid = ?', { curated, trackId })
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

local function createRacingName(source, citizenid, racerName, type, purchaseType, targetSource)
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

    if purchaseType.moneyType == 'crypto' and Config.UseRenewedCrypto then
        if exports['qb-phone']:hasEnough(source, Config.Options.cryptoType, math.floor(cost)) then
            exports['qb-phone']:RemoveCrypto(source, Config.Options.cryptoType, math.floor(cost))
            TriggerClientEvent('cw-racingapp:client:notify', source,
                Lang("remove_crypto") .. math.floor(cost) .. ' ' .. Config.Options.cryptoType, 'success')
        else
            TriggerClientEvent('cw-racingapp:client:notify', source,
                Lang("can_not_afford") .. math.floor(cost) .. ' ' .. Config.Options.cryptoType, 'error')
            return
        end
    else
        if not removeMoney(source, purchaseType.moneyType, cost) then
            TriggerClientEvent('cw-racingapp:client:notify', source, Lang("can_not_afford") .. ' $' .. math.floor(cost),
                'error')
            return
        end
    end
    if Config.UseRenewedBanking and purchaseType.profiteer and cost > 0 then
        local profit = math.floor(cost * purchaseType.profiteer.cut)
        exports['Renewed-Banking']:addAccountMoney(purchaseType.profiteer.job, profit)
        exports['Renewed-Banking']:handleTransaction(purchaseType.profiteer.job, "Racing GPS", profit, "Type: " .. type,
            "Unknown", 'RacingApp', "deposit")
    end
    local creatorCitizenId = 'unknown'
    if getCitizenId(source) then creatorCitizenId = getCitizenId(source) end
    addRacerName(citizenid, racerName, targetSource, type, creatorCitizenId)
end

local function getRacersCreatedByUser(src, citizenid, type)
    if Config.Permissions[type] and Config.Permissions[type].controlAll then
        if UseDebug then print('Fetching racers for a god') end
        return MySQL.Sync.fetchAll('SELECT * FROM racer_names')
    end
    if UseDebug then print('Fetching racers for a master') end
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE createdby = ?', { citizenid })
end

RegisterServerCallback('cw-racingapp:server:GetRacersCreatedByUser', function(source, citizenid, type)
    if UseDebug then print('Fetching all racers created by ', citizenid) end
    local result = getRacersCreatedByUser(source, citizenid, type)
    if UseDebug then print('result from fetching racers created by user', citizenid, json.encode(result)) end
    return result
end)

RegisterServerCallback('cw-racingapp:server:ChangeRacerName', function(source, racerNameInUse)
    if UseDebug then print('Changing Racer Name for src', source, ' to name', racerNameInUse) end
    changeRacerName(source, racerNameInUse)

    local racerData = getRacerData(source)
    local racerName = racerData.name
    local racerAuth = racerData.auth
    if UseDebug then print('New names', racerName, racerAuth) end

    local ranking = getRankingForRacer(source, racerNameInUse)
    if UseDebug then print('Ranking:', json.encode(ranking)) end
    return { name = racerName, type = racerAuth, ranking = ranking }
end)

RegisterNetEvent('cw-racingapp:server:RemoveRacerName', function(racername)
    if UseDebug then print('removing racer with name', racername) end
    if UseDebug then print('removed by source', source, getCitizenId(source)) end

    local res = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { racername })[1]

    MySQL.query('DELETE FROM racer_names WHERE racername = ?', { racername })
    Wait(1000)
    local playerSource = getSrcOfPlayerByCitizenId(res.citizenid)
    if playerSource ~= nil then
        if UseDebug then
            print('pinging player', playerSource)
        end
        updateRacingUserMetadata(tonumber(playerSource), nil, nil)
        TriggerClientEvent('cw-racingapp:Client:UpdateRacerNames', tonumber(playerSource))
    end
end)

local function setRevokedRacerName(src, racerName, revoked)
    local res = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { racerName })[1]
    if res then
        MySQL.Async.execute('UPDATE racer_names SET revoked = ? WHERE racername = ?', { tonumber(revoked), racerName })
        local readableRevoked = 'revoked'
        if revoked == 0 then readableRevoked = 'active' end
        TriggerClientEvent('cw-racingapp:client:notify', src, 'User is now set to ' .. readableRevoked, 'success')
        if UseDebug then print('Revoking for citizenid', res.citizenid) end
        local playerSource = getSrcOfPlayerByCitizenId(res.citizenid)
        if playerSource ~= nil then
            if UseDebug then
                print('pinging player', playerSource)
            end
            TriggerClientEvent('cw-racingapp:Client:UpdateRacerNames', tonumber(playerSource))
        end
    else
        TriggerClientEvent('cw-racingapp:client:notify', src, 'Race Name Not Found', 'error')
    end
end

RegisterNetEvent('cw-racingapp:server:SetRevokedRacenameStatus', function(racername, revoked)
    if UseDebug then print('revoking racename', racername, revoked) end
    setRevokedRacerName(source, racername, revoked)
end)

RegisterNetEvent('cw-racingapp:server:CreateRacerName', function(playerId, racerName, type, purchaseType)
    if UseDebug then
        print(
            'Creating a user',
            json.encode({ playerId = playerId, racerName = racerName, type = type, purchaseType = purchaseType })
        )
    end
    local citizenId = getCitizenId(tonumber(playerId))
    if citizenId then
        createRacingName(source, citizenId, racerName, type, purchaseType, playerId)
    else
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("could_not_find_person"), "error")
    end
end)

if UseDebug then
    registerCommand('createracinguser', "Create a racing user", {
        { name = 'type',     help = 'racer/creator/master/god' },
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
            moneyType = Config.Options.MoneyType,
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
        MySQL.query('DELETE FROM racer_names WHERE racername = ?', { name })
    end, true)
    
    local function dropRacetrackTable()
        MySQL.query('DROP TABLE IF EXISTS race_tracks')
    end
    
    registerCommand('removeallracetracks', 'Remove the race_tracks table', {}, true,function(source, args)
        dropRacetrackTable()
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
    end,true)
    
    registerCommand('cwdebugracing', 'toggle debug for racing', {}, true, function(source, args)
        UseDebug = not UseDebug
        print('debug is now:', UseDebug)
        TriggerClientEvent('cw-racingapp:client:toggleDebug', source, UseDebug)
    end, true)
end
