-- Function to add a race entry
local function addRaceEntry(raceData)
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
        SELECT * FROM races 
        WHERE JSON_SEARCH(results, 'one', ?, NULL, '$') IS NOT NULL
        ORDER BY timestamp DESC
    ]]
    
    return MySQL.Sync.fetchAll(query, { StrictSanitize(racerName) })
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
    getRacerHistory = getRacerHistory

}