local countdown = 5

local currentH2H = {}

local opponentId = nil
local inviteRaceId = nil
local invitee = nil

local startTime = 0
local maxDistance = 20
local hasFinished = false
local currentTime = 0
local useDebug = Config.Debug

local finishBlip = nil
local markers = {}

local finishEntity

local function updateH2HInfo(data)
    local newData = {
        opponentId = opponentId,
        current = currentH2H,
        inviteRaceId = inviteRaceId,
        invitee = invitee,
    }
    DebugLog('[H2H] Updating with data', json.encode(newData, {indent=true}))
    SendNUIMessage({
        action = "update",
        type = "head2head",
        data = newData,
    })
end

local function finishRace()
    DebugLog('^3[H2H] Finished Racer^0')

    currentH2H = {}
    opponentId = nil
    if finishBlip then RemoveBlip(finishBlip) end
    finishBlip = nil

    SetTimeout(5000, function()
        RaceData = {
            InCreator = false,
            InRace = false,
            ClosestCheckpoint = 0
        }
        SendNUIMessage({
            action = "update",
            type = "race",
            data = {},
            racedata = RaceData,
            active = false
        })
        updateH2HInfo()
    end)
    updateH2HInfo()
end

local function getPosition()
    
    if opponentId then
        local ply = GetPlayerPed(-1)
        local plyCoords = GetEntityCoords(ply, 0)    
        local plyDistance = #(plyCoords.xy-currentH2H.finishCoords.xy)
    
        local opponentId = GetPlayerFromServerId(opponentId)
        local target = GetPlayerPed(opponentId)
        local opponentCoords = GetEntityCoords(target, 0)
        local opponentDistance = #(opponentCoords.xy-currentH2H.finishCoords.xy)
        if plyDistance < opponentDistance then
            return 1
        elseif plyDistance == opponentDistance then
            return 2
        end
    end

    return 2
end

local function updateRaceUi()
    if currentH2H and opponentId then
        SendNUIMessage({
            action = "update",
            type = "race",
            data = {
                currentCheckpoint = 1,
                totalCheckpoints = 1,
                totalLaps = 0,
                currentLap = 0,
                raceStarted = currentH2H.started,
                raceName = 'Head 2 Head',
                time = currentTime,
                totalTime = currentTime,
                bestLap = currentTime,
                position = getPosition(),
                positions = nil,
                totalRacers = 2,
                ghosted = false,
            },
            racedata = RaceData,
            active = true
        })
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

RegisterNetEvent('cw-racingapp:h2h:client:notifyFinish', function(text)
    SendNUIMessage({
        action = "Finish",
        data = {
            value = text
        },
        active = true
    })
end)

local function initRacingThread()
    CreateThread(function()
        while currentH2H and currentH2H.raceId ~= nil do
            if currentH2H.raceId then
                if currentH2H.started and not currentH2H.finished then
                    local ped = PlayerPedId()
                    local pos = GetEntityCoords(ped)
                    local distanceToFinish = #(pos.xy - currentH2H.finishCoords.xy)
                    local height = math.min(MaxHeight, math.max(MinHeight, distanceToFinish / 2.5))
                    DrawRacingMarker(currentH2H.finishCoords, height)

                    -- Calculate text positions
                    local baseTextHeight = currentH2H.finishCoords.z + height
                    local labelHeight = baseTextHeight + 0.7 + height * 0.05
                    local distanceHeight = baseTextHeight + 0.5
                
                    local color = DistanceColor
                
                    -- Draw checkpoint label
                    local labelCoords = vector3(currentH2H.finishCoords.x, currentH2H.finishCoords.y, labelHeight)
                    Draw3DText(labelCoords, Lang("finish"), 0.25, color)
                
                    -- Draw distance
                    local distanceCoords = vector3(currentH2H.finishCoords.x, currentH2H.finishCoords.y, distanceHeight)
                    Draw3DText(distanceCoords, string.format("%.0fm", distanceToFinish), 0.5, DistanceColor)

                    currentTime = GetTimeDifference(GetGameTimer(), startTime)
                    
                    if not hasFinished and distanceToFinish < maxDistance then
                        PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        TriggerServerEvent('cw-head2head:server:finishRacer', currentH2H.raceId, getCitizenId(), GetTimeDifference(GetGameTimer(), startTime) )
                        hasFinished = true
                        Countdown = 5
                        PlaySoundFrontend(-1, Config.Sounds.Finish.lib, Config.Sounds.Finish.sound)
                        AnimpostfxPlay('CrossLineOut', 0, false)
                        Wait(1000)
                        finishRace()
                    end
                end
                updateRaceUi()
            end
            Wait(0)
        end
        DebugLog('[H2H] Breaking racing hud thread')
    end)
end

local function isPlayerNearby(playerCoords, otherPlayerCoords, maxDistance)
    return #(playerCoords - otherPlayerCoords) <= maxDistance
end

local function inviteNearbyPlayers(raceId, amount)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    local nearbyPlayersFound = false
    for _, playerId in ipairs(GetActivePlayers()) do
        local otherPed = GetPlayerPed(playerId)
        local otherPlayerCoords = GetEntityCoords(otherPed)
        if playerPed ~= otherPed and isPlayerNearby(playerCoords, otherPlayerCoords, ConfigH2H.InviteDistance) then
            TriggerServerEvent('cw-racingapp:h2h:server:invitePlayer', GetPlayerServerId(playerId), raceId, amount, CurrentName)
            nearbyPlayersFound = true
        end
    end

    if nearbyPlayersFound then
        notify(Lang('invite_sent'), 'success')
    else
        notify(Lang('prox_error'), 'error')
    end
end

RegisterNetEvent('cw-racingapp:h2h:client:invite', function(raceId, amount, inviterRacerName)
    DebugLog('[H2H] Invited to race', raceId)
    inviteRaceId = raceId
    invitee = inviterRacerName
    updateH2HInfo()
    local text = Lang('you_got_an_invite_h2h')
    if amount and amount > 0 then
        text = text..' ($'..amount..')'
    end
    notify(text, 'success')
    SetTimeout(ConfigH2H.InviteTimer, function()
        DebugLog('[H2H] Resetting invitation', raceId)
        inviteRaceId = nil
    end)
end)


RegisterNetEvent('cw-racingapp:h2h:client:checkDistance', function(raceId, amount)
    if useDebug then
        DebugLog('[H2H] checking if anyone is close', raceId)
    end
    inviteNearbyPlayers(raceId, amount)
end)

local function allNeonAreOn(vehicle)
    if IsVehicleNeonLightEnabled(vehicle, 1) and IsVehicleNeonLightEnabled(vehicle, 2) and IsVehicleNeonLightEnabled(vehicle, 3) and IsVehicleNeonLightEnabled(vehicle, 0) then
        return true
    else
        return false
    end
end

local function handleHighBeams()
    local PlayerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)
    SetVehicleFullbeam(vehicle, true)
    local FlashUnderglow = ConfigH2H.FlashUnderglow and allNeonAreOn(vehicle)
    if FlashUnderglow then
        SetVehicleNeonLightEnabled(vehicle, 2 , false)
    end
    Wait(400)
    SetVehicleFullbeam(vehicle, false)
    if FlashUnderglow then
        SetVehicleNeonLightEnabled(vehicle, 2 , true)
        SetVehicleNeonLightEnabled(vehicle, 0, false)
        SetVehicleNeonLightEnabled(vehicle, 1 , false)
    end
    Wait(400)
    SetVehicleFullbeam(vehicle, true)
    if FlashUnderglow then
        SetVehicleNeonLightEnabled(vehicle, 0, true)
        SetVehicleNeonLightEnabled(vehicle, 1 , true)
        SetVehicleNeonLightEnabled(vehicle, 3 , false)
    end
    Wait(400)
    SetVehicleFullbeam(vehicle, false)
    if FlashUnderglow then
        SetVehicleNeonLightEnabled(vehicle, 3 , true)
    end
end

local function joinHead2Head()
    if useDebug then
        DebugLog('[H2H] attempting to join', inviteRaceId)
    end
    if inviteRaceId then
        local citizenId = getCitizenId()
        local racerName = ''
        TriggerServerEvent('cw-racingapp:h2h:server:joinRace', citizenId, racerName, inviteRaceId)
        handleHighBeams()
        inviteRaceId = nil
        invitee = nil
        updateH2HInfo()

    else
        notify(Lang('error.you_have_no_invites'), 'error')
    end
end

RegisterNetEvent('cw-racingapp:h2h:client:joinRace', function()
    joinHead2Head()
end)

RegisterNetEvent('cw-racingapp:h2h:client:leaveRace', function(raceId)
    if raceId == currentH2H.raceId then
        finishRace()
    end
end)

local function setupHead2Head(data)
    if useDebug then
        DebugLog('[H2H] setting up race: $'..(data?.value or 0))
    end
    local citizenId = getCitizenId()
    local racerName = CurrentName or 'UNKNOWN'
    local startCoords = GetEntityCoords(GetPlayerPed(-1))
    local amount = data?.value or 0
    if useDebug then
        DebugLog(citizenId, json.encode(startCoords, {indent=true}))
    end
    local finishCoords = nil
    if GetFirstBlipInfoId( 8 ) ~= 0 then
        local waypointBlip = GetFirstBlipInfoId( 8 ) 
        local coord = Citizen.InvokeNative( 0xFA7C7F0AADF25D09, waypointBlip, Citizen.ResultAsVector( ) )
        finishCoords = vector3(coord.x,coord.y,coord.z)
    end
    TriggerServerEvent('cw-racingapp:h2h:server:setupRace', citizenId, racerName, startCoords, amount, 'head2head', finishCoords)
    handleHighBeams()
end

local defaultLightsState = 0
RegisterNetEvent('cw-racingapp:h2h:client:setupRace', function(data)
    setupHead2Head(data)
end)

local function getOpponent()
    local ply = GetPlayerPed(-1)
    for i, racer in pairs(currentH2H.racers) do
        local playerIdx = GetPlayerFromServerId(racer.source)
        local target = GetPlayerPed(playerIdx)
        if ply ~= target then
            opponentId = racer.source
            return racer.source
        end
    end
end

RegisterNetEvent('cw-racingapp:h2h:client:raceCountdown', function(race)
    hasFinished = false
    DebugLog('[H2H] Starting Countdown', json.encode(race, {indent=true}))
    currentH2H = race
    RaceData = {
        InRace = true,
        ClosestCheckPoint = currentH2H.finishCoords,
        RaceName = currentH2H.raceId,
        raceId = currentH2H.raceId,
    }
    opponentId = getOpponent()
    DebugLog('[H2H] Opponent SRC', opponentId)

    if currentH2H.raceId ~= nil then
        finishBlip = AddBlipForCoord(currentH2H.finishCoords)
        initRacingThread()
        SetNewWaypoint(currentH2H.finishCoords.x, currentH2H.finishCoords.y)
        while countdown ~= 0 do
            if currentH2H ~= nil then
                if countdown <= 5 then
                    updateCountdown(countdown)
                    PlaySound(-1, "slow", "SHORT_PLAYER_SWITCH_SOUND_SET", 0, 0, 1)
                end
                countdown = countdown - 1
            else
                break
            end
            Wait(1000)
        end
        updateCountdown(0)
        TriggerServerEvent('cw-racingapp:h2h:server:raceStarted', currentH2H.raceId)
        startTime = GetGameTimer()
        currentH2H.started = true
        countdown = 5
    else
        notify(Lang("error.already_in_race"), 'error')
    end
end)

RegisterNetEvent('cw-racingapp:h2h:client:debugMap', function()
    if #markers > 0 then
        DebugLog('[H2H] removing markers')
        for i, marker in pairs(markers) do
            RemoveBlip(marker)
        end
        markers = {}
    else
        DebugLog('[H2H] adding markers')
        for i, coord in pairs(ConfigH2H.Finishes) do
            markers[#markers+1] = AddBlipForCoord(coord.x, coord.y, coord.z)
        end    
    end
end)

RegisterNetEvent('cw-racingapp:h2h:client:toggleDebug', function(debug)
   DebugLog('[H2H] Setting debug to',debug)
   useDebug = debug
end)

AddEventHandler('onResourceStop', function (resource)
   if resource ~= GetCurrentResourceName() then return end
   if DoesEntityExist(finishEntity) then
        DebugLog('[H2H] deleting', finishEntity)
        DeleteEntity(finishEntity)
    end
end)

RegisterNUICallback('UiFetchH2HData', function(_, cb)
    local data = {
        opponentId = opponentId,
        current = currentH2H,
        inviteRaceId = inviteRaceId,
        invitee = invitee,
    }
    DebugLog('[H2H] fetching data', json.encode(data, {indent=true}))
    cb(data)
end)

RegisterNUICallback('UiSetupHead2Head', function(setupData, cb)
    setupHead2Head(setupData)
    Wait(1000)
    cb(true)
end)

RegisterNUICallback('UiDenyHead2Head', function(_, cb)
    inviteRaceId = nil
end)

RegisterNUICallback('UiJoinHead2Head', function(_, cb)
    joinHead2Head()
    Wait(1000)
    cb(true)
end)

RegisterNUICallback('UiLeaveHead2Head', function(_, cb)
    if currentH2H and currentH2H.raceId then TriggerServerEvent('cw-racingapp:h2h:server:leaveRace', currentH2H.raceId) end
    finishRace()
    Wait(1000)
    cb(true)
end)