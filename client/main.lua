-----------------------
----   Variables   ----
-----------------------
UseDebug = Config.Debug
UiIsOpen = false

local Countdown = 10
local FinishedUITimeout = false
local CreatorObjectLeft, CreatorObjectRight
local IsFirstUser
local CharacterHasLoaded = false

CurrentName = nil
CurrentAuth = nil
CurrentCrew = nil
CurrentCrypto = nil
CurrentRanking = nil

local CheckpointPileModel = joaat(Config.CheckpointPileModel)
local StartAndFinishModel = joaat(Config.StartAndFinishModel)

local startTime = 0
local lapStartTime = 0

RaceData = {
    InCreator = false,
    InRace = false,
    ClosestCheckpoint = 0
}

local MyRacerNames = {}
local CreatorData = {
    RaceName = nil,
    RacerName = nil,
    Checkpoints = {},
    TireDistance = 3.0,
    ConfirmDelete = false,
    IsEdit = false,
    RaceId = nil
}

CurrentRaceData = {
    RaceId = nil,
    TrackId = nil,
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

local function notifyHandler(message, type)
    if CharacterHasLoaded and hasGps() then
        notify(message, type)
    end
end

RegisterNetEvent('cw-racingapp:client:notify', function(message, type)
    notifyHandler(message, type)
end)

local Classes = getVehicleClasses()
local Entities = {}
local Kicked = false
local TraderPed

local ShowGpsRoute = Config.ShowGpsRoute or false
local IgnoreRoadsForGps = Config.IgnoreRoadsForGps or false
local UseUglyWaypoint = Config.UseUglyWaypoint or false
local UseDrawTextWaypoint = Config.UseDrawTextWaypoint or false
local CheckDistance = Config.CheckDistance or false

function DebugLog(message, message2, message3, message4)
    if UseDebug then
        print('^2CW-RACINGAPP DEBUG:^0')
        print(message)
        if message2 then
            print(message2)
        end
        if message3 then
            print(message3)
        end
        if message4 then
            print(message4)
        end
    end
end

local function updateRaceUi()
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
end

local function getSizeOfTable(table)
    local count = 0
    if table then
        for _, _ in pairs(table) do
            count = count + 1
        end
    end
    return count
end

local function updateUiData(dataType, data)
    SendNUIMessage({
        action = "update",
        type = "dataUpdate",
        dataType = dataType,
        data = data,
    })
end

RegisterNetEvent('cw-racingapp:client:updateUiData', function(dataType, data)
    if dataType == 'crypto' then CurrentCrypto = data end
    if hasGps() then
        updateUiData(dataType, data)
    end
end)

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

local timeWhenLastCheckpointWasPassed = 0
-- Racing

local function checkCheckPointTime()
    if GetTimeDifference(GetGameTimer(), timeWhenLastCheckpointWasPassed) > Config.KickTime then
        DebugLog('Getting kicked for idling')
        if not Kicked then
            Kicked = true
            notifyHandler(Lang('kicked_idling'), 'error')
            TriggerServerEvent("cw-racingapp:server:leaveRace", CurrentRaceData, 'idling')
        end
    end
end

local function getMaxDistance(center, offsetCoords)
    local distance = #(vector3(center.x, center.y, center.z) -
        vector3(offsetCoords.left.x, offsetCoords.left.y, offsetCoords.left.z))

    return distance + (Config.CheckpointBuffer or 0)
end

local function genericBlip(blip)
    SetBlipScale(blip, Config.Blips.Generic.Size)
    SetBlipColour(blip, Config.Blips.Generic.Color)
end

local function nextBlip(blip)
    SetBlipScale(blip, Config.Blips.Next.Size)
    SetBlipColour(blip, Config.Blips.Next.Color)
end

local function passedBlip(blip)
    SetBlipScale(blip, Config.Blips.Passed.Size)
    SetBlipColour(blip, Config.Blips.Passed.Color)
end

local function resetBlips()
    for _, checkpoint in pairs(CurrentRaceData.Checkpoints) do
        genericBlip(checkpoint.blip)
    end
end


local function showNonLoopParticle(dict, particleName, coords, scale, time)
    while not HasNamedPtfxAssetLoaded(dict) do
        RequestNamedPtfxAsset(dict)
        Wait(0)
    end

    UseParticleFxAssetNextCall(dict)

    local particleHandle = StartParticleFxLoopedAtCoord(particleName, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0,
        scale, false, false, false)
    SetParticleFxLoopedColour(particleHandle, 0.0, 0.0, 1.0)
    return particleHandle
end

local function handleFlare(checkpoint)
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

local function doPilePfx()
    if CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1] ~= nil then
        handleFlare(CurrentRaceData.CurrentCheckpoint + 1)
    end
    if CurrentRaceData.CurrentCheckpoint == 1 then -- start
        DebugLog('start')
        handleFlare(CurrentRaceData.CurrentCheckpoint)
    end
    if CurrentRaceData.TotalLaps > 0 and CurrentRaceData.CurrentCheckpoint == #CurrentRaceData.Checkpoints then -- finish
        DebugLog('finish')
        handleFlare(1)
        if CurrentRaceData.Lap ~= CurrentRaceData.TotalLaps then
            DebugLog('not last lap')
            handleFlare(2)
        end
    end
end

local function myCarClassIsAllowed(maxClass, myClass)
    if maxClass == nil or maxClass == '' then
        return true
    end
    DebugLog('My class:', myClass)
    DebugLog('All classes', json.encode(Classes, { indent = true }))
    local myClassIndex = Classes[myClass]
    local maxClassIndex = Classes[maxClass]
    DebugLog('My class index: ' .. tostring(myClassIndex), 'maxClassIndex: ' .. tostring(maxClassIndex))
    if myClassIndex > maxClassIndex then
        return false
    end

    return true
end

local function loadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(10)
    end
end

local function cleanupObjects()
    DeleteObject(CreatorObjectLeft)
    DeleteObject(CreatorObjectRight)
    CreatorObjectLeft, CreatorObjectRight = nil, nil
end

local function deleteClosestObject(coords, model)
    local Obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0, model, 0, 0, 0)
    DeleteObject(Obj)
    ClearAreaOfObjects(coords.x, coords.y, coords.z, 50.0, 0)
end

local function createPile(offset, model)
    if model then
        loadModel(model)
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

local function isDriver(vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

local function isPlayerNearby(playerCoords, otherPlayerCoords, maxDistance)
    return #(playerCoords - otherPlayerCoords) <= maxDistance
end

local function unGhostPlayer()
    SetLocalPlayerAsGhost(false)
    SetGhostedEntityAlpha(254)
    CurrentRaceData.Ghosted = false
end

local function ghostPlayer()
    SetLocalPlayerAsGhost(true)
    SetGhostedEntityAlpha(Config.Ghosting.Alpha)
    CurrentRaceData.Ghosted = true
end

local function checkAndDisableGhosting()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not isDriver(vehicle) then
        DebugLog('Racer was not the driver')
        unGhostPlayer()
        return
    end

    local racerSources = {}
    for _, racerData in pairs(CurrentRaceData.Racers) do
        racerSources[racerData.RacerSource] = true
    end

    local nearbyPlayersFound = false
    local activePlayers = GetActivePlayers()

    for i = 1, #activePlayers do
        local playerId = activePlayers[i]
        local serverId = GetPlayerServerId(playerId)

        if not racerSources[serverId] then
            local otherPed = GetPlayerPed(playerId)
            local otherPlayerVehicle = GetVehiclePedIsIn(otherPed, false)

            if otherPlayerVehicle ~= 0 and GetPedInVehicleSeat(otherPlayerVehicle, -1) == otherPed then
                local otherPlayerCoords = GetEntityCoords(otherPed)
                if isPlayerNearby(playerCoords, otherPlayerCoords, Config.Ghosting.DeGhostDistance) then
                    nearbyPlayersFound = true
                    break
                end
            end
        end
    end

    if nearbyPlayersFound then
        unGhostPlayer()
    else
        ghostPlayer()
    end
end

local function initGhosting()
    -- Initial ghosting setup
    ghostPlayer()

    -- Create a thread to continuously check for nearby players
    CreateThread(function()
        while CurrentRaceData.Started do
            if CurrentRaceData.GhostingTime > 0 and CurrentRaceData.GhostingTime < CurrentRaceData.RaceTime then
                DebugLog('Breaking Ghosting Due to timer')
                unGhostPlayer()
                break;
            end
            checkAndDisableGhosting()
            Wait(Config.Ghosting.DistanceLoopTime)
        end
    end)
end

local function isFinishOrStart(checkpoint)
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



function IsInRace()
    local retval = false
    if RaceData.InRace then
        retval = true
    end
    return retval
end

exports('IsInRace', IsInRace)


function IsInEditor()
    local retval = false
    if RaceData.InCreator then
        retval = true
    end
    return retval
end

exports('IsInEditor', IsInEditor)


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

local function markWithUglyWaypoint()
    if UseUglyWaypoint then
        if #CurrentRaceData.Checkpoints == CurrentRaceData.CurrentCheckpoint then
            SetNewWaypoint(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].coords.x,
                CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].coords.y)
        elseif #CurrentRaceData.Checkpoints > CurrentRaceData.CurrentCheckpoint + 1 then
            SetNewWaypoint(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 2].coords.x,
                CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 2].coords.y)
        else
            SetNewWaypoint(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x,
                CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
        end
    end
end

local function deleteCurrentRaceCheckpoints()
    for _, checkpointData in pairs(CurrentRaceData.Checkpoints) do
        local blip = checkpointData.blip
        if blip then
            RemoveBlip(blip)
        end

        if checkpointData.pileleft then
            deleteClosestObject(checkpointData.offset.left, StartAndFinishModel)
            deleteClosestObject(checkpointData.offset.left, CheckpointPileModel)
        end

        if checkpointData.pileright then
            deleteClosestObject(checkpointData.offset.right, StartAndFinishModel)
            deleteClosestObject(checkpointData.offset.right, CheckpointPileModel)
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
    CurrentRaceData.FirstPerson = false
    CurrentRaceData.RacerName = nil
    RaceData.InRace = false
end

local function finishRace()
    if CurrentRaceData.RaceId == nil then
        return
    end
    local PlayerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)
    if not isDriver(vehicle) then
        notifyHandler(Lang('kicked_cheese'), 'error')
        TriggerServerEvent("cw-racingapp:server:leaveRace", CurrentRaceData, 'cheeseing')
        return
    end

    local class = getVehicleClass(vehicle)
    local vehicleModel = getVehicleModel(vehicle)
    -- print('NEW TIME TEST', currentTotalTime, SecondsToClock(currentTotalTime))
    DebugLog('Best lap:', CurrentRaceData.BestLap, 'Total:', CurrentRaceData.TotalTime)
    TriggerServerEvent('cw-racingapp:server:finishPlayer', CurrentRaceData, CurrentRaceData.TotalTime,
        CurrentRaceData.TotalLaps, CurrentRaceData.BestLap, class, vehicleModel, CurrentRanking, CurrentCrew)

    unGhostPlayer()
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    updateRaceUi()
    deleteCurrentRaceCheckpoints()
    SetTimeout(2000, function()
        CurrentRaceData.RaceId = nil
    end)
end

local function addPointToGpsRoute(cx, cy, offset)
    local x = cx
    local y = cy
    if Config.DoOffsetGps then
        x = (x + offset.right.x) / 2;
        y = (y + offset.right.y) / 2;
    end
    if IgnoreRoadsForGps then
        AddPointToGpsCustomRoute(x, y)
    else
        AddPointToGpsMultiRoute(x, y)
    end
end

local function getIndex(Positions)
    for k, v in pairs(Positions) do
        if v.RacerName == CurrentRaceData.RacerName then return k end
    end
end

local function clearBlips()
    for _, checkPointData in pairs(CurrentRaceData.Checkpoints) do
        if checkPointData then
            local Blip = checkPointData.blip
            if Blip then
                RemoveBlip(Blip)
            end
        end
    end
end

local function deleteAllCheckpoints()
    for _, checkPointData in pairs(CreatorData.Checkpoints) do
        if checkPointData then
            if checkPointData.pileleft then
                deleteClosestObject(checkPointData.offset.left, StartAndFinishModel)
                deleteClosestObject(checkPointData.offset.left, CheckpointPileModel)
            end
            if checkPointData.pileright then
                deleteClosestObject(checkPointData.offset.right, StartAndFinishModel)
                deleteClosestObject(checkPointData.offset.right, CheckpointPileModel)
            end
            local Blip = checkPointData.blip
            if Blip then
                RemoveBlip(Blip)
            end
        end
    end

    for _, checkPointData in pairs(CurrentRaceData.Checkpoints) do
        if checkPointData then
            if checkPointData.pileleft then
                deleteClosestObject(checkPointData.offset.left, StartAndFinishModel)
                deleteClosestObject(checkPointData.offset.left, CheckpointPileModel)
            end

            if checkPointData.pileright then
                deleteClosestObject(checkPointData.offset.right, StartAndFinishModel)
                deleteClosestObject(checkPointData.offset.right, CheckpointPileModel)
            end
        end
    end
end

local function createCheckpointBlip(coords, id)
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


local function updateGpsForRace(started)
    deleteAllCheckpoints()
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
        StartGpsMultiRoute(Config.Gps.color, started, false)
    else
        ClearGpsMultiRoute()
        StartGpsMultiRoute(Config.Gps.color, started, false)
    end

    local currentCheckpoint = CurrentRaceData.CurrentCheckpoint or 1
    local lastCheckpoint = currentCheckpoint + Config.MarkAmountOfCheckpointsAhead - 1
    local totalCheckpoints = #CurrentRaceData.Checkpoints
    local isCircuit = CurrentRaceData.TotalLaps > 0

    for i = currentCheckpoint, lastCheckpoint do
        local checkpointIndex = isCircuit and ((i - 1) % totalCheckpoints) + 1 or i
        if checkpointIndex > totalCheckpoints then break end -- Stop if beyond the last checkpoint in a sprint

        if not isCircuit or (isCircuit and ((checkpointIndex >= currentCheckpoint and checkpointIndex <= lastCheckpoint) or checkpointIndex == 1)) then
            local checkpointData = CurrentRaceData.Checkpoints[checkpointIndex]

            addPointToGpsRoute(checkpointData.coords.x, checkpointData.coords.y, checkpointData.offset)

            if isFinishOrStart(checkpointIndex) then
                checkpointData.pileleft = createPile(checkpointData.offset.left, StartAndFinishModel)
                checkpointData.pileright = createPile(checkpointData.offset.right, StartAndFinishModel)
            else
                checkpointData.pileleft = createPile(checkpointData.offset.left, CheckpointPileModel)
                checkpointData.pileright = createPile(checkpointData.offset.right, CheckpointPileModel)
            end
        end
    end
    if IgnoreRoadsForGps then
        SetGpsCustomRouteRender(ShowGpsRoute, 16, 16)
    else
        SetGpsMultiRouteRender(ShowGpsRoute, 16, 16)
    end
end

local function setupBlipsForRace(started)
    clearBlips()
    if started and CurrentRaceData.TotalLaps > 0 then
        for k = 1, #CurrentRaceData.Checkpoints, 1 do
            if k > 1 then
                CurrentRaceData.Checkpoints[k].blip = createCheckpointBlip(CurrentRaceData.Checkpoints[k].coords, k)
            end
        end
        CurrentRaceData.Checkpoints[1].blip = createCheckpointBlip(CurrentRaceData.Checkpoints[1].coords,
            #CurrentRaceData.Checkpoints + 1)
    else
        -- First Lap setup
        for k, v in pairs(CurrentRaceData.Checkpoints) do
            CurrentRaceData.Checkpoints[k].blip = createCheckpointBlip(v.coords, k)
        end
    end
end

local function deleteClosestCheckpoint()
    local newCheckpoints = {}
    if RaceData.ClosestCheckpoint ~= 0 then
        local ClosestCheckpoint = CreatorData.Checkpoints[RaceData.ClosestCheckpoint]

        if ClosestCheckpoint then
            if ClosestCheckpoint.blip then
                RemoveBlip(ClosestCheckpoint.blip)
            end

            if ClosestCheckpoint.pileleft then
                deleteClosestObject(ClosestCheckpoint.offset.left, StartAndFinishModel)
                deleteClosestObject(ClosestCheckpoint.offset.left, CheckpointPileModel)
                PileLeft = nil
            end

            if ClosestCheckpoint.pileright then
                deleteClosestObject(ClosestCheckpoint.offset.right, StartAndFinishModel)
                deleteClosestObject(ClosestCheckpoint.offset.right, CheckpointPileModel)
            end

            for id, data in pairs(CreatorData.Checkpoints) do
                if id ~= RaceData.ClosestCheckpoint then
                    newCheckpoints[#newCheckpoints + 1] = data
                end
            end
            CreatorData.Checkpoints = newCheckpoints
        else
            notifyHandler(Lang("slow_down"), 'error')
        end
    else
        notifyHandler(Lang("slow_down"), 'error')
    end
end

local function deleteCreatorCheckpoints()
    for id, _ in pairs(CreatorData.Checkpoints) do
        local currentCheckpoint = CreatorData.Checkpoints[id]

        local blip = currentCheckpoint.blip
        if blip then
            RemoveBlip(blip)
        end

        if currentCheckpoint then
            if currentCheckpoint.pileleft then
                deleteClosestObject(currentCheckpoint.offset.left, CheckpointPileModel)
                deleteClosestObject(currentCheckpoint.offset.left, StartAndFinishModel)
                PileLeft = nil
            end

            if currentCheckpoint.pileright then
                deleteClosestObject(currentCheckpoint.offset.right, CheckpointPileModel)
                deleteClosestObject(currentCheckpoint.offset.right, StartAndFinishModel)
            end
        end
    end
end

local function setupPiles()
    for k, v in pairs(CreatorData.Checkpoints) do
        if not CreatorData.Checkpoints[k].pileleft then
            CreatorData.Checkpoints[k].pileleft = createPile(v.offset.left, CheckpointPileModel)
        end

        if not CreatorData.Checkpoints[k].pileright then
            CreatorData.Checkpoints[k].pileright = createPile(v.offset.right, CheckpointPileModel)
        end
    end
end

local function saveTrack()
    local raceDistance = 0

    for k, v in pairs(CreatorData.Checkpoints) do
        if k + 1 <= #CreatorData.Checkpoints then
            local checkpointdistance = #(vector3(v.coords.x, v.coords.y, v.coords.z) -
                vector3(CreatorData.Checkpoints[k + 1].coords.x,
                    CreatorData.Checkpoints[k + 1].coords.y, CreatorData.Checkpoints[k + 1].coords.z))
            raceDistance = raceDistance + checkpointdistance
        end
    end

    CreatorData.RaceDistance = raceDistance
    TriggerServerEvent('cw-racingapp:server:saveTrack', CreatorData)
    Lang("slow_down")
    notifyHandler(Lang("race_saved") .. '(' .. CreatorData.RaceName .. ')', 'success')

    deleteCreatorCheckpoints()
    cleanupObjects()

    RaceData.InCreator = false
    CreatorData.RaceName = nil
    CreatorData.RacerName = nil
    CreatorData.Checkpoints = {}
    CreatorData.IsEdit = false
    CreatorData.TrackId = nil
end

local function getClosestCheckpoint()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
    for id, _ in ipairs(CreatorData.Checkpoints) do
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
    CreatorData.ClosestCheckpoint = current
end

local function startCreatorUIThread()
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

local function redrawBlips()
    for id, CheckpointData in pairs(CreatorData.Checkpoints) do
        RemoveBlip(CheckpointData.blip)
        CheckpointData.blip = createCheckpointBlip(CheckpointData.coords, id)
    end
end

local function addCheckpoint(checkpointId)
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
            deleteClosestObject(CreatorData.Checkpoints[tonumber(checkpointId)].offset.left, StartAndFinishModel)
            deleteClosestObject(CreatorData.Checkpoints[tonumber(checkpointId)].offset.left, CheckpointPileModel)
        end

        local PileRight = CreatorData.Checkpoints[tonumber(checkpointId)].pileright
        if PileRight then
            deleteClosestObject(CreatorData.Checkpoints[tonumber(checkpointId)].offset.right, StartAndFinishModel)
            deleteClosestObject(CreatorData.Checkpoints[tonumber(checkpointId)].offset.right, CheckpointPileModel)
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
        notifyHandler(Lang("max_checkpoints") .. Config.MaxCheckpoints, 'error')
    end
    redrawBlips()
end


local function moveCheckpoint()
    local dialog

    if Config.OxInput then
        dialog = lib.inputDialog(Lang("edit_checkpoint_header"), {
            {
                text = "Checkpoint number", -- text you want to be displayed as a place holder
                name = "number",            -- name of the input should be unique otherwise it might override
                type = "number",            -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = true,          -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },
        })
    else
        dialog = exports['qb-input']:ShowInput({
            header = Lang("edit_checkpoint_header"),
            submitText = Lang("confirm"),
            inputs = {
                {
                    text = "Checkpoint number", -- text you want to be displayed as a place holder
                    name = "number",            -- name of the input should be unique otherwise it might override
                    type = "number",            -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                    isRequired = true,          -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                },
            },
        })
    end

    if dialog ~= nil then
        if UseDebug then
            print('Moving checkpoint', dialog.number or dialog[1])
        end
        addCheckpoint(dialog.number or dialog[1])
    end
end

local function clickAddCheckpoint()
    addCheckpoint()
end

local function clickDeleteCheckpoint()
    if CreatorData.Checkpoints and next(CreatorData.Checkpoints) then
        deleteClosestCheckpoint()
    else
        notifyHandler(Lang("no_checkpoints_to_delete"), 'error')
    end
end

local function clickMoveCheckpoint()
    if CreatorData.Checkpoints and next(CreatorData.Checkpoints) then
        moveCheckpoint()
    else
        notifyHandler(Lang("no_checkpoints_to_edit"), 'error')
    end
end

local function clickSaveRace()
    if CreatorData.Checkpoints and #CreatorData.Checkpoints >= Config.MinimumCheckpoints then
        saveTrack()
    else
        notifyHandler(Lang("not_enough_checkpoints") .. '(' .. Config.MinimumCheckpoints .. ')', 'error')
    end
end

local function clickIncreaseDistance()
    if CreatorData.TireDistance < Config.MaxTireDistance then
        CreatorData.TireDistance = CreatorData.TireDistance + 1.0
    else
        notifyHandler(Lang("max_tire_distance") .. Config.MaxTireDistance)
    end
end

local function clickDecreaseDistance()
    if CreatorData.TireDistance > Config.MinTireDistance then
        CreatorData.TireDistance = CreatorData.TireDistance - 1.0
    else
        notifyHandler(Lang("min_tire_distance") .. Config.MinTireDistance)
    end
end

local function clickExit()
    if not CreatorData.ConfirmDelete then
        CreatorData.ConfirmDelete = true
        notifyHandler(Lang("editor_confirm"), 'error')
    else
        deleteCreatorCheckpoints()

        cleanupObjects()
        RaceData.InCreator = false
        CreatorData.RaceName = nil
        CreatorData.Checkpoints = {}
        notifyHandler(Lang("editor_canceled"), 'error')
        CreatorData.ConfirmDelete = false
    end
end

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

local function startCreatorLoopThread()
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
    CreateThread(function()
        while RaceData.InCreator do
            getClosestCheckpoint()
            setupPiles()
            Wait(1000)
        end
        DebugLog('Exiting Closest Checkpoint check and pile setup thread')
    end)
    -- Creator
    CreateThread(function()
        while RaceData.InCreator do
            local PlayerPed = PlayerPedId()
            local PlayerVeh = GetVehiclePedIsIn(PlayerPed)
            if CreatorObjectLeft and CreatorObjectRight ~= nil then
                cleanupObjects()
            end
            CreatorCheckpointObject = CheckpointPileModel

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
                DrawMarker(22, Offset.left.x, Offset.left.y, Offset.left.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 2.5, 1.5,
                    255, 150, 0, 255, 0, 1, 0, 0, 0, 0, 0)
                DrawMarker(22, Offset.right.x, Offset.right.y, Offset.right.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 2.5,
                    1.5, 255, 150, 0, 255, 0, 1, 0, 0, 0, 0, 0)
            end
            Wait(0)
        end
    end)
end

local function startRaceUi()
    CreateThread(function()
        while true do
            if CurrentRaceData.Checkpoints ~= nil and next(CurrentRaceData.Checkpoints) ~= nil then
                if CurrentRaceData.Started then
                    CurrentRaceData.RaceTime = GetTimeDifference(GetGameTimer(), lapStartTime)
                    CurrentRaceData.TotalTime = GetTimeDifference(GetGameTimer(), startTime)
                end
                updateRaceUi()
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
    for _, value in pairs(original) do
        copy[#copy + 1] = value
    end
    return copy
end

local function bothOpponentsHaveDefinedPositions(aSrc, bSrc)
    local currentPlayer = GetPlayerPed(-1)
    local currentPlayerCoords = GetEntityCoords(currentPlayer)

    local aPly = GetPlayerFromServerId(aSrc)
    local aTarget = GetPlayerPed(aPly)
    local aCoords = GetEntityCoords(aTarget)

    local bPly = GetPlayerFromServerId(bSrc)
    local bTarget = GetPlayerPed(bPly)
    local bCoords = GetEntityCoords(bTarget)

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
    local pos = GetEntityCoords(target)
    local next
    if checkpoint + 1 > #CurrentRaceData.Checkpoints then
        next = CurrentRaceData.Checkpoints[1]
    else
        next = CurrentRaceData.Checkpoints[checkpoint + 1]
    end

    local distanceToNext = #(pos - vector3(next.coords.x, next.coords.y, next.coords.z))
    return distanceToNext
end

local function placements()
    local tempPositions = copyWihoutId(CurrentRaceData.Racers)
    if #tempPositions > 1 then
        table.sort(tempPositions, function(a, b)
            if a.Lap > b.Lap then
                return true
            elseif a.Lap < b.Lap then
                return false
            elseif a.Lap == b.Lap then
                if a.Checkpoint > b.Checkpoint then
                    return true
                elseif a.Checkpoint < b.Checkpoint then
                    return false
                elseif a.Checkpoint == b.Checkpoint then
                    if CheckDistance and bothOpponentsHaveDefinedPositions(a.RacerSource, b.RacerSource) then
                        return distanceToCheckpoint(a.RacerSource, a.Checkpoint) <
                            distanceToCheckpoint(b.RacerSource, b.Checkpoint)
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
                local positions = placements()
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

MarkerType = Config.DrawTextSetup.markerType or 1 -- Vertical cylinder
MinHeight = Config.DrawTextSetup.minHeight or 1.0
MaxHeight = Config.DrawTextSetup.maxHeight or 100.0
BaseSize = Config.DrawTextSetup.baseSize or 0.1                                          -- Thin pillar
MarkerColor = Config.DrawTextSetup.markerColor or { r = 255, g = 255, b = 255, a = 200 } -- White, semi-transparent
DistanceColor = Config.DrawTextSetup.distanceColor or { r = 0, g = 255, b = 0, a = 255 } -- Cyan
PrimaryColor = Config.DrawTextSetup.primaryColor or { r = 255, g = 0, b = 250, a = 255 } -- White

local function getFinishLabel(totalCheckpoints, index)
    if CurrentRaceData.TotalLaps == 0 and totalCheckpoints == index then -- if sprint
        return Lang('finish')
    elseif index - 1 == totalCheckpoints then                            -- if laps
        if CurrentRaceData.Lap == CurrentRaceData.TotalLaps then
            return Lang('finish')
        else
            return Lang('next_lap')
        end
    end
    return nil
end

local function getCheckpointCoord(index, totalCheckpoints)
    if CurrentRaceData.TotalLaps == 0 and index > #CurrentRaceData.Checkpoints then
        return nil
    end
    if CurrentRaceData.Lap > 0 and CurrentRaceData.Lap == CurrentRaceData.TotalLaps then
        if index - 1 == totalCheckpoints then
            return vector3(
                CurrentRaceData.Checkpoints[1].coords.x,
                CurrentRaceData.Checkpoints[1].coords.y,
                CurrentRaceData.Checkpoints[1].coords.z
            )
        elseif index > totalCheckpoints and CurrentRaceData.Lap + 1 > CurrentRaceData.TotalLaps then
            return nil
        end
    end
    index = (index - 1) % totalCheckpoints + 1
    return vector3(
        CurrentRaceData.Checkpoints[index].coords.x,
        CurrentRaceData.Checkpoints[index].coords.y,
        CurrentRaceData.Checkpoints[index].coords.z
    )
end

local function getUpcomingCheckpoints()
    local coord1, coord2, coord3
    local coord1Label, coord2Label, coord3Label
    local totalCheckpoints = #CurrentRaceData.Checkpoints
    local currentIndex = CurrentRaceData.CurrentCheckpoint + 1
    local checkpoints = {}

    if CurrentRaceData.Lap < 2 and CurrentRaceData.CurrentCheckpoint == 1 then
        checkpoints[1] = {
            coord = vector3(
                CurrentRaceData.Checkpoints[1].coords.x,
                CurrentRaceData.Checkpoints[1].coords.y,
                CurrentRaceData.Checkpoints[1].coords.z
            ),
            label = Lang('starting_line')
        }
    end

    coord1 = getCheckpointCoord(currentIndex, totalCheckpoints)
    coord2 = getCheckpointCoord(currentIndex + 1, totalCheckpoints)
    coord3 = getCheckpointCoord(currentIndex + 2, totalCheckpoints)

    coord1Label = getFinishLabel(totalCheckpoints, currentIndex) or Lang("checkpoint_next")
    coord2Label = getFinishLabel(totalCheckpoints, currentIndex + 1) or Lang("checkpoint_2nd")
    coord3Label = getFinishLabel(totalCheckpoints, currentIndex + 2) or Lang("checkpoint_3rd")

    if coord1 then checkpoints[#checkpoints + 1] = { coord = coord1, label = coord1Label } end
    if coord2 then checkpoints[#checkpoints + 1] = { coord = coord2, label = coord2Label } end
    if coord3 then checkpoints[#checkpoints + 1] = { coord = coord3, label = coord3Label } end
    return checkpoints
end

function Draw3DText(coords, text, scale, color)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(color.r, color.g, color.b, color.a)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

function DrawRacingMarker(coords, height)
    DrawMarker(
        MarkerType,
        coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0,                  -- Direction
        0.0, 0.0, 0.0,                  -- Rotation
        BaseSize, BaseSize, height,     -- Scale
        MarkerColor.r, MarkerColor.g, MarkerColor.b, MarkerColor.a,
        false, true, 2, nil, nil, false -- Bob, face camera, rotate
    )
end

local function markWithDrawTextWaypoint()
    if UseDrawTextWaypoint then
        CreateThread(function()
            while true and RaceData.InRace do
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)

                local checkpoints = getUpcomingCheckpoints()

                for i, checkpoint in ipairs(checkpoints) do
                    local distance = #(playerCoords - checkpoint.coord)
                    local height = math.min(MaxHeight, math.max(MinHeight, distance / 2.5))

                    -- Draw the marker
                    DrawRacingMarker(checkpoint.coord, height)

                    -- Calculate text positions
                    local baseTextHeight = checkpoint.coord.z + height
                    local labelHeight = baseTextHeight + 0.7 + height * 0.05
                    local distanceHeight = baseTextHeight + 0.5

                    local color = DistanceColor
                    if i == 1 or i == 2 and #checkpoints > 3 then color = PrimaryColor end

                    -- Draw checkpoint label
                    local labelCoords = vector3(checkpoint.coord.x, checkpoint.coord.y, labelHeight)
                    Draw3DText(labelCoords, checkpoint.label, 0.25, color)

                    -- Draw distance
                    local distanceCoords = vector3(checkpoint.coord.x, checkpoint.coord.y, distanceHeight)
                    Draw3DText(distanceCoords, string.format("%.0fm", distance), 0.5, DistanceColor)
                end

                Wait(0)
            end
        end)
    end
end

local checkpointsPreview = {}

local function hideTrack()
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    for _, blip in pairs(checkpointsPreview) do
        RemoveBlip(blip)
    end
end

local function displayTrack(track)
    if #checkpointsPreview > 0 then
        hideTrack()
    end
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    StartGpsMultiRoute(Config.Gps.color, false, false)
    for i, checkpoint in pairs(track.Checkpoints) do
        addPointToGpsRoute(checkpoint.coords.x, checkpoint.coords.y, checkpoint.offset)
        checkpointsPreview[#checkpointsPreview + 1] = createCheckpointBlip(checkpoint.coords, i)
        if IgnoreRoadsForGps then
            SetGpsCustomRouteRender(true, 16, 16)
        else
            SetGpsMultiRouteRender(true, 16, 16)
        end
    end
end

local function initRacingHudThread()
    CreateThread(function()
        while not Kicked and CurrentRaceData.RaceName ~= nil do
            if CurrentRaceData.Started then
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local cp
                if CurrentRaceData.CurrentCheckpoint + 1 > #CurrentRaceData.Checkpoints then
                    cp = 1
                else
                    cp = CurrentRaceData.CurrentCheckpoint + 1
                end
                local data = CurrentRaceData.Checkpoints[cp]
                local currentCheckpointCenterCoords = vector3(data.coords.x, data.coords.y, data.coords.z)
                local CheckpointDistance = #(pos - currentCheckpointCenterCoords)
                local MaxDistance = getMaxDistance(currentCheckpointCenterCoords, CurrentRaceData.Checkpoints[cp].offset)
                if CheckpointDistance < MaxDistance then
                    if CurrentRaceData.TotalLaps == 0 then                                               -- Sprint
                        if CurrentRaceData.CurrentCheckpoint + 1 < #CurrentRaceData.Checkpoints then     -- passed checkpoint
                            CurrentRaceData.CurrentCheckpoint = CurrentRaceData.CurrentCheckpoint + 1
                            TriggerServerEvent('cw-racingapp:server:updateRacerData', CurrentRaceData.RaceId,
                                CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, false, CurrentRaceData.TotalTime)
                            doPilePfx()
                            PlaySoundFrontend(-1, Config.Sounds.Checkpoint.lib, Config.Sounds.Checkpoint.sound)
                            passedBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].blip)
                            nextBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].blip)
                            updateGpsForRace(true)
                            markWithUglyWaypoint()
                        else     -- finished
                            doPilePfx()
                            CurrentRaceData.CurrentCheckpoint = CurrentRaceData.CurrentCheckpoint + 1
                            TriggerServerEvent('cw-racingapp:server:updateRacerData', CurrentRaceData.RaceId,
                                CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, true, CurrentRaceData.TotalTime)
                            PlaySoundFrontend(-1, Config.Sounds.Finish.lib, Config.Sounds.Finish.sound)
                            finishRace()
                        end
                        timeWhenLastCheckpointWasPassed = GetGameTimer()
                    else                                                                                 -- Circuit
                        if CurrentRaceData.CurrentCheckpoint + 1 > #CurrentRaceData.Checkpoints then     -- If new lap
                            if CurrentRaceData.Lap + 1 > CurrentRaceData.TotalLaps then                  -- if finish
                                doPilePfx()
                                if CurrentRaceData.RaceTime < CurrentRaceData.BestLap then
                                    CurrentRaceData.BestLap = CurrentRaceData.RaceTime
                                    DebugLog('racetime less than bestlap',
                                        CurrentRaceData.RaceTime < CurrentRaceData.BestLap, CurrentRaceData.RaceTime,
                                        CurrentRaceData.BestLap)
                                elseif CurrentRaceData.BestLap == 0 then
                                    DebugLog('bestlap == 0', CurrentRaceData.BestLap)
                                    CurrentRaceData.BestLap = CurrentRaceData.RaceTime
                                end
                                CurrentRaceData.CurrentCheckpoint = CurrentRaceData.CurrentCheckpoint + 1
                                TriggerServerEvent('cw-racingapp:server:updateRacerData', CurrentRaceData.RaceId,
                                    CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, true,
                                    CurrentRaceData.TotalTime)
                                finishRace()
                                AnimpostfxPlay('CrossLineOut', 0, false)
                                PlaySoundFrontend(-1, Config.Sounds.Finish.lib, Config.Sounds.Finish.sound)
                            else     -- if next lap
                                doPilePfx()
                                resetBlips()
                                PlaySoundFrontend(-1, Config.Sounds.Checkpoint.lib, Config.Sounds.Checkpoint.sound)
                                if CurrentRaceData.RaceTime < CurrentRaceData.BestLap then
                                    DebugLog('racetime less than bestlap',
                                        CurrentRaceData.RaceTime < CurrentRaceData.BestLap, CurrentRaceData.RaceTime,
                                        CurrentRaceData.BestLap)
                                    CurrentRaceData.BestLap = CurrentRaceData.RaceTime
                                elseif CurrentRaceData.BestLap == 0 then
                                    DebugLog('bestlap == 0', CurrentRaceData.BestLap)
                                    CurrentRaceData.BestLap = CurrentRaceData.RaceTime
                                end
                                lapStartTime = GetGameTimer()
                                CurrentRaceData.Lap = CurrentRaceData.Lap + 1
                                CurrentRaceData.CurrentCheckpoint = 1
                                TriggerServerEvent('cw-racingapp:server:updateRacerData', CurrentRaceData.RaceId,
                                    CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, false,
                                    CurrentRaceData.TotalTime)

                                passedBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].blip)
                                nextBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].blip)
                                markWithUglyWaypoint()
                                updateGpsForRace(true)
                            end
                            timeWhenLastCheckpointWasPassed = GetGameTimer()
                        else     -- if next checkpoint
                            CurrentRaceData.CurrentCheckpoint = CurrentRaceData.CurrentCheckpoint + 1
                            if CurrentRaceData.CurrentCheckpoint ~= #CurrentRaceData.Checkpoints then
                                TriggerServerEvent('cw-racingapp:server:updateRacerData', CurrentRaceData.RaceId,
                                    CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, false,
                                    CurrentRaceData.TotalTime)
                                passedBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].blip)
                                nextBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].blip)
                                markWithUglyWaypoint()
                            else
                                TriggerServerEvent('cw-racingapp:server:updateRacerData', CurrentRaceData.RaceId,
                                    CurrentRaceData.CurrentCheckpoint, CurrentRaceData.Lap, false,
                                    CurrentRaceData.TotalTime)
                                passedBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint].blip)
                                nextBlip(CurrentRaceData.Checkpoints[1].blip)
                                markWithUglyWaypoint()
                            end
                            timeWhenLastCheckpointWasPassed = GetGameTimer()
                            doPilePfx()
                            updateGpsForRace(true)
                            PlaySoundFrontend(-1, Config.Sounds.Checkpoint.lib, Config.Sounds.Checkpoint.sound)
                        end
                    end
                else
                    checkCheckPointTime()
                end
            else
                local data = CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint]
                DrawMarker(4, data.coords.x, data.coords.y, data.coords.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.9, 1.5,
                    1.5, 255, 255, 255, 255, 0, 1, 0, 0, 0, 0, 0)
                nextBlip(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].blip)
            end
            Wait(0)
        end
        DebugLog('Breaking racing hud thread')
    end)
end

local function handleActiveRace(raceData, trackCheckpoints, Laps)
    local checkpoints = trackCheckpoints
    if raceData.Reversed then checkpoints = reverseTable(checkpoints) end
    CurrentRaceData = {
        TrackId = raceData.TrackId,
        RaceId = raceData.RaceId,
        Creator = raceData.Creator,
        SetupCitizenId = raceData.SetupCitizenId,
        SetupRacerName = raceData.SetupRacerName,
        RacerName = raceData.RacerName,
        RaceName = raceData.RaceName,
        Checkpoints = checkpoints,
        Ghosting = raceData.Ghosting,
        GhostingTime = raceData.GhostingTime,
        Ranked = raceData.Ranked,
        Reversed = raceData.Reversed,
        FirstPerson = raceData.FirstPerson,
        Started = false,
        CurrentCheckpoint = 1,
        TotalLaps = Laps,
        Lap = 1,
        RaceTime = 0,
        TotalTime = 0,
        BestLap = 0,
        MaxClass = raceData.MaxClass,
        Racers = {},
        Position = 0
    }
    initRacingHudThread()
    displayTrack(CurrentRaceData)
    DebugLog('Race Was setup:', json.encode(CurrentRaceData))
    startRaceUi()
    markWithDrawTextWaypoint()
end

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
        deleteAllCheckpoints()
        clearBlips()
    end
end)

RegisterNetEvent('cw-racingapp:client:readyJoinRace', function(raceData)
    local PlayerPed = PlayerPedId()
    local PlayerIsInVehicle = IsPedInAnyVehicle(PlayerPed, false)
    local class
    if PlayerIsInVehicle then
        class = getVehicleClass(GetVehiclePedIsIn(PlayerPed, false))
    else
        notifyHandler(Lang('not_in_a_vehicle'), 'error')
        return
    end

    if myCarClassIsAllowed(raceData.MaxClass, class) then
        raceData.RacerName = CurrentName
        raceData.RacerCrew = CurrentCrew
        raceData.PlayerVehicleEntity = GetVehiclePedIsIn(PlayerPed, false)
        TriggerServerEvent('cw-racingapp:server:joinRace', raceData)
    else
        notifyHandler(Lang('incorrect_class'), 'error')
    end
end)

local function openCreatorUi()
    startCreatorUIThread()
    redrawBlips()
    startCreatorLoopThread()
end

RegisterNetEvent('cw-racingapp:client:startRaceEditor', function(raceName, racerName, trackId, checkpoints)
    if not RaceData.InCreator then
        CreatorData.RaceName = raceName
        CreatorData.RacerName = racerName
        RaceData.InCreator = true
        if type(checkpoints) == 'table' then
            DebugLog('Using shared, checkpoint existed')
            CreatorData.Checkpoints = checkpoints
            clickSaveRace()
            return
        end
        if trackId then
            DebugLog('Opening RaceTrack Editor')
            local result = cwCallback.await('cw-racingapp:server:getTrackData', trackId)
            if result then
                CreatorData.RaceName = raceName
                CreatorData.RacerName = racerName
                CreatorData.TrackId = trackId
                CreatorData.Checkpoints = {}
                CreatorData.TireDistance = 3.0
                CreatorData.ConfirmDelete = false
                CreatorData.IsEdit = true
                DebugLog('Checkpoints in track:', #result.Checkpoints or 0)
                for _, checkpoint in pairs(result.Checkpoints) do
                    CreatorData.Checkpoints[#CreatorData.Checkpoints + 1] = checkpoint
                end
                openCreatorUi()
            else
                print('^1Something went wrong with fetching this track')
                DebugLog(json.encode(result, { indent = true }))
            end
        else
            CreatorData.IsEdit = false
            openCreatorUi()
        end
    else
        notifyHandler(Lang("already_making_race"), 'error')
    end
end)

-- Exampl
local function checkElimination()
    local currentPlayerIsLast = true
    local lastCompletedLap = 0
    -- Find the last completed lap and racer
    for citizenId, data in pairs(CurrentRaceData.Racers) do
        if getCitizenId() ~= citizenId then
            if not data.Finished and data.Lap <= CurrentRaceData.Lap then
                currentPlayerIsLast = false -- someone was worse
            end
            if lastCompletedLap < data.Lap then
                lastCompletedLap = data.Lap
            end
        end
    end
    DebugLog('Is Last racer', currentPlayerIsLast, 'lap:', lastCompletedLap)
    -- Check if the current racer is the last one who completed the lap
    if currentPlayerIsLast and lastCompletedLap >= CurrentRaceData.Lap then
        DebugLog("Eliminating racer: " .. getCitizenId())
        TriggerServerEvent("cw-racingapp:server:leaveRace", CurrentRaceData, 'elimination')
        notifyHandler(Lang("eliminated"), 'error')
    end
end

RegisterNetEvent('cw-racingapp:client:updateRaceRacerData', function(raceId, citizenid, racerData)
    if (CurrentRaceData.RaceId ~= nil) and CurrentRaceData.RaceId == raceId then
        DebugLog('Race is Elimination:', CurrentRaceData.IsElimination)
        CurrentRaceData.Racers[citizenid] = racerData
        if CurrentRaceData.IsElimination then
            checkElimination()
        end
    end
end)

RegisterNetEvent('cw-racingapp:client:joinRace', function(data, checkpoints, laps, racerName)
    DebugLog('Joining', json.encode(data, {indent=true}))
    if not RaceData.InRace then
        data.RacerName = racerName
        RaceData.InRace = true
        handleActiveRace(data, checkpoints, laps)
        notifyHandler(Lang("race_joined"))
        TriggerServerEvent('cw-racingapp:server:updateRaceState', CurrentRaceData.RaceId, false, true)
    else
        notifyHandler(Lang("already_in_race"), 'error')
    end
end)

RegisterNetEvent('cw-racingapp:client:updateActiveRacers', function(raceId, racers)
    if CurrentRaceData.RaceId == raceId then
        CurrentRaceData.Racers = racers
    end
end)


RegisterNetEvent('cw-racingapp:client:updateOrganizer', function(RaceId, organizer)
    if CurrentRaceData.RaceId == RaceId then
        DebugLog('updating organizer')
        CurrentRaceData.SetupCitizenId = organizer
    end
end)

RegisterNetEvent('cw-racingapp:client:leaveRace', function()
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    Countdown = 10
    hideTrack()
    updateCountdown(-1)
    unGhostPlayer()
    deleteCurrentRaceCheckpoints()
    FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), false), false)
    CurrentRaceData.RaceId = nil
end)

RegisterNetEvent("cw-racingapp:client:DeletetrackConfirmed", function(data)
    notifyHandler(data.RaceName .. " " .. Lang("has_been_removed"))
    TriggerServerEvent("cw-racingapp:server:deleteTrack", data.RaceId)
end)

RegisterNetEvent("cw-racingapp:client:clearLeaderboardConfirmed", function(data)
    notifyHandler(data.RaceName .. " " .. Lang("leaderboard_has_been_cleared"))
    TriggerServerEvent("cw-racingapp:server:clearLeaderboard", data.RaceId)
end)

RegisterNetEvent("cw-racingapp:client:editTrack", function(data)
    TriggerEvent("cw-racingapp:client:startRaceEditor", data.RaceName, data.name, data.TrackId)
end)

local function findRacerByName()
    if #MyRacerNames == 1 and CurrentName == nil then
        CurrentName = MyRacerNames[1].racername
        CurrentAuth = MyRacerNames[1].auth
        cwCallback.await('cw-racingapp:server:changeRacerName', CurrentName)
        return MyRacerNames[1]
    end
    if MyRacerNames then
        for _, user in pairs(MyRacerNames) do
            if CurrentName == user.racername then return user end
        end
    end
    return false
end

local function split(source)
    local str = source:gsub("%s+", "")
    str = string.gsub(str, "%s+", "")
    local result, i = {}, 1
    while true do
        local a, b = str:find(',')
        if not a then break end
        local candidat = str:sub(1, a - 1)
        if candidat ~= "" then
            result[i] = candidat
        end
        i = i + 1
        str = str:sub(b + 1)
    end
    if str ~= "" then
        result[i] = str
    end
    return result
end

local function isPositionCheating()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local current = CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint]
    local next = CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1]

    local distanceToNext = #(pos - vector3(next.coords.x, next.coords.y, next.coords.z))

    local distanceBetween = #(vector3(next.coords.x, next.coords.y, next.coords.z) - vector3(current.coords.x, current.coords.y, current.coords.z))

    return distanceBetween > distanceToNext + (Config.PositionCheatBuffer or 0)
end

local function forceFirstPerson()
    DebugLog('Race has forced first person:', CurrentRaceData.FirstPerson)
    local originalCam = GetFollowVehicleCamViewMode()
    CreateThread(function()
        while CurrentRaceData and CurrentRaceData.RaceId and CurrentRaceData.FirstPerson do
            local inVeh = GetVehiclePedIsIn(PlayerPedId(), false)
            local sleep = 1000
            if inVeh then
                sleep = 1
                SetFollowVehicleCamViewMode(4)
            end
            Wait(sleep)
        end
        SetFollowVehicleCamViewMode(originalCam or 2)
    end)
end

RegisterNetEvent('cw-racingapp:client:raceCountdown', function(TotalRacers)
    hideTrack()
    setupBlipsForRace(true)
    updateGpsForRace(true)
    Kicked = false
    TriggerServerEvent('cw-racingapp:server:updateRaceState', CurrentRaceData.RaceId, true, false)
    CurrentRaceData.TotalRacers = TotalRacers
    positionThread()
    if CurrentRaceData.TotalLaps == -1 then
        DebugLog('^3Race is Elimination! setting laps to:', CurrentRaceData.TotalRacers - 1)
        CurrentRaceData.TotalLaps = CurrentRaceData.TotalRacers - 1
        CurrentRaceData.IsElimination = true
    end
    if CurrentRaceData.RaceId ~= nil then
        while Countdown ~= 0 do
            if CurrentRaceData.RaceName ~= nil then
                if Countdown == 10 then
                    updateCountdown(10)
                    PlaySoundFrontend(-1, Config.Sounds.Countdown.start.lib, Config.Sounds.Countdown.start.sound)
                elseif Countdown <= 5 then
                    FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), true), true)
                    if Countdown == 5 then forceFirstPerson() end
                    updateCountdown(Countdown)
                    PlaySoundFrontend(-1, Config.Sounds.Countdown.number.lib, Config.Sounds.Countdown.number.sound)
                end
                Countdown = Countdown - 1
            else
                break
            end
            Wait(1000)
        end
        if CurrentRaceData.RaceName ~= nil then
            updateCountdown(0)
            PlaySoundFrontend(-1, Config.Sounds.Countdown.go.lib, Config.Sounds.Countdown.go.sound)
            if isPositionCheating() then
                TriggerServerEvent("cw-racingapp:server:leaveRace", CurrentRaceData, 'positionCheat')
                notifyHandler(Lang("kicked_line"), 'error')
                FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), true), false)
                return
            end
            if IgnoreRoadsForGps then
                AddPointToGpsCustomRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x,
                    CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
            else
                AddPointToGpsMultiRoute(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.x,
                    CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].coords.y)
            end
            markWithUglyWaypoint()
            SetBlipScale(CurrentRaceData.Checkpoints[CurrentRaceData.CurrentCheckpoint + 1].blip,
                Config.Blips.Generic.Size)
            FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), true), false)
            doPilePfx()
            CurrentRaceData.Started = true
            if Config.Ghosting.Enabled and CurrentRaceData.Ghosting then
                initGhosting()
            end
            lapStartTime = GetGameTimer()
            startTime = GetGameTimer()
            timeWhenLastCheckpointWasPassed = GetGameTimer()
            Countdown = 10
        else
            FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), true), false)
            Countdown = 10
        end
    else
        notifyHandler(Lang("already_in_race"), 'error')
    end
end)

RegisterNetEvent('cw-racingapp:client:playerFinish', function(RaceId, Place, RacerName)
    if CurrentRaceData.RaceId ~= nil then
        if CurrentRaceData.RaceId == RaceId then
            notifyHandler(RacerName .. " " .. Lang("racer_finished_place") .. Place, 'primary', 3500)
        end
    end
end)

local function notCloseEnough(x, y)
    notifyHandler(Lang('not_close_enough_to_join'), 'error')
    SetNewWaypoint(x, y)
end

RegisterNetEvent('cw-racingapp:client:notCloseEnough', function(x, y)
    notCloseEnough(x, y)
end)

local function verifyTrackAccess(track, type)
    if track.Access and track.Access[type] ~= nil then
        if track.Access[type][1] == nil then
            print('no values', track.RaceName)
            return true
        end                                                -- if list is added but emptied
        local playerCid = getCitizenId()
        if track.Creator == playerCid then return true end -- if creator default to true
        if UseDebug then
            print('track', track.RaceName, 'has access limitations for', type)
            print('player cid', playerCid)
        end
        for i, citizenId in pairs(track.Access[type]) do
            DebugLog(i, citizenId)
            if citizenId == playerCid then return true end -- if one of the players in the list
        end
        return false
    end
    return true
end

local function racerNameIsValid(name)
    if #name > Config.MinRacerNameLength then
        if #name < Config.MaxRacerNameLength then
            return true
        else
            notifyHandler(Lang('name_too_long'), 'error')
        end
    else
        notifyHandler(Lang('name_too_short'), 'error')
    end
    return false
end

local function hasPermission(userType)
    if CurrentAuth == 'god' then
        return true
    elseif userType == 'racer' and Config.AllowRacerCreationForAnyone then
        return true
    elseif CurrentAuth == 'master' and (userType == 'creator' or userType == 'racer') then
        return true
    end
    return false
end

local function hasAuth(tradeType, userType)
    DebugLog('current auth', CurrentAuth)
    if CurrentAuth and Config.Permissions[CurrentAuth] and Config.Permissions[CurrentAuth].controlAll then
        DebugLog('User has controlall auth')
        return true
    end

    if tradeType.jobRequirement[userType] == true then
        DebugLog('job requirement exists for', userType)
        local jobName = getPlayerJobName()
        local playerHasJob = jobName and Config.AllowedJobs[jobName]
        local jobGradeReq
        if UseDebug then
            print('Player job: ', jobName)
        end
        if playerHasJob then
            local jobLevel = getPlayerJobLevel()
            DebugLog('Player job level: ', jobLevel)
            if Config.AllowedJobs[jobName] ~= nil then
                jobGradeReq = Config.AllowedJobs[jobName][userType]
                if UseDebug then
                    print('Required job grade: ', jobGradeReq)
                end
                if jobGradeReq ~= nil then
                    if jobLevel >= jobGradeReq then
                        return hasPermission(userType)
                    end
                end
            end
        end
        return false
    elseif tradeType.jobRequirement[userType] == nil then
        DebugLog('Requiement is nil for', userType)
        return false
    else
        DebugLog('Requiement is false for', userType)
        return true
    end
end

local function racerNameExists(listOfNames, racerName)
    for _, data in pairs(listOfNames) do
        if data.racername == racerName then
            return true
        end
    end
    return false
end

local function createOxInput(fobType, purchaseType)
    if not lib then
        print(
            '^1OxInput is enabled but no lib was found. Might be missing from fxmanifest or the dev is not able to read the config')
    else
        local options = { { type = 'input', label = 'Racer Name', required = true, min = 1, max = 100 } }

        if not purchaseType.useSlimmed then
            options[#options + 1] = { type = 'number', label = 'Paypal/temp id (leave empty if for you)', min = 1, max = 20 }
        end
        local FobInput = lib.inputDialog('Creating a [' .. fobType .. '] type user', options)
        return FobInput
    end
end

local function createQbInput(fobType, purchaseType)
    local inputs = {
        {
            text = 'Racer Name', -- text you want to be displayed as a place holder
            name = "racerName",  -- name of the input should be unique otherwise it might override
            type = "text",       -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
        },
    }

    if not purchaseType.useSlimmed then
        inputs[#inputs + 1] = {
            text = 'Paypal/temp id (leave empty if for you)', -- text you want to be displayed as a place holder
            name = "racerId",                                 -- name of the input should be unique otherwise it might override
            type = "text",                                    -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
        }
    end
    local dialog = exports['qb-input']:ShowInput({
        header = 'Creating a [' .. fobType .. '] type user',
        submitText = 'Submit',
        inputs = inputs
    })
    return dialog
end

local function attemptCreateUser(racerName, racerId, fobType, purchaseType)
    if UseDebug then
        print('Racername', racerName)
        print('RacerId', racerId)
        print('fobType', json.encode(fobType, { indent = true }))
        print('purchaseType', json.encode(purchaseType, { indent = true }))
    end
    if racerId == nil or racerId == '' then
        racerId = GetPlayerServerId(PlayerId())
    end
    if racerNameIsValid(racerName) then
        local playerNames = cwCallback.await('cw-racingapp:server:getRacerNamesByPlayer', racerId)

        DebugLog('player names', #playerNames, json.encode(playerNames))
        local maxRacerNames = Config.MaxRacerNames
        if Config.UseNameValidation and #playerNames > 1 and playerNames[1].citizenid and Config.CustomAmounts[playerNames[1].citizenid] then
            maxRacerNames = Config.CustomAmounts[playerNames[1].citizenid]
        end

        DebugLog('Racer names allowed for id ' .. racerId, maxRacerNames)
        if playerNames == nil or racerNameExists(playerNames, strictSanitize(racerName)) or #playerNames < maxRacerNames then
            local nameIsNotTaken = cwCallback.await('cw-racingapp:server:nameIsAvailable', racerName, racerId)

            if nameIsNotTaken then
                TriggerServerEvent('cw-racingapp:server:createRacerName', racerId, racerName, fobType, purchaseType,
                    CurrentName)
            else
                notifyHandler(Lang("name_is_used") .. racerName, 'error')
            end
        else
            notifyHandler(Lang("to_many_names"), 'error')
        end
    end
end

RegisterNetEvent("cw-racingapp:client:openFobInput", function(data)
    local purchaseType = data.purchaseType
    local fobType = data.fobType

    notifyHandler(Lang("max_uniques") .. " " .. Config.MaxRacerNames)

    local dialog
    local racerName
    local racerId
    if Config.OxInput then
        dialog = createOxInput(fobType, purchaseType)
        if dialog then
            racerName = dialog[1]
            racerId = dialog[2]
        end
    else
        dialog = createQbInput(fobType, purchaseType)
        if dialog then
            racerName = dialog['racerName']
            racerId = dialog['racerId']
        end
    end

    if dialog ~= nil then
        attemptCreateUser(racerName, racerId, fobType, purchaseType)
    else
        TriggerEvent('animations:client:EmoteCommandStart', { "c" })
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

        local currency
        if trader.moneyType == 'cash' or trader.moneyType == 'bank' then
            currency = '$'
        else
            currency = Config.Payments.cryptoType
        end

        local options = {}

        for authName, _ in pairs(Config.Permissions) do
            local option = {
                type = "client",
                event = "cw-racingapp:client:openFobInput",
                icon = "fas fa-flag-checkered",
                label = 'Create a new ' .. authName .. ' user (' .. currency .. trader.racingUserCosts[authName] .. ')',
                purchaseType = trader,
                fobType = authName,
                canInteract = function()
                    return hasAuth(trader, authName)
                end
            }
            options[#options + 1] = option
        end

        RequestModel(trader.model)
        while not HasModelLoaded(trader.model) do
            Wait(0)
        end

        TraderPed = CreatePed(4, trader.model, trader.location, false, false)
        SetEntityAsMissionEntity(TraderPed, true, true)
        SetPedHearingRange(TraderPed, 0.0)
        SetPedSeeingRange(TraderPed, 0.0)
        SetPedAlertness(TraderPed, 0.0)
        SetPedFleeAttributes(TraderPed, 0, 0)
        SetBlockingOfNonTemporaryEvents(TraderPed, true)
        SetPedCombatAttributes(TraderPed, 46, true)
        TaskStartScenarioInPlace(TraderPed, animation, 0, true)
        SetEntityInvincible(TraderPed, true)
        SetEntityCanBeDamaged(TraderPed, false)
        SetEntityProofs(TraderPed, true, true, true, true, true, true, 1, true)
        FreezeEntityPosition(TraderPed, true)

        if Config.UseOxTarget then
            exports.ox_target:addLocalEntity(TraderPed, options)
        else
            exports['qb-target']:AddTargetEntity(TraderPed, {
                options = options,
                distance = 2.0
            })
        end

        Entities[#Entities + 1] = TraderPed
    end)
end

local laptopEntity
if Config.Laptop.active then
    CreateThread(function()
        local laptop = Config.Laptop
        local currency
        if laptop.moneyType == 'cash' or laptop.moneyType == 'bank' then
            currency = '$'
        else
            currency = Config.Payments.cryptoType
        end

        local options = {}
        for authName, _ in pairs(Config.Permissions) do
            local option = {
                type = "client",
                event = "cw-racingapp:client:openFobInput",
                icon = "fas fa-flag-checkered",
                label = 'Create a new ' .. authName .. ' user (' .. currency .. laptop.racingUserCosts[authName] .. ')',
                purchaseType = laptop,
                fobType = authName,
                canInteract = function()
                    return hasAuth(laptop, authName)
                end
            }
            options[#options + 1] = option
        end
        laptopEntity = CreateObject(laptop.model, laptop.location.x, laptop.location.y, laptop.location.z, false, false,
            true)
        SetEntityHeading(laptopEntity, laptop.location.w)
        FreezeEntityPosition(laptopEntity, true)
        Entities[#Entities + 1] = laptopEntity

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

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, entity in pairs(Entities) do
        DebugLog('Racing app cleanup: ^2', entity)
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
        lib.addKeybind({
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

    RegisterKeyMapping("clickDeleteCheckpoint", "(Track Creator) Remove checkpoint", "keyboard",
        Config.Buttons.DeleteCheckpoint)

    RegisterCommand("clickMoveCheckpoint", function()
        if RaceData.InCreator then
            local Player = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(Player)
            if vehicle ~= 0 then
                clickMoveCheckpoint()
            end
        end
    end, false)

    RegisterKeyMapping("clickMoveCheckpoint", "(Track Creator) Move checkpoint", "keyboard",
        Config.Buttons.MoveCheckpoint)

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

    RegisterKeyMapping("clickIncreaseDistance", "(Track Creator) Increase Checkpoint Size", "keyboard",
        Config.Buttons.IncreaseDistance)

    RegisterCommand("clickDecreaseDistance", function()
        if RaceData.InCreator then
            local Player = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(Player)
            if vehicle ~= 0 then
                clickDecreaseDistance()
            end
        end
    end, false)

    RegisterKeyMapping("clickDecreaseDistance", "(Track Creator) Decrease Checkpoint Size", "keyboard",
        Config.Buttons.DecreaseDistance)

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

local function getBaseDataObject()
    local classes = { { value = '', text = Lang("no_class_limit"), number = 9000 } }
    for i, _ in pairs(Classes) do
        if UseDebug then
            print(i, Classes[i])
        end
        classes[#classes + 1] = { value = i, text = i, number = Classes[i] }
    end

    table.sort(classes, function(a, b)
        return a.number > b.number
    end)

    local currentVehicle = nil
    local Player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(Player, false)
    if vehicle and vehicle ~= 0 then
        currentVehicle = {
            model = getVehicleModel(vehicle),
            class = getVehicleClass(vehicle)
        }
    end

    local setup = {
        classes = classes,
        currentVehicle = currentVehicle;
        laps = Config.Options.Laps,
        buyIns = Config.Options.BuyIns,
        participationCurrencyOptions = Config.Options.participationCurrencyOptions,
        moneyType = Config.Payments.racing,
        cryptoType = Config.Payments.cryptoType,
        ghostingEnabled = Config.Ghosting.Enabled,
        ghostingTimes = Config.Ghosting.Options,
        allowShare = Config.AllowCreateFromShare,
        racerNames = MyRacerNames,
        currentRacerName = CurrentName,
        currentRacerAuth = CurrentAuth,
        currentCrewName = CurrentCrew,
        currentRanking = CurrentRanking,
        currentCrypto = CurrentCrypto,
        isUsingRacingCrypto = Config.Payments.useRacingCrypto,
        cryptoConversionRate = Config.Options.conversionRate,
        allowBuyingCrypto = Config.Options.allowBuyingCrypto,
        allowSellingCrypto = Config.Options.allowSellingCrypto,
        allowTransferCrypto = Config.Options.allowTransferCrypto,
        showH2H = Config.ShowH2H,
        sellCharge = Config.Options.sellCharge,
        auth = Config.Permissions[CurrentAuth],
        hudSettings = Config.HUDSettings,
        translations = Config.Locale,
        primaryColor = Config.PrimaryUiColor,
        anyoneCanCreate = Config.AllowAnyoneToCreateUserInApp,
        isFirstUser = IsFirstUser,
        payments = Config.Payments,
        hideMap = Config.HideMapInTablet,
        allAuthorities = Config.Permissions
    }
    
    if UseDebug then
        -- print('^3Tablet Setup Data:^0', json.encode(setup, { indent = true }))
    end
    return setup
end

RegisterNUICallback('GetBaseData', function(_, cb)
    cb(getBaseDataObject())
end)

RegisterNetEvent("cw-racingapp:client:notifyRacers", function(text)
    if hasGps() then
        notifyHandler(text)
    end
end)

local attachedProp = nil

local function clearProp()
    if UseDebug then
        print('REMOVING PROP', attachedProp)
    end
    if attachedProp and DoesEntityExist(attachedProp) then
        DeleteEntity(attachedProp)
        attachedProp = 0
    end
end

local function attachProp()
    clearProp()
    local model = 'prop_cs_tablet'
    local boneNumber = 28422
    SetCurrentPedWeapon(cache.ped, 0xA2719263, false)
    local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumber)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    attachedProp = CreateObject(model, 1.0, 1.0, 1.0, 1, 1, 0)
    local x, y, z = 0.0, -0.03, 0.0
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

local function openUi()
    DebugLog('opening ui')

    if not UiIsOpen then
        notifyHandler(Lang("esc"))
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'toggleApp', open = true })
        UiIsOpen = true
        StartScreenEffect('MenuMGIn', 1, true)
        handleAnimation()
    end
end

local function openRacingApp()
    openUi()
end
exports('openRacingApp', openRacingApp)

RegisterNetEvent("cw-racingapp:client:openUi", function()
    openUi()
end)

RegisterNetEvent("cw-racingapp:client:updateRanking", function(change, newRank)
    CurrentRanking = newRank
    local type = 'success'
    if change < 0 then type = 'error' end
    notifyHandler(Lang("rank_update") .. " " .. change .. ". " .. Lang("new_rank") .. newRank, type)
end)

-- UI CALLBACKS

local function sortTracksByName(tracks)
    local temp = tracks
    table.sort(temp, function(a, b)
        return a.RaceName < b.RaceName
    end)
    return temp
end

local function sortRacesByName(tracks)
    local temp = tracks
    table.sort(temp, function(a, b)
        return a.RaceData.RaceName > b.RaceData.RaceName
    end)
    return temp
end

local function closeUi()
    UiIsOpen = false
    SetNuiFocus(false, false)
    StopScreenEffect('MenuMGIn')
    stopAnimation()
end

RegisterNUICallback('UiCloseUi', function(_, cb)
    closeUi()
    cb(true)
end)

local function getActiveRacerName()
    for _, user in pairs(MyRacerNames) do
        if user.active == 1 then return user end
    end
end

RegisterNetEvent("cw-racingapp:client:updateRacerNames", function()
    Wait(2000)
    local playerNames = cwCallback.await('cw-racingapp:server:getRacerNamesByPlayer')
    MyRacerNames = playerNames
    local currentRacer = getActiveRacerName()
    DebugLog('Current racer after change', json.encode(currentRacer, { indent = true }))
    DebugLog('All player names', json.encode(MyRacerNames, { indent = true }))

    if #MyRacerNames == 1 then
        currentRacer = MyRacerNames[1]
    end
    if currentRacer then
        CurrentName = currentRacer.racername
        CurrentAuth = currentRacer.auth
        CurrentRanking = currentRacer.ranking
        CurrentCrypto = currentRacer.crypto
        CurrentCrew = currentRacer.crew
    end

    notifyHandler(Lang("user_list_updated"))
    DebugLog('current user', json.encode(currentRacer, { indent = true }))
    if CurrentName and currentRacer and currentRacer.revoked == 1 then
        notifyHandler(Lang("revoked_access"), 'error')
        Wait(2000)
        if UiIsOpen then
            SendNUIMessage({ type = 'toggleApp', open = false })
            closeUi()
        end
    elseif CurrentName and not currentRacer then
        DebugLog('Race user was deleted')
        notifyHandler(Lang('removed_user'), 'error')
        Wait(2000)
        if UiIsOpen then
            SendNUIMessage({ type = 'toggleApp', open = false })
            closeUi()
        end
    else
        SendNUIMessage({ type = 'updateBaseData' })
    end
end)

local function leaveCurrentRace()
    if CurrentRaceData and CurrentRaceData.RaceId then
        TriggerServerEvent('cw-racingapp:server:leaveRace', CurrentRaceData, 'leaving')
        return true
    end
    return false
end exports('leaveCurrentRace', leaveCurrentRace)

RegisterNetEvent('cw-racingapp:client:leaveCurrentRace', function()
    leaveCurrentRace()
end)

RegisterNUICallback('UiLeaveCurrentRace', function(raceid, cb)
    DebugLog('Leaving race with race id', raceid)
    cb(leaveCurrentRace())
end)

RegisterNUICallback('UiStartCurrentRace', function(raceid, cb)
    DebugLog('starting race with race id', raceid)
    TriggerServerEvent('cw-racingapp:server:startRace', raceid)
    cb(true)
end)

RegisterNUICallback('UiChangeRacerName', function(racername, cb)
    local result = cwCallback.await('cw-racingapp:server:changeRacerName', racername)
    if result then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNUICallback('UiGetRacerNamesByPlayer', function(racername, cb)
    local playerNames = cwCallback.await('cw-racingapp:server:getRacerNamesByPlayer')

    MyRacerNames = playerNames
    DebugLog('player names', #playerNames, json.encode(playerNames))
    local currentRacer = findRacerByName()
    if currentRacer and currentRacer.revoked == 1 then
        notifyHandler(Lang("revoked_access"), 'error')
    end
    if currentRacer then
        if currentRacer.ranking then
            CurrentRanking = currentRacer.ranking
            DebugLog('Ranking is', CurrentRanking)
        end
        if currentRacer.crypto then
            CurrentCrypto = currentRacer.crypto
            DebugLog('Crypto is', CurrentCrypto)
        end
    end
    cb(playerNames)
end)

RegisterNUICallback('UiPurchaseCrypto', function(data, cb)
    DebugLog('purchasing crypto', data.cryptoAmount)
    local result = cwCallback.await('cw-racingapp:server:purchaseCrypto', CurrentName, data.cryptoAmount)
    DebugLog('purchasing crypto result', result)
    Wait(1000)
    cb(result)
end)

RegisterNUICallback('UiSellCrypto', function(data, cb)
    DebugLog('selling crypto', data.cryptoAmount)
    local result = cwCallback.await('cw-racingapp:server:sellCrypto', CurrentName, data.cryptoAmount)
    DebugLog('selling crypto result', result)
    Wait(1000)
    cb(result)
end)

RegisterNUICallback('UiTransferCrypto', function(data, cb)
    DebugLog('selling crypto', data.cryptoAmount, 'to', data.recipient)
    local result = cwCallback.await('cw-racingapp:server:transferCrypto', CurrentName, data.cryptoAmount, data.recipient)
    DebugLog('selling crypto result', result)
    Wait(1000)
    cb(result)
end)

RegisterNUICallback('UiChangeAuth', function(data, cb)
    DebugLog('changing auth', json.encode(data, {indent=true}))
    if not Config.Permissions[data.auth] then debugPrint('User type does not exist') return end
    local result = cwCallback.await('cw-racingapp:server:setUserAuth', data)
    cb(result)
end)

RegisterNUICallback('UiRevokeRacer', function(data, cb)
    DebugLog('revoking racename', data.racername, data.status)
    local newStatus = 0
    if data.status == 0 then newStatus = 1 end
    TriggerServerEvent("cw-racingapp:server:setRevokedRacenameStatus", data.racername, newStatus)
    cb(true)
end)

RegisterNUICallback('UiRemoveRecord', function(data, cb)
    DebugLog('permanently removing record', json.encode(data, { indent = true }))
    TriggerServerEvent("cw-racingapp:server:removeRecord", data.trackId, data.record)
    cb(true)
end)

RegisterNUICallback('UiRemoveRacer', function(data, cb)
    DebugLog('permanently removing racename', data.racername)
    TriggerServerEvent("cw-racingapp:server:removeRacerName", data.racername)
    Wait(500)
    cb(true)
end)

RegisterNUICallback('UiGetRacersCreatedByUser', function(_, cb)
    local racerId = getCitizenId()
    local playerNames = cwCallback.await('cw-racingapp:server:getRacersCreatedByUser', racerId, CurrentAuth)

    DebugLog('player names', #playerNames, json.encode(playerNames))
    cb(playerNames)
end)

RegisterNUICallback('UiGetPermissionedUserTypes', function(_, cb)
    local options = {}

    local currency
    if Config.Laptop.moneyType == 'cash' or Config.Laptop.moneyType == 'money' or Config.Laptop.moneyType == 'bank' then
        currency = '$'
    else
        currency = Config.Payments.cryptoType
    end

    for authName, _ in pairs(Config.Permissions) do
        if hasAuth(Config.Laptop, authName) then
            local option = {
                label = authName .. ' user (' .. currency .. Config.Laptop.racingUserCosts[authName] .. ')',
                purchaseType = Config.Laptop,
                fobType = authName,
            }
            options[#options + 1] = option
        end
    end
    cb(options)
end)

RegisterNuiCallback('UiGetPermissionedUserTypeFirstUser', function(_, cb)
    local data = {}
    if IsFirstUser then
        data.fobType = 'god'
    else
        data.fobType = Config.BasePermission
    end
    data.purchaseType = Config.Laptop
    cb(data)
end)

RegisterNuiCallback('UiGetBounties', function(_, cb)
    local bounties = cwCallback.await('cw-racingapp:server:getBounties')
    cb(bounties)
end)

RegisterNuiCallback('UIRerollBounties', function(_, cb)
    TriggerServerEvent('cw-racingapp:server:rerollBounties')
    cb(true)
end)

RegisterNuiCallback('UiToggleHosting', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:toggleHosting')
    cb(result)
end)

RegisterNuiCallback('UiToggleAutoHost', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:toggleAutoHost')
    cb(result)
end)

RegisterNuiCallback('UINewAutoHost', function(_, cb)
    TriggerServerEvent('cw-racingapp:server:newAutoHost')
    cb(true)
end)

RegisterNuiCallback('UiGetAdminData', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:getAdminData')
    cb(result)
end)

local function getRaceByRaceId(Races, raceId)
    for _, race in pairs(Races) do
        if race.RaceId == raceId then
            return race
        end
    end
end

-- Join a race with raceId. Returns false if issue or true if worked
local function joinRace(raceId)
    DebugLog('attempt joining race with race id', raceId)
    if CurrentRaceData.RaceId ~= nil then
        notifyHandler(Lang("already_in_race"), 'error')
        return false
    end
    local PlayerPed = PlayerPedId()
    local PlayerIsInVehicle = IsPedInAnyVehicle(PlayerPed, false)

    local class
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)
    if PlayerIsInVehicle and isDriver(vehicle) then
        class = getVehicleClass(vehicle)
    else
        notifyHandler(Lang('not_in_a_vehicle'), 'error')
        return false
    end

    local result = cwCallback.await('cw-racingapp:server:getRaces')
    local currentRace = getRaceByRaceId(result, raceId)

    if currentRace == nil then
        notifyHandler(Lang("race_no_exist"), 'error')
    else
        if myCarClassIsAllowed(currentRace.MaxClass, class) then
            currentRace.RacerName = CurrentName
            currentRace.PlayerVehicleEntity = GetVehiclePedIsIn(PlayerPed, false)
            DebugLog('^2 joining race with race id', raceId)
            TriggerServerEvent('cw-racingapp:server:joinRace', currentRace)
            return true
        else
            notifyHandler(Lang('incorrect_class'), 'error')
        end
    end
    return false
end
exports('joinRace', joinRace)

RegisterNetEvent("cw-racingapp:client:joinRaceByRaceId", function(raceId)
    joinRace(raceId)
end)

RegisterNUICallback('UiJoinRace', function(raceId, cb)
    cb(joinRace(raceId))
end)

RegisterNUICallback('UiSetWaypoint', function(track, cb)
    if track and track.Checkpoints then
        SetNewWaypoint(
            track.Checkpoints[1].coords.x --[[ number ]],
            track.Checkpoints[1].coords.y --[[ number ]]
        )
    end
    cb(true)
end)

RegisterNUICallback('UiClearLeaderboard', function(track, cb)
    DebugLog('clearing leaderboard for ', track.RaceName)
    notifyHandler(track.RaceName .. Lang("leaderboard_has_been_cleared"))
    TriggerServerEvent("cw-racingapp:server:clearLeaderboard", track.TrackId)
    cb(true)
end)

RegisterNUICallback('UiDeleteTrack', function(track, cb)
    DebugLog('deleting track', track.RaceName)
    notifyHandler(track.RaceName .. Lang("has_been_removed"))
    TriggerServerEvent("cw-racingapp:server:deleteTrack", track.TrackId)
    cb(true)
end)

RegisterNUICallback('UiEditTrack', function(track, cb)
    DebugLog('opening track editor for', track.RaceName)
    TriggerEvent("cw-racingapp:client:startRaceEditor", track.RaceName, CurrentName, track.TrackId)
    cb(true)
end)

RegisterNUICallback('UiGetAccess', function(track, cb)
    DebugLog('gettingAccessFor', track.RaceName)

    local result = cwCallback.await('cw-racingapp:server:getAccess', track.TrackId)
    if not result then
        DebugLog('Access table was empty')
        result = { race = '' }
    else
        local raceText = ''
        if result.race then
            for i, v in pairs(result.race) do
                if i == 1 then
                    raceText = v
                else
                    raceText = raceText .. ', ' .. v
                end
            end
            result = { race = raceText }
        else
            result.race = ''
        end
    end
    cb(result)
end)

RegisterNUICallback('UiEditAccess', function(track, cb)
    DebugLog('editing access for', track.RaceName)
    local newAccess = {
        race = split(track.NewAccess.race)
    }
    TriggerServerEvent("cw-racingapp:server:setAccess", track.TrackId, newAccess)
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
        local canStart = false
        if CurrentRaceData.SetupCitizenId then
            canStart = (CurrentRaceData.SetupCitizenId == getCitizenId()) and not CurrentRaceData.Started
        end
        local data = {
            trackName = CurrentRaceData.RaceName,
            racers = racers,
            laps = CurrentRaceData.TotalLaps,
            class = tostring(maxClass),
            canStart = canStart,
            raceId = CurrentRaceData.RaceId,
            ghosting = CurrentRaceData.Ghosting,
            ranked = CurrentRaceData.Ranked,
            reversed = CurrentRaceData.Reversed,
            hostName = CurrentRaceData.SetupRacerName
        }
        DebugLog('Current race', json.encode(data, { indent = true }))
        cb(data)
    else
        cb({})
    end
end)

RegisterNUICallback('UiGetSettings', function(_, cb)
    cb({
        IgnoreRoadsForGps = IgnoreRoadsForGps,
        ShowGpsRoute = ShowGpsRoute,
        UseUglyWaypoint = UseUglyWaypoint,
        CheckDistance =
            CheckDistance,
        UseDrawTextWaypoint = UseDrawTextWaypoint
    })
end)

local function getAvailableTracks()
    local result = cwCallback.await('cw-racingapp:server:getTracks')
    local tracks = {}
    for _, track in pairs(result) do
        if verifyTrackAccess(track, 'race') then
            tracks[#tracks + 1] = track
        end
    end
    return sortTracksByName(tracks)
end
exports('getAvailableTracks', getAvailableTracks)

RegisterNUICallback('UiGetAvailableTracks', function(data, cb)
    cb(getAvailableTracks())
end)

local function getAvailableRaces()
    local result = cwCallback.await('cw-racingapp:server:getAvailableRaces')
    local availableRaces = {}
    if #result > 0 then
        DebugLog('Fetching available races:', json.encode(result))
        for _, race in pairs(result) do
            DebugLog('Race:', json.encode(race))
            local racers = 0
            local PlayerPed = PlayerPedId()
            race.PlayerVehicleEntity = GetVehiclePedIsIn(PlayerPed, false)
            for _ in pairs(race.RaceData.Racers) do
                racers = racers + 1
            end

            race.RacerName = CurrentName

            local maxClass = 'open'
            if (race.RaceData.MaxClass ~= nil and race.RaceData.MaxClass ~= "") then
                maxClass = race.RaceData.MaxClass
            end
            race.maxClass = maxClass
            race.racers = racers
            race.disabled = CurrentRaceData.RaceId
            race.laps = race.Laps
            availableRaces[#availableRaces + 1] = race
        end
    end
    return sortRacesByName(availableRaces)
end
exports('getAvailableRaces', getAvailableRaces)

RegisterNUICallback('UiGetListedRaces', function(_, cb)
    cb(getAvailableRaces())
end)

local function stringKeysToArray(tbl)
    local result = {}
    for _, value in pairs(tbl) do
        table.insert(result, value)
    end
    return result
end

RegisterNUICallback('UiGetRaces', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:getTracks')
    cb(sortTracksByName(stringKeysToArray(result)))
end)

RegisterNUICallback('UiGetMyTracks', function(data, cb)
    local result = cwCallback.await('cw-racingapp:server:getTracks')
    cb(sortRacesByName(result))
end)

RegisterNUICallback('UiGetRacingResults', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:getRaceResults')
    cb(result)
end)

-- Setup race. See Racingapp readme for info on what setupData needs to include
local function attemptSetupRace(setupData)
    if not setupData or setupData.track == "none" then
        DebugLog('No setup data or missing track')
        return false
    end
    DebugLog('setup data', json.encode(setupData))
    local PlayerPed = PlayerPedId()
    local PlayerIsInVehicle = IsPedInAnyVehicle(PlayerPed, false)
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)

    if PlayerIsInVehicle and isDriver(vehicle) then
        local class = getVehicleClass(GetVehiclePedIsIn(PlayerPed, false))
        if myCarClassIsAllowed(setupData.maxClass, class) then
            local data = {
                trackId = setupData.trackId,
                laps = tonumber(setupData.laps),
                hostName = CurrentName,
                maxClass = setupData.maxClass,
                ghostingEnabled = setupData.ghostingOn,
                ghostingTime = tonumber(setupData.ghostingTime),
                buyIn = tonumber(setupData.buyIn),
                ranked = setupData.ranked,
                reversed = setupData.reversed,
                participationMoney = setupData.participationMoney,
                participationCurrency = setupData.participationCurrency,
                firstPerson = setupData.firstPerson,
                silent = setupData.silent,
                hidden = setupData.hidden
            }
            local res = cwCallback.await('cw-racingapp:server:setupRace', data)
            return res
        else
            notifyHandler(Lang('incorrect_class'), 'error')
            return false
        end
    else
        notifyHandler(Lang('not_in_a_vehicle'), 'error')
        return false
    end
end
exports('attemptSetupRace', attemptSetupRace)

RegisterNUICallback('UiSetupRace', function(setupData, cb)
    cb(attemptSetupRace(setupData))
end)

RegisterNUICallback('UiQuickSetupBounty', function(bounty, cb)
    local setupData = {}
    for field, value in pairs(Config.QuickSetupDefaults) do
        setupData[field] = value
    end
    setupData.trackId = bounty.trackId
    setupData.maxClass = bounty.maxClass
    setupData.reversed = bounty.reversed

    if bounty.sprint then
        setupData.laps = 0
    end

    cb(attemptSetupRace(setupData))
end)

RegisterNUICallback('UiQuickHost', function(track, cb)
    local setupData = {}
    for field, value in pairs(Config.QuickSetupDefaults) do
        setupData[field] = value
    end
    setupData.trackId = track.TrackId
    if track.Metadata then
        if track.Metadata.raceType == 'sprint' then
            setupData.laps = 0
        end
    end

    if track.sprint then
        setupData.laps = 0
    end

    cb(attemptSetupRace(setupData))
end)

local function verifyCheckpoints(checkpoints)
    for _, data in pairs(checkpoints) do
        local coordsExist = data.coords.x and data.coords.y and data.coords.z
        local offsetExists = data.offset.left.x and data.offset.left.y and data.offset.left.z and data.offset.right.x and
            data.offset.right.y and data.offset.right.z
        if coordsExist and offsetExists then return true end
    end
    return false
end

RegisterNUICallback('UiCreateTrack', function(createData, cb)
    if not createData.name then return end
    DebugLog('create data', json.encode(createData))
    if not createData or createData.name == "" then
        return
    end

    local checkpoints = createData.checkpoints
    local decodedCheckpoints = json.decode(checkpoints)
    if checkpoints ~= nil then
        if type(decodedCheckpoints) == 'table' then
            if not verifyCheckpoints(decodedCheckpoints) then
                notifyHandler(Lang("corrupt_data"))
                return
            end
        else
            notifyHandler(Lang("cant_decode"))
            return
        end
    end

    local citizenId = getCitizenId()
    local tracks = cwCallback.await('cw-racingapp:server:getAmountOfTracks', citizenId)

    local maxCharacterTracks = Config.MaxCharacterTracks
    if Config.CustomAmountsOfTracks[citizenId] then
        maxCharacterTracks = Config.CustomAmountsOfTracks[citizenId]
    end

    DebugLog('Max allowed for you:', maxCharacterTracks, "You have this many tracks:", tracks)

    if Config.LimitTracks and tracks >= maxCharacterTracks then
        notifyHandler(Lang("max_tracks") .. maxCharacterTracks)
        return
    else
        if not #createData.name then
            notifyHandler(Lang("no_name_track"), 'error')
            cb(false)
            return
        end

        if #createData.name < Config.MinTrackNameLength then
            notifyHandler(Lang("name_too_short"), 'error')
            cb(false)
            return
        end

        if #createData.name > Config.MaxTrackNameLength then
            notifyHandler(Lang("name_too_long"), 'error')
            cb(false)
            return
        end

        local result = cwCallback.await('cw-racingapp:server:isAuthorizedToCreateRaces', createData.name, CurrentName)

        if not result.permissioned then
            notifyHandler(Lang("not_auth"), 'error')
            cb(false)
        end
        if not result.nameAvailable then
            notifyHandler(Lang("race_name_exists"), 'error')
            cb(false)
        end

        TriggerServerEvent('cw-racingapp:server:createTrack', createData.name, CurrentName, decodedCheckpoints)
        cb(true)
    end
end)
RegisterNUICallback('UiSetCurated', function(data, cb)
    DebugLog('Setting curation status for', data.trackId, data.curated)
    local result = cwCallback.await('cw-racingapp:server:curateTrack', data.trackId, data.curated)

    DebugLog('Success: ', result)
    cb(result)
end)

-- Crew stuff
RegisterNUICallback('UiJoinCrew', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:joinCrew', CurrentName, citizenId, data.crewName)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = result
        TriggerServerEvent('cw-racingapp:server:changeCrew', CurrentCrew)
    end
    cb(result)
end)

RegisterNUICallback('UiLeaveCrew', function(data, cb)
    DebugLog('Leaving', data.crewName)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:leaveCrew', CurrentName, citizenId, data.crewName)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = nil
        TriggerServerEvent('cw-racingapp:server:changeCrew', nil)
    end
    cb(result)
end)

RegisterNUICallback('UiDisbandCrew', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:disbandCrew', citizenId, data.crewName)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = nil
        TriggerServerEvent('cw-racingapp:server:changeCrew', nil)
    end
    cb(result)
end)

RegisterNUICallback('UiCreateCrew', function(data, cb)
    local sanitizedName = strictSanitize(data.crewName)
    if #sanitizedName == 0 then
        notifyHandler(Lang("name_too_short"), 'error')
        cb(false)
        return
    end
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:createCrew', CurrentName, citizenId, sanitizedName)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = sanitizedName
        TriggerServerEvent('cw-racingapp:server:changeCrew', sanitizedName)
    end
    cb(result)
end)

RegisterNUICallback('UiCreateUser', function(data, cb)
    if data.racerName and data.selectedAuth then
        attemptCreateUser(data.racerName, data.racerId, data.selectedAuth.fobType, data.selectedAuth.purchaseType)
    else
        notifyHandler(Lang("bad_input"), 'error')
    end
    cb(true)
end)

RegisterNUICallback('UiSendInvite', function(data, cb)
    if data.citizenId.length == 0 then
        notifyHandler(Lang("bad_input"), 'error')
        cb(false)
        return
    end
    local myServerID = GetPlayerServerId(PlayerId())

    local result = cwCallback.await('cw-racingapp:server:sendInvite', myServerID, data.citizenId, CurrentCrew)

    DebugLog('Success: ', result)
    cb(result)
end)
RegisterNUICallback('UiSendInviteClosest', function(data, cb)
    local closestP, distance = getClosestPlayer()
    if closestP == nil or distance > 5 then
        notifyHandler(Lang("prox_error"), 'error')
        cb(false)
        return
    end

    local closestServerID = GetPlayerServerId(closestP)
    local myServerID = GetPlayerServerId(PlayerId())

    local result = cwCallback.await('cw-racingapp:server:sendInviteClosest', myServerID, closestServerID, CurrentCrew)
    DebugLog('Success: ', result)
    cb(result)
end)

RegisterNUICallback('UiAcceptInvite', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:acceptInvite', CurrentName, citizenId)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = data.crewName
        TriggerServerEvent('cw-racingapp:server:changeCrew', data.crewName)
    end
    cb(result)
end)

RegisterNUICallback('UiDenyInvite', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:denyInvite', citizenId)
    DebugLog('Success: ', result)
    cb(result)
end)

RegisterNUICallback('UiGetAllCrews', function(data, cb)
    local result = cwCallback.await('cw-racingapp:server:getAllCrews')
    DebugLog('All crews: ', json.encode(result))
    cb(result)
end)

RegisterNUICallback('UiGetAllRacers', function(data, cb)
    local result = cwCallback.await('cw-racingapp:server:getAllRacers')
    DebugLog('All racers: ', json.encode(result))
    cb(result)
end)

RegisterNUICallback('UiConfirmSettings', function(data, cb)
    DebugLog('Settings data for track ' .. data.TrackId, json.encode(data.Metadata, { indent = true }))
    local result = cwCallback.await('cw-racingapp:server:updateTrackMetadata', data.TrackId, data.Metadata)
    cb(result)
end)

RegisterNUICallback('UiGetCrewData', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:getCrewData', citizenId, CurrentCrew)

    DebugLog('crew data: ', json.encode(result))
    cb(result)
end)

RegisterNUICallback('UiCancelRace', function(trackId, cb)
    DebugLog('Cancelling', trackId)
    local result = cwCallback.await('cw-racingapp:server:cancelRace', trackId)
    Wait(1000)
    CurrentRaceData.RaceId = nil
    cb(result)
end)

RegisterNUICallback('UiShowTrack', function(trackId, cb)
    DebugLog('displaying track', trackId)
    local result = cwCallback.await('cw-racingapp:server:getTrackData', trackId)
    if not result then notifyHandler(Lang("no_track_found")..tostring(trackId)) return end


    displayTrack(result)
    SetTimeout(20 * 1000, function()
        FinishedUITimeout = false
        hideTrack()
    end)
    cb(true)
    Wait(500)
    notifyHandler(Lang("display_tracks"))
end)

local function toggleShowRoute(boolean)
    if boolean == nil then
        ShowGpsRoute = not ShowGpsRoute
    else
        ShowGpsRoute = boolean
    end
    if ShowGpsRoute then
        notifyHandler(Lang("toggled_gps_route_on"), 'success')
    else
        notifyHandler(Lang("toggled_gps_route_off"), 'error')
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
        notifyHandler(Lang("gps_straight_on"), 'error')
    else
        notifyHandler(Lang("gps_straight_off"), 'success')
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
        notifyHandler(Lang("basic_wps_on"), 'success')
    else
        notifyHandler(Lang("basic_wps_off"), 'error')
    end
end

local function toggleDrawTextWaypoint(boolean)
    if boolean == nil then
        UseDrawTextWaypoint = not UseDrawTextWaypoint
    else
        UseDrawTextWaypoint = boolean
    end
    if UseDrawTextWaypoint then
        notifyHandler(Lang("draw_text_wps_on"), 'success')
    else
        notifyHandler(Lang("draw_text_wps_off"), 'error')
    end
end

RegisterCommand('basicwaypoint', function()
    toggleUglyWaypoint()
end)

RegisterNUICallback('UiUpdateSettings', function(data, cb)
    if data.setting == 'IgnoreRoadsForGps' then
        toggleIgnoreRoadsForGps(data.value)
    elseif data.setting == 'ShowGpsRoute' then
        toggleShowRoute(data.value)
    elseif data.setting == 'UseDrawTextWaypoint' then
        toggleDrawTextWaypoint(data.value)
    elseif data.setting == 'UseUglyWaypoint' then
        toggleUglyWaypoint(data.value)
    elseif data.setting == 'CheckDistance' then
        CheckDistance = data.value
        if CheckDistance then
            notifyHandler(Lang("distance_on"), 'success')
        else
            notifyHandler(Lang("distance_off"), 'error')
        end
    end
end)

local function getCurrentRankingFromRacer(racerNames)
    for _, racer in pairs(racerNames) do
        if racer.racername == CurrentName then
            return racer.ranking
        end
    end
end

local function getCurrentCryptoFromRacer(racerNames)
    for _, racer in pairs(racerNames) do
        if racer.racername == CurrentName then
            return racer.crypto
        end
    end
end

function initialSetup()
    Wait(1000)
    CharacterHasLoaded = true
    IsFirstUser = cwCallback.await('cw-racingapp:server:isFirstUser')

    LocalPlayer.state:set('inRace', false, true)
    LocalPlayer.state:set('raceId', nil, true)
    local playerNames = cwCallback.await('cw-racingapp:server:getRacerNamesByPlayer')
    MyRacerNames = playerNames
    DebugLog('player names', json.encode(playerNames))

    local racerData = getActiveRacerName()
    if not racerData then return end

    local racerName = racerData.racername
    local racerAuth = racerData.auth
    local racerCrew = racerData.crew

    if racerName then
        CurrentName = racerName
        CurrentAuth = racerAuth
        CurrentRanking = getCurrentRankingFromRacer(playerNames)
        CurrentCrypto = getCurrentCryptoFromRacer(playerNames)
        if UseDebug then
            print('^3Racer name in metadata: ^0', racerName)
            print('^3Racer auth in metadata: ^0', racerAuth)
            print('^3Ranking^0', CurrentRanking)
            print('^3Crypto^0', CurrentCrypto)
        end
    else
        if getSizeOfTable(playerNames) == 1 then
            local result = cwCallback.await('cw-racingapp:server:changeRacerName', playerNames[1].racername)
            if result and result.name then
                DebugLog('Only one racername available. Setting to ', result.name, result.auth)
                CurrentName = result.name
                CurrentAuth = result.auth
                CurrentRanking = getCurrentRankingFromRacer(playerNames)
                CurrentCrypto = getCurrentCryptoFromRacer(playerNames)
            end
        end
    end
    if racerCrew then
        DebugLog('Has a crew set in metadata', racerCrew)
        CurrentCrew = racerCrew
        local crewExists = cwCallback.await('cw-racingapp:server:crewStillExists', racerCrew)
        if crewExists then
            DebugLog('crew still exists', crewExists)
        else
            DebugLog('Crew does not exist anymore', CurrentCrew)
            TriggerServerEvent('cw-racingapp:server:changeCrew', CurrentName, nil)
            CurrentCrew = nil
        end
    end
    SendNUIMessage({
        type = "updateBaseData",
    })
    if UseDebug then
        notifyHandler('Racing App setup is done!', 'success')
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if UseDebug then
        print('^3--- Debug is on for Racingapp --- ')

        print('^2Inventory is set to ', Config.Inventory)
        print('^2Using Oxlib for keybinds ', Config.UseOxLibForKeybind)
        print('^2Using Racing App Crypto ', Config.Payments.useRacingCrypto)

        print('^2Permissions:', json.encode(Config.Permissions))
        print('^2Classes: ', json.encode(Classes))
    end
    initialSetup()
end)
