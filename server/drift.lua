local DriftCountdowns = {} -- [raceId] = true while countdown running
local DriftCountdownLength = (Config and ConfigDrift and ConfigDrift.finishCountdown) or 9 -- seconds fallback

local function hasDriftAdminAccess(src)
    local raceUser = RADB.getActiveRacerName(getCitizenId(src))
    if not raceUser then
        NotifyHandler(src, Lang("error_no_user"), 'error')
        return false
    end
    local auth = raceUser.auth
    if not Config.Permissions[auth] or not Config.Permissions[auth].adminMenu then
        NotifyHandler(src, Lang("not_auth"), 'error')
        return false
    end
    return true
end

-- Helper: ensure RaceResults entry exists
local function ensureRaceResults(raceId, cleanedData)
    if not RaceResults[raceId] then
        RaceResults[raceId] = { Data = cleanedData or {}, Result = {} }
    elseif not RaceResults[raceId].Result then
        RaceResults[raceId].Result = {}
    end
end

local function scoreAfterPenalty(src, score, prevTime, newTime)
    if ConfigDrift and ConfigDrift.checkpointTimePenalty and ConfigDrift.checkpointTimePenalty.usePenalty then
        local penaltySeconds = ConfigDrift.checkpointTimePenalty.penaltySeconds or 5
        local penaltyAmount = ConfigDrift.checkpointTimePenalty.penaltyAmount or 100
        local penaltyPercentage = ConfigDrift.checkpointTimePenalty.penaltyPercentage or 0.0

        local timeDiff = newTime - prevTime
        if timeDiff > penaltySeconds * 1000 then
            local penalties = ConfigDrift.checkpointTimePenalty.stackPenalties and math.floor(timeDiff / (penaltySeconds * 1000)) or 1
            local totalPenalty = penalties * penaltyAmount
            local percentagePenalty = math.floor(score * penaltyPercentage * penalties)
            local finalPenalty = totalPenalty + percentagePenalty
            if Config.Debug then
                print('^1Applying drift score penalty:^0')
                print('Src', src)
                print('original score:', score)
                print(("Drift score penalty: timeDiff=%dms, penalties=%d, totalPenalty=%d, percentagePenalty=%d, finalPenalty=%d"):format(
                    timeDiff, penalties, totalPenalty, percentagePenalty, finalPenalty
                ))
                print('New score:', math.max(0, score - finalPenalty))
            end
            score = math.max(0, score - finalPenalty)
            TriggerClientEvent('cw-racingapp:client:forceSetDriftScore', src, score)
        end
    end

    return score
end

-- Update racer data for drift races (tracks drift scores into racer record)
RegisterNetEvent('cw-racingapp:server:updateRacerDataDrift', function(raceId, checkpoint, lap, finished, raceTime, driftScore)
    local src = source
    local citizenId = getCitizenId(src)
    if not raceId or not citizenId then
        return
    end

    if not Races[raceId] or not Races[raceId].Racers or not Races[raceId].Racers[citizenId] then
        print('^1Player with src', src, ' was updating positions in race they were not in^0')
        return
    end

    local racer = Races[raceId].Racers[citizenId]
    racer.Checkpoint = checkpoint
    racer.Lap = lap
    racer.Finished = finished or racer.Finished
    local lastTime = racer.RaceTime
    racer.RaceTime = raceTime

    local score = tonumber(driftScore) or racer.DriftScore or 0
    local checkedScore = scoreAfterPenalty(src, score, lastTime or 0, raceTime)
    racer.DriftScore = checkedScore

    -- Broadcast updated racer data to all racers in this race
    for _, r in pairs(Races[raceId].Racers) do
        if GetPlayerName(r.RacerSource) then
            TriggerClientEvent('cw-racingapp:client:updateRaceRacerData', r.RacerSource, raceId, citizenId, racer)
        end
    end

    -- keep server reset timer alive if used
    if Config.UseResetTimer and raceId then
        if Timers then Timers[raceId] = GetGameTimer() end
    end
end)

-- Internal: force-finish all remaining racers for a drift race (collect current drift scores)
local function forceFinishRemainingDrifters(raceData)
    local raceId = raceData.RaceId
    ensureRaceResults(raceId, raceData)
    if not Races[raceId] then
        if Config.Debug then print('^1= Could not find raceid', raceId,' =^0') end
    end

    if Config.Debug then print('^3= Force finishing drifters =^0') end
    for _, racer in pairs(Races[raceId].Racers) do
        if Config.Debug then print('Checking racer', json.encode(racer, {indent=true})) end
        if not racer.Finished and racer.RacerSource then
            if Config.Debug then print('Force finishing ', racer.RacerSource) end
            TriggerClientEvent('cw-racingapp:client:forceFinish', racer.RacerSource)
        end
    end
    if Config.Debug then print('^3= Done finishing drifters =^0') end
end

-- Internal: sort results by DriftScore desc
local function finalizeDriftRace(raceData)
    local raceId = raceData.RaceId
    ensureRaceResults(raceId, raceData)

    -- sort by DriftScore descending
    table.sort(RaceResults[raceId].Result, function(a,b)
        return (tonumber(a.DriftScore) or 0) > (tonumber(b.DriftScore) or 0)
    end)

    -- Assign placements each player of their finish
    for i, res in ipairs(RaceResults[raceId].Result) do
        local playerSrc = res.RacerSource
        -- placement = i
        if playerSrc then
            TriggerClientEvent('cw-racingapp:client:playerFinish', playerSrc, raceId, i, RaceResults[raceId].Result[1] and RaceResults[raceId].Result[1].RacerName)
            TriggerClientEvent('cw-racingapp:client:driftRaceFinished', playerSrc, raceId, RaceResults[raceId].Result)
        end
    end

    -- broadcast full sorted results (clients / other server code may handle payouts)

    if Config.Debug then
        print("[RacingApp][Drift] Finalized drift", json.encode(RaceResults[raceId].Result, {indent=true}))
    end

    if Races[raceId] then
        Races[raceId].Racers = {}
        Races[raceId].Started = false
        Races[raceId].Waiting = false
        Races[raceId].MaxClass = nil
    end
    -- free countdown marker
    DriftCountdowns[raceId] = nil
end

-- Ensure RaceResults entry exists then either modify existing racer entry (by RacerName)
-- or create & insert a new one. If existing, adds the drift score to the stored value.
local function upsertRaceResult(raceId, racerName, src, driftScore, carClass, vehicleModel, racingCrew)
    ensureRaceResults(raceId)

    local results = RaceResults[raceId].Result
    local addVal = tonumber(driftScore) or 0

    for _, res in ipairs(results) do
        if res.RacerName == racerName then
            if Config.Debug then print('Found racer, adding drift score') end
            res.DriftScore = (tonumber(res.DriftScore) or 0) + addVal
            return res
        end
    end
    if Config.Debug then print('Did not find racer, adding racer set') end

    -- not found -> create new entry
    local newRes = {
        DriftScore = addVal,
        CarClass = carClass,
        VehicleModel = vehicleModel,
        RacerName = racerName,
        Ranking = 0,
        RacerSource = src,
        RacingCrew = racingCrew
    }
    table.insert(results, newRes)
    return newRes
end

function FinishDriftRacer(src, raceData, driftScore, carClass, vehicleModel, racingCrew, totalTime)
    if Config.Debug then print('Finishing (Drift)', src, raceData.RacerName) end
    local raceId = raceData and raceData.RaceId
    if not raceId then return end

    ensureRaceResults(raceId, raceData)

    -- create and insert this player's result (do NOT pay out now)
    local racerName = raceData.RacerName

    local citizenId = getCitizenId(src)

    if not Races[raceId] or not Races[raceId].Racers or not Races[raceId].Racers[citizenId] then
        print('^1Player with src', src, ' was updating positions in race they were not in^0')
        return
    end

    local racer = Races[raceId].Racers[citizenId]

    local lastTime = racer.RaceTime
    local checkedScore = scoreAfterPenalty(src, tonumber(driftScore) or 0, lastTime or 0, totalTime or 0)
    upsertRaceResult(raceId, racerName, src, checkedScore, carClass, vehicleModel, racingCrew)

    -- mark player as finished in race state if present
    if citizenId and Races[raceId] and Races[raceId].Racers[citizenId] then
        Races[raceId].Racers[citizenId].Finished = true
        Races[raceId].Racers[citizenId].DriftScore = tonumber(driftScore) or Races[raceId].Racers[citizenId].DriftScore or 0
    end

    -- If countdown already running, just return (their result recorded)
    if DriftCountdowns[raceId] then
        if Config.Debug then print('Race was already in countdown. Skipping') end
        return
    end

    -- First finisher: start countdown for remaining racers
    DriftCountdowns[raceId] = true
    local countdown = DriftCountdownLength

    local amountOfRacers = 0
    for _ in pairs(Races[raceId].Racers) do
        amountOfRacers = amountOfRacers + 1
    end

    if amountOfRacers == 1 then
        DebugLog('Only one racer in race, skipping kick countdown')
        finalizeDriftRace(raceData)
        return
    end -- no need for countdown if only one racer

    -- notify racers countdown started
    if AvailableRaces then
        local availableKey = GetOpenedRaceKey(raceId)
        if availableKey and AvailableRaces[availableKey] and AvailableRaces[availableKey].RaceData then
            for _, r in pairs(AvailableRaces[availableKey].RaceData.Racers) do
                TriggerClientEvent('cw-racingapp:client:driftFinishCountdown', r.RacerSource, raceId, countdown)
            end
        end
    end

    SetTimeout(countdown*1000, function()
        -- force finish remaining racers using their current drift scores
        forceFinishRemainingDrifters(raceData)

        -- finalize: sort, and emit a server event so other modules can handle payouts
        Wait(2000)
        finalizeDriftRace(raceData)
    end)
end

-- Exported helper to force immediate finalize (useful for admin/testing)
RegisterNetEvent('cw-racingapp:server:forceFinalizeDriftRace', function(raceId)
    if not hasDriftAdminAccess(source) then return end
    if not raceId or not Races[raceId] then return end
    local raceData = {
        RaceId = raceId,
        RaceName = Races[raceId].RaceName,
    }
    forceFinishRemainingDrifters(raceData)
    finalizeDriftRace(raceData)
end)
