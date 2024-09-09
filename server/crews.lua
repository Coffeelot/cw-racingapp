local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

local racingCrews = {} -- This table will hold the racing crews locally
local activeInvites = {}  -- Variable to hold active invites

-- Helper functions

local function getRacingCrewByName(crewName)
    if crewName then
        for _, crew in ipairs(racingCrews) do
            if crew.crewName:lower() == crewName:lower() then
                return crew
            end
        end
    end
    return nil
end

local function getRacingCrewThatCitizenIDIsIn(citizenId)
    for _, crew in ipairs(racingCrews) do
        if crew.founderCitizenid == citizenId then
            return crew
        end
        for _, member in ipairs(crew.members) do
            if member.citizenID == citizenId then
                return crew
            end
        end
    end

    return nil  -- Player is not in any racing crew with the specified racer name
end

local function getRacingCrewThatRacerNameIsIn(racername)
    for _, crew in ipairs(racingCrews) do
        if crew.founderName == racername then
            return crew
        end
        for _, member in ipairs(crew.members) do
            if member.racername == racername then
                return crew
            end
        end
    end

    return nil  -- Player is not in any racing crew with the specified racer name
end

local function changeRacerCrew(src, selectedCrew)
    if useDebug then print('Changing racer crew for', src, selectedCrew) end
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("selectedCrew", selectedCrew)
end

-- SQL calling functions

local function joinRacingCrew(memberName, citizenId, crewName)
    local query = "UPDATE racing_crews SET members = JSON_ARRAY_APPEND(members, '$', JSON_OBJECT('citizenID', ?, 'racername', ?, 'rank', 0)) WHERE crew_name = ?"
    local result = MySQL.Sync.execute(query, {citizenId, memberName, crewName})

    if result then
        local crew = getRacingCrewByName(crewName)
        if crew then
            local newMember = {
                citizenID = citizenId,
                racername = memberName,
                rank = 0
            }
            table.insert(crew.members, newMember)
        end
        return crewName
    end

    return false
end

local function createRacingCrew(founderName, citizenId, crewName)
    local query = "INSERT INTO racing_crews (crew_name, founder_name, founder_citizenid, members, wins, races, rank) VALUES (?, ?, ?, '[]', 0, 0, 0)"
    local result = MySQL.Sync.execute(query, {crewName, founderName, citizenId})

    if result then
        local newCrew = {
            id = result,
            crewName = crewName,
            founderName = founderName,
            founderCitizenid = citizenId,
            members = {},
            wins = 0,
            races = 0,
            rank = 0
        }

        table.insert(racingCrews, newCrew)
        joinRacingCrew(founderName, citizenId, crewName)
        return true
    end
    return false
end

local function leaveRacingCrew(memberName, citizenId, crewName)
    local query = "UPDATE racing_crews SET members = JSON_REMOVE(members, JSON_UNQUOTE(JSON_SEARCH(members, 'one', ?))) WHERE crew_name = ?"
    local result = MySQL.Sync.execute(query, {citizenId, crewName})

    if result then
        local crew = getRacingCrewByName(crewName)
        if crew then
            for i, member in ipairs(crew.members) do
                if member.citizenID == citizenId then
                    table.remove(crew.members, i)
                    return true
                end
            end
        end
    end

    return false
end

local function addWinToCrew(crewName)
    local query = "UPDATE racing_crews SET wins = wins + 1, races = races + 1 WHERE crew_name = ?"
    local result = MySQL.Sync.execute(query, {crewName})

    if result then
        local crew = getRacingCrewByName(crewName)
        if crew then
            crew.wins = crew.wins + 1
        end
    end

    return result
end

local function addRaceToCrew(crewName)
    local query = "UPDATE racing_crews SET races = races + 1 WHERE crew_name = ?"
    local result = MySQL.Sync.execute(query, {crewName})

    if result then
        local crew = getRacingCrewByName(crewName)
        if crew then
            crew.races = crew.races + 1
        end
    end

    return result
end

local function updateRanking(crewName, amount)
    if not amount then print('^1Input for ranking update was incorrect') return end
    local query = "UPDATE racing_crews SET rank = rank + ? WHERE crew_name = ?"
    local result = MySQL.Sync.execute(query, {amount, crewName})

    if result then
        local crew = getRacingCrewByName(crewName)
        if crew then
            crew.rank = crew.rank + amount
        end
    end

    return result
end

local function decreaseRank(crewName)
    local query = "UPDATE racing_crews SET rank = rank - 1 WHERE crew_name = ?"
    local result = MySQL.Sync.execute(query, {crewName})

    if result then
        local crew = getRacingCrewByName(crewName)
        if crew then
            crew.rank = crew.rank - 1
        end
    end

    return result
end

local function disbandRacingCrew(crewName)
    local query = "DELETE FROM racing_crews WHERE crew_name = ?"
    local result = MySQL.Sync.execute(query, {crewName})

    if result then
        for i, crew in ipairs(racingCrews) do
            if crew.crewName == crewName then
                for _, member in pairs(crew.members) do
                    local player = QBCore.Functions.GetPlayerByCitizenId(member.citizenID)
                    if player ~= nil then
                        TriggerClientEvent('cw-racingapp:client:notify', player.PlayerData.source, Lang("disbanded_crew") , 'error')
                    end
                end
                table.remove(racingCrews, i)
                return true
            end
        end
    end

    return false
end

-- invitations
local function inviteToCrew(invitedBySource, invitedCitizenId, crewName)
    local player = QBCore.Functions.GetPlayerByCitizenId(invitedCitizenId)
    if player ~= nil then
        if getRacingCrewThatCitizenIDIsIn(invitedCitizenId) then TriggerClientEvent('cw-racingapp:client:notify', invitedBySource, Lang("racer_already_in_crew") , 'error') return false end
        if useDebug then print(invitedBySource, 'is inviting player to crew', player.PlayerData.source) end
        activeInvites[invitedCitizenId] = { crewName = crewName, invitedBySource = invitedBySource }
        TriggerClientEvent('cw-racingapp:client:notify', player.PlayerData.source, Lang("pending_crew_invite")..' '..crewName)
        return true
    else
        return false
    end
end

local function acceptInvite(racerName, invitedCitizenId)
    local crewName = activeInvites[invitedCitizenId].crewName
    if crewName then
        joinRacingCrew(racerName, invitedCitizenId, crewName)
        if activeInvites[invitedCitizenId].invitedBySource then
            if useDebug then print('notifying inviter ', activeInvites[invitedCitizenId].invitedBySource) end            
            TriggerClientEvent('cw-racingapp:client:notify', activeInvites[invitedCitizenId].invitedBySource, Lang("crew_invite_accepted"), 'success')
        end
        activeInvites[invitedCitizenId] = nil  -- Remove the invite after accepting
        return true
    else
        return false
    end
end

local function denyInvite(invitedCitizenId)
    if activeInvites[invitedCitizenId].invitedBySource then
        if useDebug then print('notifying inviter ', activeInvites[invitedCitizenId].invitedBySource) end            
        TriggerClientEvent('cw-racingapp:client:notify', activeInvites[invitedCitizenId].invitedBySource, Lang("crew_invite_rejected"), 'error')
    end
    activeInvites[invitedCitizenId] = nil  -- Remove the invite
    return true
end

function handleCrewEloUpdates(crewRes)
    for i, crew in pairs(crewRes) do
        if useDebug then print('Updating ELO for crew', crew.crewName, 'with', crew.totalChange) end
        updateRanking(crew.crewName, crew.totalChange)
        Wait(100)
        if i == 1 then
            addWinToCrew(crew.crewName)
        else
            addRaceToCrew(crew.crewName)
        end
        Wait(500)
    end
end

function getCrewRanking(crewName)
    local currentCrew = getRacingCrewByName(crewName)
    if currentCrew then 
        if useDebug then print('crew existed with ranking', currentCrew.rank) end
        return currentCrew.rank
    else
        if useDebug then print('crew didnt exist defaulting to 0') end
        return 0
    end    
end
-- Event specific helpers

local function canFounderCreateCrew(founderCitizenId)
    for _, crew in ipairs(racingCrews) do
        for _, member in ipairs(crew.members) do
            if member.citizenID == founderCitizenId then
                return false  -- Founder is already in a crew
            end
        end
    end

    return true
end

local function isMemberInCrew(citizenId, crewName)
    local crew = getRacingCrewByName(crewName)

    if crew then
        for _, member in ipairs(crew.members) do
            print('meb', json.encode(member))
            if member.citizenID == citizenId then
                return true
            end
        end
    end

    return false
end

local function canFounderDisbandCrew(founderCitizenId, crewName)
    local crew = getRacingCrewByName(crewName)
    return (crew and crew.founderCitizenid == founderCitizenId) or false
end

-- Events
RegisterServerEvent('cw-racingapp:server:changeCrew', function(crewName)
    changeRacerCrew(source, crewName)
end)

-- Callbacks

RegisterServerCallback('cw-racingapp:server:getCrewData', function(source, citizenId, racerName)
    return { invites = activeInvites[citizenId], crew = getRacingCrewThatCitizenIDIsIn(citizenId) }
end)

RegisterServerCallback('cw-racingapp:server:getMyCrew', function(source, racerName)
    local crew = getRacingCrewThatRacerNameIsIn(racerName)
    if crew then
        return crew.crewName
    else
        return nil
    end
end)

RegisterServerCallback('cw-racingapp:server:getAllCrews', function(source)
    if useDebug then print('Getting all racing crews', racingCrews) end
    return racingCrews
end)

RegisterServerCallback('cw-racingapp:server:sendInvite', function(source, invitedBySource, invitedCitizenId, crewName)
    if useDebug then print(invitedBySource, ' is Inviting ',invitedCitizenId, ' to', crewName ) end
    return inviteToCrew(invitedBySource, invitedCitizenId, crewName)
end)

RegisterServerCallback('cw-racingapp:server:sendInviteClosest', function(source, invitedBySource, invitedSource, crewName)
    local player = QBCore.Functions.GetPlayer(invitedSource)
    if not player then return TriggerClientEvent('cw-racingapp:client:notify', source, Lang("person_no_exist"), 'error') end

    local citizenid = player.PlayerData.citizenid
    if useDebug then print(invitedBySource, ' is Inviting ',citizenid, ' to', crewName ) end
    return inviteToCrew(invitedBySource, citizenid, crewName)
end)

RegisterServerCallback('cw-racingapp:server:acceptInvite', function(source, racerName, invitedCitizenId)
    if useDebug then print(invitedCitizenId, ' is joining a crew with racer name', racerName ) end
    return acceptInvite(racerName, invitedCitizenId)
end)

RegisterServerCallback('cw-racingapp:server:denyInvite', function(source, invitedCitizenId)
    return denyInvite(invitedCitizenId)
end)

RegisterServerCallback('cw-racingapp:server:createCrew', function(source, founderName, founderCitizenId, crewName)
    local canCreateCrew = canFounderCreateCrew(founderCitizenId)
    local trimmedCrewName = string.gsub(crewName, '^%s*(.-)%s*$', '%1')
    if getRacingCrewByName(trimmedCrewName) then 
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("name_taken"), 'error')
        return false
    end
    if canCreateCrew then
        if useDebug then print('Player can create ') end
        return createRacingCrew(founderName, founderCitizenId, trimmedCrewName)
    else
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("disband_crew_first"), 'error')
    end
    return false
end)

RegisterServerCallback('cw-racingapp:server:joinCrew', function(source, memberName, citizenId, crewName)
    local canJoinCrew = isMemberInCrew(citizenId, crewName)

    if canJoinCrew then
        return joinRacingCrew(memberName, citizenId, crewName)
    else
        print("Error: Member cannot join the crew")
    end
    return false
end)

RegisterServerCallback('cw-racingapp:server:leaveCrew', function(source, memberName, citizenId, crewName)
    if not getRacingCrewByName(crewName) then
        if useDebug then print('The racing crew did not exist') end
        changeRacerCrew(source, nil)
    end
    local canLeaveCrew = isMemberInCrew(citizenId, crewName)
    local isFounder = canFounderDisbandCrew(citizenId, crewName)

    if isFounder then
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("founder_can_not_leave"), 'error')
    end
    if canLeaveCrew then
        return leaveRacingCrew(memberName, citizenId, crewName)
    else
        if useDebug then print("Error: Member cannot leave the crew") end
        changeRacerCrew(source, nil)
        return true
    end
    return false
end)

RegisterServerCallback('cw-racingapp:server:disbandCrew', function(source, founderCitizenId, crewName)
    local canDisbandCrew = canFounderDisbandCrew(founderCitizenId, crewName)

    if canDisbandCrew then
        return disbandRacingCrew(crewName)
    else
        print("Error: Only the founder can disband the crew")
    end
    return false
end)

RegisterServerCallback('cw-racingapp:server:disbandCrew', function(source, founderCitizenId, crewName)
    local canDisbandCrew = canFounderDisbandCrew(founderCitizenId, crewName)

    if canDisbandCrew then
        return disbandRacingCrew(crewName)
    else
        print("Error: Only the founder can disband the crew")
    end
    return false
end)

-- On start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        MySQL.ready(function()
            local query = "SELECT * FROM racing_crews"
            local result = MySQL.Sync.fetchAll(query, {})

            if result then
                for _, row in ipairs(result) do
                    local crew = {
                        id = row.id,
                        crewName = row.crew_name,
                        founderName = row.founder_name,
                        founderCitizenid = row.founder_citizenid,
                        members = json.decode(row.members) or {},
                        wins = row.wins,
                        races = row.races,
                        rank = row.rank
                    }

                    table.insert(racingCrews, crew)
                end
            else
                print("Error fetching racing crews from database")
            end
        end)
    end
end)

-- Debugging
QBCore.Commands.Add('createracingcrew', "Create a new racing crew", {
    { name = 'founder', help = 'Founder name' },
    { name = 'citizenid', help = 'Citizen ID' },
    { name = 'crew', help = 'Crew name' },
}, true, function(source, args)
    print('Creating racing crew for', args[1], 'citizenid', args[2], 'named', args[3])
    createRacingCrew(args[1], args[2], args[3])
end, 'admin')

QBCore.Commands.Add('joinracingcrew', "Join a racing crew", {
    { name = 'member', help = 'Member name' },
    { name = 'citizenid', help = 'Citizen ID' },
    { name = 'crew', help = 'Crew name' },
}, true, function(source, args)
    print(args[1], 'joining racing crew', args[3])
    joinRacingCrew(args[1], args[2], args[3])
end, 'admin')

QBCore.Commands.Add('leaveracingcrew', "Leave a racing crew", {
    { name = 'member', help = 'Member name' },
    { name = 'citizenid', help = 'Citizen ID' },
    { name = 'crew', help = 'Crew name' },
}, true, function(source, args)
    print(args[1], 'leaving racing crew', args[3])
    leaveRacingCrew(args[1], args[2], args[3])
end, 'admin')

QBCore.Commands.Add('addwintocrew', "Add a win to a racing crew", {
    { name = 'crew', help = 'Crew name' },
}, true, function(source, args)
    print('Adding a win to racing crew', args[1])
    addWinToCrew(args[1])
end, 'admin')

QBCore.Commands.Add('addracetocrew', "Add a race to a racing crew", {
    { name = 'crew', help = 'Crew name' },
}, true, function(source, args)
    print('Adding a race to racing crew', args[1])
    addRaceToCrew(args[1])
end, 'admin')

QBCore.Commands.Add('updateranking', "add/remove rank for a racing crew", {
    { name = 'crew', help = 'Crew name' },
    { name = 'amount', help = 'How much do you want to increase/decrease with' },
}, true, function(source, args)
    print('changing rank of racing crew', args[1], 'with', args[2])
    updateRanking(args[1], args[2])
end, 'admin')

QBCore.Commands.Add('disbandracingcrew', "Disband a racing crew", {
    { name = 'crew', help = 'Crew name' },
}, true, function(source, args)
    print('Disbanding racing crew', args[1])
    disbandRacingCrew(args[1])
end, 'admin')

QBCore.Commands.Add('printracingcrews', "Print racing crews", {
}, true, function(source, args)
    print(json.encode(racingCrews))
end, 'admin')

QBCore.Commands.Add('printinvites', "Print racing crews", {
}, true, function(source, args)
    print(json.encode(activeInvites))
end, 'admin')