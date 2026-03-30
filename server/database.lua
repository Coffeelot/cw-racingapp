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

local function dbLog(msg)
    if Config.Debug and Config.DatabaseDebug then
        print('[RADB] ' .. tostring(msg))
    end
end

local function getAllRaceTracks()
    dbLog('getAllRaceTracks')
    return MySQL.Sync.fetchAll('SELECT * FROM race_tracks', {})
end

local function setTrackCheckpoints(checkpoints, raceid)
    dbLog('setTrackCheckpoints | raceid: ' .. tostring(raceid))
    MySQL.query('UPDATE race_tracks SET checkpoints = ? WHERE raceid = ?', { json.encode(checkpoints), raceid })
end

local function createTrack(raceData, checkpoints, citizenId, raceId)
    dbLog('createTrack | raceId: ' .. tostring(raceId) .. ', citizenId: ' .. tostring(citizenId))
    MySQL.Async.insert(
        'INSERT INTO race_tracks (name, checkpoints, creatorid, creatorname, distance, raceid, curated, access, racerid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        { StrictSanitize(raceData.RaceName), json.encode(checkpoints), citizenId, StrictSanitize(raceData.RacerName),
            raceData.RaceDistance, raceId, 0, '{}', StrictSanitize(raceData.RacerId) }
    )
end

local function getSizeOfRacerNameTable()
    dbLog('getSizeOfRacerNameTable')
    return MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM racer_names', {})
end

local function clearLeaderboardForTrack(raceId)
    dbLog('clearLeaderboardForTrack | raceId: ' .. tostring(raceId))
    MySQL.query('UPDATE race_tracks SET records = NULL WHERE raceid = ?', { raceId })
end

local function deleteTrack(raceId)
    dbLog('deleteTrack | raceId: ' .. tostring(raceId))
    local result = MySQL.Sync.fetchAll('SELECT creatorname FROM race_tracks WHERE raceid = ?', { raceId })[1]
    if result then
        MySQL.query('DELETE FROM race_tracks WHERE raceid = ?', { raceId })
    end
end

local function updateTrackMetadata(raceId, metadata)
    dbLog('updateTrackMetadata | raceId: ' .. tostring(raceId))
    return MySQL.Sync.execute('UPDATE race_tracks SET metadata = ? WHERE raceid = ?', { json.encode(metadata), raceId })
end

local function getAllRacerNames()
    dbLog('getAllRacerNames')
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
    dbLog('setAccessForTrack | raceId: ' .. tostring(raceId))
    return MySQL.Sync.execute('UPDATE race_tracks SET access = ? WHERE raceid = ?', { json.encode(access), raceId })
end

local function changeRaceUser(citizenId, racerName)
    dbLog('changeRaceUser | citizenId: ' .. tostring(citizenId) .. ', racerName: ' .. tostring(racerName))
    if MySQL.Sync.execute('UPDATE racer_names SET active = 0 WHERE citizenid = ?', { citizenId }) then
        return MySQL.Sync.execute('UPDATE racer_names SET active = 1 WHERE citizenid = ? AND racername = ?',
            { citizenId, racerName })
    end
    return nil
end

local function getActiveRacerName(citizenId)
    dbLog('getActiveRacerName | citizenId: ' .. tostring(citizenId))
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE citizenid = ?', { StrictSanitize(citizenId) })[1]
end

local function getActiveRacerCrew(racerName)
    dbLog('getActiveRacerCrew | racerName: ' .. tostring(racerName))
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { StrictSanitize(racerName) })[1].crew
end

local function setActiveRacerCrew(racerName, crewName)
    dbLog('setActiveRacerCrew | racerName: ' .. tostring(racerName) .. ', crewName: ' .. tostring(crewName))
    return MySQL.Sync.execute('UPDATE racer_names SET crew = ? WHERE racername = ?', { crewName, racerName })
end

local function getUserAuth(racerName)
    dbLog('getUserAuth | racerName: ' .. tostring(racerName))
    local result = MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { StrictSanitize(racerName) })
    [1]
    if result then
        return result.auth
    end
end

local function updateRacer(racerName, field, value)
    dbLog('updateRacer | racerName: ' .. tostring(racerName) .. ', field: ' .. tostring(field))
    local query = 'UPDATE racer_names SET ' .. field .. ' = ? WHERE racername = ?'
    return MySQL.Sync.execute(query, { value, StrictSanitize(racerName) })
end

local function setActiveRacerUserByRacerId(racerId, active)
    dbLog('setActiveRacerUserByRacerId | racerId: ' .. tostring(racerId) .. ', active: ' .. tostring(active))
    return MySQL.Sync.execute('UPDATE racer_names SET active = ? WHERE racerid = ?', { tonumber(active), racerId })     
end

local function getRaceUserByName(racerName)
    dbLog('getRaceUserByName | racerName: ' .. tostring(racerName))
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racername = ?', { StrictSanitize(racerName) })[1]
end

local function getRaceUserByRacerId(racerId)
    dbLog('getRaceUserByRacerId | racerId: ' .. tostring(racerId))
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE racerid = ?', { StrictSanitize(racerId) })[1]
end

local function createRaceUser(citizenId, racerName, auth, creatorCitizenId, racerId)
    dbLog('createRaceUser | citizenId: ' .. tostring(citizenId) .. ', racerName: ' .. tostring(racerName) .. ', racerId: ' .. tostring(racerId))
    MySQL.Async.insert('INSERT INTO racer_names (citizenid, racername, auth, createdby, racerid) VALUES (?, ?, ?, ?, ?)',
        { citizenId, StrictSanitize(racerName), auth, creatorCitizenId, racerId })
end

local function getRaceUserRankingByName(racerName)
    dbLog('getRaceUserRankingByName | racerName: ' .. tostring(racerName))
    local res = MySQL.Sync.fetchAll('SELECT ranking FROM racer_names WHERE racername = ?', { StrictSanitize(racerName) })
    if res and res[1] then
        return res[1].ranking
    end
end

local function increaseRaceCount(racerName, position)
    dbLog('increaseRaceCount | racerName: ' .. tostring(racerName) .. ', position: ' .. tostring(position))
    local query = 'UPDATE racer_names SET races = races + 1'
    if position == 1 then
        query = query .. ', wins = wins + 1'
    end
    query = query .. ' WHERE racername = ?'
    MySQL.Async.execute(query, { StrictSanitize(racerName) })
end

local function updateRacerElo(racerName, eloChange)
    dbLog('updateRacerElo | racerName: ' .. tostring(racerName) .. ', eloChange: ' .. tostring(eloChange))
    MySQL.Async.execute('UPDATE racer_names SET ranking = ranking + ? WHERE racername = ?',
        { eloChange, StrictSanitize(racerName) })
end

local function mapTable(tbl, func)
    local t = {}
    for i, v in ipairs(tbl) do
        t[i] = func(v, i)
    end
    return t
end

local function updateEloForRaceResult(results)
    dbLog('updateEloForRaceResult | count: ' .. tostring(#results))
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
    dbLog('getTracksByCitizenId | citizenId: ' .. tostring(citizenId))
    return MySQL.Sync.fetchAll('SELECT name FROM race_tracks WHERE creatorid = ?', { citizenId })
end

local function getRaceUsersCreatedByCitizenId(citizenId)
    dbLog('getRaceUsersCreatedByCitizenId | citizenId: ' .. tostring(citizenId))
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE createdby = ?', { citizenId })
end

local function getRaceUsersBelongingToCitizenId(citizenId)
    dbLog('getRaceUsersBelongingToCitizenId | citizenId: ' .. tostring(citizenId))
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE citizenid = ?', { citizenId })
end

local function setCurationForTrack(curated, trackId)
    dbLog('setCurationForTrack | trackId: ' .. tostring(trackId) .. ', curated: ' .. tostring(curated))
    return MySQL.Sync.execute('UPDATE race_tracks SET curated = ? WHERE raceid = ?', { curated, trackId })
end

local function getAllRaceUsers()
    dbLog('getAllRaceUsers')
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names')
end

local function removeRaceUserByName(racerName)
    dbLog('removeRaceUserByName | racerName: ' .. tostring(racerName))
    return MySQL.query('DELETE FROM racer_names WHERE racername = ?', { StrictSanitize(racerName) })
end

local function setRaceUserRevoked(racerName, revoked)
    dbLog('setRaceUserRevoked | racerName: ' .. tostring(racerName) .. ', revoked: ' .. tostring(revoked))
    return MySQL.Async.execute('UPDATE racer_names SET revoked = ? WHERE racername = ?',
        { tonumber(revoked), StrictSanitize(racerName) })
end

local function setRaceUserAuth(racerName, auth)
    dbLog('setRaceUserAuth | racerName: ' .. tostring(racerName) .. ', auth: ' .. tostring(auth))
    return MySQL.Sync.execute('UPDATE racer_names SET auth = ? WHERE racername = ?',
        { auth, StrictSanitize(racerName) })
end

local function wipeTracksTable()
    dbLog('wipeTracksTable')
    MySQL.query('DROP TABLE IF EXISTS race_tracks')
end

local function joinRacingCrew(citizenId, memberName, crewName)
    dbLog('joinRacingCrew | citizenId: ' .. tostring(citizenId) .. ', memberName: ' .. tostring(memberName) .. ', crewName: ' .. tostring(crewName))
    local query =
    "UPDATE racing_crews SET members = JSON_ARRAY_APPEND(members, '$', JSON_OBJECT('citizenID', ?, 'racername', ?, 'rank', 0)) WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { citizenId, StrictSanitize(memberName), StrictSanitize(crewName) })
end

local function createRacingCrew(crewName, founderName, citizenId)
    dbLog('createRacingCrew | crewName: ' .. tostring(crewName) .. ', founderName: ' .. tostring(founderName))
    local query =
    "INSERT INTO racing_crews (crew_name, founder_name, founder_citizenid, members, wins, races, rank) VALUES (?, ?, ?, '[]', 0, 0, 0)"
    return MySQL.Sync.execute(query, { StrictSanitize(crewName), StrictSanitize(founderName), citizenId })
end

local function leaveRacingCrew(citizenId, crewName)
    dbLog('leaveRacingCrew | citizenId: ' .. tostring(citizenId) .. ', crewName: ' .. tostring(crewName))
    local members = MySQL.Sync.fetchScalar(
        "SELECT members FROM racing_crews WHERE crew_name = ?", 
        { StrictSanitize(crewName) }
    )

    if not members then return false end

    local parsed = json.decode(members)
    for i = #parsed, 1, -1 do
        if parsed[i].citizenID == citizenId then
            table.remove(parsed, i)
        end
    end

    local updated = json.encode(parsed)
    MySQL.Sync.execute(
        "UPDATE racing_crews SET members = ? WHERE crew_name = ?", 
        { updated, StrictSanitize(crewName) }
    )

    return true
end

local function increaseCrewWins(crewName)
    dbLog('increaseCrewWins | crewName: ' .. tostring(crewName))
    local query = "UPDATE racing_crews SET wins = wins + 1, races = races + 1 WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { StrictSanitize(crewName) })
end

local function increaseCrewRaces(crewName)
    dbLog('increaseCrewRaces | crewName: ' .. tostring(crewName))
    local query = "UPDATE racing_crews SET races = races + 1 WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { StrictSanitize(crewName) })
end

local function changeCrewRank(crewName, amount)
    dbLog('changeCrewRank | crewName: ' .. tostring(crewName) .. ', amount: ' .. tostring(amount))
    local query = "UPDATE racing_crews SET rank = rank + ? WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { amount, StrictSanitize(crewName) })
end

local function disbandCrew(crewName)
    dbLog('disbandCrew | crewName: ' .. tostring(crewName))
    local query = "DELETE FROM racing_crews WHERE crew_name = ?"
    return MySQL.Sync.execute(query, { StrictSanitize(crewName) })
end

local function getAllCrews()
    dbLog('getAllCrews')
    local query = "SELECT * FROM racing_crews"
    return MySQL.Sync.fetchAll(query, {})
end

-- Fetch crypto balance for a specific racer
local function getCryptoForRacer(racerName)
    dbLog('getCryptoForRacer | racerName: ' .. tostring(racerName))
    local result = MySQL.Sync.fetchScalar('SELECT crypto FROM racer_names WHERE racername = ?', { StrictSanitize(racerName) })
    return result or 0
end

-- Add crypto to a racer's balance
local function addCryptoToRacer(racerName, amount)
    dbLog('addCryptoToRacer | racerName: ' .. tostring(racerName) .. ', amount: ' .. tostring(amount))
    return MySQL.Sync.execute('UPDATE racer_names SET crypto = crypto + ? WHERE racername = ?', 
        { amount, StrictSanitize(racerName) })
end

-- Remove crypto from a racer's balance
local function removeCryptoFromRacer(racerName, amount)
    dbLog('removeCryptoFromRacer | racerName: ' .. tostring(racerName) .. ', amount: ' .. tostring(amount))
    return MySQL.Sync.execute('UPDATE racer_names SET crypto = crypto - ? WHERE racername = ?', 
        { amount, StrictSanitize(racerName) })
end

-- Get racing users belonging to a specific citizenid
local function getRacingUsersByCitizenId(citizenId)
    dbLog('getRacingUsersByCitizenId | citizenId: ' .. tostring(citizenId))
    return MySQL.Sync.fetchAll('SELECT * FROM racer_names WHERE citizenid = ?', { citizenId })
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
    updateRacer = updateRacer,
    getRaceUserByName = getRaceUserByName,
    getRaceUserByRacerId = getRaceUserByRacerId,
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
    setRaceUserAuth = setRaceUserAuth,
    setTrackCheckpoints = setTrackCheckpoints,
    updateEloForRaceResult = updateEloForRaceResult,
    updateRacerElo = updateRacerElo,
    wipeTracksTable = wipeTracksTable,
    updateTrackMetadata = updateTrackMetadata,
    getCryptoForRacer = getCryptoForRacer,
    addCryptoToRacer = addCryptoToRacer,
    removeCryptoFromRacer = removeCryptoFromRacer,
    getRacingUsersByCitizenId = getRacingUsersByCitizenId,
    setActiveRacerUserByRacerId = setActiveRacerUserByRacerId,
}
