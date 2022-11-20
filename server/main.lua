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
                MaxClass = nil
            }
        end
    end
end

-----------------------
----   Threads     ----
-----------------------
MySQL.ready(function ()
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
       print('Time', PlayerTime, RacerName, CarClass, VehicleModel)
       print('All times for this class', dump(FilteredLeaderboard))
    end

    if useDebug then
       print('racer has previous record: ', dump(PersonalBest), index)
    end
    if PersonalBest and PersonalBest.Time > PlayerTime then
        if useDebug then
           print('new pb', PlayerTime, RacerName, CarClass, VehicleModel)
        end
        TriggerClientEvent('QBCore:Notify', src, string.format(Lang:t("success.new_pb"), RaceData.RaceName, SecondsToClock(PlayerTime)), 'success')
        local playerPlacement = {
            Time = PlayerTime,
            Holder = RacerName,
            Class = CarClass,
            Vehicle = VehicleModel
        }
        records[index] = playerPlacement
        records = sortRecordsByTime(records)
        print('records being sent to db', dump(records))
        MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?',
            {json.encode(records), RaceData.RaceId})
        return true

    elseif not PersonalBest then
        TriggerClientEvent('QBCore:Notify', src, string.format(Lang:t("success.time_added"), RaceData.RaceName, SecondsToClock(PlayerTime)), 'success')
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
    local BLap = 0
    if TotalLaps < 2 then
        BLap = TotalTime*60
    else
        BLap = BestLap*60
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
            TriggerClientEvent('QBCore:Notify', src, string.format(Lang:t("success.race_record"), RaceData.RaceName, SecondsToClock(BLap)), 'success')
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

RegisterNetEvent('cw-racingapp:server:JoinRace', function(RaceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerVehicleEntity = RaceData.PlayerVehicleEntity
    local RaceName = RaceData.RaceData.RaceName
    local RaceId = GetRaceId(RaceName)
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local CurrentRace = GetCurrentRace(Player.PlayerData.citizenid)
    local RacerName = RaceData.RacerName
    if not Races[RaceId].Started then
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
        else
            Races[RaceId].OrganizerCID = Player.PlayerData.citizenid
        end
    
        Races[RaceId].Waiting = true
        Races[RaceId].MaxClass = RaceData.MaxClass
        Races[RaceId].Ghosting = RaceData.Ghosting
        Races[RaceId].GhostingTime = RaceData.GhostingTime
        Races[RaceId].Racers[Player.PlayerData.citizenid] = {
            Checkpoint = 0,
            Lap = 1,
            Finished = false,
            RacerName = RacerName,
            Placement = 0,
            PlayerVehicleEntity = PlayerVehicleEntity
        }
        table.insert(racersSortedByPosition, Races[RaceId].Racers[Player.PlayerData.citizenid] )
        AvailableRaces[AvailableKey].RaceData = Races[RaceId]
        TriggerClientEvent('cw-racingapp:client:JoinRace', src, Races[RaceId], RaceData.Laps, RacerName)
        TriggerClientEvent('cw-racingapp:client:UpdateRaceRacers', src, RaceId, Races[RaceId].Racers)
        local creatorsource = QBCore.Functions.GetPlayerByCitizenId(AvailableRaces[AvailableKey].SetupCitizenId).PlayerData.source
        if creatorsource ~= Player.PlayerData.source then
            TriggerClientEvent('QBCore:Notify', creatorsource, Lang:t("primary.race_someone_joined"))
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.race_already_started"))
    end
end)

RegisterNetEvent('cw-racingapp:server:LeaveRace', function(RaceData)
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
    TriggerClientEvent('cw-racingapp:client:UpdateRaceRacers', src, RaceId, Races[RaceId].Racers)
end)

RegisterNetEvent('cw-racingapp:server:SetupRace', function(RaceId, Laps, RacerName, MaxClass, GhostingEnabled, GhostingTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
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
                    GhostingTime = GhostingTime
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
end)

RegisterNetEvent('cw-racingapp:server:UpdateRaceState', function(RaceId, Started, Waiting)
    Races[RaceId].Waiting = Waiting
    Races[RaceId].Started = Started
end)


local function placements()
    table.sort(racersSortedByPosition, function(a,b) 
        if a.Lap > b.Lap then return true
        elseif a.Lap < b.Lap then return false
        elseif a.Lap == b.Lap then
            if a.Checkpoint > b.Checkpoint then return true
            elseif a.Checkpoint < b.Checkpoint then return false
            elseif a.Checkpoint == b.Checkpoint then
                if a.RaceTime < b.RaceTime then
                    if useDebug then
                       print(a.RacerName, a.RaceTime, ' > ',b.RacerName, b.RaceTime)
                    end
                    return true
                else
                    return false
                end
            end
        end
        print('I SHOULD NOT BE HERE')
    end)
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
        if useDebug then
           print('before', racersSortedByPosition[1].RacerName, racersSortedByPosition[2].RacerName)
        end
        placements()
        if useDebug then
           print('after', racersSortedByPosition[1].RacerName, racersSortedByPosition[2].RacerName)
        end
        TriggerClientEvent('cw-racingapp:client:UpdateRaceRacerData', -1, RaceId, Races[RaceId], racersSortedByPosition)
    else
        -- Attemt to make sure script dont break if something goes wrong
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.youre_not_in_the_race"), 'error')
        TriggerClientEvent('cw-racingapp:client:LeaveRace', -1, nil)
    end

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
    for Index, Value in pairs(Races[RaceId].Racers) do
        TotalRacers = TotalRacers + 1
    end
    for CitizenId, _ in pairs(Races[RaceId].Racers) do
        local Player = QBCore.Functions.GetPlayerByCitizenId(CitizenId)
        if Player ~= nil then
            TriggerClientEvent('cw-racingapp:client:RaceCountdown', Player.PlayerData.source,TotalRacers)
        end
    end
end)

RegisterNetEvent('cw-racingapp:server:SaveRace', function(RaceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local RaceId = GenerateRaceId()
    local Checkpoints = {}
    for k, v in pairs(RaceData.Checkpoints) do
        Checkpoints[k] = {
            offset = v.offset,
            coords = v.coords
        }
    end

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
        LastLeaderboard = {}
    }
    MySQL.Async.insert('INSERT INTO race_tracks (name, checkpoints, creatorid, creatorname, distance, raceid) VALUES (?, ?, ?, ?, ?, ?)',
        {RaceData.RaceName, json.encode(Checkpoints), Player.PlayerData.citizenid, RaceData.RacerName, RaceData.RaceDistance, RaceId})
end)

RegisterNetEvent('cw-racingapp:Server:DeleteTrack', function(RaceId)
    print('DELETING ', RaceId)
    Races[RaceId] = nil
    MySQL.query('DELETE FROM race_tracks WHERE raceid = ?', {RaceId} )
end)

RegisterNetEvent('cw-racingapp:Server:ClearLeaderboard', function(RaceId)
    print('CLEARING LEADERBOARD ', RaceId)
    Races[RaceId].Records = nil
    MySQL.query('UPDATE race_tracks SET records = NULL WHERE raceid = ?',
    {RaceId})
end)

-----------------------
----   Functions   ----
-----------------------

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)
    local retval = 0
    if seconds <= 0 then
        retval = "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds / 3600));
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
        retval = hours .. ":" .. mins .. ":" .. secs
    end
    return retval
end


function IsPermissioned(CitizenId, type)
    local Player = QBCore.Functions.GetPlayerByCitizenId(CitizenId)

    local HasMaster = Player.Functions.GetItemsByName('fob_racing_master')
    if HasMaster then
        for _, item in ipairs(HasMaster) do
            if item.info.owner == CitizenId and Config.Permissions['fob_racing_master'][type] then
                return true
            end
        end
    end

    local HasBasic = Player.Functions.GetItemsByName('fob_racing_basic')
    if HasBasic then
        for _, item in ipairs(HasBasic) do
            if item.info.owner == CitizenId and Config.Permissions['fob_racing_basic'][type] then
                return true
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

    if item.info.owner == citizenid then
        TriggerClientEvent('cw-racingapp:Client:OpenMainMenu', source, { type = item.name, name = item.info.name})
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.unowned_dongle"), "error")
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

QBCore.Functions.CreateCallback('cw-racingapp:server:HasCreatedRace', function(source, cb)
    cb(HasOpenedRace(QBCore.Functions.GetPlayer(source).PlayerData.citizenid))
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:IsAuthorizedToCreateRaces', function(source, cb, TrackName)
    cb(IsPermissioned(QBCore.Functions.GetPlayer(source).PlayerData.citizenid, 'create'), IsNameAvailable(TrackName))
end)

QBCore.Functions.CreateCallback('cw-racingapp:server:GetTrackData', function(source, cb, RaceId)
    local result = MySQL.Sync.fetchAll('SELECT * FROM players WHERE citizenid = ?', {Races[RaceId].Creator})
    if result[1] ~= nil then
        result[1].charinfo = json.decode(result[1].charinfo)
        cb(Races[RaceId], result[1])
    else
        cb(Races[RaceId], {
            charinfo = {
                firstname = "Unknown",
                lastname = "Unknown"
            }
        })
    end
end)

local function createRacingFob(source, citizenid, racerName, type)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveMoney(Config.Trader.moneyType, Config.Trader.racingFobCost)
    Player.Functions.AddItem(type, 1, nil, { owner = citizenid, name = racerName })
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[type], "add")
end

RegisterNetEvent('cw-racingapp:server:CreateFob', function(playerId, racerName, type)
    local player = QBCore.Functions.GetPlayer(tonumber(playerId))
    if player then
        local citizenId = player.PlayerData.citizenid
        createRacingFob(source, citizenId, racerName, type)
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

    if fobTypes[type:lower()] then
        type = fobTypes[type:lower()]
    else
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

    QBCore.Functions.GetPlayer(source).Functions.AddItem(type, 1, nil, { owner = citizenid, name = name })
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[type], 'add', 1)
end, 'admin')

QBCore.Functions.CreateUseableItem("fob_racing_basic", function(source, item)
    UseRacingFob(source, item)
end)

QBCore.Functions.CreateUseableItem("fob_racing_master", function(source, item)
    UseRacingFob(source, item)
end)

local function generateRacetrackTable ()
    MySQL.query('CREATE TABLE IF NOT EXISTS race_tracks ( id int(11) NOT NULL AUTO_INCREMENT, name varchar(50) DEFAULT NULL, checkpoints text DEFAULT NULL, records text DEFAULT NULL, creatorid varchar(50) DEFAULT NULL, creatorname varchar(50) DEFAULT NULL, distance int(11) DEFAULT NULL, raceid varchar(50) DEFAULT NULL, PRIMARY KEY (id))')
end

local function dropRacetrackTable()
    MySQL.query('DROP TABLE IF EXISTS race_tracks')
end

local function updateRaceTrackTable()
    MySQL.query('ALTER TABLE race_tracks RENAME COLUMN creator TO creatorid; ALTER TABLE race_tracks ADD COLUMN creatorname VARCHAR(50) NULL DEFAULT NULL AFTER creatorid;')
end

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