local useDebug = Config.Debug

local activeRaces = {}
local Timers = {}

local race = {
    racers = { nil, nil},
    startCoords = nil,
    finishCoords = nil,
    winner = nil,
    started = false,
    finished = false,
    forMoney = false,
    amount = 0
}

local function generateRaceId()
    local RaceId = "IR-" .. math.random(1111, 9999)
    while activeRaces[RaceId] ~= nil do
        RaceId = "IR-" .. math.random(1111, 9999)
    end
    return RaceId
end

local function getFinish(startCoords)
    for i=1, 100 do
        local finishCoords = ConfigH2H.Finishes[math.random(1,#ConfigH2H.Finishes)]
        local distance = #(finishCoords.xy-startCoords.xy)
        if tonumber(distance) > ConfigH2H.MinimumDistance and tonumber(distance) < ConfigH2H.MaximumDistance then
            return finishCoords
        end
    end
end

local function resetRace(raceId)
    if not activeRaces[raceId] then
        return
    end

    for _, racer in pairs(activeRaces[raceId].racers) do
        if GetPlayerName(racer.source) then
            TriggerClientEvent('cw-racingapp:h2h:client:leaveRace', racer.source, raceId)
        end
    end
    activeRaces[raceId] = nil
end

local function getRaceParticipant(raceId, src)
    local raceData = activeRaces[raceId]
    if not raceData then
        return nil, nil
    end

    for index, racer in ipairs(raceData.racers) do
        if racer.source == src then
            return index, racer
        end
    end

    return nil, nil
end

local function isRaceOrganizer(raceId, src)
    local raceData = activeRaces[raceId]
    return raceData and raceData.racers[1] and raceData.racers[1].source == src
end

local function getSourceRacerIdentity(src)
    local citizenId = getCitizenId(src)
    if not citizenId then
        return nil
    end

    local raceUser = RADB.getActiveRacerName(citizenId)
    local racerName = raceUser and raceUser.racername or ''

    return {
        citizenId = citizenId,
        racerName = racerName,
        source = src,
    }
end

local startRaceInternal

local function handleTimeout(raceId)
    SetTimeout(Config.RaceResetTimer, function()
        if activeRaces[raceId] then
            if useDebug then print('Cleaning up '.. raceId..' due to inactivit') end
            resetRace(raceId)
        end
    end)
end

RegisterNetEvent('cw-racingapp:h2h:server:leaveRace', function(raceId)
    if not getRaceParticipant(raceId, source) then
        return
    end

    resetRace(raceId)
end)

RegisterNetEvent('cw-racingapp:h2h:server:setupRace', function(citizenId, racerName, startCoords, amount, waypoint)
    local identity = getSourceRacerIdentity(source)
    if not identity then
        return
    end

    local raceId = generateRaceId()
    if useDebug then
        print('setting up', identity.citizenId, identity.racerName, startCoords, amount)
    end

    local finishCoords = getFinish(startCoords)
    if finishCoords then
        activeRaces[raceId] = {
            raceId = raceId,
            racers = { identity },
            startCoords = startCoords,
            finishCoords = finishCoords,
            winner = nil,
            started = false,
            finished = false,
            amount = amount,
        }
        if useDebug then print('Race Data:', json.encode(activeRaces[raceId], {indent=true})) end
        if ConfigH2H.SoloRace then
            startRaceInternal(raceId) -- Used for debugging
        else
            TriggerClientEvent('cw-racingapp:h2h:client:checkDistance', source, raceId, amount)
        end
        handleTimeout(raceId)
    else
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("error.failed_to_find_a_waypoint"), "error")
    end
end)

RegisterNetEvent('cw-racingapp:h2h:server:invitePlayer', function(sourceToInvite, raceId, amount, racerName)
    local raceData = activeRaces[raceId]
    if not raceData or not isRaceOrganizer(raceId, source) or raceData.started then
        return
    end

    local inviter = raceData.racers[1]
    if useDebug then print('[H2H]', inviter and inviter.racerName or '', ' is inviting', sourceToInvite,'to', raceId) end
    TriggerClientEvent('cw-racingapp:h2h:client:invite', sourceToInvite, raceId, raceData.amount, inviter and inviter.racerName or '')
end)

startRaceInternal = function(raceId)
    if useDebug then
        print('starting race')
    end
    if not activeRaces[raceId] then
        return
    end
    activeRaces[raceId].started = false
    for citizenId, racer in pairs(activeRaces[raceId].racers) do
        if useDebug then
            print('racer', json.encode(racer, {indent=true}))
        end
        local playerSource = getSrcOfPlayerByCitizenId(racer.citizenId)
        if playerSource ~= nil then
            if useDebug then
                print('pinging player', playerSource)
            end
            if activeRaces[raceId].amount > 0 then
                if useDebug then
                    print('money', activeRaces[raceId].amount)
                end
                removeMoney(playerSource, ConfigH2H.MoneyType, activeRaces[raceId].amount, "H2H")
            end
            TriggerClientEvent('cw-racingapp:h2h:client:raceCountdown', playerSource, activeRaces[raceId])
        end
    end
end

RegisterNetEvent('cw-racingapp:h2h:server:startRace', function(raceId)
    if not isRaceOrganizer(raceId, source) then
        return
    end

    startRaceInternal(raceId)
end)

RegisterNetEvent('cw-racingapp:h2h:server:raceStarted', function(raceId)
    if not getRaceParticipant(raceId, source) then
        return
    end

    if activeRaces[raceId] then
        activeRaces[raceId].started = true
    end
end)

RegisterNetEvent('cw-racingapp:h2h:server:joinRace', function(citizenId, racerName, raceId)
    local identity = getSourceRacerIdentity(source)
    if not identity then
        return
    end

    if not activeRaces[raceId] then
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("error.race_does_not_exist"), "error")
        return
    end

    if activeRaces[raceId].started then
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("error.race_already_started"), "error")
        return
    end

    if activeRaces[raceId].amount > 0 then
        if not canPay(source, ConfigH2H.MoneyType, activeRaces[raceId].amount) then
            TriggerClientEvent('cw-racingapp:client:notify', source, Lang("can_not_afford"), "error")
            return
        end
    end

    if #activeRaces[raceId].racers >= 2 then
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("error.race_already_started"), "error")
        return
    end

    if getRaceParticipant(raceId, source) then
        return
    end

    activeRaces[raceId].racers[#activeRaces[raceId].racers+1] = identity
    if #activeRaces[raceId].racers > 1 then
        startRaceInternal(raceId)
    end
end)

RegisterNetEvent('cw-racingapp:h2h:server:finishRacer', function(raceId, citizenId, finishTime)
    local _, racer = getRaceParticipant(raceId, source)
    if not racer then
        return
    end

    if useDebug then
        print('finishing', racer.citizenId, 'in race', raceId)
    end
    if not activeRaces[raceId] or not activeRaces[raceId].started then
        return
    end
    if activeRaces[raceId].winner == nil then
        activeRaces[raceId].winner = racer.citizenId
        TriggerClientEvent('cw-racingapp:h2h:client:notifyFinish', source, Lang('info.winner'))
        if activeRaces[raceId].amount > 0 then
            addMoney(source, ConfigH2H.MoneyType, activeRaces[raceId].amount * 2)
        end
    else
        activeRaces[raceId].finished = true
        TriggerClientEvent('cw-racingapp:h2h:client:notifyFinish', source, Lang('info.loser'))
    end
end)

if Config.EnableCommands then

    RegisterRacingAppCommand('h2hsetup', 'Setup Impromptu',{}, false, function(source)
        TriggerClientEvent('cw-racingapp:h2h:client:setupRace', source)
    end, true)
    
    RegisterRacingAppCommand('h2hjoin', 'join impromtu',{}, false, function(source)
        TriggerClientEvent('cw-racingapp:h2h:client:joinRace', source)
    end, true)
    
    RegisterRacingAppCommand('impdebugmap', 'Show H2H locations',{}, false, function(source)
        TriggerClientEvent('cw-racingapp:h2h:client:debugMap', source)
    end, true)
    
    RegisterRacingAppCommand('cwdebughead2head', 'toggle debug for head2head', {}, true, function(source, args)
        useDebug = not useDebug
        print('debug is now:', useDebug)
        TriggerClientEvent('cw-racingapp:h2h:client:toggleDebug',source, useDebug)
    end, true)
end
