if not ConfigDrift.useDriftChallenges then return end

local ActiveDriftChallengeId = nil
local ActiveChallengerName = nil
local LatestChallengeId = nil
local LatestChallengerName = nil

local isHost = false

local DriftChallengeResults = {}

local function startDriftChallenge()

    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not IsDriver(playerVehicle) then
        NotifyHandler(Lang('drift_challenge_must_be_driver'))
        return
    end

    isHost = true
    TriggerServerEvent('cw-racingapp:drift-challenge:server:setup', CurrentUserData.racername)
end

local function joinDriftChallenge(challengeId)
    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not IsDriver(playerVehicle) then
        NotifyHandler(Lang('drift_challenge_must_be_driver'))
        return
    end

    isHost = false
    TriggerServerEvent('cw-racingapp:drift-challenge:server:join', challengeId, CurrentUserData.racername )
    LatestChallengeId = nil
    LatestChallengerName = nil
    ActiveDriftChallengeId = challengeId
end

-- Event handlers
RegisterNetEvent('cw-racingapp:drift-challenge:client:checkForJoiners', function(challengeId)
    DebugLog('Drift challenge started! Looking for nearby players to invite...')
    -- Similar to head2head proximity check
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local amountInvited = 0
    ActiveDriftChallengeId = challengeId
    for _, playerId in ipairs(GetActivePlayers()) do
        local otherPed = GetPlayerPed(playerId)
        local otherCoords = GetEntityCoords(otherPed)
        
        if playerPed ~= otherPed and #(playerCoords - otherCoords) <= 20.0 then
            local playerSrc = GetPlayerServerId(playerId)
            DebugLog('Inviting player', playerSrc, 'to drift challenge', challengeId)

            TriggerServerEvent('cw-racingapp:drift-challenge:server:invitePlayer', playerSrc, challengeId, CurrentUserData.racername)
            amountInvited = amountInvited + 1
        end
    end
    DebugLog('Total players invited to drift challenge:', amountInvited)

    if amountInvited == 0 then
        -- No one to invite, start countdown immediately
        DebugLog('No players nearby to invite, starting challenge countdown')
        isHost = false
        NotifyHandler(Lang('drift_challenge_invite_none'))
        TriggerServerEvent('cw-racingapp:drift-challenge:server:leaveChallenge', challengeId)
        ActiveDriftChallengeId = nil
    end
    
end)

RegisterNetEvent('cw-racingapp:drift-challenge:client:notifyNewJoiner', function(racerName)
    NotifyHandler(racerName..Lang('drift_challenge_new_joiner'))
end)

RegisterNetEvent('cw-racingapp:drift-challenge:client:receiveInvite', function(challengeId, inviterName)
    LatestChallengeId = challengeId
    LatestChallengerName = inviterName
    NotifyHandler(Lang('drift_challenge_invite'))
    local data = {
        latestChallengeId = LatestChallengeId,
        latestChallengerName = LatestChallengerName,
        activeChallengerName = ActiveChallengerName,
        activeDriftChallengeId = ActiveDriftChallengeId
    }
    UpdateUiData('driftChallenge', data)
end)

RegisterNetEvent('cw-racingapp:drift-challenge:client:startCountdown', function(challengeId)
    ActiveDriftChallengeId = challengeId
    ActiveChallengerName = LatestChallengerName
    local countdown = 5

    CreateThread(function()
        while countdown > 0 do
            -- Update UI with countdown
            SendNUIMessage({
                type = 'drift_countdown',
                action = 'countdown',
                data = { seconds = countdown }
            })
            
            countdown = countdown - 1
            Wait(1000)
        end
        SendNUIMessage({
            type = 'drift_countdown',
            action = 'countdown',
            data = { seconds = 0 }
        })
        SetTimeout(1500, function()
            SendNUIMessage({
              type = 'drift_countdown',
                action = 'countdown',
                data = { seconds = -1 }
            })
        end)
            

        -- Start drift session
        if isHost then TriggerServerEvent('cw-racingapp:drift-challenge:server:started', challengeId) end
        StartDriftSystem()

        -- Start score update thread
        CreateThread(function()
            while ActiveDriftChallengeId do
                local score = GetCurrentDriftScore()
                TriggerServerEvent('cw-racingapp:drift-challenge:server:updateScore', 
                    challengeId, score)
                Wait(1000)
            end
        end)
    end)
end)

RegisterNetEvent('cw-racingapp:drift-challenge:client:getFinalScore', function()
    ForceDriftScore()
    local score = GetCurrentDriftScore()
    TriggerServerEvent('cw-racingapp:drift-challenge:server:updateScore', 
        ActiveDriftChallengeId, score)
    NotifyHandler(Lang('in_driftChallenge'))
    ActiveDriftChallengeId = nil
    StopDriftSystem()
end)

RegisterNetEvent('cw-racingapp:drift-challenge:client:finish', function(winner, highestScore,challengeId, allScores)
    
    local isWinner = winner == GetPlayerServerId(PlayerId())
    NotifyHandler(isWinner and Lang('drift_challenge_you_won') or 
        Lang('drift_challenge_you_lost'))
    
    -- Update UI with results
    SendNUIMessage({
        type = 'drift_finish',
        data = {
            winner = winner,
            highestScore = highestScore,
            scores = allScores,
            challengerName = ActiveChallengerName
        }
    })
    SetTimeout(ConfigDrift.driftChallengeSettings.scoreBoardTimeout * 1000, function()
        SendNUIMessage({
            type = 'drift_finish',
            data = nil
        })
    end)
    DriftChallengeResults[challengeId] = allScores
end)

RegisterNUICallback('UiFetchDriftChallengeData', function(_, cb)
    local data = {
        latestChallengeId = LatestChallengeId,
        latestChallengerName = LatestChallengerName,
        activeChallengerName = ActiveChallengerName,
        activeDriftChallengeId = ActiveDriftChallengeId
    }
    DebugLog('[H2H] fetching data', json.encode(data, {indent=true}))
    cb(data)
end)

RegisterNUICallback('UiSetupDriftChallenge', function(_, cb)
    DebugLog('[Drift] setting up challenge')
    startDriftChallenge()
    Wait(1000)
    cb(true)
end)

RegisterNUICallback('UiDenyDriftChallenge', function(_, cb)
    DebugLog('[Drift] denying challenge invite')
    LatestChallengeId = nil
    cb(true)
end)

RegisterNUICallback('UiJoinDriftChallenge', function(_, cb)
    DebugLog('[Drift] joining challenge', LatestChallengeId)
    joinDriftChallenge(LatestChallengeId)
    Wait(1000)
    cb(true)
end)

RegisterNUICallback('UiLeaveDriftChallenge', function(_, cb)
    DebugLog('[Drift] leaving active challenge', ActiveDriftChallengeId)
    if ActiveDriftChallengeId then TriggerServerEvent('cw-racingapp:drift-challenge:server:leaveChallenge', ActiveDriftChallengeId) end
    Wait(1000)
    cb(true)
end)


-- Command to start a challenge
RegisterCommand('driftchallenge', function()
    startDriftChallenge()
end, false)

-- Command to join a challenge (or use UI button)
RegisterCommand('joindrift', function()
    if LatestChallengeId then
        joinDriftChallenge(LatestChallengeId)
    else
        print('No active drift challenge to join.')
    end
end, false)