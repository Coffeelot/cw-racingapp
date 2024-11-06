function strictSanitize(input)
    if type(input) ~= "string" then
        return input
    end

    -- Remove leading/trailing spaces and collapse multiple spaces into single spaces
    input = input:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")

    -- Keep only allowed characters
    input = input:gsub("[^%w%s%-_]", "")

    return input
end

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
        { strictSanitize(raceData.RaceName), json.encode(checkpoints), citizenId, strictSanitize(raceData.RacerName),
            raceData.RaceDistance, raceId, 0, '{}' }
    )
end

local function getSizeOfRacerNameTable()
    return MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM racer_names', {})
end

local function clearLeaderboardForTrack(raceId)
    MySQL.query('UPDATE race_tracks SET records = NULL WHERE raceid = ?', { raceId })
end

local function deleteTrack(raceId)
    local result = MySQL.Sync.fetchAll('SELECT creatorname FROM race_tracks WHERE raceid = ?', { raceId })[1]
    if result then
        MySQL.query('DELETE FROM race_tracks WHERE raceid = ?', { raceId })
    end
end

local function updateTrackMetadata(raceId, metadata)
    return MySQL.Sync.execute('UPDATE race_tracks SET metadata = ? WHERE raceid = ?', { json.encode(metadata), raceId })
end

local function getAllRacerNames()
    local query = 'SELECT * FROM racer_names'
    if Config.DontShowRankingsUnderZero then
        query = query .. ' WHERE ranking > 0'
    end
    if Config.LimitTopListTo then
        query = query .. ' ORDER BY ranking DESC LIMIT ?'
        return MySQL.Sync.fetchAll(query, { Config.LimitTopListTo })
    end
    return MySQL.Sync.fetchAll(query)
end

local function setAccessForTrack(raceId, access)
    return MySQL.Sync.execute('UPDATE race_tracks SET access = ? WHERE raceid = ?', { json.encode(access), raceId })
end

local function changeRaceUser(citizenId, racerName)
    if MySQL.Sync.execute('UPDATE racer_names SET active = 0 WHERE citizenid = ?', { citizenId }) then
        return MySQL.Sync.execute('UPDATE racer_names SET active = 1 WHERE citizenid = ? AND racername = ?',
            { citizenId, racerName })
    end
    return nil
end

local function getActiveRacerName(citizenId)
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE citizenid = ?', { strictSanitize(citizenId) })[1]
end

local function getActiveRacerCrew(racerName)
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { strictSanitize(racerName) })[1].crew
end

local function setActiveRacerCrew(racerName, crewName)
    return MySQL.Sync.execute('UPDATE racer_names SET crew = ? WHERE racername = ?', { crewName, racerName })
end

local function getUserAuth(racerName)
    local result = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { strictSanitize(racerName) })
    [1]
    if result then
        return result.auth
    end
end

local function getRaceUserByName(racerName)
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { strictSanitize(racerName) })[1]
end

local function createRaceUser(citizenId, racerName, auth, creatorCitizenId)
    MySQL.Async.insert('INSERT INTO racer_names (citizenid, racername, auth, createdby) VALUES (?, ?, ?, ?)',
        { citizenId, strictSanitize(racerName), auth, creatorCitizenId })
end

local function getRaceUserRankingByName(racerName)
    local res = MySQL.Sync.fetchAll('SELECT ranking FROM racer_names WHERE racername = ?', { strictSanitize(racerName) })
    if res and res[1] then
        return res[1].ranking
    end
end

local function increaseRaceCount(racerName, position)
    local query = 'UPDATE racer_names SET races = races + 1'
    if position == 1 then
        query = query .. ', wins = wins + 1'
    end
    query = query .. ' WHERE racername = ?'
    MySQL.Async.execute(query, { strictSanitize(racerName) })
end

local function updateRacerElo(racerName, eloChange)
    MySQL.Async.execute('UPDATE racer_names SET ranking = ranking + ? WHERE racername = ?',
        { eloChange, strictSanitize(racerName) })
end

local function mapTable(tbl, func)
    local t = {}
    for i, v in ipairs(tbl) do
        t[i] = func(v, i)
    end
    return t
end

local function updateEloForRaceResult(results)
    local params = {}
    local sql = "UPDATE racer_names SET Ranking = Ranking + (CASE RacerName "
    for _, racer in ipairs(results) do
        sql = sql .. "WHEN ? THEN ? "
        table.insert(params, racer.RacerName)
        table.insert(params, racer.TotalChange)
    end
    sql = sql .. "END) WHERE RacerName IN (" ..
        table.concat(mapTable(results, function() return "?" end), ", ") .. ")"

    -- Add all RacerName values to the params again for the WHERE clause
    for _, racer in ipairs(results) do
        table.insert(params, racer.RacerName)
    end
    MySQL.Async.execute(sql, params)
end

local function getTracksByCitizenId(citizenId)
    return MySQL.Sync.fetchAll('SELECT name FROM race_tracks WHERE creatorid = ?', { citizenId })
end

local function getRaceUsersCreatedByCitizenId(citizenId)
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE createdby = ?', { citizenId })
end

local function getRaceUsersBelongingToCitizenId(citizenId)
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE citizenid = ?', { citizenId })
end

local function setCurationForTrack(curated, trackId)
    return MySQL.Sync.execute('UPDATE race_tracks SET curated = ? WHERE raceid = ?', { curated, trackId })
end

local function getAllRaceUsers()
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names')
end

local function removeRaceUserByName(racerName)
    return MySQL.query('DELETE FROM racer_names WHERE racername = ?', { strictSanitize(racerName) })
end

local function setRaceUserRevoked(racerName, revoked)
    return MySQL.Async.execute('UPDATE racer_names SET revoked = ? WHERE racername = ?',
        { tonumber(revoked), strictSanitize(racerName) })
end

local function wipeTracksTable()
    MySQL.query('DROP TABLE IF EXISTS race_tracks')
end

local function joinRacingCrew(citizenId, memberName, crewName)
    local query =
    "UPDATE racing_crews SET members = JSON_ARRAY_APPEND(members, '$', JSON_OBJECT('citizenID', ?, 'racername', ?, 'rank', 0)) WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { citizenId, strictSanitize(memberName), strictSanitize(crewName) })
end

local function createRacingCrew(crewName, founderName, citizenId)
    local query =
    "INSERT INTO racing_crews (crew_name, founder_name, founder_citizenid, members, wins, races, rank) VALUES (?, ?, ?, '[]', 0, 0, 0)"
    return MySQL.Sync.execute(query, { strictSanitize(crewName), strictSanitize(founderName), citizenId })
end

local function leaveRacingCrew(citizenId, crewName)
    local query =
    "UPDATE racing_crews SET members = JSON_REMOVE(members, JSON_UNQUOTE(JSON_SEARCH(members, 'one', ?))) WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { citizenId, strictSanitize(crewName) })
end

local function increaseCrewWins(crewName)
    local query = "UPDATE racing_crews SET wins = wins + 1, races = races + 1 WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { strictSanitize(crewName) })
end

local function increaseCrewRaces(crewName)
    local query = "UPDATE racing_crews SET races = races + 1 WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { strictSanitize(crewName) })
end

local function changeCrewRank(crewName, amount)
    local query = "UPDATE racing_crews SET rank = rank + ? WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { amount, strictSanitize(crewName) })
end

local function disbandCrew(crewName)
    local query = "DELETE FROM racing_crews WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { strictSanitize(crewName) })
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
    changeRaceUser = changeRaceUser,
    getRaceUserByName = getRaceUserByName,
    getUserAuth = getUserAuth,
    getActiveRacerName = getActiveRacerName,
    getActiveRacerCrew = getActiveRacerCrew,
    setActiveRacerCrew = setActiveRacerCrew,
    getRaceUserRankingByName = getRaceUserRankingByName,
    getRaceUsersBelongingToCitizenId = getRaceUsersBelongingToCitizenId,
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
    wipeTracksTable = wipeTracksTable,
    updateTrackMetadata = updateTrackMetadata,
}
