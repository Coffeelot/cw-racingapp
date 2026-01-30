if not ConfigDrift or not ConfigDrift.useDrift then DebugLog('Drift is disabled') return end
DebugLog('^2Drift is enabled^0')

local DriftLocal = {
    countdownActive = {},
    localFinished = false,
    lastSentDrift = 0
}

function ForceDriftScore()
    exports.cw_drifting:forceScore()
end

function GetCurrentDriftScore()
    return exports.cw_drifting:getDriftScore() or 0
end

function StartDriftSystem()
    ToggleDriftHud(true)
    return exports.cw_drifting:toggleDriftSystem(true)
end

function StopDriftSystem()
    ToggleDriftHud(false)
    return exports.cw_drifting:toggleDriftSystem(false)
end

function PauseDriftScoring()
    return exports.cw_drifting:pauseDriftScoring()
end

function DriftIsActive()
    return exports.cw_drifting:driftSystemIsActive()
end

local function setTotalDriftScore(score)
    return exports.cw_drifting:setTotalDriftScore(score)
end

-- UI helper: show countdown / notify via NUI
local function showDriftCountdown(raceId, seconds)
    SendNUIMessage({
        action = "update",
        type = "drift_countdown",
        data = { raceId = raceId, seconds = seconds },
        active = true
    })
end

RegisterNetEvent('cw-racingapp:client:forceSetDriftScore', function(driftScore)
    DebugLog('^4Received forceSetDriftScore event with score:^0', driftScore)
    setTotalDriftScore(driftScore)
end)

local function finalizeDriftRace(raceId)
    if not DriftLocal.localFinished and CurrentRaceData and CurrentRaceData.RaceId == raceId then
        -- mark finished to avoid double sends
        DriftLocal.localFinished = true
    end
end
-- When server tells clients a drift finish countdown started (first finisher crossed)
RegisterNetEvent('cw-racingapp:client:driftFinishCountdown', function(raceId, countdown)
    if not raceId then return end
    -- prevent multiple countdowns for same race
    if DriftLocal.countdownActive[raceId] then return end
    DriftLocal.countdownActive[raceId] = true
    DriftLocal.localFinished = DriftLocal.localFinished or false

    -- no countdown -> nothing to do
    if not countdown then
        finalizeDriftRace(raceId)
        return
    end


    -- show initial UI
    showDriftCountdown(raceId, countdown)

    -- Start local countdown thread. When it expires, auto-send finish with current drift score if player hasn't finished.
    CreateThread(function()
        local t = countdown
        while t > 0 do
            Wait(1000)
            t = t - 1
            showDriftCountdown(raceId, t)
        end

        finalizeDriftRace(raceId)

        DriftLocal.countdownActive[raceId] = nil
        showDriftCountdown(raceId, -1)  -- -1 means hide
    end)
end)

-- Show final results when server announces race finished
RegisterNetEvent('cw-racingapp:client:driftRaceFinished', function(raceId, results)
    if CurrentRaceData and CurrentRaceData.RaceId == raceId then
        -- results is a table of {RacerName, DriftScore, RacerSource, ...} sorted by score server-side
        SendNUIMessage({
            action = "update",
            type = "drift_results",
            data = { raceId = raceId, results = results },
            active = true
        })
    end
    -- reset local finished flag for this race
    DriftLocal.localFinished = false
    DriftLocal.countdownActive[raceId] = nil
end)

-- Event to listen for drift score updates to update the UI
RegisterNetEvent('cw_drifting:client:scoreUpdate', function(info)

end)
