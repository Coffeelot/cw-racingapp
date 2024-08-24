-----------------------
----   Variables   ----
-----------------------
local QBCore = exports['qb-core']:GetCoreObject()

local Players = {}
local Countdown = 10
local ToFarCountdown = 10
local FinishedUITimeout = false
local useDebug = Config.Debug
local creatorObjectLeft, creatorObjectRight
local creatorCheckpointObject
local start

local currentName = nil
local currentAuth = nil
local currentCrew = nil
local currentRanking = nil

local RaceData = {
    InCreator = false,
    InRace = false,
    ClosestCheckpoint = 0
}

local LastCheckPointDeleted = nil
local PreCheckpoints = {}
local PostCheckpoints = {}
local NewCheckpoint = {}
local MyRacerNames = {}

local EditingCheckpoint = false
local CreatorData = {
    RaceName = nil,
    RacerName = nil,
    Checkpoints = {},
    TireDistance = 3.0,
    ConfirmDelete = false,
    IsEdit = false,
    RaceId = nil
}

local CurrentRaceData = {
    RaceId = nil,
    RaceName = nil,
    RacerName = nil,
    MaxClass = nil,
    Checkpoints = {},
    Started = false,
    CurrentCheckpoint = nil,
    TotalLaps = 0,
    TotalRacers = 0,
    Lap = 0,
    Position = 0,
    Ghosted = false,
}

local Classes = exports['cw-performance']:getPerformanceClasses()
local Entities = {}
local Kicked = false
local traderPed

local ShowGpsRoute = Config.ShowGpsRoute or false
local IgnoreRoadsForGps = Config.IgnoreRoadsForGps or false
local UseUglyWaypoint = Config.UseUglyWaypoint or false
local CheckDistance = Config.CheckDistance or false

local function debugLog(message, message2)
    if useDebug then
        print('^2CW-RACINGAPP DEBUG:^0', message)
        if message2 then
            print(message2)
        end
    end
end

local function getVehicleFromVehList(hash)
    for _, v in pairs(QBCore.Shared.Vehicles) do
		if hash == joaat(v.hash) then
			return v.name, v.brand
		end
	end
    print('^1It seems like you have not added your vehicle ('..GetDisplayNameFromVehicleModel(hash)..') to the vehicles.lua')
    return 'model not found', 'brand not found'
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

local function getSizeOfTable(table)
    local count = 0
    if table then
        for i, item in pairs(table) do
            count = count + 1
        end
    end
    return count
end
-----------------------
----   Functions   ----
-----------------------
local function reverseTable(tbl)
    local len = #tbl
    local mid = math.floor(len / 2)
    for i = 1, mid do
        local temp = tbl[i]
        tbl[i] = tbl[len - i + 1]
        tbl[len - i + 1] = temp
    end
    return tbl
end

local function myCarClassIsAllowed(maxClass, myClass)
    if maxClass == nil or maxClass == '' then
        return true
    end
    local myClassIndex = Classes[myClass]
    local maxClassIndex = Classes[maxClass]
    debugLog('My class index', myClassIndex, 'maxClassIndex', maxClassIndex)
    if myClassIndex > maxClassIndex then
        return false
    end

    return true
end

local function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(10)
    end
end

local function cleanupObjects()
    DeleteObject(creatorObjectLeft)
    DeleteObject(creatorObjectRight)
    creatorObjectLeft, creatorObjectRight = nil, nil
end

local function DeleteClosestObject(coords, model)
    local Obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0, model, 0, 0, 0)
    DeleteObject(Obj)
    ClearAreaOfObjects(coords.x, coords.y, coords.z, 50.0, 0)
end

local function CreatePile(offset, model)
    if model then
        LoadModel(model)
        local Obj = CreateObject(model, offset.x, offset.y, offset.z, 0, 0, 0) -- CHANGE ONE OF THESE TO MAKE NETWORKED???
        PlaceObjectOnGroundProperly(Obj)
        FreezeEntityPosition(Obj, 1)
        SetEntityAsMissionEntity(Obj, 1, 1)
        SetEntityCollision(Obj, false, true)
        SetEntityCanBeDamaged(Obj, false)
        SetEntityInvincible(Obj, true)
    
        return Obj
    end        
end

local function GhostPlayers()
    CreateGhostLoop()
end

local function UnGhostPlayer()
    debugLog('DE GHOSTED')
    CurrentRaceData.Ghosted = false
end

local function isFinishOrStart(CurrentRaceData, checkpoint)
    if CurrentRaceData.TotalLaps == 0 then
        if checkpoint == 1 or checkpoint == #CurrentRaceData.Checkpoints then
            return true
        else 
            return false
        end
    else
        if checkpoint == 1 then
            return true
        else 
            return false
        end  
    end
end

local function AddPointToGpsRoute(cx, cy, offset)
    local x = cx
    local y = cy
    if Config.DoOffsetGps then
        x = (x + offset.right.x) / 2;
        y = (y + offset.right.y) / 2;
    end
    if IgnoreRoadsForGps then
        AddPointToGpsCustomRoute(x,y)
    else
        AddPointToGpsMultiRoute(x,y)
    end
        
end

local function clearBlips()
    for i,v in pairs(CurrentRaceData.Checkpoints) do
        
    end
end

local function getIndex (Positions)
    for k,v in pairs(Positions) do
        if v.RacerName == CurrentRaceData.RacerName then return k end
    end
end

local function doGPSForRace(started)
    DeleteAllCheckpoints()
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
        StartGpsMultiRoute(12, started, false)
    else
        ClearGpsMultiRoute()
        StartGpsMultiRoute(12, started , false)
    end
    if started and CurrentRaceData.TotalLaps > 0 then
        for k=1, #CurrentRaceData.Checkpoints, 1 do
            AddPointToGpsRoute(CurrentRaceData.Checkpoints[k].coords.x,CurrentRaceData.Checkpoints[k].coords.y, CurrentRaceData.Checkpoints[k].offset)
            if started then
                if isFinishOrStart(CurrentRaceData,k) then
                    CurrentRaceData.Checkpoints[k].pileleft = CreatePile(CurrentRaceData.Checkpoints[k].offset.left, Config.StartAndFinishModel)
                    CurrentRaceData.Checkpoints[k].pileright = CreatePile(CurrentRaceData.Checkpoints[k].offset.right, Config.StartAndFinishModel)
                else
                    CurrentRaceData.Checkpoints[k].pileleft = CreatePile(CurrentRaceData.Checkpoints[k].offset.left, Config.CheckpointPileModel)
                    CurrentRaceData.Checkpoints[k].pileright = CreatePile(CurrentRaceData.Checkpoints[k].offset.right, Config.CheckpointPileModel)
                end
                if k > 1 then
                    CurrentRaceData.Checkpoints[k].blip = CreateCheckpointBlip(CurrentRaceData.Checkpoints[k].coords, k)
                end
            end
        end
        if not IgnoreRoadsForGps then
            AddPointToGpsRoute(CurrentRaceData.Checkpoints[1].coords.x,CurrentRaceData.Checkpoints[1].coords.y,  CurrentRaceData.Checkpoints[1].offset)
        end
        CurrentRaceData.Checkpoints[1].blip = CreateCheckpointBlip(CurrentRaceData.Checkpoints[1].coords, #CurrentRaceData.Checkpoints+1)
    else
        -- First Lap setup
        for k, v in pairs(CurrentRaceData.Checkpoints) do
            AddPointToGpsRoute(CurrentRaceData.Checkpoints[k].coords.x,CurrentRaceData.Checkpoints[k].coords.y, v.offset)
            if started then
                if isFinishOrStart(CurrentRaceData,k) then
                    CurrentRaceData.Checkpoints[k].pileleft = CreatePile(v.offset.left, Config.StartAndFinishModel)
                    CurrentRaceData.Checkpoints[k].pileright = CreatePile(v.offset.right, Config.StartAndFinishModel)
                else
                    CurrentRaceData.Checkpoints[k].pileleft = CreatePile(v.offset.left, Config.CheckpointPileModel)
                    CurrentRaceData.Checkpoints[k].pileright = CreatePile(v.offset.right, Config.CheckpointPileModel)
                end
            end
            CurrentRaceData.Checkpoints[k].blip = CreateCheckpointBlip(v.coords, k)
        end
        if not IgnoreRoadsForGps and CurrentRaceData.TotalLaps > 0 then
            AddPointToGpsRoute(CurrentRaceData.Checkpoints[1].coords.x,CurrentRaceData.Checkpoints[1].coords.y,  CurrentRaceData.Checkpoints[1].offset)
        end
    end
    if IgnoreRoadsForGps then
        SetGpsCustomRouteRender(ShowGpsRoute, 16, 16)
    else
        SetGpsMultiRouteRender(ShowGpsRoute, 16, 16)
    end
end

function DeleteAllCheckpoints()
    for k, v in pairs(CreatorData.Checkpoints) do
        local CurrentCheckpoint = CreatorData.Checkpoints[k]

        if CurrentCheckpoint then
            local LeftPile = CurrentCheckpoint.pileleft
            local RightPile = CurrentCheckpoint.pileright

            if LeftPile then
                DeleteClosestObject(CurrentCheckpoint.offset.left, Config.StartAndFinishModel)
                DeleteClosestObject(CurrentCheckpoint.offset.left, Config.CheckpointPileModel)
                LeftPile = nil
            end
            if RightPile then
                DeleteClosestObject(CurrentCheckpoint.offset.right, Config.StartAndFinishModel)
                DeleteClosestObject(CurrentCheckpoint.offset.right, Config.CheckpointPileModel)
                RightPile = nil
            end
            local Blip = CurrentCheckpoint.blip
            if Blip then
                RemoveBlip(Blip)
                Blip = nil
            end
        end
    end

    for k, v in pairs(CurrentRaceData.Checkpoints) do
        local CurrentCheckpoint = CurrentRaceData.Checkpoints[k]

        if CurrentCheckpoint then
            local LeftPile = CurrentCheckpoint.pileleft
            local RightPile = CurrentCheckpoint.pileright

            if LeftPile then
                DeleteClosestObject(CurrentRaceData.Checkpoints[k].offset.left, Config.StartAndFinishModel)
                DeleteClosestObject(CurrentRaceData.Checkpoints[k].offset.left, Config.CheckpointPileModel)
                LeftPile = nil
            end

            if RightPile then
                DeleteClosestObject(CurrentRaceData.Checkpoints[k].offset.right, Config.StartAndFinishModel)
                DeleteClosestObject(CurrentRaceData.Checkpoints[k].offset.right, Config.CheckpointPileModel)
                RightPile = nil
            end
            local Blip = CurrentCheckpoint.blip
            if Blip then
                RemoveBlip(Blip)
                Blip = nil
            end
        end
    end
end

local function DeleteCheckpoint()
    local NewCheckpoints = {}
    if RaceData.ClosestCheckpoint ~= 0 then
        local ClosestCheckpoint = CreatorData.Checkpoints[RaceData.ClosestCheckpoint]
        debugLog('deleting checkpoint', dump(ClosestCheckpoint))

        if ClosestCheckpoint then
            local Blip = ClosestCheckpoint.blip
            if Blip then
                RemoveBlip(Blip)
                Blip = nil
            end

            local PileLeft = ClosestCheckpoint.pileleft
            if PileLeft then
                DeleteClosestObject(ClosestCheckpoint.offset.left, Config.StartAndFinishModel)
                DeleteClosestObject(ClosestCheckpoint.offset.left, Config.CheckpointPileModel)
                PileLeft = nil
            end

            local PileRight = ClosestCheckpoint.pileright
            if PileRight then
                DeleteClosestObject(ClosestCheckpoint.offset.right, Config.StartAndFinishModel)
                DeleteClosestObject(ClosestCheckpoint.offset.right, Config.CheckpointPileModel)
                PileRight = nil
            end

            for id, data in pairs(CreatorData.Checkpoints) do
                if id ~= RaceData.ClosestCheckpoint then
                    NewCheckpoints[#NewCheckpoints + 1] = data
                end
            end
            CreatorData.Checkpoints = NewCheckpoints
        else
            QBCore.Functions.Notify(Lang("slow_down"), 'error')
        end
    else
        QBCore.Functions.Notify(Lang("slow_down"), 'error')
    end
end

function DeleteCreatorCheckpoints()
    for id, _ in pairs(CreatorData.Checkpoints) do
        local CurrentCheckpoint = CreatorData.Checkpoints[id]

        local Blip = CurrentCheckpoint.blip
        if Blip then
            RemoveBlip(Blip)
            Blip = nil
        end

        if CurrentCheckpoint then
            local PileLeft = CurrentCheckpoint.pileleft
            if PileLeft then
                DeleteClosestObject(CurrentCheckpoint.offset.left, Config.CheckpointPileModel)
                DeleteClosestObject(CurrentCheckpoint.offset.left, Config.StartAndFinishModel)
                PileLeft = nil
            end

            local PileRight = CurrentCheckpoint.pileright
            if PileRight then
                DeleteClosestObject(CurrentCheckpoint.offset.right, Config.CheckpointPileModel)
                DeleteClosestObject(CurrentCheckpoint.offset.right, Config.StartAndFinishModel)
                PileRight = nil
            end
        end
    end
end

function SetupPiles()
    for k, v in pairs(CreatorData.Checkpoints) do
        if not CreatorData.Checkpoints[k].pileleft then
            CreatorData.Checkpoints[k].pileleft = CreatePile(v.offset.left, Config.CheckpointPileModel)
        end

        if not CreatorData.Checkpoints[k].pileright then
            CreatorData.Checkpoints[k].pileright = CreatePile(v.offset.right, Config.CheckpointPileModel)
        end
    end
end

function SaveRace()
    local RaceDistance = 0

    for k, v in pairs(CreatorData.Checkpoints) do
        if k + 1 <= #CreatorData.Checkpoints then
            local checkpointdistance = #(vector3(v.coords.x, v.coords.y, v.coords.z) -
                                           vector3(CreatorData.Checkpoints[k + 1].coords.x,
                    CreatorData.Checkpoints[k + 1].coords.y, CreatorData.Checkpoints[k + 1].coords.z))
            RaceDistance = RaceDistance + checkpointdistance
        end
    end

    CreatorData.RaceDistance = RaceDistance
    TriggerServerEvent('cw-racingapp:server:SaveTrack', CreatorData)
    Lang("slow_down")
    QBCore.Functions.Notify(Lang("race_saved") .. '(' .. CreatorData.RaceName .. ')', 'success')

    DeleteCreatorCheckpoints()
    cleanupObjects()

    RaceData.InCreator = false
    CreatorData.RaceName = nil
    CreatorData.RacerName = nil
    CreatorData.Checkpoints = {}
    CreatorData.IsEdit = false
    CreatorData.RaceId = nil
end

function GetClosestCheckpoint()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
    for id, _ in pairs(CreatorData.Checkpoints) do
        if current ~= nil then
            if #(pos -
                vector3(CreatorData.Checkpoints[id].coords.x, CreatorData.Checkpoints[id].coords.y,
                    CreatorData.Checkpoints[id].coords.z)) < dist then
                current = id
                dist = #(pos -
                           vector3(CreatorData.Checkpoints[id].coords.x, CreatorData.Checkpoints[id].coords.y,
                        CreatorData.Checkpoints[id].coords.z))
            end
        else
            dist = #(pos -
                       vector3(CreatorData.Checkpoints[id].coords.x, CreatorData.Checkpoints[id].coords.y,
                    CreatorData.Checkpoints[id].coords.z))
            current = id
        end
    end
    RaceData.ClosestCheckpoint = current
end

function CreatorUI()
    CreateThread(function()
        while true do
            if RaceData.InCreator then
                SendNUIMessage({
                    action = "update",
                    type = "creator",
                    data = CreatorData,
                    racedata = RaceData,
                    buttons = Config.Buttons,
                    active = true
                })
            else
                SendNUIMessage({
                    action = "update",
                    type = "creator",
                    data = CreatorData,
                    racedata = RaceData,
                    buttons = Config.Buttons,
                    active = false
                })
                break
            end
            Wait(200)
        end
    end)
end


function CreateCheckpointBlip(coords, id)
    local Blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(Blip, 1)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, Config.Blips.Generic.Size)
    SetBlipAsShortRange(Blip, true)
    SetBlipColour(Blip, Config.Blips.Generic.Color)
    ShowNumberOnBlip(Blip, id)
    SetBlipShowCone(Blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Checkpoint: " .. id)
    EndTextCommandSetBlipName(Blip)

    return Blip
end

local function redrawBlips()
    for id, CheckpointData in pairs(CreatorData.Checkpoints) do
        RemoveBlip(CheckpointData.blip)
        CheckpointData.blip = CreateCheckpointBlip(CheckpointData.coords, id)
    end
end

local function AddCheckpoint(checkpointId)
    local PlayerPed = PlayerPedId()
    local PlayerPos = GetEntityCoords(PlayerPed)
    local PlayerVeh = GetVehiclePedIsIn(PlayerPed)
    local Offset = {
        left = {
            x = (GetOffsetFromEntityInWorldCoords(PlayerVeh, -CreatorData.TireDistance, 0.0, 0.0)).x,
            y = (GetOffsetFromEntityInWorldCoords(PlayerVeh, -CreatorData.TireDistance, 0.0, 0.0)).y,
            z = (GetOffsetFromEntityInWorldCoords(PlayerVeh, -CreatorData.TireDistance, 0.0, 0.0)).z
        },
        right = {
            x = (GetOffsetFromEntityInWorldCoords(PlayerVeh, CreatorData.TireDistance, 0.0, 0.0)).x,
            y = (GetOffsetFromEntityInWorldCoords(PlayerVeh, CreatorData.TireDistance, 0.0, 0.0)).y,
            z = (GetOffsetFromEntityInWorldCoords(PlayerVeh, CreatorData.TireDistance, 0.0, 0.0)).z
        }
    }
    if checkpointId ~= nil then
        RemoveBlip(tonumber(CreatorData.Checkpoints[tonumber(checkpointId)].blip))
        local PileLeft = CreatorData.Checkpoints[tonumber(checkpointId)].pileleft
        if PileLeft then
            DeleteClosestObject(CreatorData.Checkpoints[tonumber(checkpointId)].offset.left, Config.StartAndFinishModel)
            DeleteClosestObject(CreatorData.Checkpoints[tonumber(checkpointId)].offset.left, Config.CheckpointPileModel)
            PileLeft = nil
        end

        local PileRight = CreatorData.Checkpoints[tonumber(checkpointId)].pileright
        if PileRight then
            DeleteClosestObject(CreatorData.Checkpoints[tonumber(checkpointId)].offset.right, Config.StartAndFinishModel)
            DeleteClosestObject(CreatorData.Checkpoints[tonumber(checkpointId)].offset.right, Config.CheckpointPileModel)
            PileRight = nil
        end

        CreatorData.Checkpoints[tonumber(checkpointId)] = {
            coords = {
                x = PlayerPos.x,
                y = PlayerPos.y,
                z = PlayerPos.z
            },
            offset = Offset
        }
    else
        CreatorData.Checkpoints[#CreatorData.Checkpoints + 1] = {
            coords = {
                x = PlayerPos.x,
                y = PlayerPos.y,
                z = PlayerPos.z
            },
            offset = Offset
        }
    end
    if #CreatorData.Checkpoints > Config.MaxCheckpoints then
        QBCore.Functions.Notify(Lang("max_checkpoints")..Config.MaxCheckpoints , 'error')
    end
    redrawBlips()
end


local function MoveCheckpoint()
    local dialog = exports['qb-input']:ShowInput({
        header = Lang("edit_checkpoint_header"),
        submitText = Lang("confirm"),
        inputs = {
            {
                text = "Checkpoint number", -- text you want to be displayed as a place holder
                name = "number", -- name of the input should be unique otherwise it might override
                type = "number", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },
        },
    })
    if dialog ~= nil then
        if useDebug then
            print('Moving checkpoint', dialog.number)
         end
        AddCheckpoint(dialog.number)
    end
end

local function clickAddCheckpoint()
    AddCheckpoint()
end

local function clickDeleteCheckpoint()
    if CreatorData.Checkpoints and next(CreatorData.Checkpoints) then
        DeleteCheckpoint()
    else
        QBCore.Functions.Notify(Lang("no_checkpoints_to_delete"), 'error')
    end
end

local function clickMoveCheckpoint()
    if CreatorData.Checkpoints and next(CreatorData.Checkpoints) then
        MoveCheckpoint()
    else
        QBCore.Functions.Notify(Lang("no_checkpoints_to_edit"), 'error')
    end
end

local function clickSaveRace()
    if CreatorData.Checkpoints and #CreatorData.Checkpoints >= Config.MinimumCheckpoints then
        SaveRace()
    else
        QBCore.Functions.Notify(Lang("not_enough_checkpoints") .. '(' ..Config.MinimumCheckpoints .. ')', 'error')
    end
end

local function clickIncreaseDistance()
    if CreatorData.TireDistance < Config.MaxTireDistance then
        CreatorData.TireDistance = CreatorData.TireDistance + 1.0
    else
        QBCore.Functions.Notify(Lang("max_tire_distance") .. Config.MaxTireDistance)
    end
end

local function clickDecreaseDistance()
    if CreatorData.TireDistance > Config.MinTireDistance then
        CreatorData.TireDistance = CreatorData.TireDistance - 1.0
    else
        QBCore.Functions.Notify(Lang("min_tire_distance") .. Config.MinTireDistance)
    end
end

local function clickExit()
    if not CreatorData.ConfirmDelete then
        CreatorData.ConfirmDelete = true
        QBCore.Functions.Notify(Lang("editor_confirm"), 'error')
    else
        DeleteCreatorCheckpoints()

        cleanupObjects()
        RaceData.InCreator = false
        CreatorData.RaceName = nil
        CreatorData.Checkpoints = {}
        QBCore.Functions.Notify(Lang("editor_canceled"), 'error')
        CreatorData.ConfirmDelete = false
    end
end


function CreatorLoop()
    redrawBlips()
    CreateThread(function()
        while RaceData.InCreator do
            local PlayerPed = PlayerPedId()
            local PlayerVeh = GetVehiclePedIsIn(PlayerPed)

            if PlayerVeh == 0 then
                local coords = GetEntityCoords(PlayerPedId())
                DrawText3Ds(coords.x, coords.y, coords.z, Lang("get_in_vehicle"))
            end
            Wait(10)
        end
    end)
end

local function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end
    return players
end

local ghostLoopStart = 0

local function actuallyValidateTime(Timer)
    if Timer == 0 then
        debugLog('Timer is off')
        return true
    else
        if GetTimeDifference(GetGameTimer(), ghostLoopStart) < Timer then
            if useDebug then
               print('Timer has NOT been reached', GetTimeDifference(GetGameTimer(), ghostLoopStart) )
            end
            return true
        end
        debugLog('Timer has been reached')
        return false
    end
end

local function validateTime()
    if CurrentRaceData.Ghosting and CurrentRaceData.GhostingTime then
        return actuallyValidateTime(CurrentRaceData.GhostingTime)
    else
        debugLog('Ghosting | Defaulting time validation. Ghosting:', CurrentRaceData.Ghosting, 'Ghosting Time:', CurrentRaceData.GhostingTime )
        return actuallyValidateTime(0)
    end
end

local function ghostThread()
    Citizen.CreateThread(function()
        while CurrentRaceData.Ghosted do
            Citizen.Wait(0)
            if CurrentRaceData.Started then
                local playerPed = PlayerPedId()
                local playerVehicle = GetVehiclePedIsIn(playerPed, false)
                local playerId = PlayerId()
                local playerServerId = GetPlayerServerId(playerId)

                for otherPlayercitizenID, otherPlayer in pairs(CurrentRaceData.Racers) do
                    if playerServerId ~= otherPlayer.RacerSource then
                        local otherPed = GetPlayerPed(GetPlayerFromServerId(otherPlayer.RacerSource))
                        local otherVehicle = GetVehiclePedIsIn(otherPed, false)
                        
                        if DoesEntityExist(otherVehicle) then
                            if playerVehicle and otherVehicle then
                                SetEntityNoCollisionEntity(playerVehicle, otherVehicle, true)
                                SetEntityNoCollisionEntity(otherVehicle, playerVehicle, true)
                                DisableCamCollisionForObject(otherVehicle)
                                DisableCamCollisionForEntity(otherVehicle)
                            end
                        else
                        end
                    end
                end
            else
                debugLog('Race wasnt started, skipping ghosting')
            end
        end
        debugLog('Player is not ghosted anymore')
    end)
end

function CreateGhostLoop()
    ghostLoopStart = GetGameTimer()
    if useDebug then
       print('^3 Starting ghost loop. All player:', json.encode(CurrentRaceData.Racers, {indent=true}))
    end
    CurrentRaceData.Ghosted = true
    ghostThread()
    Citizen.CreateThread(function()
        while CurrentRaceData.Started do
            if not validateTime() then
                debugLog('Breaking due to time')
                UnGhostPlayer()
                break
            end
            Wait(Config.Ghosting.DistanceLoopTime)
        end
    end)
end

local startTime = 0
local lapStartTime = 0

local function updateCountdown(value)
    AnimpostfxPlay('CrossLineOut', 0, false)
    SendNUIMessage({
        type = 'race',
        action = "countdown",
        data = {
            value = value
        },
        active = true
    })
end

local function RaceUI()
    CreateThread(function()
        while true do
            if CurrentRaceData.Checkpoints ~= nil and next(CurrentRaceData.Checkpoints) ~= nil then
                if CurrentRaceData.Started then
                    CurrentRaceData.RaceTime = GetTimeDifference(GetGameTimer(), lapStartTime)
                    CurrentRaceData.TotalTime = GetTimeDifference(GetGameTimer(), startTime)
                end
                SendNUIMessage({
                    action = "update",
                    type = "race",
                    data = {
                        currentCheckpoint = CurrentRaceData.CurrentCheckpoint,
                        totalCheckpoints = #CurrentRaceData.Checkpoints,
                        totalLaps = CurrentRaceData.TotalLaps,
                        currentLap = CurrentRaceData.Lap,
                        raceStarted = CurrentRaceData.Started,
                        raceName = CurrentRaceData.RaceName,
                        time = CurrentRaceData.RaceTime,
                        totalTime = CurrentRaceData.TotalTime,
                        bestLap = CurrentRaceData.BestLap,
                        position = CurrentRaceData.Position,
                        positions = CurrentRaceData.Positions,
                        totalRacers = CurrentRaceData.TotalRacers,
                        ghosted = CurrentRaceData.Ghosted,
                    },
                    racedata = RaceData,
                    active = true
                })
            else
                if not FinishedUITimeout then
                    FinishedUITimeout = true
                    SetTimeout(10000, function()
                        FinishedUITimeout = false
                        SendNUIMessage({
                            action = "update",
                            type = "race",
                            data = {},
                            racedata = RaceData,
                            active = false
                        })
                    end)
                end
                break
            end
            Wait(100)
        end
    end)
end

local function copyWihoutId(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[#copy+1] = value
	end
	return copy
end

local function bothOpponentsHaveDefinedPositions(aSrc, bSrc)

    local currentPlayer = GetPlayerPed(-1)
    local currentPlayerCoords = GetEntityCoords(currentPlayer, 0)    

    local aPly = GetPlayerFromServerId(aSrc)
    local aTarget = GetPlayerPed(aPly)
    local aCoords = GetEntityCoords(aTarget, 0)    

    local bPly = GetPlayerFromServerId(bSrc)
    local bTarget = GetPlayerPed(bPly)
    local bCoords = GetEntityCoords(bTarget, 0)

    if currentPlayer == aTarget then
        return #(currentPlayerCoords - bCoords) > 0 -- not defined if 0
    elseif currentPlayer == bTarget then
        return #(currentPlayerCoords - aCoords) > 0 -- not defined if 0
    else
        if #(currentPlayerCoords - aCoords) == 0 then
            return false
        elseif #(currentPlayerCoords - bCoords) == 0 then
            return false
        else
            return #(bCoords - aCoords) > 0
        end
    end
end

local function distanceToCheckpoint(src, checkpoint)
    local ped = GetPlayerFromServerId(src)
    local target = GetPlayerPed(ped)
    local pos = GetEntityCoords(target, 0)
    local next
    if checkpoint + 1 > #CurrentRaceData.Checkpoints then
        next = CurrentRaceData.Checkpoints[1]
    else
        next = CurrentRaceData.Checkpoints[checkpoint+1]
    end
    
    local distanceToNext = #(pos - vector3(next.coords.x, next.coords.y, next.coords.z))
    return distanceToNext
end

local function placements(CurrentRaceData)
    local tempPositions = copyWihoutId(CurrentRaceData.Racers)
    if #tempPositions > 1 then
        table.sort(tempPositions, function(a,b)
            if a.Lap > b.Lap then return true
            elseif a.Lap < b.Lap then return false
            elseif a.Lap == b.Lap then
                if a.Checkpoint > b.Checkpoint then return true
                elseif a.Checkpoint < b.Checkpoint then return false
                elseif a.Checkpoint == b.Checkpoint then
                    if CheckDistance and bothOpponentsHaveDefinedPositions(a.RacerSource, b.RacerSource) then
                        return distanceToCheckpoint(a.RacerSource, a.Checkpoint) < distanceToCheckpoint(b.RacerSource, b.Checkpoint)
                    else
                        if a.RaceTime ~= nil and b.RaceTime ~= nil and a.RaceTime < b.RaceTime then
                            return true
                        else
                            return false
                        end
                    end
                end
            end
        end)
    end
    return tempPositions
end

local function positionThread()
    CreateThread(function()
        while true do
            if CurrentRaceData.Checkpoints ~= nil and next(CurrentRaceData.Checkpoints) ~= nil then
                local positions = placements(CurrentRaceData)
                local MyPosition = getIndex(positions)
                CurrentRaceData.Position = MyPosition
                CurrentRaceData.Positions = positions
            else

                break
            end
            Wait(1000)
        end
    end)
end

local function SetupRace(RaceData, Laps)
    local checkpoints = RaceData.Checkpoints
    if RaceData.Reversed then checkpoints = reverseTable(checkpoints) end
    CurrentRaceData = {
        RaceId = RaceData.RaceId,
        Creator = RaceData.Creator,
        OrganizerCID = RaceData.OrganizerCID,
        RacerName = RaceData.RacerName,
        RaceName = RaceData.RaceName,
        Checkpoints = checkpoints,
        Ghosting = RaceData.Ghosting,
        GhostingTime = RaceData.GhostingTime,
        Ranked = RaceData.Ranked,
        Reversed = RaceData.Reversed,
        Started = false,
        CurrentCheckpoint = 1,
        TotalLaps = Laps,
        Lap = 1,
        RaceTime = 0,
        TotalTime = 0,
        BestLap = 0,
        MaxClass = RaceData.MaxClass,
        Racers = {},
        Position = 0
    }
    doGPSForRace()
    debugLog('Race Was setup:', json.encode(CurrentRaceData))
    RaceUI()
end

local function showNonLoopParticle(dict, particleName, coords, scale, time)
    while not HasNamedPtfxAssetLoaded(dict) do
        RequestNamedPtfxAsset(dict)
        Wait(0)
    end

    UseParticleFxAssetNextCall(dict)

    local particleHandle = StartParticleFxLoopedAtCoord(particleName, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0,
    scale, false, false, false)
    SetParticleFxLoopedColour(particleHandle,0.0,0.0,1.0)
    return particleHandle
end

local function handleFlare (checkpoint)

    local Size = 1.0
    local left = showNonLoopParticle('core', 'exp_grd_flare',
        CurrentRaceData.Checkpoints[checkpoint].offset.left, Size)
    local right = showNonLoopParticle('core', 'exp_grd_flare',
        CurrentRaceData.Checkpoints[checkpoint].offset.right, Size)

    SetTimeout(Config.FlareTime, function()
        StopParticleFxLooped(left, false)
        StopParticleFxLooped(right, false)
    end)
end


local function DoPilePfx()
    if CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1] ~= nil then
        handleFlare(CurrentRaceData.CurrentCheckpoint + 1)
    end
    if CurrentRaceData.CurrentCheckpoint == 1 then -- start
        debugLog('start')
        handleFlare(CurrentRaceData.CurrentCheckpoint)

    end
    if CurrentRaceData.TotalLaps > 0 and CurrentRaceData.CurrentCheckpoint == #CurrentRaceData.Checkpoints then -- finish
        debugLog('finish')
        handleFlare(1)
        if CurrentRaceData.Lap ~= CurrentRaceData.TotalLaps then
            debugLog('not last lap')
            handleFlare(2)
        end
    end
end

local function GetMaxDistance(OffsetCoords)
    local Distance = #(vector3(OffsetCoords.left.x, OffsetCoords.left.y, OffsetCoords.left.z) -
                         vector3(OffsetCoords.right.x, OffsetCoords.right.y, OffsetCoords.right.z))
    local Retval = 12.5
    if Distance > 20.0 then
        Retval = 18.5
    end
    return Retval
end

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

function DeleteCurrentRaceCheckpoints()
    for k, v in pairs(CurrentRaceData.Checkpoints) do
        local CurrentCheckpoint = CurrentRaceData.Checkpoints[k]
        local Blip = CurrentCheckpoint.blip
        if Blip then
            RemoveBlip(Blip)
            Blip = nil
        end

        local PileLeft = CurrentCheckpoint.pileleft
        if PileLeft then
            DeleteClosestObject(CurrentCheckpoint.offset.left, Config.StartAndFinishModel)
            DeleteClosestObject(CurrentCheckpoint.offset.left, Config.CheckpointPileModel)
            PileLeft = nil
        end

        local PileRight = CurrentCheckpoint.pileright
        if PileRight then
            DeleteClosestObject(CurrentCheckpoint.offset.right, Config.StartAndFinishModel)
            DeleteClosestObject(CurrentCheckpoint.offset.right, Config.CheckpointPileModel)
            PileRight = nil
        end
    end

    CurrentRaceData.RaceName = nil
    CurrentRaceData.Checkpoints = {}
    CurrentRaceData.Started = false
    CurrentRaceData.CurrentCheckpoint = 0
    CurrentRaceData.TotalLaps = 0
    CurrentRaceData.Lap = 0
    CurrentRaceData.RaceTime = 0
    CurrentRaceData.TotalTime = 0
    CurrentRaceData.BestLap = 0
    CurrentRaceData.RaceId = nil
    CurrentRaceData.RacerName = nil
    RaceData.InRace = false
end

local function isDriver(vehicle) 
    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

local function FinishRace()
    if CurrentRaceData.RaceId == nil then
        return
    end
    local PlayerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)
    if not isDriver(vehicle) then
        QBCore.Functions.Notify(Lang('kicked_cheese'), 'error')
        TriggerServerEvent("cw-racingapp:server:LeaveRace", CurrentRaceData, 'cheeseing')
        return
    end

    local info, class, perfRating = exports['cw-performance']:getVehicleInfo(vehicle)
    local vehicleModel, vehicleMaker = getVehicleFromVehList(GetEntityModel(vehicle))
    -- print('NEW TIME TEST', currentTotalTime, SecondsToClock(currentTotalTime))
    debugLog('Best lap:', CurrentRaceData.BestLap, 'Total:', CurrentRaceData.TotalTime)
    TriggerServerEvent('cw-racingapp:server:FinishPlayer', CurrentRaceData, CurrentRaceData.TotalTime,
        CurrentRaceData.TotalLaps, CurrentRaceData.BestLap, class, vehicleModel, currentRanking, currentCrew)
    QBCore.Functions.Notify(Lang("race_finished") .. MilliToTime(CurrentRaceData.TotalTime), 'success')
    if CurrentRaceData.BestLap ~= 0 then
        QBCore.Functions.Notify(Lang("race_best_lap") .. MilliToTime(CurrentRaceData.BestLap), 'success')
    end
    UnGhostPlayer()
    Players = {}
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    DeleteCurrentRaceCheckpoints()
    CurrentRaceData.RaceId = nil
end



function IsInRace()
    local retval = false
    if RaceData.InRace then
        retval = true
    end
    return retval
end exports('IsInRace', IsInRace)


function IsInEditor()
    local retval = false
    if RaceData.InCreator then
        retval = true
    end
    return retval
end exports('IsInEditor', IsInEditor)


function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-----------------------
----   Threads     ----
-----------------------



CreateThread(function()
    while true do
        if RaceData.InCreator then
            GetClosestCheckpoint()
            SetupPiles()
        end
        Wait(1000)
    end
end)

local function genericBlip(Blip)
    SetBlipScale(Blip, Config.Blips.Generic.Size)
    SetBlipColour(Blip, Config.Blips.Generic.Color)
end

local function nextBlip(Blip)
    SetBlipScale(Blip, Config.Blips.Next.Size)
    SetBlipColour(Blip, Config.Blips.Next.Color)
end

local function passedBlip(Blip)
    SetBlipScale(Blip, Config.Blips.Passed.Size)
    SetBlipColour(Blip, Config.Blips.Passed.Color)
end

local function resetBlips()
    for i, checkpoint in pairs(CurrentRaceData.Checkpoints) do
        genericBlip(checkpoint.blip)
    end
end

local function markWithUglyWaypoint()
    if UseUglyWaypoint then
        if #CurrentRaceData.Checkpoints == CurrentRaceData.CurrentCheckpoint then
            SetNewWaypoint(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].coords.x, CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].coords.y)
        elseif #CurrentRaceData.Checkpoints > CurrentRaceData.CurrentCheckpoint+1 then
            SetNewWaypoint(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint+2].coords.x, CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint+2].coords.y)
        else
            SetNewWaypoint(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint+1].coords.x, CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint+1].coords.y)
        end
    end
end

local timeWhenLastCheckpointWasPassed = 0
-- Racing

local function checkCheckPointTime()
    if GetTimeDifference(GetGameTimer(), timeWhenLastCheckpointWasPassed) > Config.KickTime then
        debugLog('Getting kicked for idling')
        if not Kicked then
            Kicked = true
            QBCore.Functions.Notify(Lang('kicked_idling'), 'error')
            TriggerServerEvent("cw-racingapp:server:LeaveRace", CurrentRaceData, 'idling')
        end
    end
end

CreateThread(function()
    while true do
        if not Kicked and CurrentRaceData.RaceName ~= nil then
            if CurrentRaceData.Started then
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local cp = 0
                if CurrentRaceData.CurrentCheckpoint + 1 > #CurrentRaceData.Checkpoints then
                    cp = 1
                else
                    cp = CurrentRaceData.CurrentCheckpoint + 1
                end
                local data = CurrentRaceData.Checkpoints[cp]
                local CheckpointDistance = #(pos - vector3(data.coords.x, data.coords.y, data.coords.z))
                local MaxDistance = GetMaxDistance(CurrentRaceData.Checkpoints[cp].offset)
                if CheckpointDistance < MaxDistance then
                    if CurrentRaceData.TotalLaps == 0 then -- Sprint
                        if CurrentRaceData.CurrentCheckpoint + 1 < #CurrentRaceData.Checkpoints then
                            CurrentRaceData.CurrentCheckpoint = CurrentRaceData.CurrentCheckpoint + 1
                            if IgnoreRoadsForGps then
                                AddPointToGpsCustomRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x,CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
                            else
                                AddPointToGpsMultiRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x,CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
                            end
                            TriggerServerEvent('cw-racingapp:server:UpdateRacerData', CurrentRaceData.RaceId,
                                CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, false, CurrentRaceData.TotalTime)
                            DoPilePfx()
                            PlaySoundFrontend(-1, Config.Sounds.Checkpoint.lib, Config.Sounds.Checkpoint.sound)
                            passedBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].blip)
                            nextBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].blip)
                            markWithUglyWaypoint()
                        else
                            DoPilePfx()
                            CurrentRaceData.CurrentCheckpoint = CurrentRaceData.CurrentCheckpoint + 1
                            TriggerServerEvent('cw-racingapp:server:UpdateRacerData', CurrentRaceData.RaceId,
                                CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, true, CurrentRaceData.TotalTime)
                            PlaySoundFrontend(-1, Config.Sounds.Finish.lib, Config.Sounds.Finish.sound)
                            FinishRace()
                        end
                        timeWhenLastCheckpointWasPassed = GetGameTimer()
                    else -- Circuit
                        if CurrentRaceData.CurrentCheckpoint + 1 > #CurrentRaceData.Checkpoints then -- If new lap
                            if CurrentRaceData.Lap + 1 > CurrentRaceData.TotalLaps then -- if finish
                                DoPilePfx()
                                PlaySoundFrontend(-1, Config.Sounds.Checkpoint.lib, Config.Sounds.Checkpoint.sound)
                                if CurrentRaceData.RaceTime < CurrentRaceData.BestLap then
                                    CurrentRaceData.BestLap = CurrentRaceData.RaceTime
                                    debugLog('racetime less than bestlap', CurrentRaceData.RaceTime < CurrentRaceData.BestLap, CurrentRaceData.RaceTime, CurrentRaceData.BestLap)
                                elseif CurrentRaceData.BestLap == 0 then
                                    debugLog('bestlap == 0', CurrentRaceData.BestLap)
                                    CurrentRaceData.BestLap = CurrentRaceData.RaceTime
                                end
                                CurrentRaceData.CurrentCheckpoint = CurrentRaceData.CurrentCheckpoint + 1
                                TriggerServerEvent('cw-racingapp:server:UpdateRacerData', CurrentRaceData.RaceId,
                                    CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, true, CurrentRaceData.TotalTime)
                                FinishRace()
                                PlaySoundFrontend(-1, Config.Sounds.Finish.lib, Config.Sounds.Finish.sound)
                            else -- if next lap
                                DoPilePfx()
                                resetBlips()
                                PlaySoundFrontend(-1, Config.Sounds.Checkpoint.lib, Config.Sounds.Checkpoint.sound)
                                if CurrentRaceData.RaceTime < CurrentRaceData.BestLap then
                                    debugLog('racetime less than bestlap', CurrentRaceData.RaceTime < CurrentRaceData.BestLap, CurrentRaceData.RaceTime, CurrentRaceData.BestLap)
                                    CurrentRaceData.BestLap = CurrentRaceData.RaceTime
                                elseif CurrentRaceData.BestLap == 0 then
                                    debugLog('bestlap == 0', CurrentRaceData.BestLap)
                                    CurrentRaceData.BestLap = CurrentRaceData.RaceTime
                                end
                                lapStartTime = GetGameTimer()
                                CurrentRaceData.Lap = CurrentRaceData.Lap + 1
                                CurrentRaceData.CurrentCheckpoint = 1
                                if IgnoreRoadsForGps then
                                    AddPointToGpsCustomRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x,CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
                                else
                                    AddPointToGpsMultiRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x,CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
                                end
                                TriggerServerEvent('cw-racingapp:server:UpdateRacerData', CurrentRaceData.RaceId,
                                    CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, false, CurrentRaceData.TotalTime)
                                doGPSForRace(true)
                                passedBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].blip)
                                nextBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].blip)
                                markWithUglyWaypoint()
                            end
                            timeWhenLastCheckpointWasPassed = GetGameTimer()
                        else -- if next checkpoint 
                            CurrentRaceData.CurrentCheckpoint = CurrentRaceData.CurrentCheckpoint + 1
                            if CurrentRaceData.CurrentCheckpoint ~= #CurrentRaceData.Checkpoints then
                                if IgnoreRoadsForGps then
                                    AddPointToGpsCustomRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x, CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
                                else
                                    AddPointToGpsMultiRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x, CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
                                end
                                TriggerServerEvent('cw-racingapp:server:UpdateRacerData', CurrentRaceData.RaceId,
                                    CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, false, CurrentRaceData.TotalTime)
                                passedBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].blip)
                                nextBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].blip)
                                markWithUglyWaypoint()
                            else
                                if IgnoreRoadsForGps then
                                    AddPointToGpsCustomRoute(CurrentRaceData.Checkpoints[1].coords.x,CurrentRaceData.Checkpoints[1].coords.y)
                                else
                                    AddPointToGpsMultiRoute(CurrentRaceData.Checkpoints[1].coords.x,CurrentRaceData.Checkpoints[1].coords.y)
                                end
                                TriggerServerEvent('cw-racingapp:server:UpdateRacerData', CurrentRaceData.RaceId,
                                    CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, false, CurrentRaceData.TotalTime)
                                passedBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].blip)
                                nextBlip(CurrentRaceData.Checkpoints[1].blip)
                                markWithUglyWaypoint()
                            end
                            timeWhenLastCheckpointWasPassed = GetGameTimer()
                            DoPilePfx()
                            PlaySoundFrontend(-1, Config.Sounds.Checkpoint.lib, Config.Sounds.Checkpoint.sound)
                        end
                    end
                else
                    checkCheckPointTime()
                end
            else
                local data = CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint]
                DrawMarker(4, data.coords.x, data.coords.y, data.coords.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.9, 1.5,
                    1.5, 255, 255, 255, 255, 0, 1, 0, 0, 0, 0, 0)
                    nextBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint+1].blip)
            end
        else
            Wait(1000)
        end

        Wait(0)
    end
end)

-- Creator
CreateThread(function()
    while true do
        if RaceData.InCreator then
            local PlayerPed = PlayerPedId()
            local PlayerVeh = GetVehiclePedIsIn(PlayerPed)
            if creatorObjectLeft and creatorObjectRight ~= nil then
                cleanupObjects()
            end
            creatorCheckpointObject = Config.CheckpointPileModel

            if PlayerVeh ~= 0 then
                local Offset = {
                    left = {
                        x = (GetOffsetFromEntityInWorldCoords(PlayerVeh, -CreatorData.TireDistance, 0.0, 0.0)).x,
                        y = (GetOffsetFromEntityInWorldCoords(PlayerVeh, -CreatorData.TireDistance, 0.0, 0.0)).y,
                        z = (GetOffsetFromEntityInWorldCoords(PlayerVeh, -CreatorData.TireDistance, 0.0, 0.0)).z
                    },
                    right = {
                        x = (GetOffsetFromEntityInWorldCoords(PlayerVeh, CreatorData.TireDistance, 0.0, 0.0)).x,
                        y = (GetOffsetFromEntityInWorldCoords(PlayerVeh, CreatorData.TireDistance, 0.0, 0.0)).y,
                        z = (GetOffsetFromEntityInWorldCoords(PlayerVeh, CreatorData.TireDistance, 0.0, 0.0)).z
                    }
                }
                DrawMarker(22, Offset.left.x, Offset.left.y, Offset.left.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 2.5, 1.5, 255, 150, 0, 255, 0, 1, 0, 0, 0, 0, 0)
                DrawMarker(22, Offset.right.x, Offset.right.y, Offset.right.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 2.5, 1.5, 255, 150, 0, 255, 0, 1, 0, 0, 0, 0, 0)
            end
        end
        Wait(0)
    end
end)

-----------------------
---- Client Events ----
-----------------------

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if IgnoreRoadsForGps then
            ClearGpsCustomRoute()
        else
            ClearGpsMultiRoute()
        end
        DeleteAllCheckpoints()
    end
end)

RegisterNetEvent('cw-racingapp:client:ReadyJoinRace', function(RaceData)
    local PlayerPed = PlayerPedId()
    local PlayerIsInVehicle = IsPedInAnyVehicle(PlayerPed, false)

    local info, class, perfRating = '', '', ''
    if PlayerIsInVehicle then
        info, class, perfRating = exports['cw-performance']:getVehicleInfo(GetVehiclePedIsIn(PlayerPed, false))
    else
        QBCore.Functions.Notify(Lang('not_in_a_vehicle'), 'error')
        return
    end
    
    if myCarClassIsAllowed(RaceData.MaxClass, class) then
        RaceData.RacerName = currentName
        RaceData.RaceCrew = currentCrew
        RaceData.PlayerVehicleEntity = GetVehiclePedIsIn(PlayerPed, false)
        TriggerServerEvent('cw-racingapp:server:JoinRace', RaceData)
    else 
        QBCore.Functions.Notify(Lang('incorrect_class'), 'error')
    end
end)

local function openCreatorUi()
    CreatorUI()
    CreatorLoop()
end

RegisterNetEvent('cw-racingapp:client:StartRaceEditor', function(RaceName, RacerName, RaceId, Checkpoints)
    if not RaceData.InCreator then
        CreatorData.RaceName = RaceName
        CreatorData.RacerName = RacerName
        RaceData.InCreator = true
        if type(Checkpoints) == 'table' then
            debugLog('Using shared, checkpoint existed')
            CreatorData.Checkpoints = Checkpoints
            clickSaveRace()
            return
        end
        if RaceId then
            QBCore.Functions.TriggerCallback('cw-racingapp:server:GetTrackData', function(track)
                if track then
                    CreatorData.RaceName = RaceName
                    CreatorData.RacerName = RacerName
                    CreatorData.RaceId = RaceId
                    CreatorData.CheckPoints = {}
                    CreatorData.TireDistance = 3.0
                    CreatorData.ConfirmDelete = false
                    CreatorData.IsEdit = true
                    for i, checkpoint in pairs(track.Checkpoints) do
                        CreatorData.Checkpoints[#CreatorData.Checkpoints+1] = checkpoint
                    end
                    openCreatorUi()
                    
                else
                    print('Something went wrong with fetching this track')
                end
            end, RaceId)
        else
            CreatorData.IsEdit = false
            openCreatorUi()
        end
    else
        QBCore.Functions.Notify(Lang("already_making_race"), 'error')
    end
end)


-- Exampl
local function checkElimination()
    local currentPlayerIsLast = true
    local lastCompletedLap = 0
    -- Find the last completed lap and racer
    for citizenId, data in pairs(CurrentRaceData.Racers) do
        if QBCore.Functions.GetPlayerData().citizenid ~= citizenId then
            if not data.Finished and data.Lap <= CurrentRaceData.Lap then
                currentPlayerIsLast = false -- someone was worse
            end
            if lastCompletedLap < data.Lap then
                lastCompletedLap = data.Lap
            end
        end
    end
    debugLog('Is Last racer', currentPlayerIsLast, 'lap:', lastCompletedLap)
    -- Check if the current racer is the last one who completed the lap
    if currentPlayerIsLast and lastCompletedLap >= CurrentRaceData.Lap then
        debugLog("Eliminating racer: " .. QBCore.Functions.GetPlayerData().citizenid)
        TriggerServerEvent("cw-racingapp:server:LeaveRace", CurrentRaceData, 'elimination')
        QBCore.Functions.Notify(Lang("eliminated"), 'error')
    end
end

RegisterNetEvent('cw-racingapp:client:UpdateRaceRacerData', function(RaceId, RaceData)
    if (CurrentRaceData.RaceId ~= nil) and CurrentRaceData.RaceId == RaceId then
        debugLog('Race is Elimination:', CurrentRaceData.IsElimination)
        CurrentRaceData.Racers = RaceData.Racers
        if CurrentRaceData.IsElimination then
            checkElimination()
        end
    end
end)

RegisterNetEvent('cw-racingapp:client:JoinRace', function(Data, Laps, RacerName)
    if not RaceData.InRace then
        Data.RacerName = RacerName
        RaceData.InRace = true
        SetupRace(Data, Laps)
        QBCore.Functions.Notify(Lang("race_joined"))
        TriggerServerEvent('cw-racingapp:server:UpdateRaceState', CurrentRaceData.RaceId, false, true)
    else
        QBCore.Functions.Notify(Lang("already_in_race"), 'error')
    end
end)

RegisterNetEvent('cw-racingapp:client:UpdateRaceRacers', function(RaceId, Racers)
    if CurrentRaceData.RaceId == RaceId then
        CurrentRaceData.Racers = Racers
    end
end)


RegisterNetEvent('cw-racingapp:client:UpdateOrganizer', function(RaceId, organizer)
    if CurrentRaceData.RaceId == RaceId then
        debugLog('updating organizer')
        CurrentRaceData.OrganizerCID = organizer
    end
end)

RegisterNetEvent('cw-racingapp:client:LeaveRace', function(data)
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    Countdown = 10
    updateCountdown(-1)
    UnGhostPlayer()
    DeleteCurrentRaceCheckpoints()
    FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), false), false)
end)

RegisterNetEvent("cw-racingapp:Client:DeleteTrackConfirmed", function(data)
    QBCore.Functions.Notify(data.RaceName.." "..Lang("has_been_removed"))
    TriggerServerEvent("cw-racingapp:server:DeleteTrack", data.RaceId)
end)

RegisterNetEvent("cw-racingapp:Client:ClearLeaderboardConfirmed", function(data)
    QBCore.Functions.Notify(data.RaceName.." "..Lang("leaderboard_has_been_cleared"))
    TriggerServerEvent("cw-racingapp:server:ClearLeaderboard", data.RaceId)
end)

RegisterNetEvent("cw-racingapp:Client:EditTrack", function(data)
    TriggerEvent("cw-racingapp:client:StartRaceEditor", data.RaceName, data.name, data.RaceId)
end)

local function findRacerByName(name)
    if MyRacerNames then
        for i, user in pairs(MyRacerNames) do
            if currentName == user.racername then return user end
        end
    end
    return false
end

RegisterNetEvent("cw-racingapp:Client:UpdateRacerNames", function(data)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetRacerNamesByPlayer', function(playerNames)
        MyRacerNames = playerNames
        local currentRacer = findRacerByName(currentName, MyRacerNames)
        QBCore.Functions.Notify(Lang("user_list_updated"))
        if currentRacer and currentRacer.revoked == 1 then 
            QBCore.Functions.Notify(Lang("revoked_access"), 'error')
        end
    end, GetPlayerServerId(PlayerId()))
end)

function split(source)
    local str = source:gsub("%s+", "")
    str = string.gsub(str, "%s+", "")
    local result, i = {}, 1
    while true do
        local a, b = str:find(',')
        if not a then break end
        local candidat = str:sub(1, a - 1)
        if candidat ~= "" then 
            result[i] = candidat
        end i=i+1
        str = str:sub(b + 1)
    end
    if str ~= "" then 
        result[i] = str
    end
    return result
end

local function filterTracksByRacer(Tracks)
    local filteredTracks = {}
    for i, track in pairs(Tracks) do      
        if track.Creator == QBCore.Functions.GetPlayerData().citizenid then
            filteredTracks[i] = track
        end
    end
    return filteredTracks
end

local function isPositionCheating()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local current = CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint]
    local next = CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint+1]
    
    local distanceToStart = #(pos - vector3(current.coords.x, current.coords.y, current.coords.z))
    local distanceToNext = #(pos - vector3(next.coords.x, next.coords.y, next.coords.z))

    local distanceBetween = #(vector3(next.coords.x, next.coords.y, next.coords.z) - vector3(current.coords.x, current.coords.y, current.coords.z))
    
    return distanceBetween > distanceToNext
end

RegisterNetEvent('cw-racingapp:client:RaceCountdown', function(TotalRacers)
    doGPSForRace(true)
    Players = {}
    Kicked = false
    TriggerServerEvent('cw-racingapp:server:UpdateRaceState', CurrentRaceData.RaceId, true, false)
    CurrentRaceData.TotalRacers = TotalRacers
    positionThread()
    if CurrentRaceData.TotalLaps == -1 then 
        debugLog('^3Race is Elimination! setting laps to:', CurrentRaceData.TotalRacers-1)
        CurrentRaceData.TotalLaps = CurrentRaceData.TotalRacers-1
        CurrentRaceData.IsElimination = true
    end
    if CurrentRaceData.RaceId ~= nil then
        while Countdown ~= 0 do
            if CurrentRaceData.RaceName ~= nil then
                if Countdown == 10 then
                    updateCountdown(10)
                    PlaySoundFrontend(-1, Config.Sounds.Countdown.start.lib, Config.Sounds.Countdown.start.sound)
                elseif Countdown <= 5 then
                    updateCountdown(Countdown)
                    PlaySoundFrontend(-1, Config.Sounds.Countdown.number.lib, Config.Sounds.Countdown.number.sound)
                end
                Countdown = Countdown - 1
                FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), true), true)
            else
                break
            end
            Wait(1000)
        end
        if CurrentRaceData.RaceName ~= nil then
            updateCountdown(0)
            PlaySoundFrontend(-1, Config.Sounds.Countdown.go.lib, Config.Sounds.Countdown.go.sound)
            if isPositionCheating() then 
                TriggerServerEvent("cw-racingapp:server:LeaveRace", CurrentRaceData, 'positionCheat')
                QBCore.Functions.Notify(Lang("kicked_line"), 'error')
                FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), true), false)
                return 
            end
            if IgnoreRoadsForGps then
                AddPointToGpsCustomRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x, CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
            else
               AddPointToGpsMultiRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x, CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
            end
            markWithUglyWaypoint()
            SetBlipScale(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].blip, Config.Blips.Generic.Size)
            FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), true), false)
            DoPilePfx()
            if Config.Ghosting.Enabled and CurrentRaceData.Ghosting then
                Players = GetPlayers()
                GhostPlayers()
            end
            lapStartTime = GetGameTimer()
            startTime = GetGameTimer()
            CurrentRaceData.Started = true
            timeWhenLastCheckpointWasPassed = GetGameTimer()
            Countdown = 10
        else
            FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), true), false)
            Countdown = 10
        end
    else
        QBCore.Functions.Notify(Lang("already_in_race"), 'error')
    end
end)

RegisterNetEvent('cw-racingapp:client:PlayerFinish', function(RaceId, Place, RacerName)
    if CurrentRaceData.RaceId ~= nil then
        if CurrentRaceData.RaceId == RaceId then
            QBCore.Functions.Notify(RacerName .. " ".. Lang("racer_finished_place") .. Place, 'primary', 3500)
        end
    end
end)

RegisterNetEvent('cw-racingapp:client:NotCloseEnough', function(x,y)
    QBCore.Functions.Notify(Lang('not_close_enough_to_join'), 'error')
    SetNewWaypoint(x, y)
end)

local function verifyTrackAccess(track, type)
    if track.Access[type] ~= nil then
        if track.Access[type][1] == nil then print('no values', track.RaceName) return true end -- if list is added but emptied 
        local playerCid = QBCore.Functions.GetPlayerData().citizenid
        if track.Creator == playerCid then return true end -- if creator default to true
        if useDebug then
            print('track', track.RaceName, 'has access limitations for', type)
            print('player cid', playerCid)
        end
        for i, citizenId in pairs(track.Access[type]) do
            debugLog(i, citizenId)
            if citizenId == playerCid then return true end -- if one of the players in the list
        end
        return false
    end
    return true
end

local function indexOf(array, value)
    for i, v in ipairs(array) do
        print(i, value)
        if i == value then
            return i
        end
    end
    return nil
end

local function racerNameIsValid(name)
    if #name > Config.MinRacerNameLength then
        if #name < Config.MaxRacerNameLength then
            return true
        else
            QBCore.Functions.Notify(Lang('name_too_long'), 'error')
        end
    else
        QBCore.Functions.Notify(Lang('name_too_short'), 'error')
    end
    return false
end

local function hasPermission(userType)
    if currentAuth == 'god' then 
        return true
    elseif userType == 'racer' and Config.AllowRacerCreationForAnyone then
        return true 
    elseif currentAuth == 'master' and (userType == 'creator' or userType == 'racer') then
        return true
    end
    return false
end

local function hasAuth(tradeType, userType)
    if currentAuth and Config.Permissions[currentAuth] and Config.Permissions[currentAuth].controlAll then 
        debugLog('User has controlall auth')
        return true 
    end

    if tradeType.jobRequirement[userType] == true then
        debugLog('job requirement exists for', userType)
        local Player = QBCore.Functions.GetPlayerData()
        local playerHasJob = Config.AllowedJobs[Player.job.name]
        local jobGradeReq = nil
        if useDebug then
           print('Player job: ', Player.job.name)
           print('Allowed jobs: ', dump(Config.AllowedJobs))
        end
        if playerHasJob then
            debugLog('Player job level: ', Player.job.grade.level)
            if Config.AllowedJobs[Player.job.name] ~= nil then
                jobGradeReq = Config.AllowedJobs[Player.job.name][userType]
                if useDebug then
                   print('Required job grade: ', jobGradeReq)
                end
                if jobGradeReq ~= nil then
                    if Player.job.grade.level >= jobGradeReq then
                        return hasPermission(userType)
                    end
                end
            end
        end
        return false
    elseif tradeType.jobRequirement[userType] == nil then
        debugLog('Requiement is nil for', userType)
        return false
    else
        debugLog('Requiement is false for', userType)
        return true
    end
end

local function racerNameExists(listOfNames, racerName)
    for i, data in pairs(listOfNames) do
        if data.racername == racerName then
            return true
        end
    end
    return false
end

local function createOxInput(fobType, purchaseType)
    if not lib then
        print('^1OxInput is enabled but no lib was found. Might be missing from fxmanifest or the dev is not able to read the config')
    else
        local options = {{type = 'input', label = 'Racer Name', required = true, min = 1, max = 100}}

        if not purchaseType.useSlimmed then
            options[#options+1] =  {type = 'number', label = 'Paypal/temp id (leave empty if for you)', min = 1, max = 20}
        end
        local FobInput = lib.inputDialog('Creating a ['..fobType..'] type user', options)
        return FobInput
    end
end

local function createQbInput(fobType, purchaseType)
    local inputs = {
        {
            text = 'Racer Name', -- text you want to be displayed as a place holder
            name = "racerName", -- name of the input should be unique otherwise it might override
            type = "text", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
        },
    }

    if not purchaseType.useSlimmed then
        inputs[#inputs+1] = {
            text = 'Paypal/temp id (leave empty if for you)', -- text you want to be displayed as a place holder
            name = "racerId", -- name of the input should be unique otherwise it might override
            type = "text", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
        }
    end
    local dialog = exports['qb-input']:ShowInput({
        header = 'Creating a ['..fobType..'] type user',
        submitText = 'Submit',
        inputs = inputs
    })
    return dialog
end

local function attemptCreateUser(racerName, racerId, fobType, purchaseType)
    if useDebug then 
        print('Racername', racerName)
        print('RacerId', racerId)
    end
    if racerId == nil or racerId == '' then
        racerId = GetPlayerServerId(PlayerId())
    end
    if racerNameIsValid(racerName) then
        QBCore.Functions.TriggerCallback('cw-racingapp:server:GetRacerNamesByPlayer', function(playerNames)
            debugLog('player names', #playerNames, json.encode(playerNames))
            local maxRacerNames = Config.MaxRacerNames
            if Config.UseNameValidation and #playerNames > 1 and playerNames[1].citizenid and Config.CustomAmounts[playerNames[1].citizenid] then
                maxRacerNames = Config.CustomAmounts[playerNames[1].citizenid]
            end

            debugLog('Racer names allowed for', racerId, maxRacerNames)
            if playerNames == nil or racerNameExists(playerNames, racerName) or #playerNames < maxRacerNames then
                QBCore.Functions.TriggerCallback('cw-racingapp:server:NameIsAvailable', function(nameIsNotTaken)
                    if nameIsNotTaken then
                        TriggerEvent('animations:client:EmoteCommandStart', {"idle7"})
                        QBCore.Functions.Progressbar("item_check", 'Creating Racing User Account', 2000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                            }, {
                            }, {}, {}, function() -- Done
                                TriggerServerEvent('cw-racingapp:server:CreateRacerName', racerId, racerName, fobType, purchaseType)
                                TriggerEvent('animations:client:EmoteCommandStart', {"keyfob"})
                            end, function()
                                TriggerEvent('animations:client:EmoteCommandStart', {"damn"})
                            end)
                    else
                        QBCore.Functions.Notify( Lang("name_is_used")..racerName, 'error')
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    end
                end, racerName, racerId)
            else
                QBCore.Functions.Notify( Lang("to_many_names"), 'error')
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            end
        end, racerId)

    else
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end
end

RegisterNetEvent("cw-racingapp:client:OpenFobInput", function(data)
    local purchaseType = data.purchaseType
    local fobType = data.fobType

    QBCore.Functions.Notify(Lang("max_uniques").. " " ..Config.MaxRacerNames)

    local dialog = nil
    local racerName = nil
    local racerId = nil
    if Config.OxInput then
        dialog = createOxInput(fobType, purchaseType)
        racerName = dialog[1]
        racerId = dialog[2]
    else
        dialog = createQbInput(fobType, purchaseType)
        racerName = dialog['racerName']
        racerId = dialog['racerId']
    end

    if dialog ~= nil then
        attemptCreateUser(racerName, racerId, fobType, purchaseType)

    else
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end
end)

if Config.Trader.active then
    local trader = Config.Trader
    CreateThread(function()
        local animation
        if trader.animation then
            animation = trader.animation
        else
            animation = "WORLD_HUMAN_STAND_IMPATIENT"
        end
    
        local currency = ''
        if trader.moneyType == 'cash' or trader.moneyType == 'bank' then
            currency = '$'
        else
            currency = Config.Options.cryptoType
        end

        local options = {}

        for authName, authData in pairs(Config.Permissions) do
            local option = {
                type = "client",
                event = "cw-racingapp:client:OpenFobInput",
                icon = "fas fa-flag-checkered",
                label = 'Create a new '..authName..' user ('..currency..trader.racingUserCosts[authName]..')',
                purchaseType = trader,
                fobType = authName,
                canInteract = function()
                    return hasAuth(trader, authName)
                end
            }
            options[#options+1] = option
        end
       
        RequestModel(trader.model)
        while not HasModelLoaded(trader.model) do
            Wait(0)
        end

        traderPed = CreatePed(4, trader.model, trader.location, false, false)
        SetEntityAsMissionEntity(traderPed, true, true)
        SetPedHearingRange(traderPed, 0.0)
        SetPedSeeingRange(traderPed, 0.0)
        SetPedAlertness(traderPed, 0.0)
        SetPedFleeAttributes(traderPed, 0, 0)
        SetBlockingOfNonTemporaryEvents(traderPed, true)
        SetPedCombatAttributes(traderPed, 46, true)
        TaskStartScenarioInPlace(traderPed, trader.animation, 0, true)
        SetEntityInvincible(traderPed, true)
        SetEntityCanBeDamaged(traderPed,false)
        SetEntityProofs(traderPed, true, true, true, true, true, true, 1, true)
        FreezeEntityPosition(traderPed, true)

        if Config.Sundown then
            exports['sundown-utils']:addPedToBanlist(traderPed)
        end

        if Config.UseOxTarget then
            exports.ox_target:addLocalEntity(traderPed, options)
        else
            exports['qb-target']:AddTargetEntity(traderPed, {
                options = options,
                distance = 2.0
            })
        end

        Entities[#Entities+1] = traderPed
    end)
end

local laptopEntity
if Config.Laptop.active then
    CreateThread(function()        
        local laptop = Config.Laptop
        local currency = ''
        if laptop.moneyType == 'cash' or laptop.moneyType == 'bank' then
            currency = '$'
        else
            currency = Config.Options.cryptoType
        end

            local options = {}
        for authName, authData in pairs(Config.Permissions) do
            local option = {
                type = "client",
                event = "cw-racingapp:client:OpenFobInput",
                icon = "fas fa-flag-checkered",
                label = 'Create a new '..authName..' user ('..currency..laptop.racingUserCosts[authName]..')',
                purchaseType = laptop,
                fobType = authName,
                canInteract = function()
                    return hasAuth(laptop, authName)
                end
            }
            options[#options+1] = option
        end
        laptopEntity = CreateObject(laptop.model, laptop.location.x, laptop.location.y, laptop.location.z, false,  false, true)
        SetEntityHeading(laptopEntity, laptop.location.w)
        CreateObject(laptopEntity)
        FreezeEntityPosition(laptopEntity, true)
        Entities[#Entities+1] = laptopEntity

        if Config.UseOxTarget then
            exports.ox_target:addLocalEntity(laptopEntity, options)
        else
            exports['qb-target']:AddTargetEntity(laptopEntity, {
                options = options,
                distance = 3.0 
            })
        end
        
    end)
end

AddEventHandler('onResourceStop', function (resource)
   if resource ~= GetCurrentResourceName() then return end
   for i, entity in pairs(Entities) do
       debugLog('Racing app cleanup: ^2', entity)
       if DoesEntityExist(entity) then
          DeleteEntity(entity)
       end
    end
end)
--- CREATOR BUTTONS
if Config.UseOxLibForKeybind then
    if not lib then
        print('^1UseOxLibForKeybind is enabled but no lib was found. Might be missing from fxmanifest')
    else
        local keyb= lib.addKeybind({
            name = 'clickAddCheckpoint',
            description = '(Track Creator) Add checkpoint',
            defaultKey = Config.Buttons.AddCheckpoint,
            onPressed = function(self)
                if RaceData.InCreator then
                    clickAddCheckpoint()
                end
            end
        })
        lib.addKeybind({
            name = 'clickDeleteCheckpoint',
            description = '(Track Creator) Remove checkpoint',
            defaultKey = Config.Buttons.DeleteCheckpoint,
            onPressed = function(self)
                if RaceData.InCreator then
                    clickDeleteCheckpoint()
                end
            end
        })
        lib.addKeybind({
            name = 'clickMoveCheckpoint',
            description = '(Track Creator) Move checkpoint',
            defaultKey = Config.Buttons.MoveCheckpoint,
            onPressed = function(self)
                if RaceData.InCreator then
                    clickMoveCheckpoint()
                end
            end
        })
        lib.addKeybind({
            name = 'clickSaveRace',
            description = '(Track Creator) Save track',
            defaultKey = Config.Buttons.SaveRace,
            onPressed = function(self)
                if RaceData.InCreator then
                    clickSaveRace()
                end
            end
        })
        lib.addKeybind({
            name = 'clickIncreaseDistance',
            description = '(Track Creator) Increase Checkpoint Size',
            defaultKey = Config.Buttons.IncreaseDistance,
            onPressed = function(self)
                if RaceData.InCreator then
                    clickIncreaseDistance()
                end
            end
        })
        lib.addKeybind({
            name = 'clickDecreaseDistance',
            description = '(Track Creator) Decrease Checkpoint Size',
            defaultKey = Config.Buttons.DecreaseDistance,
            onPressed = function(self)
                if RaceData.InCreator then
                    clickDecreaseDistance()
                end
            end
        })
        lib.addKeybind({
            name = 'clickExit',
            description = '(Track Creator) Exit track creation',
            defaultKey = Config.Buttons.Exit,
            onPressed = function(self)
                if RaceData.InCreator then
                    clickExit()
                end
            end
        })
    end 
else
    RegisterCommand("clickAddCheckpoint", function()
        if RaceData.InCreator then
            local Player = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(Player)
            if vehicle ~= 0 then
                clickAddCheckpoint()
            end
        end
    end, false)
    
    RegisterKeyMapping("clickAddCheckpoint", "(Track Creator) Add checkpoint", "keyboard", Config.Buttons.AddCheckpoint)
    
    RegisterCommand("clickDeleteCheckpoint", function()
        if RaceData.InCreator then
            local Player = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(Player)
            if vehicle ~= 0 then
                clickDeleteCheckpoint()
            end
        end
    end, false)
    
    RegisterKeyMapping("clickDeleteCheckpoint", "(Track Creator) Remove checkpoint", "keyboard", Config.Buttons.DeleteCheckpoint)
    
    RegisterCommand("clickMoveCheckpoint", function()
        if RaceData.InCreator then
            local Player = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(Player)
            if vehicle ~= 0 then
                clickMoveCheckpoint()
            end
        end
    end, false)
    
    RegisterKeyMapping("clickMoveCheckpoint", "(Track Creator) Move checkpoint", "keyboard", Config.Buttons.MoveCheckpoint)
    
    RegisterCommand("clickSaveRace", function()
        if RaceData.InCreator then
            local Player = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(Player)
            if vehicle ~= 0 then
                clickSaveRace()
            end
        end
    end, false)
    
    RegisterKeyMapping("clickSaveRace", "(Track Creator) Save track", "keyboard", Config.Buttons.SaveRace)
    
    RegisterCommand("clickIncreaseDistance", function()
        if RaceData.InCreator then
            local Player = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(Player)
            if vehicle ~= 0 then
                clickIncreaseDistance()
            end
        end
    end, false)
    
    RegisterKeyMapping("clickIncreaseDistance", "(Track Creator) Increase Checkpoint Size", "keyboard", Config.Buttons.IncreaseDistance)
    
    RegisterCommand("clickDecreaseDistance", function()
        if RaceData.InCreator then
            local Player = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(Player)
            if vehicle ~= 0 then
                clickDecreaseDistance()
            end
        end
    end, false)
    
    RegisterKeyMapping("clickDecreaseDistance", "(Track Creator) Decrease Checkpoint Size", "keyboard", Config.Buttons.DecreaseDistance)
    
    RegisterCommand("clickExit", function()
        if RaceData.InCreator then
            local Player = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(Player)
            if vehicle ~= 0 then
                clickExit()
            end
        end
    end, false)
    
    RegisterKeyMapping("clickExit", "(Track Creator) Exit track creation", "keyboard", Config.Buttons.Exit)
end

-- Custom UI

local uiIsOpen = false

RegisterNUICallback('GetBaseData', function(_, cb)
    local classes = { {value = '', text = Lang("no_class_limit"), number = 9000} }
    for i, class in pairs(Classes) do
        if useDebug then
            print(i, Classes[i])
        end
        classes[#classes+1] = { value = i, text = i, number = Classes[i] }
    end

    table.sort(classes, function(a,b)
        return a.number > b.number
    end)
    local setup = {
        classes = classes,
        laps = Config.Options.Laps,
        buyIns = Config.Options.BuyIns,
        moneyType = Config.Options.MoneyType,
        cryptoType = Config.Options.cryptoType,
        ghostingEnabled = Config.Ghosting.Enabled,
        ghostingTimes = Config.Ghosting.Options,
        allowShare = Config.AllowCreateFromShare,
        racerNames = MyRacerNames,
        currentRacerName = currentName,
        currentRacerAuth = currentAuth,
        currentCrewName = currentCrew,
        currentRanking = currentRanking,
        auth = Config.Permissions[currentAuth],
        hudSettings = Config.HUDSettings,
        translations = Config.Locale
    }
    cb(setup)
end)

local function hasGps()
    if Config.Inventory == 'qb' then
        if QBCore.Functions.HasItem(Config.ItemName.gps) then return true end
    else
        if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then return true end
    end
    return false
end

RegisterNetEvent("cw-racingapp:client:notifyRacers", function(text)
    if hasGps() then
        QBCore.Functions.Notify(text)
    end
end)

local attachedProp = nil

local function clearProp()
    if useDebug then
       print('REMOVING PROP', attachedProp)
    end
    if DoesEntityExist(attachedProp) then
        DeleteEntity(attachedProp)
        attachedProp = 0
    end
end

local function attachProp()
    clearProp()
    local model = 'prop_cs_tablet'
    local boneNumber = 28422
    SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263)
    local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumber)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
    attachedProp = CreateObject(model, 1.0, 1.0, 1.0, 1, 1, 0)
    local x, y,z = 0.0, -0.03, 0.0
    local xR, yR, zR = 20.0, -90.0, 0.0
    AttachEntityToEntity(attachedProp, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, 0, true, false, true, 2, true)
end

local function stopAnimation()
    ClearPedTasks(PlayerPedId())
    clearProp()
end

local function handleAnimation()
    local animDict = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a'
    if not DoesAnimDictExist(animDict) then
        print('animation dict does not exist')
        return false
    end
    RequestAnimDict(animDict)
    while (not HasAnimDictLoaded(animDict)) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, "idle_a", 5.0, 5.0, -1, 51, 0, false, false, false)
    attachProp()
end

local function openUi(data)
    if not uiIsOpen then
        currentName = data.name
        currentAuth = data.type
        currentCrew = data.crew
        QBCore.Functions.Notify(Lang("esc"))
        SetNuiFocus(true,true)
        SendNUIMessage({ type = 'toggleApp', open = true})
        uiIsOpen = true
        StartScreenEffect('MenuMGIn', 1, true)
        handleAnimation()
    end
end

local function openRacingApp()
    local data = {
        name = currentName,
        type = currentAuth,
        crew = currentCrew
    }
    openUi(data)
end exports('openRacingApp', openRacingApp)

RegisterNetEvent("cw-racingapp:client:openUi", function(data)
    openUi(data)
end)

RegisterNetEvent("cw-racingapp:client:updateRanking", function(change, newRank)
    currentRanking = newRank
    local type = 'success'
    if change < 0 then type = 'error' end
    QBCore.Functions.Notify(Lang("rank_update") .. " "..change..". "..Lang("new_rank")..newRank, type)
end)

-- UI CALLBACKS

local function sortTracksByName(tracks)
    local temp = tracks
    table.sort(temp, function (a,b)
        return a.RaceName > b.RaceName
    end)
    return temp
end

local function sorRacesByName(tracks)
    local temp = tracks
    table.sort(temp, function (a,b)
        return a.RaceData.RaceName > b.RaceData.RaceName
    end)
    return temp
end


RegisterNUICallback('UiCloseUi', function(_, cb)
    uiIsOpen = false
    SetNuiFocus(false,false)
    cb(true)
    StopScreenEffect('MenuMGIn')
    stopAnimation()
end)

RegisterNUICallback('UiFetchRaceResults', function(_, cb)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:getRaceResults', function(RaceResults)
        debugLog('Results: ', json.encode(RaceResults))
        if RaceResults then
            cb(RaceResults)
        else
            debugLog('No Results to show')
            cb({})
        end
    end)
end)

RegisterNUICallback('UiLeaveCurrentRace', function(raceid, cb)
    debugLog('Leaving race with race id', raceid)
    TriggerServerEvent('cw-racingapp:server:LeaveRace', CurrentRaceData, 'leaving')
    cb(true)
end)

RegisterNUICallback('UiStartCurrentRace', function(raceid, cb)
    debugLog('starting race with race id', raceid)
    TriggerServerEvent('cw-racingapp:server:StartRace', raceid)
    cb(true)
end)

RegisterNUICallback('UiChangeRacerName', function(racername, cb)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:ChangeRacerName', function(result)
        if result and result.name then
            debugLog('New name and type', result.name, result.type)
            currentName = result.name
            currentAuth = result.type
            QBCore.Functions.TriggerCallback('cw-racingcrews:server:getMyCrew', function(result)
                if result then
                    debugLog('Is in a crew', result)
                    currentCrew = result
                    TriggerServerEvent('cw-racingcrews:server:changeCrew', currentCrew)
                else
                    currentCrew = nil
                end
            end, currentName)
            currentRanking = result.ranking
            cb(true)
        else
            cb(false)
        end
    end, racername)
end)

RegisterNUICallback('UiGetRacerNamesByPlayer', function(racername, cb)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetRacerNamesByPlayer', function(playerNames)
        MyRacerNames = playerNames
        debugLog('player names', #playerNames, json.encode(playerNames))
        local currentRacer = findRacerByName(currentName)
        if currentRacer and currentRacer.revoked == 1 then 
            QBCore.Functions.Notify(Lang("revoked_access"), 'error')
        end
        if currentRacer and currentRacer.ranking then
            currentRanking = currentRacer.ranking
            debugLog('Ranking is', currentRanking)
        end
        cb(playerNames)
    end, GetPlayerServerId(PlayerId()))
end)

RegisterNUICallback('UiRevokeRacer', function(data, cb)
    debugLog('revoking racename', data.racername, data.status)
    local newStatus = 0
    if data.status == 0 then newStatus = 1 end
    TriggerServerEvent("cw-racingapp:server:SetRevokedRacenameStatus", data.racername, newStatus)
end)

RegisterNUICallback('UiRemoveRacer', function(data, cb)
    debugLog('permanently removing racename', data.racername)
    TriggerServerEvent("cw-racingapp:server:RemoveRacerName", data.racername)
end)

RegisterNUICallback('UiGetRacersCreatedByUser', function(_, cb)
    local racerId = QBCore.Functions.GetPlayerData().citizenid
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetRacersCreatedByUser', function(playerNames)
        debugLog('player names', #playerNames, json.encode(playerNames))
        cb(playerNames)
    end, racerId, currentAuth)
end)

RegisterNUICallback('UiGetPermissionedUserTypes', function(_, cb)
    local options = {}
    
    local currency = ''
    if Config.Laptop.moneyType == 'cash' or Config.Laptop.moneyType == 'bank' then
        currency = '$'
    else
        currency = Config.Options.cryptoType
    end

    for authName, authData in pairs(Config.Permissions) do
        if hasAuth(Config.Laptop, authName) then
            local option = {
                label = authName..' user ('..currency..Config.Laptop.racingUserCosts[authName]..')',
                purchaseType = Config.Laptop,
                fobType = authName,
            }
            options[#options+1] = option
        end
    end
    cb(options)
end)

local function getRaceByRaceId(Races, raceId)
    for i, race in pairs(Races) do
        if race.RaceId == raceId then
            return race
        end
    end
end

RegisterNUICallback('UiJoinRace', function(RaceId, cb)
    debugLog('joining race with race id', RaceId)
    if CurrentRaceData.RaceId ~= nil then
        QBCore.Functions.Notify(Lang("already_in_race"), 'error')
        cb(false)
        return
    end
    local PlayerPed = PlayerPedId()
    local PlayerIsInVehicle = IsPedInAnyVehicle(PlayerPed, false)

    local info, class, perfRating = '', '', ''
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)
    if PlayerIsInVehicle and isDriver(vehicle) then
        info, class, perfRating = exports['cw-performance']:getVehicleInfo(vehicle)
    else
        QBCore.Functions.Notify(Lang('not_in_a_vehicle'), 'error')
        return
    end

    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetRaces', function(Races)
        local PlayerPed = PlayerPedId()
        local currentRace = getRaceByRaceId(Races, RaceId)

        if currentRace == nil then
            QBCore.Functions.Notify(Lang("race_no_exist"), 'error')
        else
            if myCarClassIsAllowed(currentRace.MaxClass, class) then
                currentRace.RacerName = currentName
                currentRace.PlayerVehicleEntity = GetVehiclePedIsIn(PlayerPed, false)
                TriggerServerEvent('cw-racingapp:server:JoinRace', currentRace)
                cb(true)
                return
            else 
                QBCore.Functions.Notify(Lang('incorrect_class'), 'error')
            end
        end
        cb(false)
    end)
    
end)

RegisterNUICallback('UiClearLeaderboard', function(track, cb)
    debugLog('clearing leaderboard for ', track.RaceName)
    QBCore.Functions.Notify(track.RaceName..Lang("leaderboard_has_been_cleared"))
    TriggerServerEvent("cw-racingapp:server:ClearLeaderboard", track.RaceId)
    cb(true)
end)

RegisterNUICallback('UiDeleteTrack', function(track, cb)
    debugLog('deleting track', track.RaceName)
    QBCore.Functions.Notify(track.RaceName..Lang("has_been_removed"))
    TriggerServerEvent("cw-racingapp:server:DeleteTrack", track.RaceId)
    cb(true)
end)

RegisterNUICallback('UiEditTrack', function(track, cb)
    debugLog('opening track editor for', track.RaceName)
    TriggerEvent("cw-racingapp:client:StartRaceEditor", track.RaceName, currentName, track.RaceId)
    cb(true)
end)

RegisterNUICallback('UiGetAccess', function(track, cb)
    debugLog('gettingAccessFor', track.RaceName)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetAccess', function(accessTable)
        if not accessTable then
            if useDebug then
               print('Access table was empty')
            end
            accessTable = { race = ''}
        else            
            local raceText = ''
            if accessTable.race then
                for i, v in pairs(accessTable.race) do
                    if i == 1 then raceText = v else
                        raceText = raceText..', '..v
                    end
                end
                accessTable = { race = raceText}
            else
            accessTable.race = ''
            end
        end
        cb(accessTable)
    end, track.RaceId)    
end)

RegisterNUICallback('UiEditAccess', function(track, cb)
    debugLog('editing access for', track.RaceName)
    local newAccess = {
        race = split(track.NewAccess.race)
    }
    TriggerServerEvent("cw-racingapp:server:SetAccess", track.RaceId, newAccess)
    cb(true)
end)

RegisterNUICallback('UiFetchCurrentRace', function(_, cb)
    local racers = 0
    local maxClass = 'open'
    if CurrentRaceData.RaceId then
        for _ in pairs(CurrentRaceData.Racers) do
            racers = racers + 1
        end
        if (CurrentRaceData.MaxClass ~= nil and CurrentRaceData.MaxClass ~= "") then
            maxClass = CurrentRaceData.MaxClass
        end
        print('Ranked?', CurrentRaceData.Ranked)
        print('Reversed?', CurrentRaceData.Reversed)
        local data = {
            trackName = CurrentRaceData.RaceName,
            racers = racers,
            laps = CurrentRaceData.TotalLaps,
            class =  tostring(maxClass),
            cantStart = (not (CurrentRaceData.OrganizerCID == QBCore.Functions.GetPlayerData().citizenid) or
            CurrentRaceData.Started),
            raceId = CurrentRaceData.RaceId,
            ghosting = CurrentRaceData.Ghosting,
            ranked = CurrentRaceData.Ranked,
            reversed = CurrentRaceData.Reversed
        }
        cb(data)
    else
        cb({})
    end
end)

RegisterNUICallback('UiGetSettings', function(_, cb)
    cb({IgnoreRoadsForGps = IgnoreRoadsForGps, ShowGpsRoute = ShowGpsRoute, UseUglyWaypoint = UseUglyWaypoint, CheckDistance = CheckDistance})
end)

RegisterNUICallback('UiGetAvailableTracks', function(data, cb)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetListedRaces', function(Races)
        local tracks = {}
        for id, track in pairs(Races) do
            if not track.Waiting and verifyTrackAccess(track, 'race') then
                tracks[#tracks+1] = track
            end
        end
        cb(sortTracksByName(tracks))
    end)
end)

RegisterNUICallback('UiGetListedRaces', function(_, cb)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetRaces', function(Races)
        local availableRaces = {}
        if #Races > 0 then
            debugLog('Fetching available races:', json.encode(Races))
            for _, race in pairs(Races) do
                local RaceData = race.RaceData
                local racers = 0
                local PlayerPed = PlayerPedId()
                race.PlayerVehicleEntity = GetVehiclePedIsIn(PlayerPed, false)
                for _ in pairs(RaceData.Racers) do
                    racers = racers + 1
                end
    
                race.RacerName = currentName
    
                local maxClass = 'open'
                if (RaceData.MaxClass ~= nil and RaceData.MaxClass ~= "") then
                    maxClass = RaceData.MaxClass
                end
                race.maxClass = maxClass
                race.racers = racers
                race.disabled = CurrentRaceData.RaceId
                race.laps = race.Laps
                availableRaces[#availableRaces+1] = race
            end
        end
        
        cb(sorRacesByName(availableRaces))
    end)
end)

RegisterNUICallback('UiGetTracks', function(_, cb)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetTracks', function(tracks)
        table.sort(tracks, function (a,b)
            return a.RaceName < b.RaceName
        end)
        cb(tracks)
    end)
end)

RegisterNUICallback('UiGetMyTracks', function(data, cb)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetTracks', function(Tracks)
        
        local filtered = filterTracksByRacer(Tracks)
        table.sort(filtered, function (a,b)
            return a.RaceName > b.RaceName
        end)
        cb(filtered)
    end)
end)

RegisterNUICallback('UiGetRacingResults', function(_, cb)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:getRaceResults', function(RaceResults)
            debugLog('Results: ', json.encode(RaceResults))
            cb(RaceResults)
    end)
end)

RegisterNUICallback('UiSetupRace', function(setupData, cb)
    if not setupData or setupData.track == "none" then
        print('No data')
        return
    end
    debugLog('setup data', json.encode(setupData))
    local PlayerPed = PlayerPedId()
    local PlayerIsInVehicle = IsPedInAnyVehicle(PlayerPed, false)
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)

    if PlayerIsInVehicle and isDriver(vehicle) then
        local info, class, perfRating = exports['cw-performance']:getVehicleInfo(GetVehiclePedIsIn(PlayerPed, false))
        if myCarClassIsAllowed(setupData.maxClass, class) then
            TriggerServerEvent('cw-racingapp:server:SetupRace',
                setupData.track,
                tonumber(setupData.laps),
                currentName,
                setupData.maxClass,
                setupData.ghostingOn,
                tonumber(setupData.ghostingTime),
                tonumber(setupData.buyIn),
                setupData.ranked,
                setupData.reversed,
                setupData.participationMoney,
                setupData.participationCurrency
            )
        else
            cb(false)
            QBCore.Functions.Notify(Lang('incorrect_class'), 'error')
            return
        end
        cb(true)
    else
        cb(false)
        QBCore.Functions.Notify(Lang('not_in_a_vehicle'), 'error')
    end
end)

local function verifyCheckpoints(checkpoints) 
    for index, data in pairs(checkpoints) do
        local coordsExist = data.coords.x and data.coords.y and data.coords.z
        local offsetExists = data.offset.left.x and data.offset.left.y and data.offset.left.z and data.offset.right.x and data.offset.right.y and data.offset.right.z
        if coordsExist and offsetExists then return true end
    end
    return false
end

RegisterNUICallback('UiCreateTrack', function(createData, cb)
    if not createData.name then return end
    debugLog('create data', json.encode(createData))
    if not createData or createData.name == "" then
        print('No data')
        return
    end
    
    local checkpoints = createData.checkpoints
    local decodedCheckpoints = json.decode(checkpoints)
    if checkpoints ~= nil then
        if type(decodedCheckpoints) == 'table' then
            if not verifyCheckpoints(decodedCheckpoints) then
                QBCore.Functions.Notify(Lang("corrupt_data"))
                return
            end
        else
            QBCore.Functions.Notify(Lang("cant_decode"))
            return
        end
    end

    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetAmountOfTracks', function(tracks)
        local maxCharacterTracks = Config.MaxCharacterTracks
        if Config.CustomAmountsOfTracks[citizenId] then
            maxCharacterTracks = Config.CustomAmountsOfTracks[citizenId]
        end
        debugLog('Max allowed for you:', maxCharacterTracks, "You have this many tracks:", tracks)
        if Config.LimitTracks and tracks >= maxCharacterTracks then
            QBCore.Functions.Notify(Lang("max_tracks").. maxCharacterTracks)
            return
        else

            if not #createData.name then
                QBCore.Functions.Notify(Lang("no_name_track"), 'error')
                cb(false)
                return
            end
        
            if #createData.name < Config.MinTrackNameLength then
                QBCore.Functions.Notify(Lang("name_too_short"), 'error')
                cb(false)
                return
            end
        
            if #createData.name > Config.MaxTrackNameLength then
                QBCore.Functions.Notify(Lang("name_too_long"), 'error')
                cb(false)
                return
            end
        
            QBCore.Functions.TriggerCallback('cw-racingapp:server:IsAuthorizedToCreateRaces',
                function(IsAuthorized, NameAvailable)
                    if not IsAuthorized then
                        QBCore.Functions.Notify(Lang("not_auth"), 'error')
                        return
                    end
                    if not NameAvailable then
                        QBCore.Functions.Notify(Lang("race_name_exists"), 'error')
                        cb(false)
                        return
                    end
                    cb(true)
                    TriggerServerEvent('cw-racingapp:server:CreateLapRace', createData.name, currentName, decodedCheckpoints)
                end, createData.name)
            end
    end, citizenId)
end)

-- Crew stuff
RegisterNUICallback('UiJoinCrew', function(data, cb)
    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    QBCore.Functions.TriggerCallback('cw-racingcrews:server:joinCrew', function(result)
        debugLog('Success: ', result)
        if result then
            currentCrew = result
            TriggerServerEvent('cw-racingcrews:server:changeCrew', currentCrew)
        end
        cb(result)
    end, currentName, citizenId, data.crewName)
end)

RegisterNUICallback('UiLeaveCrew', function(data, cb)
    debugLog('Leaving', data.crewName)
    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    QBCore.Functions.TriggerCallback('cw-racingcrews:server:leaveCrew', function(result)
        debugLog('Success: ', result)
        if result then
            currentCrew = nil
            TriggerServerEvent('cw-racingcrews:server:changeCrew', nil)
        end
        cb(result)
    end, currentName, citizenId, data.crewName)
end)

RegisterNUICallback('UiDisbandCrew', function(data, cb)
    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    QBCore.Functions.TriggerCallback('cw-racingcrews:server:disbandCrew', function(result)
        debugLog('Success: ', result)
        if result then
            currentCrew = nil
            TriggerServerEvent('cw-racingcrews:server:changeCrew', nil)
        end
        cb(result)
    end, citizenId, data.crewName)
end)

RegisterNUICallback('UiCreateCrew', function(data, cb)
    if #data.crewName == 0 then QBCore.Functions.Notify(Lang("name_too_short"), 'error')  cb(false) return end
    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    QBCore.Functions.TriggerCallback('cw-racingcrews:server:createCrew', function(result)
        debugLog('Success: ', result)
        if result then
            currentCrew = data.crewName
            TriggerServerEvent('cw-racingcrews:server:changeCrew', data.crewName)
        end
        cb(result)
    end, currentName, citizenId, data.crewName)
end)

RegisterNUICallback('UiCreateUser', function(data, cb)
    if data.racerName and data.selectedAuth then
        attemptCreateUser(data.racerName, data.racerId, data.selectedAuth.fobType, data.selectedAuth.purchaseType)
    else
        QBCore.Functions.Notify(Lang("bad_input"), 'error')
    end
    cb(true)
end)

RegisterNUICallback('UiSendInvite', function(data, cb)
    if data.citizenId.length == 0 then QBCore.Functions.Notify(Lang("bad_input"), 'error')  cb(false) return end

    QBCore.Functions.TriggerCallback('cw-racingcrews:server:sendInvite', function(result)
        debugLog('Success: ', result)
        cb(result)
    end, PlayerId(), data.citizenId, currentCrew )
end)
RegisterNUICallback('UiSendInviteClosest', function(data, cb)
    local closestP, distance = QBCore.Functions.GetClosestPlayer()
    if closestP == nil or distance > 5 then QBCore.Functions.Notify(Lang("prox_error"), 'error') cb(false) return end

    local closestServerID = GetPlayerServerId(closestP)
    local myServerID = GetPlayerServerId( PlayerId())

    QBCore.Functions.TriggerCallback('cw-racingcrews:server:sendInviteClosest', function(result)
        debugLog('Success: ', result)
        cb(result)
    end, myServerID, closestServerID, currentCrew )
end)

RegisterNUICallback('UiAcceptInvite', function(data, cb)
    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    QBCore.Functions.TriggerCallback('cw-racingcrews:server:acceptInvite', function(result)
        debugLog('Success: ', result)
        if result then
            currentCrew = data.crewName
            TriggerServerEvent('cw-racingcrews:server:changeCrew', data.crewName)
        end
        cb(result)
    end, currentName, citizenId )
end)

RegisterNUICallback('UiDenyInvite', function(data, cb)
    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    QBCore.Functions.TriggerCallback('cw-racingcrews:server:denyInvite', function(result)
        debugLog('Success: ', result)
        cb(result)
    end, citizenId )
end)

RegisterNUICallback('UiGetAllCrews', function(data, cb)
    QBCore.Functions.TriggerCallback('cw-racingcrews:server:getAllCrews', function(result)
        debugLog('All crews: ', json.encode(result))
        cb(result)
    end)
end)

RegisterNUICallback('UiGetAllRacers', function(data, cb)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:getAllRacers', function(result)
        debugLog('All racers: ', json.encode(result))
        cb(result)
    end)
end)

RegisterNUICallback('UiGetCrewData', function(data, cb)
    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    QBCore.Functions.TriggerCallback('cw-racingcrews:server:getCrewData', function(result)
        debugLog('crew data: ', json.encode(result))
        cb(result)
    end, citizenId, currentName)
end)

local trackIsBeingDisplayed = false
local checkpointsPreview = {}

local function HideTrack()
    local trackIsBeingDisplayed = false
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    for i, blip in pairs(checkpointsPreview) do
        RemoveBlip(blip)
    end
end

local function DisplayTrack(track)
    if #checkpointsPreview > 0 then
        HideTrack()
    end
    QBCore.Functions.Notify(Lang("display_tracks"))
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    StartGpsMultiRoute(12, false , false)
    for i, checkpoint in pairs(track.Checkpoints) do
        AddPointToGpsRoute(checkpoint.coords.x,checkpoint.coords.y, checkpoint.offset)
        checkpointsPreview[#checkpointsPreview+1] = CreateCheckpointBlip(checkpoint.coords, i)
        if IgnoreRoadsForGps then
            SetGpsCustomRouteRender(true, 16, 16)
        else
            SetGpsMultiRouteRender(true, 16, 16)
        end
    end
    local trackIsBeingDisplayed = true
end

RegisterNUICallback('UiShowTrack', function(RaceId, cb)
    debugLog('displaying track', RaceId)
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetTracks', function(tracks)
        DisplayTrack(tracks[RaceId])
        SetTimeout(20*1000, function()
            FinishedUITimeout = false
            HideTrack()
        end)
        cb(true)
    end)
end)

local function toggleShowRoute(boolean)
    if boolean == nil then
        ShowGpsRoute = not ShowGpsRoute
    else
        ShowGpsRoute = boolean
    end
    if ShowGpsRoute then
        QBCore.Functions.Notify(Lang("toggled_gps_route_on"), 'success')
    else
        QBCore.Functions.Notify(Lang("toggled_gps_route_off"), 'error')
    end
end

RegisterCommand('showroute', function()
    toggleShowRoute()
end)

local function toggleIgnoreRoadsForGps(boolean)
    if boolean == nil then
        IgnoreRoadsForGps = not IgnoreRoadsForGps
    else
        IgnoreRoadsForGps = boolean
    end
    if IgnoreRoadsForGps then
        QBCore.Functions.Notify(Lang("gps_straight_on"), 'error')
    else
        QBCore.Functions.Notify(Lang("gps_straight_off"), 'success')
    end
end

RegisterCommand('ignoreroads', function()
    toggleIgnoreRoadsForGps()
end)

local function toggleUglyWaypoint(boolean)
    if boolean == nil then
        UseUglyWaypoint = not UseUglyWaypoint
    else
        UseUglyWaypoint = boolean
    end
    if UseUglyWaypoint then
        QBCore.Functions.Notify(Lang("basic_wps_on"), 'success')
    else
        QBCore.Functions.Notify(Lang("basic_wps_off"), 'error')
    end
end

RegisterCommand('basicwaypoint', function()
    toggleUglyWaypoint()
end)

RegisterNUICallback('UiUpdateSettings', function(data, cb)
    if data.setting == 'IgnoreRoadsForGps' then
        toggleIgnoreRoadsForGps(data.value)
    elseif data.setting =='ShowGpsRoute' then
        toggleShowRoute(data.value)
    elseif data.setting =='UseUglyWaypoint' then
        toggleUglyWaypoint(data.value)
    elseif data.setting =='CheckDistance' then
        CheckDistance = data.value
        if CheckDistance then
            QBCore.Functions.Notify(Lang("distance_on"), 'success')
        else
            QBCore.Functions.Notify(Lang("distance_off"), 'error')
        end
    end
end)

local function getCurrentRankingFromRacer(racerNames)
    for i, racer in pairs(racerNames) do
        if racer.racername == currentName then
            return racer.ranking
        end
    end
end

local function setup()
    QBCore.Functions.TriggerCallback('cw-racingapp:server:GetRacerNamesByPlayer', function(playerNames)
        MyRacerNames = playerNames
        debugLog('player names', json.encode(playerNames))
        local PlayerData = QBCore.Functions.GetPlayerData()
        if getSizeOfTable(MyRacerNames) == 0 then
            debugLog('user has been removed')
            return
        end
        if PlayerData.metadata.selectedRacerName then
            currentAuth = PlayerData.metadata.selectedRacerAuth
            currentName = PlayerData.metadata.selectedRacerName
            currentRanking = getCurrentRankingFromRacer(playerNames)
            if useDebug then 
                print('^3Racer name in metadata: ', PlayerData.metadata.selectedRacerName) 
                print('^3Racer auth in metadata: ', PlayerData.metadata.selectedRacerAuth) 
                print('^3Ranking', currentRanking)
            end
        else
            if getSizeOfTable(MyRacerNames) == 1 then 
                QBCore.Functions.TriggerCallback('cw-racingapp:server:ChangeRacerName', function(result)
                    if result and result.name then
                        debugLog('Only one racername available. Setting to ', result.name, result.type)
                        currentName = result.name
                        currentAuth = result.type
                        currentRanking = getCurrentRankingFromRacer(playerNames)
                    end
                end, MyRacerNames[1].racername)
            end
        end
        if PlayerData.metadata.selectedCrew then
            currentCrew = PlayerData.metadata.selectedCrew
            QBCore.Functions.TriggerCallback('cw-racingcrews:server:getMyCrew', function(result)
                if result then
                    debugLog('Is in a crew', result)

                    currentCrew = result
                end
            end, currentName)
        end
    end, GetPlayerServerId(PlayerId()))
end

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    setup()
end)

AddEventHandler('onResourceStart', function (resource)
    if resource ~= GetCurrentResourceName() then return end
    if useDebug then 
        print('^3--- Debug is on for Racingapp --- ')
        print('^2Inventory is set to ', Config.Inventory)
        print('^2Using Oxlib for keybinds ', Config.UseOxLibForKeybind)
        print('^2Using Renewed Crypto ', Config.UseRenewedCrypto)
        print('^2Using Renewed Banking ', Config.UseRenewedBanking)

        print('^2Permissions:', json.encode(Config.Permissions))
        print('^2Classes: ', json.encode(Classes))
        LocalPlayer.state:set('inRace', false, true)
        LocalPlayer.state:set('raceId', nil, true)
    end
    setup()
 end)