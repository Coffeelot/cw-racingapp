local function getAllRaceTracks()
    return MySQL.Sync.fetchAll('SELECT * FROM race_tracks', {})
end

local function setTrackRecords(records, raceid) 
    MySQL.Async.execute('UPDATE race_tracks SET records = ? WHERE raceid = ?', { json.encode(records), raceid })
end

local function setTrackCheckpoints(checkpoints, raceid) 
    MySQL.query('UPDATE race_tracks SET checkpoints = ? WHERE raceid = ?', { json.encode(checkpoints), raceid })
end

local function createTrack(raceData, checkpoints, citizenId, raceId)
    MySQL.Async.insert(
        'INSERT INTO race_tracks (name, checkpoints, creatorid, creatorname, distance, raceid, curated, access) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        { raceData.RaceName, json.encode(checkpoints), citizenId, raceData.RacerName, raceData.RaceDistance, raceId, 0, '{}' })
end

local function getSizeOfRacerNameTable()
    return MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM racer_names', {}) 
end

local function clearLeaderboardForTrack(raceId)
    MySQL.query('UPDATE race_tracks SET records = NULL WHERE raceid = ?',{ raceId })
end

local function deleteTrack(raceId)
    local result = MySQL.Sync.fetchAll('SELECT creatorname FROM race_tracks WHERE raceid = ?', { raceId })[1]
    if result then
        MySQL.query('DELETE FROM race_tracks WHERE raceid = ?', { raceId })
    end
end

local function getAllRacerNames()
    local query = 'SELECT * FROM racer_names'
    if Config.DontShowRankingsUnderZero then
        query = query .. ' WHERE ranking > 0'
    end
    if Config.LimitTopListTo then
        query = query .. ' ORDER BY ranking DESC LIMIT ' .. Config.LimitTopListTo
    end
    local result = MySQL.Sync.fetchAll(query)
    return result
end

local function setAccessForTrack(raceId, access)
    return MySQL.Sync.execute('UPDATE race_tracks SET access = ? WHERE raceid = ?', { json.encode(access), raceId })
end

local function getRaceUserByName(racerName)
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { racerName })[1]
end

local function createRaceUser(citizenId, racerName, auth, creatorCitizenId)
    MySQL.Async.insert('INSERT INTO racer_names (citizenid, racername, auth, createdby) VALUES (?, ?, ?, ?)', { citizenId, racerName, auth, creatorCitizenId })
end

local function getRaceUserRankingByName(racerName)
    local res = MySQL.Sync.fetchAll('SELECT ranking FROM racer_names WHERE racername = ?', { racername })
    if res and res[1] then
        return res[1].ranking
    end
end

local function increaseRaceCount(racerName, position)
    local query = 'UPDATE racer_names SET races = races + 1 WHERE racername = "' .. racerName .. '"'
    if position == 1 then
        query = 'UPDATE racer_names SET races = races + 1, wins = wins + 1 WHERE racername = "' .. racerName .. '"'
    end
    MySQL.Async.execute(query)
end

local function updateRacerElo(racerName, eloChange)
    local sql = "UPDATE racer_names SET ranking = ranking + " .. eloChange .. " WHERE racername = '" .. racerName .. "'"
    MySQL.Async.execute(sql)
end

local function updateEloForRaceResult(results)
    -- Prepare the SQL statement
    local sql = "UPDATE racer_names SET Ranking = CASE"

    -- Iterate over the racers table to build the SQL statement
    for _, racer in ipairs(results) do
        sql = sql .. " WHEN RacerName = '" .. racer.RacerName .. "' THEN Ranking + " .. racer.TotalChange
    end

    -- Add the default case and close the SQL statement
    sql = sql .. " END WHERE RacerName IN ("

    -- Append the RacerName values to the SQL statement
    for i, racer in ipairs(results) do
        if i > 1 then
            sql = sql .. ", "
        end
        sql = sql .. "'" .. racer.RacerName .. "'"
    end

    -- Close the SQL statement
    sql = sql .. ")"
    MySQL.Async.execute(sql)
end

local function getTracksByCitizenId(citizenId)
    return MySQL.Sync.fetchAll('SELECT name FROM race_tracks WHERE creatorid = ?', { citizenId })
end

local function getRaceUsersCreatedByCitizenId(citizenId)
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE citizenid = ?', { citizenId })
end

local function setCurationForTrack(curated, trackId)
    return MySQL.Sync.execute('UPDATE race_tracks SET curated = ? WHERE raceid = ?', { curated, trackId })
end

local function getAllRaceUsers()
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names')
end

local function removeRaceUserByName(racerName)
    return MySQL.query('DELETE FROM racer_names WHERE racername = ?', { racerName })
end

local function setRaceUserRevoked(racerName, revoked)
    return MySQL.Async.execute('UPDATE racer_names SET revoked = ? WHERE racername = ?', { tonumber(revoked), racerName })
end

local function wipeTracksTable()
    MySQL.query('DROP TABLE IF EXISTS race_tracks')
end

local function joinRacingCrew(citizenId, memberName, crewName)
    local query =
    "UPDATE racing_crews SET members = JSON_ARRAY_APPEND(members, '$', JSON_OBJECT('citizenID', ?, 'racername', ?, 'rank', 0)) WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { citizenId, memberName, crewName })
end

local function createRacingCrew(crewName, founderName, citizenId)
    local query =
    "INSERT INTO racing_crews (crew_name, founder_name, founder_citizenid, members, wins, races, rank) VALUES (?, ?, ?, '[]', 0, 0, 0)"
    return MySQL.Sync.execute(query, { crewName, founderName, citizenId })
end

local function leaveRacingCrew(citizenId, crewName)
    local query =
    "UPDATE racing_crews SET members = JSON_REMOVE(members, JSON_UNQUOTE(JSON_SEARCH(members, 'one', ?))) WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { citizenId, crewName })
end

local function increaseCrewWins(crewName)
    local query = "UPDATE racing_crews SET wins = wins + 1, races = races + 1 WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { crewName })
end

local function increaseCrewRaces(crewName)
    local query = "UPDATE racing_crews SET races = races + 1 WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { crewName })
end

local function changeCrewRank(crewName, amount)
    local query = "UPDATE racing_crews SET rank = rank + ? WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { amount, crewName })
end

local function disbandCrew(crewName)
    local query = "DELETE FROM racing_crews WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { crewName })
end

local function getAllCrews()
    local query = "SELECT * FROM racing_crews"
    return MySQL.Sync.fetchAll(query, {})
end

RADB = {
    changeCrewRank = changeCrewRank,
    clearLeaderboardForTrack = clearLeaderboardForTrack,
    createRaceUser = createRaceUser,
    createRacingCrew = createRacingCrew,
    createTrack = createTrack,
    deleteTrack = deleteTrack,
    disbandCrew = disbandCrew,
    getAllCrews = getAllCrews,
    getAllRacerNames = getAllRacerNames,
    getAllRaceTracks = getAllRaceTracks,
    getAllRaceUsers = getAllRaceUsers,
    getRaceUserByName = getRaceUserByName,
    getRaceUserRankingByName = getRaceUserRankingByName,
    getRaceUsersCreatedByCitizenId = getRaceUsersCreatedByCitizenId,
    getSizeOfRacerNameTable = getSizeOfRacerNameTable,
    getTracksByCitizenId = getTracksByCitizenId,
    increaseCrewRaces = increaseCrewRaces,
    increaseCrewWins = increaseCrewWins,
    increaseRaceCount = increaseRaceCount,
    joinRacingCrew = joinRacingCrew,
    leaveRacingCrew = leaveRacingCrew,
    removeRaceUserByName = removeRaceUserByName,
    setAccessForTrack = setAccessForTrack,
    setCurationForTrack = setCurationForTrack,
    setRaceUserRevoked = setRaceUserRevoked,
    setTrackCheckpoints = setTrackCheckpoints,
    setTrackRecords = setTrackRecords,
    updateEloForRaceResult = updateEloForRaceResult,
    updateRacerElo = updateRacerElo,
    wipeTracksTable = wipeTracksTable
}