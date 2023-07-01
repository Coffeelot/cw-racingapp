-----------------------
----   Variables   ----
-----------------------
local QBCore = exports['qb-core']:GetCoreObject()
local Races = {}
local AvailableRaces = {}
local LastRaces = {}
local NotFinished = {}
local racersSortedByPosition = {}
local useDebug = Config.Debug

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
            Races[v.raceid] = {
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
                Access = json.decode(v.access)
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

local function newRecord(src, RacerName, PlayerTime, RaceData, CarClass, VehicleModel)
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
            Vehicle = VehicleModel
        }
        records[index] = playerPlacement
        records = sortRecordsByTime(records)
        if useDebug then print('records being sent to db', dump(records)) end
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
            Vehicle = VehicleModel
        }
        if useDebug then
           print('records', dump(records))
        end
        table.insert(records, playerPlacement)
        records = sortRecordsByTime(records)
        if useDebug then
           print('new records', dump(records))
        end
        MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
            {json.encode(records), RaceData.RaceId})
        return true
    end

    return false
end

local function giveSplit(src, racers, position, pot)
    local total = 0
    if racers == 2 and position == 1 then
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
            exports['qb-phone']:AddCrypto(src, Config.Options.CryptoType, math.floor(total))
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.participation_trophy_crypto").. math.floor(total).. ' '.. Config.Options.CryptoType, 'success')
        else
            Player.Functions.AddMoney(Config.Options.MoneyType, math.floor(total))
        end
    end
end

local function handOutParticipationTrophy(src, position)
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.ParticpationTrophies.amount[position] then
        if Config.ParticpationTrophies.type == 'crypto' and Config.UseRenewedCrypto then
            exports['qb-phone']:AddCrypto(src, Config.ParticpationTrophies.cryptoType, Config.ParticpationTrophies.amount[position])
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.participation_trophy_crypto")..Config.ParticpationTrophies.amount[position].. ' '.. Config.ParticpationTrophies.cryptoType, 'success')
        else
            Player.Functions.AddMoney(Config.ParticpationTrophies.type, Config.ParticpationTrophies.amount[position])
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.participation_trophy")..Config.ParticpationTrophies.amount[position], 'success')
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

-----------------------
---- Server Events ----
-----------------------
RegisterNetEvent('cw-racingapp:server:FinishPlayer', function(RaceData, TotalTime, TotalLaps, BestLap, CarClass, VehicleModel)
    local src = source
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local RacerName = RaceData.RacerName
    local PlayersFinished = 0
    local AmountOfRacers = 0


    for k, v in pairs(Races[RaceData.RaceId].Racers) do
        if v.Finished then
            PlayersFinished = PlayersFinished + 1
        end
        AmountOfRacers = AmountOfRacers + 1
    end
    print('Racers', AmountOfRacers)
    if AmountOfRacers > 1 then
        updateRacerNameLastRaced(RacerName, PlayersFinished)
    end
    if useDebug then
        print('Total: ', TotalTime)
        print('Best Lap: ', BestLap)
        print('Place:', PlayersFinished, Races[RaceData.RaceId].BuyIn)
    end
    if PlayersFinished == 1 or PlayersFinished == 2 or PlayersFinished == 3 and Races[RaceData.RaceId].BuyIn > 0 then
        local distance = Races[RaceData.RaceId].Distance
        if TotalLaps > 1 then
            distance = distance*TotalLaps
        end
        if distance > Config.ParticpationTrophies.minumumRaceLength then
            giveSplit(src, AmountOfRacers, PlayersFinished, Races[RaceData.RaceId].BuyIn)
        else
            if useDebug then print('Race length was to short: ', distance,' Minumum required:', Config.ParticpationTrophies.minumumRaceLength) end
        end
    end

    if Config.ParticpationTrophies.enabled and Config.ParticpationTrophies.minimumOfRacers <= AmountOfRacers then
        if useDebug then print('Participation Trophies are enabled. Handing out to', src) end
        handOutParticipationTrophy(src, PlayersFinished)
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

    if Races[RaceData.RaceId].Records ~= nil and next(Races[RaceData.RaceId].Records) ~= nil then
        local newRecord = newRecord(src, RacerName, BLap, RaceData, CarClass, VehicleModel)
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
        Races[RaceData.RaceId].Records = {
            Time = BLap,
            Holder = RacerName,
            Class = CarClass,
            Vehicle = VehicleModel
        }
        MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
            {json.encode({ Races[RaceData.RaceId].Records }), RaceData.RaceId})
            TriggerClientEvent('QBCore:Notify', src, string.format(Lang:t("success.race_record"), RaceData.RaceName, MilliToTime(BLap)), 'success')
    end
    AvailableRaces[AvailableKey].RaceData = Races[RaceData.RaceId]
    TriggerClientEvent('cw-racingapp:client:PlayerFinish', -1, RaceData.RaceId, PlayersFinished, RacerName)
    if PlayersFinished == AmountOfRacers then
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
        Races[RaceData.RaceId].LastLeaderboard = LastRaces[RaceData.RaceId]
        Races[RaceData.RaceId].Racers = {}
        Races[RaceData.RaceId].Started = false
        Races[RaceData.RaceId].Waiting = false
        table.remove(AvailableRaces, AvailableKey)
        LastRaces[RaceData.RaceId] = nil
        NotFinished[RaceData.RaceId] = nil
        Races[RaceData.RaceId].MaxClass = nil
    end
end)

RegisterNetEvent('cw-racingapp:server:CreateLapRace', function(RaceName, RacerName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if IsPermissioned(Player.PlayerData.citizenid, 'create') then
        if IsNameAvailable(RaceName) then
            TriggerClientEvent('cw-racingapp:client:StartRaceEditor', source, RaceName, RacerName)
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("primary.race_name_exists"), 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("primary.no_permission"), 'error')
    end
end)

local function isToFarAway(src, RaceId)
    return Config.JoinDistance <= #(GetEntityCoords(GetPlayerPed(src)).xy- vec2(Races[RaceId].Checkpoints[1].coords.x, Races[RaceId].Checkpoints[1].coords.y))
end

local function hasEnoughMoney(source, cost)
    if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
        if useDebug then print('Is using crypto and renewed crypto') end
        if exports['qb-phone']:hasEnough(source, Config.Options.CryptoType, math.floor(cost)) then
            return true
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.can_not_afford").. math.floor(cost).. ' '.. Config.Options.CryptoType, 'error')
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

    if isToFarAway(src, RaceId) then
        TriggerClientEvent('cw-racingapp:client:NotCloseEnough', src, Races[RaceId].Checkpoints[1].coords.x, Races[RaceId].Checkpoints[1].coords.y)
        return
    end
    if not Races[RaceId].Started then
        if useDebug then
            print('Join: BUY IN', RaceData.BuyIn)
        end

        if RaceData.BuyIn > 0 and not hasEnoughMoney(src, RaceData.BuyIn) then
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_enough_money"))
        else
            if CurrentRace ~= nil then
                local AmountOfRacers = 0
                local PreviousRaceKey = GetOpenedRaceKey(CurrentRace)
                for _,_ in pairs(Races[CurrentRace].Racers) do
                    AmountOfRacers = AmountOfRacers + 1
                end
                Races[CurrentRace].Racers[Player.PlayerData.citizenid] = nil
                if (AmountOfRacers - 1) == 0 then
                    Races[CurrentRace].Racers = {}
                    Races[CurrentRace].Started = false
                    Races[CurrentRace].Waiting = false
                    table.remove(AvailableRaces, PreviousRaceKey)
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("primary.race_last_person"))
                    TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Races[CurrentRace])
                else
                    AvailableRaces[PreviousRaceKey].RaceData = Races[CurrentRace]
                    TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Races[CurrentRace])
                end
            end

            local AmountOfRacers = 0
            for _,_ in pairs(Races[RaceId].Racers) do
                AmountOfRacers = AmountOfRacers + 1
            end
            if AmountOfRacers == 0 then
                if useDebug then print('setting creator') end
                Races[RaceId].OrganizerCID = Player.PlayerData.citizenid
            end
            if RaceData.BuyIn > 0 then
                if Config.Options.MoneyType == 'crypto' and Config.UseRenewedCrypto then
                    exports['qb-phone']:RemoveCrypto(src, Config.Options.CryptoType, math.floor(RaceData.BuyIn))
                    TriggerClientEvent('QBCore:Notify', source, Lang:t("success.remove_crypto").. math.floor(RaceData.BuyIn).. ' '.. Config.Options.CryptoType, 'success')
                else
                    Player.Functions.RemoveMoney(Config.Options.MoneyType, RaceData.BuyIn, "Bought into Race")
                end
            end

            Races[RaceId].Waiting = true
            Races[RaceId].MaxClass = RaceData.MaxClass
            Races[RaceId].Ghosting = RaceData.Ghosting
            Races[RaceId].BuyIn = RaceData.BuyIn
            Races[RaceId].GhostingTime = RaceData.GhostingTime
            Races[RaceId].Racers[Player.PlayerData.citizenid] = {
                Checkpoint = 0,
                Lap = 1,
                Finished = false,
                RacerName = RacerName,
                Placement = 0,
                PlayerVehicleEntity = PlayerVehicleEntity,
                RacerSource = src
            }
            table.insert(racersSortedByPosition, Races[RaceId].Racers[Player.PlayerData.citizenid] )
            AvailableRaces[AvailableKey].RaceData = Races[RaceId]
            TriggerClientEvent('cw-racingapp:client:JoinRace', src, Races[RaceId], RaceData.Laps, RacerName)
            TriggerClientEvent('cw-racingapp:client:UpdateRaceRacers', -1, RaceId, Races[RaceId].Racers)
            local creatorsource = QBCore.Functions.GetPlayerByCitizenId(AvailableRaces[AvailableKey].SetupCitizenId).PlayerData.source
            if creatorsource ~= Player.PlayerData.source then
                TriggerClientEvent('QBCore:Notify', creatorsource, Lang:t("primary.race_someone_joined"))
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.race_already_started"))
    end
end)

local function assignNewOrganizer(RaceId, src)
    for i,v in pairs(Races[RaceId].Racers) do
        if i ~= QBCore.Functions.GetPlayer(src).PlayerData.citizenid then
            Races[RaceId].OrganizerCID = i
            TriggerClientEvent('QBCore:Notify', v.RacerSource, Lang:t("text.new_host"))
            TriggerClientEvent('cw-racingapp:client:UpdateOrganizer', -1, RaceId, i)
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
    local creatorsource = QBCore.Functions.GetPlayerByCitizenId(AvailableRaces[AvailableKey].SetupCitizenId).PlayerData.source

    if creatorsource ~= Player.PlayerData.source then
        TriggerClientEvent('QBCore:Notify', creatorsource, Lang:t("primary.race_someone_left"))
    end

    local AmountOfRacers = 0
    for k, v in pairs(Races[RaceData.RaceId].Racers) do
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
    Races[RaceId].Racers[Player.PlayerData.citizenid] = nil
    if Races[RaceId].OrganizerCID == QBCore.Functions.GetPlayer(src).PlayerData.citizenid then
        assignNewOrganizer(RaceId, src)
    end
    if (AmountOfRacers - 1) == 0 then
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
        Races[RaceId].LastLeaderboard = LastRaces[RaceId]
        Races[RaceId].Racers = {}
        Races[RaceId].Started = false
        Races[RaceId].Waiting = false
        table.remove(AvailableRaces, AvailableKey)
        TriggerClientEvent('QBCore:Notify', src, Lang:t("primary.race_last_person"))
        TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Races[RaceId])
        LastRaces[RaceId] = nil
        NotFinished[RaceId] = nil
    else
        AvailableRaces[AvailableKey].RaceData = Races[RaceId]
        TriggerClientEvent('cw-racingapp:client:LeaveRace', src, Races[RaceId])
    end
    TriggerClientEvent('cw-racingapp:client:UpdateRaceRacers', -1, RaceId, Races[RaceId].Racers)
end)

RegisterNetEvent('cw-racingapp:server:SetupRace', function(RaceId, Laps, RacerName, MaxClass, GhostingEnabled, GhostingTime, BuyIn)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if isToFarAway(src, RaceId) then
        TriggerClientEvent('cw-racingapp:client:NotCloseEnough', src, Races[RaceId].Checkpoints[1].coords.x, Races[RaceId].Checkpoints[1].coords.y)
        return
    end
    if BuyIn > 0 and not hasEnoughMoney(src, BuyIn) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_enough_money"))
    else
        if Races[RaceId] ~= nil then
            if not Races[RaceId].Waiting then
                if not Races[RaceId].Started then
                    Races[RaceId].Waiting = true
                    local allRaceData = {
                        RaceData = Races[RaceId],
                        Laps = Laps,
                        RaceId = RaceId,
                        SetupCitizenId = Player.PlayerData.citizenid,
                        SetupRacerName = RacerName,
                        MaxClass = MaxClass,
                        Ghosting = GhostingEnabled,
                        GhostingTime = GhostingTime,
                        BuyIn = BuyIn
                    }
                    AvailableRaces[#AvailableRaces+1] = allRaceData
                    TriggerClientEvent('QBCore:Notify', src,  Lang:t("success.race_created"), 'success')
                    TriggerClientEvent('cw-racingapp:client:ReadyJoinRace', src, allRaceData)

                    CreateThread(function()
                        local count = 0
                        while Races[RaceId].Waiting do
                            Wait(1000)
                            if count < 5 * 60 then
                                count = count + 1
                            else
                                local AvailableKey = GetOpenedRaceKey(RaceId)
                                for cid, _ in pairs(Races[RaceId].Racers) do
                                    local RacerData = QBCore.Functions.GetPlayerByCitizenId(cid)
                                    if RacerData ~= nil then
                                        TriggerClientEvent('QBCore:Notify', RacerData.PlayerData.source, Lang:t("error.race_timed_out"), 'error')
                                        TriggerClientEvent('cw-racingapp:client:LeaveRace', RacerData.PlayerData.source, Races[RaceId])
                                    end
                                end
                                table.remove(AvailableRaces, AvailableKey)
                                Races[RaceId].LastLeaderboard = {}
                                Races[RaceId].Racers = {}
                                Races[RaceId].Started = false
                                Races[RaceId].Waiting = false
                                Races[RaceId].MaxClass = nil
                                Races[RaceId].Ghosting = false
                                Races[RaceId].GhostingTime = nil
                                LastRaces[RaceId] = nil
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
end)

RegisterNetEvent('cw-racingapp:server:UpdateRaceState', function(RaceId, Started, Waiting)
    Races[RaceId].Waiting = Waiting
    Races[RaceId].Started = Started
end)

local function copyWihoutId(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[#copy+1] = value
	end
	return copy
end

local function placements(RaceId)
    local tempPositions = copyWihoutId(Races[RaceId].Racers)
    if #tempPositions > 1 then
        if useDebug then print('More than one racer') end
        table.sort(tempPositions, function(a,b)
            if a.Lap > b.Lap then return true
            elseif a.Lap < b.Lap then return false
            elseif a.Lap == b.Lap then
                if a.Checkpoint > b.Checkpoint then return true
                elseif a.Checkpoint < b.Checkpoint then return false
                elseif a.Checkpoint == b.Checkpoint then
                    if a.RaceTime ~= nil and b.RaceTime ~= nil and a.RaceTime < b.RaceTime then
                        if useDebug then
                           print(a.RacerName, a.RaceTime, ' < ',b.RacerName, b.RaceTime)
                        end
                        return true
                    else
                        return false
                    end
                end
            end
        end)
        if useDebug then
            print('placement function temp pos:', QBCore.Debug(tempPositions))
        end
    else
        if useDebug then print('Only one racer') end
    end
    racersSortedByPosition = tempPositions
    return tempPositions
end

local Timers = {}

local function timer(raceId)
    SetTimeout(Config.RaceResetTimer, function()
        if useDebug then print('Checking timer') end
        if math.abs(GetGameTimer() - Timers[raceId]) < Config.RaceResetTimer then
            Timers[raceId] = GetGameTimer()
            timer(raceId)
        else
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
            for i,racer in pairs(Races[raceId].Racers) do
                TriggerClientEvent('cw-racingapp:client:LeaveRace', racer.RacerSource, Races[raceId] )
                
            end
            Races[raceId].LastLeaderboard = LastRaces[raceId]
            Races[raceId].Racers = {}
            Races[raceId].Started = false
            Races[raceId].Waiting = false
            local AvailableKey = GetOpenedRaceKey(raceId)
            table.remove(AvailableRaces, AvailableKey)
            LastRaces[raceId] = nil
            NotFinished[raceId] = nil
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
    if Races[RaceId].Racers[CitizenId] then
        Races[RaceId].Racers[CitizenId].Checkpoint = Checkpoint
        Races[RaceId].Racers[CitizenId].Lap = Lap
        Races[RaceId].Racers[CitizenId].Finished = Finished
        Races[RaceId].Racers[CitizenId].RaceTime = RaceTime
        if useDebug and racersSortedByPosition[2] then
           print('before', racersSortedByPosition[1].RacerName, racersSortedByPosition[2].RacerName)
        end
        local newPositions = placements(RaceId)
        if useDebug and racersSortedByPosition[2] then
           print('after', newPositions[1].RacerName, newPositions[2].RacerName)
        end
        TriggerClientEvent('cw-racingapp:client:UpdateRaceRacerData', -1, RaceId, Races[RaceId], newPositions)
    else
        -- Attemt to make sure script dont break if something goes wrong
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.youre_not_in_the_race"), 'error')
        TriggerClientEvent('cw-racingapp:client:LeaveRace', -1, nil)
    end
    if Config.UseResetTimer then updateTimer(RaceId) end
end)

RegisterNetEvent('cw-racingapp:server:StartRace', function(RaceId)
    local src = source
    local MyPlayer = QBCore.Functions.GetPlayer(src)
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
    local newPositions = placements(RaceId)
    for Index, Value in pairs(Races[RaceId].Racers) do
        TotalRacers = TotalRacers + 1
    end
    for CitizenId, _ in pairs(Races[RaceId].Racers) do
        local Player = QBCore.Functions.GetPlayerByCitizenId(CitizenId)
        if Player ~= nil then
            TriggerClientEvent('cw-racingapp:client:RaceCountdown', Player.PlayerData.source,TotalRacers, newPositions)
        end
    end
    if Config.UseResetTimer then startTimer(RaceId) end
end)

local function increaseTracksAmount(racerName)
    local query = 'UPDATE racer_names SET tracks = tracks + 1 WHERE racername = "'..racerName..'"'
    MySQL.Async.execute(query)
end

local function decreaseTracksAmount(racerName)
    local query = 'UPDATE racer_names SET tracks = tracks - 1 WHERE racername = "'..racerName..'"'
    MySQL.Async.execute(query)
end

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
        Races[RaceId].Checkpoints = Checkpoints
    else
        Races[RaceId] = {
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
            LastLeaderboard = {}
        }
        MySQL.Async.insert('INSERT INTO race_tracks (name, checkpoints, creatorid, creatorname, distance, raceid) VALUES (?, ?, ?, ?, ?, ?)',
            {RaceData.RaceName, json.encode(Checkpoints), Player.PlayerData.citizenid, RaceData.RacerName, RaceData.RaceDistance, RaceId})
        if Config.UseNameValidation then increaseTracksAmount(RaceData.RacerName) end
    end
end)

RegisterNetEvent('cw-racingapp:Server:DeleteTrack', function(RaceId)
    print('DELETING ', RaceId)
    Races[RaceId] = nil
    local result = MySQL.Sync.fetchAll('SELECT creatorname FROM race_tracks WHERE raceid = ?', {RaceId})[1]
    MySQL.query('DELETE FROM race_tracks WHERE raceid = ?', {RaceId} )
    if Config.UseNameValidation then decreaseTracksAmount(result.creatorname) end
end)

RegisterNetEvent('cw-racingapp:Server:ClearLeaderboard', function(RaceId)
    print('CLEARING LEADERBOARD ', RaceId)
    Races[RaceId].Records = nil
    MySQL.query('UPDATE race_tracks SET records = NULL WHERE raceid = ?',
    {RaceId})
end)

QBCore.Functions.CreateCallback('cw-racingapp:Server:getplayers', function(_, cb)
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
    local HasMaster = Player.Functions.GetItemsByName('fob_racing_master')
    if HasMaster then
        for _, item in pairs(HasMaster) do
            if Config.Inventory == 'ox' then
                if item.metadata.owner == CitizenId and Config.Permissions['fob_racing_master'][type] then
                    return true
                end
            else
                if item.info.owner == CitizenId and Config.Permissions['fob_racing_master'][type] then
                    return true
                end
            end
        end
    end

    local HasBasic = Player.Functions.GetItemsByName('fob_racing_basic')
    if HasBasic then
        for _, item in pairs(HasBasic) do
            if Config.Inventory == 'ox' then
                if item.metadata.owner == CitizenId and Config.Permissions['fob_racing_basic'][type] then
                    return true
                end
            else
                if item.info.owner == CitizenId and Config.Permissions['fob_racing_basic'][type] then
                    return true
                end
            end
        end
    end
end

function IsNameAvailable(RaceName)
    local retval = true
    for RaceId, _ in pairs(Races) do
        if Races[RaceId].RaceName == RaceName then
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
    for RaceId, _ in pairs(Races) do
        for cid, _ in pairs(Races[RaceId].Racers) do
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
    for k, v in pairs(Races) do
        if v.RaceName == name then
            retval = k
            break
        end
    end
    return retval
end

function GenerateRaceId()
    local RaceId = "LR-" .. math.random(1111, 9999)
    while Races[RaceId] ~= nil do
        RaceId = "LR-" .. math.random(1111, 9999)
    end
    return RaceId
end

function UseRacingFob(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenid = Player.PlayerData.citizenid
    if Config.Inventory == 'qb' then
        if item.info.owner == citizenid then
            TriggerClientEvent('cw-racingapp:Client:OpenMainMenu', source, { type = item.name, name = item.info.name})
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.unowned_dongle"), "error")
        end
    elseif Config.Inventory == 'ox' then
        if item.metadata.owner == citizenid then
            TriggerClientEvent('cw-racingapp:Client:OpenMainMenu', source, { type = item.name, name = item.metadata.name})
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.unowned_dongle"), "error")
        end
    end
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
    cb(Races[RaceId].Racers)
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetListedRaces', function(source, cb)
    cb(Races)
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetRacingData', function(source, cb, RaceId)
    cb(Races[RaceId])
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetTracks', function(source, cb)
    cb(Races)
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetTrackData', function(source, cb, RaceId)
    if Races[RaceId] then
        cb(Races[RaceId])
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
        Races[raceId].Access = access
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

local function addRacerName(citizenId, racerName)
    if not MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ? AND citizenid = ?', {racerName, citizenId})[1] then
        local previousTracks = MySQL.Sync.fetchAll('SELECT name FROM race_tracks WHERE creatorname = ? AND creatorid = ?', {racerName, citizenId})
        MySQL.Async.insert('INSERT INTO racer_names (citizenid, racername, tracks) VALUES (?, ?, ?)',
        {citizenId, racerName, #previousTracks})
    end
end

QBCore.Functions.CreateCallback('cw-racingapp:server:NameIsAvailable', function(source, cb, racerName, serverId)
    if Config.UseNameValidation then
        local Player = QBCore.Functions.GetPlayer(serverId)
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
    if Config.UseNameValidation then
        local Player = QBCore.Functions.GetPlayer(serverId)
        local citizenId = Player.PlayerData.citizenid
        local result = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE citizenid = ?', {citizenId})
        print('res', json.encode(result))
        cb(result)
    else
        cb(nil)
    end
end)

local function createRacingFob(source, citizenid, racerName, type, purchaseType)
    if useDebug then
        print('Creating a racing fob. Input:')
        print('citizenid', citizenid)
        print('racerName', racerName)
        print('type', type)
        print('purchaseType', dump(purchaseType))
    end
    local fobTypes = {
        ['basic'] = "fob_racing_basic",
        ['master'] = "fob_racing_master"
    }

    local Player = QBCore.Functions.GetPlayer(source)
    local cost = nil
    if type == 'master' then
        cost = purchaseType.racingFobMasterCost
    else
        cost = purchaseType.racingFobCost
    end

    if purchaseType.moneyType == 'crypto' and Config.UseRenewedCrypto then
        if exports['qb-phone']:hasEnough(source, Config.Options.CryptoType, math.floor(cost)) then
            exports['qb-phone']:RemoveCrypto(source, Config.Options.CryptoType, math.floor(cost))
            TriggerClientEvent('QBCore:Notify', source, Lang:t("success.remove_crypto").. math.floor(cost).. ' '.. Config.Options.CryptoType, 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.can_not_afford").. math.floor(cost).. ' '.. Config.Options.CryptoType, 'error')
            return
        end
    else
        if not Player.Functions.RemoveMoney(purchaseType.moneyType, cost, "Created Fob: "..type) then
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.can_not_afford")..' $'.. math.floor(cost), 'error')
            return
        end
    end
    if purchaseType.profiteer then
        exports['Renewed-Banking']:addAccountMoney(purchaseType.profiteer.job, cost)
    end
    Player.Functions.AddItem(fobTypes[type], 1, nil, { owner = citizenid, name = racerName })
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[fobTypes[type]], "add")
    addRacerName(citizenid, racerName)
end

RegisterNetEvent('cw-racingapp:server:CreateFob', function(playerId, racerName, type, purchaseType)
    local player = QBCore.Functions.GetPlayer(tonumber(playerId))
    if player then
        local citizenId = player.PlayerData.citizenid
        createRacingFob(source, citizenId, racerName, type, purchaseType)
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.could_not_find_person"), "error")
    end
end)

QBCore.Commands.Add('createracingfob', Lang:t("commands.create_racing_fob_description"), { {name='type', help='Basic/Master'}, {name='identifier', help='CitizenID or ID'}, {name='Racer Name', help='Racer Name to associate with Fob'} }, true, function(source, args)
    local type = args[1]
    local citizenid = args[2]

    local name = {}
    for i = 3, #args do
        name[#name+1] = args[i]
    end
    name = table.concat(name, ' ')

    local fobTypes = {
        ['basic'] = "fob_racing_basic",
        ['master'] = "fob_racing_master"
    }

    if not fobTypes[type:lower()] then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.invalid_fob_type"), "error")
        return
    end

    if tonumber(citizenid) then
        local Player = QBCore.Functions.GetPlayer(tonumber(citizenid))
        if Player then
            citizenid = Player.PlayerData.citizenid
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.id_not_found"), "error")
            return
        end
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
        racingFobMasterCost = 0,
        racingFobCost = 0,
        moneyType = 'cash',
        profiteer = 'your mom'
    }

    createRacingFob(source, citizenid, name, type:lower(), tradeType)
end, 'admin')

QBCore.Commands.Add('remracename', 'Remove Racing Name From Database', { {name='name', help='Racer name. Put in quotations if multiple words'} }, true, function(source, args)
    local name = args[1]
    print('name of racer to delete:', name)
    MySQL.query('DELETE FROM racer_names WHERE racername = ?', {name} )
end, 'admin')

QBCore.Functions.CreateUseableItem("fob_racing_basic", function(source, item)
    UseRacingFob(source, item)
end)

QBCore.Functions.CreateUseableItem("fob_racing_master", function(source, item)
    UseRacingFob(source, item)
end)

local function generateRacetrackTable ()
    MySQL.query('CREATE TABLE IF NOT EXISTS race_tracks ( id int(11) NOT NULL AUTO_INCREMENT, name varchar(50) DEFAULT NULL, checkpoints text DEFAULT NULL, records text DEFAULT NULL, creatorid varchar(50) DEFAULT NULL, creatorname varchar(50) DEFAULT NULL, distance int(11) DEFAULT NULL, raceid varchar(50) DEFAULT NULL, access TEXT DEFAULT "[]" PRIMARY KEY (id))')
end

local function dropRacetrackTable()
    MySQL.query('DROP TABLE IF EXISTS race_tracks')
end

local function updateRaceTrackTable()
    MySQL.query('ALTER TABLE race_tracks RENAME COLUMN creator TO creatorid; ALTER TABLE race_tracks ADD COLUMN creatorname VARCHAR(50) NULL DEFAULT NULL ADD access TEXT DEFAULT "[]" AFTER creatorid;')
end

local function addAccessCol()
    MySQL.query("ALTER TABLE race_tracks ADD access TEXT DEFAULT '{}'")
end

QBCore.Commands.Add('addAccessCol', 'Add Access column', {}, true, function(source, args)
    addAccessCol()
end, 'admin')

QBCore.Commands.Add('resetracetracks', 'Reset the race track table', {}, true, function(source, args)
    dropRacetrackTable()
    generateRacetrackTable()
end, 'admin')

QBCore.Commands.Add('updateracetracks', 'Update the race track table to fit qb-racing/cw-racingapp', {}, true, function(source, args)
    updateRaceTrackTable()
end, 'admin')

QBCore.Commands.Add('removeallracetracks', 'Remove the race_tracks table', {}, true, function(source, args)
    dropRacetrackTable()
end, 'admin')

QBCore.Commands.Add('cwdebugracing', 'toggle debug for racing', {}, true, function(source, args)
    useDebug = not useDebug
    print('debug is now:', useDebug)
    TriggerClientEvent('cw-racingapp:client:toggleDebug',source, useDebug)
end, 'admin')
