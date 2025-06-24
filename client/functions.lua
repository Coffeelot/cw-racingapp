------------------------
-- CALLBACK FUNCTIONS --
------------------------

cwCallback = {}
local callbackId = 0
local callbacks = {}

function cwCallback.await(name, ...)
    local p = promise.new()

    local id = callbackId
    callbackId = callbackId + 1

    callbacks[id] = p

    TriggerServerEvent('server:triggerServerCallback', name, id, ...)

    return Citizen.Await(p)[1]
end

RegisterNetEvent('client:serverCallback')
AddEventHandler('client:serverCallback', function(id, ...)
    if callbacks[id] then
        callbacks[id]:resolve({ ... })
        callbacks[id] = nil
    end
end)

-- Global Functions --

function NotifyHandler(message, type)
    if CharacterHasLoaded and hasGps() then
        notify(message, type)
    end
end

function GetSizeOfTable(table)
    local count = 0
    if table then
        for _, _ in pairs(table) do
            count = count + 1
        end
    end
    return count
end

function StrictSanitize(input)
    if type(input) ~= "string" then
        return input
    end

    -- Remove leading/trailing spaces and collapse multiple spaces into single spaces
    input = input:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")

    -- Keep only allowed characters
    input = input:gsub("[^%w%s%-_]", "")

    return input
end

function NotifyHandler(message, type)
    if CharacterHasLoaded and hasGps() then
        notify(message, type)
    end
end

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

function AddPointToGpsRoute(cx, cy, offset)
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

function IsDriver(vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

function MyCarClassIsAllowed(maxClass, myClass)
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

CheckpointsPreview = {}

function HideTrack()
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    for _, blip in pairs(CheckpointsPreview) do
        RemoveBlip(blip)
    end
end

function FlatTable(table)
    local newTable = {}
    for _, tableData in pairs(table) do
        newTable[#newTable+1] = tableData
    end
    return newTable
end

function DisplayTrack(track)
    if #CheckpointsPreview > 0 then
        HideTrack()
    end
    if IgnoreRoadsForGps then
        ClearGpsCustomRoute()
    else
        ClearGpsMultiRoute()
    end
    StartGpsMultiRoute(Config.Gps.color, false, false)
    for i, checkpoint in pairs(track.Checkpoints) do
        AddPointToGpsRoute(checkpoint.coords.x, checkpoint.coords.y, checkpoint.offset)
        CheckpointsPreview[#CheckpointsPreview + 1] = CreateCheckpointBlip(checkpoint.coords, i)
        if IgnoreRoadsForGps then
            SetGpsCustomRouteRender(true, 16, 16)
        else
            SetGpsMultiRouteRender(true, 16, 16)
        end
    end
end

function LeaveCurrentRace()
    if CurrentRaceData and CurrentRaceData.RaceId then
        TriggerServerEvent('cw-racingapp:server:leaveRace', CurrentRaceData, 'leaving')
        return true
    end
    return false
end exports('leaveCurrentRace', LeaveCurrentRace)

function initialSetup()
    Wait(1000)
    CharacterHasLoaded = true
    IsFirstUser = cwCallback.await('cw-racingapp:server:isFirstUser')

    LocalPlayer.state:set('inRace', false, true)
    LocalPlayer.state:set('raceId', nil, true)
    local playerNames = cwCallback.await('cw-racingapp:server:getRacerNamesByPlayer')
    MyRacerNames = playerNames
    DebugLog('player names', json.encode(playerNames))
    
    local racerData = GetActiveRacerName()
    DebugLog('Racer Data', json.encode(racerData))
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
        if GetSizeOfTable(playerNames) == 1 then
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
        NotifyHandler('Racing App setup is done!', 'success')
    end
end