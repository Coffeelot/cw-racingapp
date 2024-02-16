-----------------------
----   Variables   ----
-----------------------
local QBCore = exports['qb-core']:GetCoreObject()
local Tracks = {}
local AvailableRaces = {}
local LastRaces = {}
local NotFinished = {}
local useDebug = Config.Debug
local RaceResults = {}
if Config.Debug then
    RaceResults = {
        ["LR-7666"]= {
            ["Data"]= {
                ["Ghosting"] = false,
                ["SetupRacerName"] = "PAODPOAS2",
                ["BuyIn"] = 0,
                ["Laps"] = 3,
                ["MaxClass"] = "",
                ["GhostingTime"] = 0,
                ["RaceId"] = "LR-7666",
                ["RaceData"] = {
                    ["Ghosting"]= false,
                    ["Started"]= false,
                    ["Waiting"]= false,
                    ["Records"]= {
                        {
                            ["Holder"]= "mamamamamam",
                            ["Time"]= 24262,
                            ["Class"]= "X",
                            ["Vehicle"]= "Osiris FR",
                            ["RaceType"]= "Circuit",
                        },
                        {
                            ["Holder"]= "mamamamamam",
                            ["Time"]= 26305,
                            ["Class"]= "S",
                            ["Vehicle"]= "model not found",
                            ["RaceType"]= "Sprint",
                        },
                    },
                    ["Distance"]= 1045,
                    ["Creator"]= "SYY99260",
                    ["BuyIn"]= 0,
                    ["Racers"]= {},
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
        ["LR-1123"]= {
            ["Data"]= {
                ["Ghosting"] = false,
                ["SetupRacerName"] = "PAODPOAS2",
                ["BuyIn"] = 0,
                ["Laps"] = 0,
                ["MaxClass"] = "",
                ["GhostingTime"] = 0,
                ["RaceId"] = "LR-1123",
                ["RaceData"] = {
                    ["Ghosting"]= false,
                    ["Started"]= false,
                    ["Waiting"]= false,
                    ["Ranked"] = true,
                    ["Records"]= {
                        {
                            ["Holder"]= "mamamamamam",
                            ["Time"]= 24262,
                            ["Class"]= "X",
                            ["Vehicle"]= "Osiris FR",
                            ["RaceType"]= "Circuit",
                     
                        },
                        {
                            ["Holder"]= "mamamamamam",
                            ["Time"]= 26305,
                            ["Class"]= "S",
                            ["Vehicle"]= "model not found",
                            ["RaceType"]= "Sprint",
                        },
                    },
                    ["Distance"]= 1045,
                    ["Creator"]= "SYY99260",
                    ["BuyIn"]= 0,
                    ["Racers"]= {},
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


-- for debug
local function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

local function updateRaces()
    local races = MySQL.Sync.fetchAll('SELECT * FROM race_tracks', {})
    if races[1] ~= nil then
        for _, v in pairs(races) do
            local Records = {}
            if v.records ~= nil then
                Records = json.decode(v.records)
                if #Records == 0 then
                    if useDebug then
                       print('Only one record')
                    end
                    MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
                     {json.encode({Records}), v.raceid})
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
                Access = json.decode(v.access),
                Curated = v.curated,
                NumStarted = 0
            }
        end
    end
end

-----------------------
----   Threads     ----
-----------------------
MySQL.ready(function ()
    MySQL.query("ALTER TABLE race_tracks ADD COLUMN IF NOT EXISTS access TEXT DEFAULT '{}'")
    updateRaces()
end)

local function getAllRacerNames()
    local result = {}
    local query = 'SELECT * FROM racer_names'
    if Config.DontShowRankingsUnderZero then
        query = query..' WHERE ranking > 0'
    end
    if Config.LimitTopListTo then
        query = query..' ORDER BY ranking DESC LIMIT '..Config.LimitTopListTo
    end
    result = MySQL.Sync.fetchAll(query)
    return result
end

local function sortRecordsByTime(Records)
    table.sort(Records, function (a,b) return a.Time < b.Time end)
    return Records
end

local function filterLeaderboardsByClass(Leaderboard, class)
    local filteredLeaderboard = {}
    if useDebug then
       print(dump(Leaderboard))
    end
    for i, Record in pairs(Leaderboard) do
        if Record.Class == class then
            table.insert(filteredLeaderboard, Record)
        end
    end
    return sortRecordsByTime(filteredLeaderboard)
end

local function getAmountOfRacers(RaceId)
    local AmountOfRacers = 0
    local PlayersFinished = 0
    for k, v in pairs(Tracks[RaceId].Racers) do
        if v.Finished then
            PlayersFinished = PlayersFinished + 1
        end
        AmountOfRacers = AmountOfRacers + 1
    end
    return AmountOfRacers, PlayersFinished
end

local function racerHasPreviousRecordInClass(Records, RacerName, CarClass)
    if Records then
        if useDebug then
           print(RacerName, CarClass)
        end
        for i, Record in pairs(Records) do
            if useDebug then
               print('Checking previous records:', Record.Holder, Record.Class)
               print('check', Record.Holder == RacerName, Record.Class == CarClass)
            end
            if Record.Holder == RacerName and Record.Class == CarClass then
                return Record, i
            end
        end
    else
        return false
    end
end

local function getLatestRecordsById(RaceId)
    local results = MySQL.Sync.fetchAll('SELECT records FROM race_tracks WHERE raceid = ?', {RaceId})[1]
    if results.records then
        if useDebug then
           print('results by id : ', dump(results.records))
           print('decoded results by id : ', dump(json.decode(results.records)))
        end
        return json.decode(results.records)
    else
        if useDebug then
           print('found no latest')
        end
        return {}
    end
end

local function getLatestRecordsByName(RaceName)
    local results = MySQL.Sync.fetchAll('SELECT records FROM race_tracks WHERE name = ?', {RaceName})[1]
    if results.records then
        if useDebug then
           print('results by name : ', dump(results.records))
           print('decoded results by name : ', dump(json.decode(results.records)))
        end
        return json.decode(results.records)
    else
        if useDebug then
           print('found no latest')
        end
        return {}
    end
end

local function newRecord(src, RacerName, PlayerTime, RaceData, CarClass, VehicleModel, RaceType)
    local records = getLatestRecordsById(RaceData.RaceId)
    local FilteredLeaderboard = {}
    local PersonalBest, index = nil, nil
    if #records == 0 then
        if useDebug then
           print('no records have been set yet')
        end
    else
        FilteredLeaderboard = filterLeaderboardsByClass(records, CarClass)
        PersonalBest, index = racerHasPreviousRecordInClass(records, RacerName, CarClass)
    end
    if useDebug then
       print('Time for player', PlayerTime, RacerName, CarClass, VehicleModel)
       print('All times for this class', dump(FilteredLeaderboard))
    end

    if useDebug then
       print('racer has previous record: ', dump(PersonalBest), index)
    end
    if PersonalBest and PersonalBest.Time > PlayerTime then
        if useDebug then
           print('new pb', PlayerTime, RacerName, CarClass, VehicleModel)
        end
        TriggerClientEvent('QBCore:Notify', src, string.format(Lang:t("success.new_pb"), RaceData.RaceName, MilliToTime(PlayerTime)), 'success')
        local playerPlacement = {
            Time = PlayerTime,
            Holder = RacerName,
            Class = CarClass,
            Vehicle = VehicleModel,
            RaceType = RaceType
        }
        records[index] = playerPlacement
        records = sortRecordsByTime(records)
        if useDebug then print('records being sent to db', dump(records)) end
        Tracks[RaceData.RaceId].Records = records
        MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
            {json.encode(records), RaceData.RaceId})
        return true

    elseif not PersonalBest then
        TriggerClientEvent('QBCore:Notify', src, string.format(Lang:t("success.time_added"), RaceData.RaceName, MilliToTime(PlayerTime)), 'success')
        if useDebug then
           print('had no pb')
        end
        if useDebug then
            print('new pb', PlayerTime, RacerName, CarClass, VehicleModel)
         end
        local playerPlacement = {
            Time = PlayerTime,
            Holder = RacerName,
            Class = CarClass,
            Vehicle = VehicleModel,
            RaceType = RaceType
        }
        if useDebug then
           print('records', dump(records))
        end
        table.insert(records, playerPlacement)
        records = sortRecordsByTime(records)
        if useDebug then
           print('new records', dump(records))
        end
        Tracks[RaceData.RaceId].Records = records
        MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
            {json.encode(records), RaceData.RaceId})
        return true
    end

    return false
end

local function giveSplit(src, racers, position, pot)
    local total = 0
    if (racers == 2 or racers == 1) and position == 1 then
        total = pot
    elseif racers == 3 and (position == 1 or position == 2) then
        total = Config.Splits['three'][position]*pot
        if useDebug then print('Payout for ', position, total) end
    elseif racers > 3 then
        total = Config.Splits['more'][position]*pot
        if useDebug then print('Payout for ', position, total) end
    else
        if useDebug then print('No one got a payout') end
    end
    local Player = QBCore.Functions.GetPlayer(src)
    if total > 0 then
        if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
            exports['qb-phone']:AddCrypto(src, Config.Options.cryptoType, math.floor(total))
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.participation_trophy_crypto").. math.floor(total).. ' '.. Config.Options.cryptoType, 'success')
        else
            Player.Functions.AddMoney(Config.Options.MoneyType, math.floor(total))
        end
    end
end

local function handOutParticipationTrophy(src, position)
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.ParticipationTrophies.amount[position] then
        if Config.ParticipationTrophies.type == 'crypto' and Config.UseRenewedCrypto then
            exports['qb-phone']:AddCrypto(src, Config.ParticipationTrophies.cryptoType, Config.ParticipationTrophies.amount[position])
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.participation_trophy_crypto")..Config.ParticipationTrophies.amount[position].. ' '.. Config.ParticipationTrophies.cryptoType, 'success')
        else
            Player.Functions.AddMoney(Config.ParticipationTrophies.type, Config.ParticipationTrophies.amount[position])
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.participation_trophy")..Config.ParticipationTrophies.amount[position], 'success')
        end
    end
end

local function handOutAutomationPayout(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.Options.MoneyType then
        if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
            exports['qb-phone']:AddCrypto(src, Config.Options.cryptoType, amount)
            TriggerClientEvent('QBCore:Notify', source, "Extra payout: "..amount.. ' '.. Config.Options.cryptoType, 'success')
        else
            Player.Functions.AddMoney(Config.Options.MoneyType, amount)
            TriggerClientEvent('QBCore:Notify', source, "Extra payout: "..amount, 'success')
        end
    end
end

local function updateRacerNameLastRaced(racerName, Position)
    local query = 'UPDATE racer_names SET races = races + 1 WHERE racername = "'..racerName..'"'
    if Position == 1 then
        query = 'UPDATE racer_names SET races = races + 1, wins = wins + 1 WHERE racername = "'..racerName..'"'
    end
    MySQL.Async.execute(query)
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
    for i, racer in ipairs(results) do
        TriggerClientEvent('cw-racingapp:client:updateRanking', racer.RacerSource, racer.TotalChange, racer.Ranking+racer.TotalChange)
    end
end

-----------------------
---- Server Events ----
-----------------------
RegisterNetEvent('cw-racingapp:server:FinishPlayer', function(RaceData, TotalTime, TotalLaps, BestLap, CarClass, VehicleModel, Ranking, RacingCrew)
    local src = source
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local RacerName = RaceData.RacerName
    local PlayersFinished = 0
    local AmountOfRacers = 0

    RaceResults[RaceData.RaceId].Result[#RaceResults[RaceData.RaceId].Result+1] = { 
        TotalTime = TotalTime, 
        BestLap = BestLap, 
        CarClass = CarClass, 
        VehicleModel = VehicleModel, 
        RacerName = RacerName,
        Ranking = Ranking,
        RacerSource = src,
        RacingCrew = RacingCrew
    }  
    for k, v in pairs(Tracks[RaceData.RaceId].Racers) do
        if v.Finished then
            PlayersFinished = PlayersFinished + 1
        end
        AmountOfRacers = AmountOfRacers + 1
    end
    if AmountOfRacers > 1 then
        updateRacerNameLastRaced(RacerName, PlayersFinished)
    end
    if useDebug then
        print('Total: ', TotalTime)
        print('Best Lap: ', BestLap)
        print('Place:', PlayersFinished, Tracks[RaceData.RaceId].BuyIn)
    end
    if Tracks[RaceData.RaceId].BuyIn > 0 then
        giveSplit(src, AmountOfRacers, PlayersFinished, Tracks[RaceData.RaceId].BuyIn)
    end

    if Config.ParticipationTrophies.enabled and Config.ParticipationTrophies.minimumOfRacers <= AmountOfRacers then
        if useDebug then print('Participation Trophies are enabled') end
        local distance = Tracks[RaceData.RaceId].Distance
        if TotalLaps > 1 then
            distance = distance*TotalLaps
        end
        if distance > Config.ParticipationTrophies.minumumRaceLength then
            if not Config.ParticipationTrophies.requireBuyins or (Config.ParticipationTrophies.requireBuyins and Config.ParticipationTrophies.buyInMinimum >= Tracks[RaceData.RaceId].BuyIn) then
                if useDebug then print('Participation Trophies buy in check passed', src) end
                if not Config.ParticipationTrophies.requireRanked or (Config.ParticipationTrophies.requireRanked and AvailableRaces[AvailableKey].Ranked) then
                    if useDebug then print('Participation Trophies Rank check passed, handing out to', src) end
                    handOutParticipationTrophy(src, PlayersFinished)
                end 
            end
        else
            if useDebug then print('Race length was to short: ', distance,' Minumum required:', Config.ParticipationTrophies.minumumRaceLength) end
        end
    end
    if useDebug then print('Race has participation price', Tracks[RaceData.RaceId].ParticipationAmount, Tracks[RaceData.RaceId].ParticipationCurrency ) end

    if Tracks[RaceData.RaceId].ParticipationAmount and Tracks[RaceData.RaceId].ParticipationAmount > 0 then
        local amountToGive = math.floor(Tracks[RaceData.RaceId].ParticipationAmount/AmountOfRacers)
        if useDebug then print('Race has participation price set', Tracks[RaceData.RaceId].ParticipationAmount, amountToGive, Tracks[RaceData.RaceId].ParticipationCurrency ) end
        local Player = QBCore.Functions.GetPlayer(src)
        if Tracks[RaceData.RaceId].ParticipationCurrency == 'crypto' and Config.UseRenewedCrypto then
            exports['qb-phone']:AddCrypto(src, Config.Options.cryptoType, amountToGive)
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.participation_trophy_crypto")..amountToGive.. ' '.. Tracks[RaceData.RaceId].ParticipationCurrency, 'success')
        else
            Player.Functions.AddMoney(Tracks[RaceData.RaceId].ParticipationCurrency, amountToGive)
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.participation_trophy")..amountToGive, 'success')
        end
    end

    if Tracks[RaceData.RaceId].Automated then
        if useDebug then print('Race Was Automated', src) end
        if Config.AutomatedOptions.payouts then
            local payoutData = Config.AutomatedOptions.payouts
            if useDebug then print('Automation Payouts exist', src) end
            local total = 0
            if payoutData.participation then total = total + payoutData.participation end
            if payoutData.perRacer then 
                total = total + payoutData.perRacer*AmountOfRacers
            end
            if PlayersFinished == 1 and payoutData.winner then 
                total = total + payoutData.winner
            end
            handOutAutomationPayout(src, total)
        end
    end

    local BLap = 0
    if TotalLaps < 2 then
        if useDebug then
            print('Sprint or 1 lap')
        end
        BLap = TotalTime
    else
        if useDebug then
            print('2+ laps')
        end
        BLap = BestLap
    end

    if LastRaces[RaceData.RaceId] ~= nil then
        LastRaces[RaceData.RaceId][#LastRaces[RaceData.RaceId]+1] =  {
            TotalTime = TotalTime,
            BestLap = BLap,
            Holder = RacerName
        }
    else
        LastRaces[RaceData.RaceId] = {}
        LastRaces[RaceData.RaceId][#LastRaces[RaceData.RaceId]+1] =  {
            TotalTime = TotalTime,
            BestLap = BLap,
            Holder = RacerName
        }
    end

    if Tracks[RaceData.RaceId].Records ~= nil and next(Tracks[RaceData.RaceId].Records) ~= nil then
        local RaceType = 'Sprint'
        if TotalLaps > 0 then RaceType = 'Circuit' end
        local newRecord = newRecord(src, RacerName, BLap, RaceData, CarClass, VehicleModel, RaceType)
        if newRecord then
            if useDebug then
               print('Player got a record', BLap)
            end
        else
            if useDebug then
               print('Player did not get a record')
            end
        end
    else
        Tracks[RaceData.RaceId].Records = {{
            Time = BLap,
            Holder = RacerName,
            Class = CarClass,
            Vehicle = VehicleModel
        }}
        MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
            {json.encode(Tracks[RaceData.RaceId].Records ), RaceData.RaceId})
            TriggerClientEvent('QBCore:Notify', src, string.format(Lang:t("success.race_record"), RaceData.RaceName, MilliToTime(BLap)), 'success')
    end
    AvailableRaces[AvailableKey].RaceData = Tracks[RaceData.RaceId]
    for cid, racer in pairs(Tracks[RaceData.RaceId].Racers) do
        TriggerClientEvent('cw-racingapp:client:PlayerFinish', racer.RacerSource, RaceData.RaceId, PlayersFinished, RacerName)
    end
    if PlayersFinished == AmountOfRacers then
        if AmountOfRacers == 1 then
            if useDebug then print('^3Only one racer. No ELO change') end
        else
            if AvailableRaces[AvailableKey].Ranked then
                if useDebug then print('Is ranked. Doing Elo check') end
                if useDebug then print('^2 Pre elo', json.encode(RaceResults[RaceData.RaceId].Result)) end
                local crewResult = {}
                RaceResults[RaceData.RaceId].Result, crewResult = calculateTrueSkillRatings(RaceResults[RaceData.RaceId].Result)

                if useDebug then print('^2 Post elo', json.encode(RaceResults[RaceData.RaceId].Result)) end
                handleEloUpdates(RaceResults[RaceData.RaceId].Result)
                if #crewResult > 1 then
                    if useDebug then print('Enough crews to give ranking') end
                    handleCrewEloUpdates(crewResult)
                end
            end
        end
        if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[RaceData.RaceId] ~= nil and
            next(NotFinished[RaceData.RaceId]) ~= nil then
            for k, v in pairs(NotFinished[RaceData.RaceId]) do
                LastRaces[RaceData.RaceId][#LastRaces[RaceData.RaceId]+1] = {
                    TotalTime = v.TotalTime,
                    BestLap = v.BestLap,
                    Holder = v.Holder
                }
            end
        end
        Tracks[RaceData.RaceId].LastLeaderboard = LastRaces[RaceData.RaceId]
        Tracks[RaceData.RaceId].Racers = {}
        Tracks[RaceData.RaceId].Started = false
        Tracks[RaceData.RaceId].Waiting = false
        table.remove(AvailableRaces, AvailableKey)
        LastRaces[RaceData.RaceId] = nil
        NotFinished[RaceData.RaceId] = nil
        Tracks[RaceData.RaceId].MaxClass = nil
    end
end)

RegisterNetEvent('cw-racingapp:server:CreateLapRace', function(RaceName, RacerName, Checkpoints)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if IsPermissioned(Player.PlayerData.citizenid, 'create') then
        if IsNameAvailable(RaceName) then
            TriggerClientEvent('cw-racingapp:client:StartRaceEditor', source, RaceName, RacerName, nil, Checkpoints)
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("primary.race_name_exists"), 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("primary.no_permission"), 'error')
    end
end)

local function isToFarAway(src, RaceId)
    return Config.JoinDistance <= #(GetEntityCoords(GetPlayerPed(src)).xy- vec2(Tracks[RaceId].Checkpoints[1].coords.x, Tracks[RaceId].Checkpoints[1].coords.y))
end

local function hasEnoughMoney(source, cost)
    if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
        if useDebug then print('Is using crypto and renewed crypto') end
        if exports['qb-phone']:hasEnough(source, Config.Options.cryptoType, math.floor(cost)) then
            return true
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.can_not_afford").. math.floor(cost).. ' '.. Config.Options.cryptoType, 'error')
            return false
        end
    else
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.PlayerData.money[Config.Options.MoneyType] >= cost then
            return true
        else
            return false
        end

    end

end

RegisterNetEvent('cw-racingapp:server:JoinRace', function(RaceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerVehicleEntity = RaceData.PlayerVehicleEntity
    local RaceName = RaceData.RaceData.RaceName
    local RaceId = GetRaceId(RaceName)
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local CurrentRace = GetCurrentRace(Player.PlayerData.citizenid)
    local RacerName = RaceData.RacerName
    local RacerCrew = RaceData.RacerCrew

    if useDebug then
        print('======= Joining Race =======')
        print('AvailableKey', AvailableKey)
        print('PreviousRaceKey', GetOpenedRaceKey(CurrentRace))
        print('Racer Name:', RacerName)
        print('Racer Crew:', RacerCrew)
    end

    if isToFarAway(src, RaceId) then
        TriggerClientEvent('cw-racingapp:client:NotCloseEnough', src, Tracks[RaceId].Checkpoints[1].coords.x, Tracks[RaceId].Checkpoints[1].coords.y)
        return
    end
    if not Tracks[RaceId].Started then
        if useDebug then
            print('Join: BUY IN', RaceData.BuyIn)
        end

        if RaceData.BuyIn > 0 and not hasEnoughMoney(src, RaceData.BuyIn) then
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_enough_money"))
        else
            if CurrentRace ~= nil then
                local AmountOfRacers = 0
                local PreviousRaceKey = GetOpenedRaceKey(CurrentRace)
                for _,_ in pairs(Tracks[CurrentRace].Racers) do
                    AmountOfRacers = AmountOfRacers + 1
                end
                Tracks[CurrentRace].Racers[Player.PlayerData.citizenid] = nil
                if (AmountOfRacers - 1) == 0 then
                    Tracks[CurrentRace].Racers = {}
                    Tracks[CurrentRace].Started = false
                    Tracks[CurrentRace].Waiting = false
                    table.remove(AvailableRaces, PreviousRaceKey)
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("primary.race_last_person"))
                    TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Tracks[CurrentRace])
                else
                    AvailableRaces[PreviousRaceKey].RaceData = Tracks[CurrentRace]
                    TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Tracks[CurrentRace])
                end
            end

            local AmountOfRacers = 0
            for _,_ in pairs(Tracks[RaceId].Racers) do
                AmountOfRacers = AmountOfRacers + 1
            end
            if AmountOfRacers == 0 and not Tracks[RaceId].Automated then
                if useDebug then print('setting creator') end
                Tracks[RaceId].OrganizerCID = Player.PlayerData.citizenid
            end
            if RaceData.BuyIn > 0 then
                if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
                    exports['qb-phone']:RemoveCrypto(src, Config.Options.cryptoType, math.floor(RaceData.BuyIn))
                    TriggerClientEvent('QBCore:Notify', source, Lang:t("success.remove_crypto").. math.floor(RaceData.BuyIn).. ' '.. Config.Options.cryptoType, 'success')
                else
                    Player.Functions.RemoveMoney(Config.Options.MoneyType, RaceData.BuyIn, "Bought into Race")
                end
            end

            Tracks[RaceId].Waiting = true
            Tracks[RaceId].MaxClass = RaceData.MaxClass
            Tracks[RaceId].Ghosting = RaceData.Ghosting
            Tracks[RaceId].BuyIn = RaceData.BuyIn
            Tracks[RaceId].Ranked = RaceData.Ranked
            Tracks[RaceId].ParticipationAmount = tonumber(RaceData.ParticipationAmount)
            Tracks[RaceId].ParticipationCurrency = RaceData.ParticipationCurrency
            Tracks[RaceId].GhostingTime = RaceData.GhostingTime
            Tracks[RaceId].Racers[Player.PlayerData.citizenid] = {
                Checkpoint = 1,
                Lap = 1,
                Finished = false,
                RacerName = RacerName,
                RacerCrew = RacerCrew,
                Placement = 0,
                PlayerVehicleEntity = PlayerVehicleEntity,
                RacerSource = src
            }
            AvailableRaces[AvailableKey].RaceData = Tracks[RaceId]
            TriggerClientEvent('cw-racingapp:client:JoinRace', src, Tracks[RaceId], RaceData.Laps, RacerName)
            for cid, racer in pairs(Tracks[RaceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:UpdateRaceRacers', racer.RacerSource, RaceId, Tracks[RaceId].Racers)
            end
            if not Tracks[RaceId].Automated then
                local creatorsource = QBCore.Functions.GetPlayerByCitizenId(AvailableRaces[AvailableKey].SetupCitizenId).PlayerData.source
                if creatorsource ~= Player.PlayerData.source then
                    TriggerClientEvent('QBCore:Notify', creatorsource, Lang:t("primary.race_someone_joined"))
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.race_already_started"))
    end
end)

local function assignNewOrganizer(RaceId, src)
    for i,v in pairs(Tracks[RaceId].Racers) do
        if i ~= QBCore.Functions.GetPlayer(src).PlayerData.citizenid then
            Tracks[RaceId].OrganizerCID = i
            TriggerClientEvent('QBCore:Notify', v.RacerSource, Lang:t("text.new_host"))
            for cid, racer in pairs(Tracks[RaceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:UpdateOrganizer', racer.RacerSource, RaceId, i)
            end
            return
        end
    end
end

RegisterNetEvent('cw-racingapp:server:LeaveRace', function(RaceData)
    if useDebug then print('Player left race', source) end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local RacerName = RaceData.RacerName
    local RaceName = RaceData.RaceName
    if RaceData.RaceData then
        RaceName = RaceData.RaceData.RaceName
    end

    local RaceId = GetRaceId(RaceName)
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    
    if not Tracks[RaceData.RaceId].Automated then
        local creator = QBCore.Functions.GetPlayerByCitizenId(AvailableRaces[AvailableKey].SetupCitizenId)
        local creatorsource = nil
    
        if creator.PlayerData then
            local creatorsource = creator.PlayerData.source
        end
    
        if creatorsource and creatorsource ~= Player.PlayerData.source then
            TriggerClientEvent('QBCore:Notify', creatorsource, Lang:t("primary.race_someone_left"))
        end 
    end

    local AmountOfRacers = 0
    for k, v in pairs(Tracks[RaceData.RaceId].Racers) do
        AmountOfRacers = AmountOfRacers + 1
    end
    if NotFinished[RaceData.RaceId] ~= nil then
        NotFinished[RaceData.RaceId][#NotFinished[RaceData.RaceId]+1] = {
            TotalTime = "DNF",
            BestLap = "DNF",
            Holder = RacerName
        }
    else
        NotFinished[RaceData.RaceId] = {}
        NotFinished[RaceData.RaceId][#NotFinished[RaceData.RaceId]+1] = {
            TotalTime = "DNF",
            BestLap = "DNF",
            Holder = RacerName
        }
    end
    Tracks[RaceId].Racers[Player.PlayerData.citizenid] = nil
    if Tracks[RaceId].OrganizerCID == QBCore.Functions.GetPlayer(src).PlayerData.citizenid then
        assignNewOrganizer(RaceId, src)
    end
    if (AmountOfRacers - 1) == 0 then
        if not Tracks[RaceData.RaceId].Automated then
            if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[RaceId] ~= nil and next(NotFinished[RaceId]) ~=
                nil then
                for k, v in pairs(NotFinished[RaceId]) do
                    if LastRaces[RaceId] ~= nil then
                        LastRaces[RaceId][#LastRaces[RaceId]+1] = {
                            TotalTime = v.TotalTime,
                            BestLap = v.BestLap,
                            Holder = v.Holder
                        }
                    else
                        LastRaces[RaceId] = {}
                        LastRaces[RaceId][#LastRaces[RaceId]+1] = {
                            TotalTime = v.TotalTime,
                            BestLap = v.BestLap,
                            Holder = v.Holder
                        }
                    end
                end
            end
            Tracks[RaceId].LastLeaderboard = LastRaces[RaceId]
            Tracks[RaceId].Racers = {}
            Tracks[RaceId].Started = false
            Tracks[RaceId].Waiting = false
            table.remove(AvailableRaces, AvailableKey)
            TriggerClientEvent('QBCore:Notify', src, Lang:t("primary.race_last_person"))
            LastRaces[RaceId] = nil
            NotFinished[RaceId] = nil
        end
    else
        AvailableRaces[AvailableKey].RaceData = Tracks[RaceId]
    end
    TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Tracks[RaceId])
    for cid, racer in pairs(Tracks[RaceId].Racers) do
        TriggerClientEvent('cw-racingapp:client:UpdateRaceRacers', racer.RacerSource, RaceId, Tracks[RaceId].Racers)
    end
end)

local function setupRace(RaceId, Laps, RacerName, MaxClass, GhostingEnabled, GhostingTime, BuyIn, Ranked, ParticipationAmount, ParticipationCurrency, Automated, src)
    if useDebug then 
        print('Setting up race', json.encode({
            RaceId= RaceId, Laps= Laps, RacerName=RacerName, MaxClass = MaxClass, GhostingEnabled=GhostingEnabled, GhostingTime=GhostingTime, BuyIn=BuyIn, Automated=Automated, Ranked=Ranked, ParticipationAmount=ParticipationAmount, ParticipationCurrency=ParticipationCurrency
        }))
    end 
    if Tracks[RaceId] ~= nil then
        if not Tracks[RaceId].Waiting then            
            if not Tracks[RaceId].Started then
                local Player = QBCore.Functions.GetPlayer(src)
                local setupId = 0
                if src then 
                    setupId = Player.PlayerData.citizenid
                end
                Tracks[RaceId].Waiting = true
                Tracks[RaceId].Automated = Automated
                Tracks[RaceId].NumStarted = Tracks[RaceId].NumStarted + 1
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
                    ParticipationAmount = ParticipationAmount,
                    ParticipationCurrency = ParticipationCurrency,
                    ExpirationTime = os.date("%c", os.time()+60*Config.TimeOutTimerInMinutes),
                }
                AvailableRaces[#AvailableRaces+1] = allRaceData
                if not Automated then
                    TriggerClientEvent('QBCore:Notify', src,  Lang:t("success.race_created"), 'success')
                    TriggerClientEvent('cw-racingapp:client:ReadyJoinRace', src, allRaceData)
                end
                RaceResults[RaceId] = { Data = allRaceData, Result = {}}
                if Config.NotifyRacers then TriggerClientEvent('cw-racingapp:client:notifyRacers', -1, 'New Race Available') end
                CreateThread(function()
                    local count = 0
                    while Tracks[RaceId].Waiting do
                        Wait(1000)
                        if count < Config.TimeOutTimerInMinutes * 60 then
                            count = count + 1
                        else
                            local AvailableKey = GetOpenedRaceKey(RaceId)
                            if Tracks[RaceId].Automated then
                                if useDebug then print('Track Timed Out. Automated') end
                                local amountOfRacers = getAmountOfRacers(RaceId)
                                if amountOfRacers > Config.AutomatedOptions.minimumParticipants -1 then
                                    if useDebug then print('Enough Racers to start automated') end
                                    TriggerEvent('cw-racingapp:server:StartRace', RaceId)
                                else
                                    if useDebug then print('NOT Enough Racers to start automated') end
                                    if amountOfRacers > 0 then
                                        for cid, _ in pairs(Tracks[RaceId].Racers) do
                                            local RacerData = QBCore.Functions.GetPlayerByCitizenId(cid)
                                            if RacerData ~= nil then
                                                TriggerClientEvent('QBCore:Notify', RacerData.PlayerData.source, Lang:t("error.race_timed_out"), 'error')
                                                TriggerClientEvent('cw-racingapp:client:LeaveRace', RacerData.PlayerData.source, Tracks[RaceId])
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
                                if useDebug then print('Track Timed Out. NOT automated') end
                                for cid, _ in pairs(Tracks[RaceId].Racers) do
                                    local RacerData = QBCore.Functions.GetPlayerByCitizenId(cid)
                                    if RacerData ~= nil then
                                        TriggerClientEvent('QBCore:Notify', RacerData.PlayerData.source, Lang:t("error.race_timed_out"), 'error')
                                        TriggerClientEvent('cw-racingapp:client:LeaveRace', RacerData.PlayerData.source, Tracks[RaceId])
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
            else
                TriggerClientEvent('QBCore:Notify', src, Lang:t("error.race_already_started"), 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.race_already_started"), 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.race_doesnt_exist"), 'error')
    end

end

RegisterNetEvent('cw-racingapp:server:SetupRace', function(RaceId, Laps, RacerName, MaxClass, GhostingEnabled, GhostingTime, BuyIn, Ranked, ParticipationAmount, ParticipationCurrency)
    local src = source
    if not Automated and isToFarAway(src, RaceId) then
        TriggerClientEvent('cw-racingapp:client:NotCloseEnough', src, Tracks[RaceId].Checkpoints[1].coords.x, Tracks[RaceId].Checkpoints[1].coords.y)
        return
    end
    if not Automated and (BuyIn > 0 and not hasEnoughMoney(src, BuyIn)) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_enough_money"))
    else
        setupRace(RaceId, Laps, RacerName, MaxClass, GhostingEnabled, GhostingTime, BuyIn, Ranked, ParticipationAmount, ParticipationCurrency, false, src)
    end
end)

-- AUTOMATED RACES SETUP

local function GenerateAutomatedRace()
    local race = Config.AutomatedRaces[math.random(1, #Config.AutomatedRaces)]
    if race == nil or race.trackId == nil then
        if useDebug then print('Race Id for generated track was nil, your Config might be incorrect') end
        return  
    end
    if Tracks[race.trackId] == nil then
        if useDebug then print('ID'.. race.trackId..' does not exist in tracks list') end
        return
    end
    if Tracks[race.trackId].Waiting then
        if useDebug then print('Automation: RaceId is already active') end
        return
    end
    if useDebug then print('Creating new Automated Race from', race.trackId) end
    local ranked = race.ranked
    if ranked == nil then
        if useDebug then print('Automation: rank was not set. defaulting to ranked = true') end
        ranked = true
    end
    setupRace(race.trackId, race.laps, race.racerName, race.maxClass, race.ghostingEnabled, race.ghostingTime, race.buyIn, ranked, race.participationMoney, race.ParticipationCurrency, true, nil)
end

if Config.AutomatedOptions and Config.AutomatedRaces then 
    CreateThread(function()
        if #Config.AutomatedRaces == 0 then if useDebug then print('^3No automated races in list') end return end
        while true do
            if not useDebug then Wait(Config.AutomatedOptions.timeBetweenRaces) else Wait(1000) end
            GenerateAutomatedRace()
            Wait(Config.AutomatedOptions.timeBetweenRaces)
        end
    end)
end

RegisterNetEvent('cw-racingapp:server:UpdateRaceState', function(RaceId, Started, Waiting)
    Tracks[RaceId].Waiting = Waiting
    Tracks[RaceId].Started = Started
end)

local Timers = {}

local function timer(raceId)
    local NumStartedAtTimerCreation = Tracks[raceId].NumStarted
    if useDebug then print('============== Creating timer for '..raceId..' with numstarted: '..NumStartedAtTimerCreation.. ' ==============') end
    SetTimeout(Config.RaceResetTimer, function()
        if useDebug then print('============== Checking timer for '..raceId..' ==============') end
        if NumStartedAtTimerCreation ~= Tracks[raceId].NumStarted then 
            if useDebug then print('============== A new race has been created on this track. Canceling '..raceId..' ==============') end
            return
        end
        if next(Tracks[raceId].Racers) == nil then
            if useDebug then print('Race is finished. Canceling timer '..raceId..'') end
            return
        end
        if math.abs(GetGameTimer() - Timers[raceId]) < Config.RaceResetTimer then
            Timers[raceId] = GetGameTimer()
            timer(raceId)
        else
            if useDebug then print('Cleaning up race '..raceId) end
            if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[raceId] ~= nil and next(NotFinished[raceId]) ~= nil then
                for k, v in pairs(NotFinished[raceId]) do
                    if LastRaces[raceId] ~= nil then
                        LastRaces[raceId][#LastRaces[raceId]+1] = {
                            TotalTime = v.TotalTime,
                            BestLap = v.BestLap,
                            Holder = v.Holder
                        }
                    else
                        LastRaces[raceId] = {}
                        LastRaces[raceId][#LastRaces[raceId]+1] = {
                            TotalTime = v.TotalTime,
                            BestLap = v.BestLap,
                            Holder = v.Holder
                        }
                    end
                end
            end
            for i,racer in pairs(Tracks[raceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:LeaveRace', racer.RacerSource, Tracks[raceId] )
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
    if useDebug then print('Starting timer', raceId) end
    Timers[raceId] = GetGameTimer()
    timer(raceId)
end

local function updateTimer(raceId)
    if useDebug then print('Updating timer', raceId) end
    Timers[raceId] = GetGameTimer()
end

RegisterNetEvent('cw-racingapp:server:UpdateRacerData', function(RaceId, Checkpoint, Lap, Finished, RaceTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local CitizenId = Player.PlayerData.citizenid
    if Tracks[RaceId].Racers[CitizenId] then
        Tracks[RaceId].Racers[CitizenId].Checkpoint = Checkpoint
        Tracks[RaceId].Racers[CitizenId].Lap = Lap
        Tracks[RaceId].Racers[CitizenId].Finished = Finished
        Tracks[RaceId].Racers[CitizenId].RaceTime = RaceTime
        for cid, racer in pairs(Tracks[RaceId].Racers) do
            TriggerClientEvent('cw-racingapp:client:UpdateRaceRacerData', racer.RacerSource, RaceId, Tracks[RaceId])
        end
    else
        -- Attemt to make sure script dont break if something goes wrong
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.youre_not_in_the_race"), 'error')
        TriggerClientEvent('cw-racingapp:client:LeaveRace', -1, nil)
    end
    if Config.UseResetTimer then updateTimer(RaceId) end
end)

RegisterNetEvent('cw-racingapp:server:StartRace', function(RaceId)
    local src = source
    local AvailableKey = GetOpenedRaceKey(RaceId)

    if not RaceId then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_in_race"), 'error')
        return
    end

    if AvailableRaces[AvailableKey].RaceData.Started then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.race_already_started"), 'error')
        return
    end

    AvailableRaces[AvailableKey].RaceData.Started = true
    AvailableRaces[AvailableKey].RaceData.Waiting = false
    local TotalRacers = 0
    for Index, Value in pairs(Tracks[RaceId].Racers) do
        TotalRacers = TotalRacers + 1
    end
    for CitizenId, _ in pairs(Tracks[RaceId].Racers) do
        local Player = QBCore.Functions.GetPlayerByCitizenId(CitizenId)
        if Player ~= nil then
            TriggerClientEvent('cw-racingapp:client:RaceCountdown', Player.PlayerData.source,TotalRacers)
        end
    end
    if Config.UseResetTimer then startTimer(RaceId) end
end)

RegisterNetEvent('cw-racingapp:server:SaveRace', function(RaceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local RaceId = ''
    if RaceData.RaceId ~= nil then
        RaceId = RaceData.RaceId
    else
        RaceId = GenerateRaceId()
    end
    local Checkpoints = {}
    for k, v in pairs(RaceData.Checkpoints) do
        Checkpoints[k] = {
            offset = v.offset,
            coords = v.coords
        }
    end

    if RaceData.IsEdit then
        print('Saving over previous track', RaceData.RaceId)
        MySQL.query('UPDATE race_tracks SET checkpoints = ? WHERE raceid = ?', { json.encode(Checkpoints), RaceData.RaceId})
        Tracks[RaceId].Checkpoints = Checkpoints
    else
        Tracks[RaceId] = {
            RaceName = RaceData.RaceName,
            Checkpoints = Checkpoints,
            Records = {},
            Creator = Player.PlayerData.citizenid,
            CreatorName = RaceData.RacerName,
            RaceId = RaceId,
            Started = false,
            Waiting = false,
            Distance = math.ceil(RaceData.RaceDistance),
            Racers = {},
            Access = {},
            LastLeaderboard = {},
            NumStarted = 0,
        }
        MySQL.Async.insert('INSERT INTO race_tracks (name, checkpoints, creatorid, creatorname, distance, raceid, curated) VALUES (?, ?, ?, ?, ?, ?, ?)',
            {RaceData.RaceName, json.encode(Checkpoints), Player.PlayerData.citizenid, RaceData.RacerName, RaceData.RaceDistance, RaceId, 0})
    end
end)

RegisterNetEvent('cw-racingapp:server:DeleteTrack', function(RaceId)
    print('DELETING ', RaceId)
    Tracks[RaceId] = nil
    local result = MySQL.Sync.fetchAll('SELECT creatorname FROM race_tracks WHERE raceid = ?', {RaceId})[1]
    MySQL.query('DELETE FROM race_tracks WHERE raceid = ?', {RaceId} )
end)

RegisterNetEvent('cw-racingapp:server:ClearLeaderboard', function(RaceId)
    print('CLEARING LEADERBOARD ', RaceId)
    Tracks[RaceId].Records = nil
    MySQL.query('UPDATE race_tracks SET records = NULL WHERE raceid = ?',
    {RaceId})
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:getplayers', function(_, cb)
    local players = QBCore.Functions.GetPlayers()
    if useDebug then
        print(json.encode(players))
    end
    local playerIds = {}
    for index, player in pairs(players) do
        if useDebug then
            local name = GetPlayerName(player)
            print('adding', name, ' to list')
        end
        local playerData = QBCore.Functions.GetPlayer(tonumber(player)).PlayerData
        playerIds[#playerIds+1] = {
            citizenid = playerData.citizenid,
            name = playerData.name,
            sourceplayer = player,
            id = player
        }
    end
    cb(playerIds)
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:getRaceResults', function(_, cb)
    cb(RaceResults)
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:getAllRacers', function(_, cb)
    if useDebug then print('Fetching all racers') end
    local allRacers = getAllRacerNames()
    if useDebug then print("^2Result", json.encode(allRacers)) end
    cb(allRacers)
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
        minutes = "0"..tostring(minutes);
    else
        minutes = tostring(minutes)
    end
    if seconds < 10 then
        seconds = "0"..tostring(seconds);
    else
        seconds = tostring(seconds)
    end
    return minutes..":"..seconds.."."..milliseconds;
end

function IsPermissioned(CitizenId, type)
    local Player = QBCore.Functions.GetPlayerByCitizenId(CitizenId)
    local playerAuth = Player.PlayerData.metadata.selectedRacerAuth
    return Config.Permissions[playerAuth][type]
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

function HasOpenedRace(CitizenId)
    local retval = false
    for k, v in pairs(AvailableRaces) do
        if v.SetupCitizenId == CitizenId then
            retval = true
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
    local retval = nil
    for k, v in pairs(Tracks) do
        if v.RaceName == name then
            retval = k
            break
        end
    end
    return retval
end

function GenerateRaceId()
    local RaceId = "LR-" .. math.random(1111, 9999)
    while Tracks[RaceId] ~= nil do
        RaceId = "LR-" .. math.random(1111, 9999)
    end
    return RaceId
end

local function UseRacingGps(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent('cw-racingapp:client:openUi', source, {name = Player.PlayerData.metadata.selectedRacerName, type = Player.PlayerData.metadata.selectedRacerAuth, crew = Player.PlayerData.metadata.selectedCrew })
end

QBCore.Functions.CreateCallback('cw-racingapp:server:GetRacingLeaderboards', function(source, cb, class, trackName)
    local Leaderboard = {}
    Leaderboard[trackName] = getLatestRecordsByName(trackName)
    if useDebug then
       print(class, trackName, dump(Leaderboard[trackName]))
    end
    if Leaderboard[trackName] then
        if class == 'all' then
            cb(sortRecordsByTime(Leaderboard[trackName]))
        else
            cb(filterLeaderboardsByClass(Leaderboard[trackName], class))
        end
    end
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetRaces', function(source, cb)
    cb(AvailableRaces)
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetRacers', function(source, cb, RaceId)
    cb(Tracks[RaceId].Racers)
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetListedRaces', function(source, cb)
    cb(Tracks)
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetRacingData', function(source, cb, RaceId)
    cb(Tracks[RaceId])
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetTracks', function(source, cb)
    if useDebug then print('Getting all tracks') end
    cb(Tracks)
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetTrackData', function(source, cb, RaceId)
    if Tracks[RaceId] then
        cb(Tracks[RaceId])
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetAccess', function(source, cb, raceId)
    local res = MySQL.Sync.fetchAll('SELECT access FROM race_tracks WHERE raceid = ?', {raceId})
    if res then
        if res[1] then
            cb(json.decode(res[1].access))
        else
            cb('NOTHING')
        end
    end
end)

RegisterNetEvent('cw-racingapp:server:SetAccess', function(raceId, access)
    local src = source
    if useDebug then
        print('source ', src, 'has updated access for', raceId)
        print(json.encode(access))
    end
    local res = MySQL.Sync.execute('UPDATE race_tracks SET access = ? WHERE raceid = ?', {json.encode(access), raceId})
    if res then
        if res == 1 then
            TriggerClientEvent('QBCore:Notify', src, Lang:t('success.access_updated'), "success")
        end
        Tracks[raceId].Access = access
    end
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:HasCreatedRace', function(source, cb)
    cb(HasOpenedRace(QBCore.Functions.GetPlayer(source).PlayerData.citizenid))
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:IsAuthorizedToCreateRaces', function(source, cb, TrackName)
    cb(IsPermissioned(QBCore.Functions.GetPlayer(source).PlayerData.citizenid, 'create'), IsNameAvailable(TrackName))
end)

local function nameIsValid(racerName, citizenId)
    local result = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', {racerName})[1]
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
    if not MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ? AND citizenid = ?', {racerName, citizenId})[1] then
        MySQL.Async.insert('INSERT INTO racer_names (citizenid, racername, auth, createdby) VALUES (?, ?, ?, ?)',
        {citizenId, racerName, auth, creatorCitizenId})
    end
    TriggerClientEvent('cw-racingapp:Client:UpdateRacerNames', tonumber(targetSource))
end

QBCore.Functions.CreateCallback('cw-racingapp:server:GetAmountOfTracks', function(source, cb, citizenid)
    if Config.UseNameValidation then
        local tracks = MySQL.Sync.fetchAll('SELECT name FROM race_tracks WHERE creatorid = ?', {citizenid})
        cb(#tracks)
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:NameIsAvailable', function(source, cb, racerName, serverId)
    if Config.UseNameValidation then
        local Player = QBCore.Functions.GetPlayer(tonumber(serverId))
        local citizenId = Player.PlayerData.citizenid
        if nameIsValid(racerName, citizenId) then
            cb(true)
        else
            cb(false)
        end
    else
        cb(true)
    end
end)


QBCore.Functions.CreateCallback('cw-racingapp:server:GetRacerNamesByPlayer', function(source, cb, serverId)
    if useDebug then print('Getting racer names for serverid', serverId) end
    local Player = QBCore.Functions.GetPlayer(tonumber(serverId))
    local citizenId = Player.PlayerData.citizenid
    if useDebug then print('Racer citizenid', citizenId) end
    local result = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE citizenid = ?', {citizenId})
    if useDebug then print('Racer Names found:', json.encode(result)) end
    cb(result)
end)

local function createRacingName(source, citizenid, racerName, type, purchaseType, targetSource)
    if useDebug then
        print('Creating a racing fob. Input:')
        print('citizenid', citizenid)
        print('racerName', racerName)
        print('type', type)
        print('purchaseType', dump(purchaseType))
    end

    local Player = QBCore.Functions.GetPlayer(source)
    local cost = 1000
    if purchaseType and purchaseType.racingUserCosts and purchaseType.racingUserCosts[type] then
        cost = purchaseType.racingUserCosts[type]
    else
        TriggerClientEvent('QBCore:Notify', source, 'The user type you entered does not exist, defaulting to $1000', 'error' )
    end

    if purchaseType.moneyType == 'crypto' and Config.UseRenewedCrypto then
        if exports['qb-phone']:hasEnough(source, Config.Options.cryptoType, math.floor(cost)) then
            exports['qb-phone']:RemoveCrypto(source, Config.Options.cryptoType, math.floor(cost))
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.remove_crypto").. math.floor(cost).. ' '.. Config.Options.cryptoType, 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.can_not_afford").. math.floor(cost).. ' '.. Config.Options.cryptoType, 'error')
            return
        end
    else
        if not Player.Functions.RemoveMoney(purchaseType.moneyType, cost, "Created Fob: "..type) then
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.can_not_afford")..' $'.. math.floor(cost), 'error')
            return
        end
    end
    if Config.UseRenewedBanking and purchaseType.profiteer and cost > 0 then
        local profit = math.floor(cost * purchaseType.profiteer.cut)
        exports['Renewed-Banking']:addAccountMoney(purchaseType.profiteer.job, profit)
        exports['Renewed-Banking']:handleTransaction(purchaseType.profiteer.job, "Racing GPS", profit, "Type: "..type,  "Unknown", QBCore.Shared.Jobs[purchaseType.profiteer.job].label , "deposit")
    end
    local creatorCitizenId = 'unknown'
    if Player.PlayerData and Player.PlayerData.citizenid then creatorCitizenId = Player.PlayerData.citizenid end
    addRacerName(citizenid, racerName, targetSource, type, creatorCitizenId)
end

local function getRacersCreatedByUser(src, citizenid, type)
    if Config.Permissions[type] and Config.Permissions[type].controlAll then
       if useDebug then  print('Fetching racers for a god') end
        return MySQL.Sync.fetchAll('SELECT * FROM racer_names')
    end
    if useDebug then  print('Fetching racers for a master') end
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE createdby = ?', {citizenid})
end

QBCore.Functions.CreateCallback('cw-racingapp:server:GetRacersCreatedByUser', function(source, cb, citizenid, type)
    print('Fetching all racers created by ', citizenid)
    local result = getRacersCreatedByUser(source, citizenid, type)
    if useDebug then print('result from fetching racers created by user', citizenid, json.encode(result)) end
    cb(result)
end)

local function changeRacerName(src, racerName)
    local auth = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', {racerName})[1].auth
    local Player = QBCore.Functions.GetPlayer(src)
    if auth then
        Player.Functions.SetMetaData("selectedRacerAuth", auth)
    else
        Player.Functions.SetMetaData("selectedRacerAuth", 'racer')
    end
    Player.Functions.SetMetaData("selectedRacerName", racerName)
    Player.Functions.SetMetaData("selectedCrew", nil)
end

local function getRankingForRacer(src, racername)
    if useDebug then print('Fetching ranking for racer', racername) end
    local res = MySQL.Sync.fetchAll('SELECT ranking FROM racer_names WHERE racername = ?', {racername})
    if res and res[1] then
        return res[1].ranking
    end
    return 0
end

QBCore.Functions.CreateCallback('cw-racingapp:server:ChangeRacerName', function(source, cb, racerNameInUse)
    if useDebug then print('Changing Racer Name for (1) src to (2) name', source, racerNameInUse) end
    changeRacerName(source, racerNameInUse)
    local Player = QBCore.Functions.GetPlayer(source)
    if useDebug then
       print('New names', Player.PlayerData.metadata.selectedRacerName, Player.PlayerData.metadata.selectedRacerAuth )
    end
    local ranking = getRankingForRacer(source, racerNameInUse)
    if useDebug then print('Ranking:', json.encode(ranking)) end
    cb({ name = Player.PlayerData.metadata.selectedRacerName, type = Player.PlayerData.metadata.selectedRacerAuth, ranking = ranking })
end)

RegisterNetEvent('cw-racingapp:server:RemoveRacerName', function(racername)
    if useDebug then print('removing racer with name', racername) end
    if useDebug then print('removed by source', source, QBCore.Functions.GetPlayer(source).PlayerData.citizenid) end
    local res = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', {racername})[1]
    MySQL.query('DELETE FROM racer_names WHERE racername = ?', {racername} )
    Wait(1000)
    local Player = QBCore.Functions.GetPlayerByCitizenId(res.citizenid)
    if Player ~= nil then
        if useDebug then
            print('pinging player', Player.PlayerData.source)
        end
        TriggerClientEvent('cw-racingapp:Client:UpdateRacerNames', tonumber(Player.PlayerData.source))
    end
end)

local function setRevokedRacerName(src, racerName, revoked)
    local res = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', {racerName})[1]
    if res then
        MySQL.Async.execute('UPDATE racer_names SET revoked = ? WHERE racername = ?', { tonumber(revoked), racerName})
        local readableRevoked = 'revoked'
        if revoked == 0 then readableRevoked = 'active' end
        TriggerClientEvent('QBCore:Notify', src, 'User is now set to '..readableRevoked, 'success')
        if useDebug then print('Revoking for citizenid', res.citizenid) end
        local Player = QBCore.Functions.GetPlayerByCitizenId(res.citizenid)
        if Player ~= nil then
            if useDebug then
                print('pinging player', Player.PlayerData.source)
            end
            TriggerClientEvent('cw-racingapp:Client:UpdateRacerNames', tonumber(Player.PlayerData.source))
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Race Name Not Found', 'error')
    end
end

RegisterNetEvent('cw-racingapp:server:SetRevokedRacenameStatus', function(racername, revoked)
    if useDebug then print('revoking racename', racername, revoked) end
    setRevokedRacerName(source, racername, revoked)
end)

RegisterNetEvent('cw-racingapp:server:CreateRacerName', function(playerId, racerName, type, purchaseType)
    if useDebug then print(
        'Creating a user',
        json.encode({ playerId = playerId, racerName = racerName, type = type, purchaseType = purchaseType})
    ) end
    local player = QBCore.Functions.GetPlayer(tonumber(playerId))
    if player then
        local citizenId = player.PlayerData.citizenid
        createRacingName(source, citizenId, racerName, type, purchaseType, playerId)
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.could_not_find_person"), "error")
    end
end)

QBCore.Commands.Add('createracinguser',"Create a racing user", { 
    {name='type', help='racer/creator/master/god'},
    {name='identifier', help='Server ID'},
    {name='Racer Name', help='Racer name. Put in quotations if multiple words'}
}, true, function(source, args)
    local type = args[1]
    local id = args[2]
    print(
        'Creating a user',
            json.encode({ playerId = args[2], racerName = args[3], type = args[1]})
        ) 
    print('^3 If this looks like the wrong variables, your Core might be doing funky things. Just try to match the spots accordingly')    
    if args[4] then
        print('^1Too many args!')
        TriggerClientEvent('QBCore:Notify', source, "Too many arguments. You probably did not read the command input suggestions.", "error")
        return
    end

    local name = {}
    for i = 3, #args do
        name[#name+1] = args[i]
    end
    name = table.concat(name, ' ')

    if not Config.Permissions[type:lower()] then
        TriggerClientEvent('QBCore:Notify', source, "This user type does not exist", "error")
        return
    end

    local citizenid
    if tonumber(id) then
        local Player = QBCore.Functions.GetPlayer(tonumber(id))
        if Player then
            citizenid = Player.PlayerData.citizenid
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.id_not_found"), "error")
            return
        end
    else
        citizenid = id
    end

    if #name >= Config.MaxRacerNameLength then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.name_too_short"), "error")
        return
    end

    if #name <= Config.MinRacerNameLength then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.name_too_long"), "error")
        return
    end

    local tradeType = {
        moneyType = 'cash',
        racingUserCosts = {
            racer = 0,
            creator = 0,
            master = 0,
            god = 0
        },
    }

    createRacingName(source, citizenid, name, type:lower(), tradeType, id)
end, 'dev')

QBCore.Commands.Add('remracename', 'Remove Racing Name From Database', { {name='name', help='Racer name. Put in quotations if multiple words'} }, true, function(source, args)
    local name = args[1]
    print('name of racer to delete:', name)
    MySQL.query('DELETE FROM racer_names WHERE racername = ?', {name} )
end, 'dev')

QBCore.Functions.CreateUseableItem(Config.ItemName.gps, function(source, item)
    UseRacingGps(source, item)
end)

local function dropRacetrackTable()
    MySQL.query('DROP TABLE IF EXISTS race_tracks')
end

QBCore.Commands.Add('removeallracetracks', 'Remove the race_tracks table', {}, true, function(source, args)
    dropRacetrackTable()
end, 'admin')

QBCore.Commands.Add('racingappcurated', 'Mark/Unmark track as curated', { {name='trackid', help='Track ID (not name). Use quotation marks!!!'}, {name='curated', help='true/false'}  }, true, function(source, args)
    print('Curating track: ', args[1], args[2])
    local curated = 0
    if args[2] == 'true' then
        curated = 1
    end
    local res = MySQL.Sync.execute('UPDATE race_tracks SET curated = ? WHERE raceid = ?', {curated, args[1]})
    if res == 1 then
        Tracks[args[1]].Curated = curated
        TriggerClientEvent('QBCore:Notify', source, 'Successfully set track curated as '..args[2])
    else
        TriggerClientEvent('QBCore:Notify', source, 'Your input seems to be lacking...')
    end
end, 'admin')

QBCore.Commands.Add('cwdebugracing', 'toggle debug for racing', {}, true, function(source, args)
    useDebug = not useDebug
    print('debug is now:', useDebug)
    TriggerClientEvent('cw-racingapp:client:toggleDebug',source, useDebug)
end, 'admin')