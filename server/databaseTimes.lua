local trackRaceStatsCache = {}
local topRacerWinnersCache = {}


local function getCacheKey(datespanDays)
    return tostring(datespanDays)
end

local function getTopRacerWinnersCacheKey(days)
    return tostring(days)
end

local function invalidateTopRacerWinnersCache()
    topRacerWinnersCache = {}
end


local function invalidateTrackRaceStatsCache()
    trackRaceStatsCache = {}
end

-- Fetch track race stats for all tracks within the given datespan (in days)
local function getTrackRaceStats(datespanDays)
    local cacheKey = getCacheKey(datespanDays)
    if trackRaceStatsCache[cacheKey] then
        if UseDebug then print('Returning cache', json.encode(trackRaceStatsCache[cacheKey], {indent=true})) end
        return trackRaceStatsCache[cacheKey]
    end

    -- Fetch all tracks
    local tracks = MySQL.Sync.fetchAll("SELECT raceid, name FROM race_tracks", {})

    local result = {}

    for _, track in ipairs(tracks) do
        -- Fetch all races for this track in the datespan
        local races = MySQL.Sync.fetchAll(
            "SELECT * FROM racing_races WHERE trackId = ? AND timestamp >= DATE_SUB(NOW(), INTERVAL ? DAY)",
            { track.raceid, datespanDays }
        )

        local stats = {
            trackId = track.raceid,
            trackName = track.name,
            totalRaces = #races,
            avgParticipants = 0,
            avgTime = 0,
            bestTime = nil,
            ghostingCount = 0,
            rankedCount = 0,
            firstPersonCount = 0,
            automatedCount = 0,
            silentCount = 0,
            mostUsedMaxClass = nil,
        }

        local totalParticipants = 0
        local totalTimes = 0
        local bestTime = nil
        local maxClassCount = {}

        for _, race in ipairs(races) do
            totalParticipants = totalParticipants + (race.amountOfRacers or 0)
            stats.ghostingCount = stats.ghostingCount + (race.ghosting and 1 or 0)
            stats.rankedCount = stats.rankedCount + (race.ranked  and 1 or 0)
            stats.firstPersonCount = stats.firstPersonCount + (race.firstPerson  and 1 or 0)
            stats.automatedCount = stats.automatedCount + (race.automated  and 1 or 0)
            stats.silentCount = stats.silentCount + (race.silent and 1 or 0)

            if race.maxClass and race.maxClass ~= "" then
                maxClassCount[race.maxClass] = (maxClassCount[race.maxClass] or 0) + 1
            end

            -- Parse results JSON for times
            if race.results and race.results ~= "" then
                local ok, parsed = pcall(json.decode, race.results)
                if ok and type(parsed) == "table" then
                    for _, res in ipairs(parsed) do
                        if res.TotalTime then
                            totalTimes = totalTimes + res.TotalTime
                            if not bestTime or res.TotalTime < bestTime then
                                bestTime = res.TotalTime
                            end
                        end
                    end
                end
            end
        end

        -- Fetch all track_times for this track in the datespan
        local times = MySQL.Sync.fetchAll(
            "SELECT time FROM track_times WHERE trackId = ? AND timestamp >= DATE_SUB(NOW(), INTERVAL ? DAY)",
            { track.raceid, datespanDays }
        )

        local totalTimeSum = 0
        local bestTimeFromTimes = nil
        local timeCount = 0

        for _, t in ipairs(times) do
            if t.time then
                local timeVal = tonumber(t.time)
                totalTimeSum = totalTimeSum + timeVal
                timeCount = timeCount + 1
                if not bestTimeFromTimes or timeVal < bestTimeFromTimes then
                    bestTimeFromTimes = timeVal
                end
            end
        end

        -- Use track_times for avgTime and bestTime if available
        if timeCount > 0 then
            stats.avgTime = math.floor(totalTimeSum / timeCount)
            stats.bestTime = bestTimeFromTimes
        end

        stats.avgParticipants = stats.totalRaces > 0 and math.floor(totalParticipants / stats.totalRaces) or 0
        stats.avgTime = stats.totalRaces > 0 and math.floor(totalTimes / stats.totalRaces) or 0
        stats.bestTime = bestTime or 0

        -- Find most used maxClass
        local maxCount, maxClass = 0, nil
        for class, count in pairs(maxClassCount) do
            if count > maxCount then
                maxCount = count
                maxClass = class
            end
        end
        stats.mostUsedMaxClass = maxClass or ""

        table.insert(result, stats)
    end

    trackRaceStatsCache[cacheKey] = result
    if UseDebug then print('Returning fresh result', json.encode(result, {indent=true})) end
    return result
end

-- Overwrite addRaceEntry to invalidate cache
local function addRaceEntry(raceData)
    invalidateTopRacerWinnersCache()
    invalidateTrackRaceStatsCache()
    local query = [[
        INSERT INTO racing_races (
            raceId, trackId, results, amountOfRacers, laps, hostName, maxClass,
            ghosting, ranked, reversed, firstPerson, automated, hidden, silent, buyIn, data
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]]
    local params = {
        StrictSanitize(raceData.raceId),
        StrictSanitize(raceData.trackId),
        json.encode(raceData.results or {}),
        raceData.amountOfRacers or 0,
        raceData.laps or 1,
        raceData.hostName and StrictSanitize(raceData.hostName) or nil,
        raceData.maxClass and StrictSanitize(raceData.maxClass) or nil,
        raceData.ghosting or false,
        raceData.ranked or false,
        raceData.reversed or false,
        raceData.firstPerson or false,
        raceData.automated or false,
        raceData.hidden or false,
        raceData.silent or false,
        raceData.buyIn or 0,
        json.encode(raceData.data or {})
    }
    return MySQL.Sync.execute(query, params)
end

-- Overwrite cleanupOldRaces to invalidate cache
local function cleanupOldRaces(daysOld)
    invalidateTrackRaceStatsCache()
    invalidateTopRacerWinnersCache()
    local query = "DELETE FROM racing_races WHERE timestamp < DATE_SUB(NOW(), INTERVAL ? DAY)"
    return MySQL.Sync.execute(query, { daysOld })
end

-- Function to add/update track time (returns "PB" if new personal best)
local function addTrackTime(timeData)
    -- First check if there's an existing record
    local existingQuery = [[
        SELECT time, pbHistory FROM track_times 
        WHERE trackId = ? AND racerName = ? AND carClass = ? AND raceType = ? AND reversed = ?
    ]]
    
    local existingParams = {
        StrictSanitize(timeData.trackId),
        StrictSanitize(timeData.racerName),
        StrictSanitize(timeData.carClass),
        StrictSanitize(timeData.raceType),
        timeData.reversed or false
    }
    
    local existingRecord = MySQL.Sync.fetchAll(existingQuery, existingParams)
    local newTime = tonumber(timeData.time)
    
    -- If no existing record or new time is better
    if not existingRecord or #existingRecord == 0 or newTime < tonumber(existingRecord[1].time) then
        local pbHistory = {}
        
        -- Get existing PB history if it exists
        if existingRecord and #existingRecord > 0 and existingRecord[1].pbHistory then
            pbHistory = json.decode(existingRecord[1].pbHistory) or {}
        end
        
        -- Add the new PB to history
        table.insert(pbHistory, newTime)
        
        -- Delete existing record if it exists
        if existingRecord and #existingRecord > 0 then
            local deleteQuery = [[
                DELETE FROM track_times 
                WHERE trackId = ? AND racerName = ? AND carClass = ? AND raceType = ? AND reversed = ?
            ]]
            MySQL.Sync.execute(deleteQuery, existingParams)
        end
        
        -- Insert new record with updated PB history
        local insertQuery = [[
            INSERT INTO track_times (trackId, racerName, carClass, vehicleModel, raceType, time, reversed, pbHistory)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ]]
        
        local insertParams = {
            StrictSanitize(timeData.trackId),
            StrictSanitize(timeData.racerName),
            StrictSanitize(timeData.carClass),
            StrictSanitize(timeData.vehicleModel),
            StrictSanitize(timeData.raceType),
            newTime,
            timeData.reversed or false,
            json.encode(pbHistory)
        }
        
        MySQL.Sync.execute(insertQuery, insertParams)
        return "PB"
    end
    
    return nil -- No personal best
end

-- Function to get race results by raceId
local function getRaceResults(raceId)
    local query = "SELECT * FROM racing_races WHERE raceId = ?"
    return MySQL.Sync.fetchAll(query, { StrictSanitize(raceId) })
end

-- Function to get all racing_races for a specific track
local function getRacesByTrackId(trackId)
    local query = "SELECT * FROM racing_races WHERE trackId = ? ORDER BY timestamp DESC"
    return MySQL.Sync.fetchAll(query, { StrictSanitize(trackId) })
end

-- Function to get best times for a track (top 10)
local function getBestTimesForTrack(trackId, raceType, carClass, reversed)
    local query = [[
        SELECT * FROM track_times 
        WHERE trackId = ? AND raceType = ? AND carClass = ? AND reversed = ?
        ORDER BY time DESC 
        LIMIT 10
    ]]
    
    local params = {
        StrictSanitize(trackId),
        StrictSanitize(raceType),
        StrictSanitize(carClass),
        reversed or 0
    }
    
    return MySQL.Sync.fetchAll(query, params)
end

-- Function to get all best times for a track (all classes/types)
local function getAllBestTimesForTrack(trackId)
    local query = [[
        SELECT * FROM track_times 
        WHERE trackId = ?
        ORDER BY time ASC
    ]]
    
    local params = {
        StrictSanitize(trackId),
    }
    
    return MySQL.Sync.fetchAll(query, params)
end

-- Function to get best personal time for a racer by trackId
local function getBestPersonalTime(racerName, trackId, carClass, raceType, reversed)
    local query = [[
        SELECT * FROM track_times 
        WHERE racerName = ? AND trackId = ? AND carClass = ? AND raceType = ? AND reversed = ?
        ORDER BY time ASC 
        LIMIT 1
    ]]
    
    local params = {
        StrictSanitize(racerName),
        StrictSanitize(trackId),
        StrictSanitize(carClass),
        StrictSanitize(raceType),
        reversed or false
    }
    
    return MySQL.Sync.fetchAll(query, params)
end

-- Function to get all personal times for a racer
local function getAllPersonalTimes(racerName)
    local query = [[
        SELECT * FROM track_times 
        WHERE racerName = ?
        ORDER BY trackId, carClass, raceType, time ASC
    ]]
    
    return MySQL.Sync.fetchAll(query, { StrictSanitize(racerName) })
end

-- Function to get recent racing_races (last 50)
local function getRecentRaces(limit)
    local query = "SELECT * FROM racing_races ORDER BY timestamp DESC LIMIT ?"
    return MySQL.Sync.fetchAll(query, { limit or 50 })
end

-- Function to get race statistics for a track
local function getTrackStats(trackId)
    local query = [[
        SELECT 
            COUNT(*) as totalRaces,
            AVG(amountOfRacers) as avgRacers,
            MAX(amountOfRacers) as maxRacers,
            MIN(amountOfRacers) as minRacers
        FROM racing_races 
        WHERE trackId = ?
    ]]
    
    return MySQL.Sync.fetchAll(query, { StrictSanitize(trackId) })
end

-- Function to delete old racing_races (older than specified days)
local function cleanupOldRaces(daysOld)
    local query = "DELETE FROM racing_races WHERE timestamp < DATE_SUB(NOW(), INTERVAL ? DAY)"
    return MySQL.Sync.execute(query, { daysOld })
end

-- Function to get leaderboard for a specific track/class combination
local function getTrackLeaderboard(trackId, carClass, raceType, reversed, limit)
    local query = [[
        SELECT 
            racerName,
            MIN(time) as bestTime,
            vehicleModel,
            timestamp
        FROM track_times 
        WHERE trackId = ? AND carClass = ? AND raceType = ? AND reversed = ?
        GROUP BY racerName
        ORDER BY bestTime ASC
        LIMIT ?
    ]]
    
    local params = {
        StrictSanitize(trackId),
        StrictSanitize(carClass),
        StrictSanitize(raceType),
        reversed or false,
        limit or 10
    }
    
    return MySQL.Sync.fetchAll(query, params)
end

-- Function to clear all track records for a specific track
local function clearTrackRecords(trackId)
    local query = "DELETE FROM track_times WHERE trackId = ?"
    return MySQL.Sync.execute(query, { StrictSanitize(trackId) })
end

-- Function to remove a specific track record by database ID
local function removeTrackRecord(recordId)
    local query = "DELETE FROM track_times WHERE id = ?"
    return MySQL.Sync.execute(query, { recordId })
end

-- Alternative function using MySQL JSON functions (MySQL 5.7+)
local function getRacerHistory(racerName)
    local query = [[
        SELECT * FROM racing_races 
        WHERE JSON_SEARCH(results, 'one', ?, NULL, '$') IS NOT NULL
        ORDER BY timestamp DESC
    ]]
    
    return MySQL.Sync.fetchAll(query, { StrictSanitize(racerName) })
end

local function getTopRacerWinnersAndWinLoss(racers, days)
    local amountOfRacers = racers or Config.Dashboard.defaultTopRacers
    local cacheKey = getTopRacerWinnersCacheKey(days)
    if UseDebug then
        print('Checking top racer winners cache for key:', cacheKey)
        print('Cache', json.encode(topRacerWinnersCache[cacheKey] or {}, { indent = true }))
    end
    if topRacerWinnersCache[cacheKey] then
        return { topRacerWins = topRacerWinnersCache[cacheKey].topRacerWins, topRacerWinLoss = topRacerWinnersCache[cacheKey].topRacerWinLoss }
    end

    local query, params
    if Config.Dashboard.topRacersOnlyIncludeRanked then
        query = [[
            SELECT results FROM racing_races
            WHERE timestamp >= DATE_SUB(NOW(), INTERVAL ? DAY) AND ranked = 1
        ]]
        params = { days }
    else
        query = [[
            SELECT results FROM racing_races
            WHERE timestamp >= DATE_SUB(NOW(), INTERVAL ? DAY)
        ]]
        params = { days }
    end

    local races = MySQL.Sync.fetchAll(query, params)

    local winCounts = {}
    local raceCounts = {}

    for _, race in ipairs(races) do
        if race.results and race.results ~= "" then
            local ok, results = pcall(json.decode, race.results)
            if ok and type(results) == "table" and #results > 0 then
                -- Find winner (lowest TotalTime)
                local winner, bestTime
                for _, res in ipairs(results) do
                    if res.RacerName then
                        raceCounts[res.RacerName] = (raceCounts[res.RacerName] or 0) + 1
                    end
                    if res.TotalTime and (not bestTime or res.TotalTime < bestTime) then
                        bestTime = res.TotalTime
                        winner = res.RacerName
                    end
                end
                if winner then
                    winCounts[winner] = (winCounts[winner] or 0) + 1
                end
            end
        end
    end

    -- Top x by wins
    local winList = {}
    for name, count in pairs(winCounts) do
        table.insert(winList, { racerName = name, wins = count })
    end
    table.sort(winList, function(a, b) return a.wins > b.wins end)
    local topRacerWins = {}
    for i = 1, math.min(amountOfRacers, #winList) do
        table.insert(topRacerWins, winList[i])
    end

    -- Top x by win/loss ratio
    local winLossList = {}
    for name, totalRaces in pairs(raceCounts) do
        local wins = winCounts[name] or 0
        local nonWins = totalRaces - wins
        local ratio = totalRaces > 0 and (wins / totalRaces) or (wins > 0 and math.huge or 0)
        if UseDebug then print("Racer:", name, "Wins:", wins, "Losses:", nonWins, "Ratio:", ratio , "totalRaces:", totalRaces) end
        table.insert(winLossList, { racerName = name, wins = wins, losses = nonWins, winLoss = ratio })
    end
    table.sort(winLossList, function(a, b) return a.winLoss > b.winLoss end)
    local topRacerWinLoss = {}
    for i = 1, math.min(amountOfRacers, #winLossList) do
        table.insert(topRacerWinLoss, winLossList[i])
    end

    topRacerWinnersCache[cacheKey] = { topRacerWins = topRacerWins, topRacerWinLoss = topRacerWinLoss }
    return { topRacerWins = topRacerWins, topRacerWinLoss = topRacerWinLoss }
end

-- Export functions (if using a module system)
RESDB = {
    addRaceEntry = addRaceEntry,
    addTrackTime = addTrackTime,
    getRaceResults = getRaceResults,
    getRacesByTrackId = getRacesByTrackId,
    getBestTimesForTrack = getBestTimesForTrack,
    getAllBestTimesForTrack = getAllBestTimesForTrack,
    getBestPersonalTime = getBestPersonalTime,
    getAllPersonalTimes = getAllPersonalTimes,
    getRecentRaces = getRecentRaces,
    getTrackStats = getTrackStats,
    cleanupOldRaces = cleanupOldRaces,
    getTrackLeaderboard = getTrackLeaderboard,
    clearTrackRecords = clearTrackRecords,
    removeTrackRecord = removeTrackRecord,
    getRacerHistory = getRacerHistory,
    getTrackRaceStats = getTrackRaceStats,
    getTopRacerWinnersAndWinLoss = getTopRacerWinnersAndWinLoss,
}