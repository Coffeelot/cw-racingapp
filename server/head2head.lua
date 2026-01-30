local useDebug = Config.Debug

local activeRaces = {}

local function generateRaceId()
    local RaceId = "IR-" .. math.random(1111, 9999)
    while activeRaces[RaceId] ~= nil do
        RaceId = "IR-" .. math.random(1111, 9999)
    end
    return RaceId
end

local function getFinish(startCoords)
    for _ = 1, 100 do
        local finishCoords = ConfigH2H.Finishes[math.random(1,#ConfigH2H.Finishes)]
        local distance = #(finishCoords.xy-startCoords.xy)
        if tonumber(distance) > ConfigH2H.MinimumDistance and tonumber(distance) < ConfigH2H.MaximumDistance then
            return finishCoords
        end
    end
end

local function resetRace(raceId)
    for _, racer in pairs(activeRaces[raceId].racers) do
        if GetPlayerName(racer.source) then
            TriggerClientEvent('cw-racingapp:h2h:client:leaveRace', racer.source, raceId)
        end
    end
    activeRaces[raceId] = nil
end

local function handleTimeout(raceId)
    SetTimeout(Config.RaceResetTimer, function()
        if activeRaces[raceId] then
            if useDebug then print('Cleaning up '.. raceId..' due to inactivit') end
            resetRace(raceId)
        end
    end)
end

RegisterNetEvent('cw-racingapp:h2h:server:leaveRace', function(raceId)
    resetRace(raceId)
end)

RegisterNetEvent('cw-racingapp:h2h:server:setupRace', function(citizenId, racerName, startCoords, amount, waypoint)
    local raceId = generateRaceId()
    if useDebug then
        print('setting up', citizenId, racerName, startCoords, amount)
    end

    local finishCoords = getFinish(startCoords)
    if finishCoords then
        activeRaces[raceId] = {
            raceId = raceId,
            racers = { { citizenId = citizenId, racerName = racerName, source = source } },
            startCoords = startCoords,
            finishCoords = finishCoords,
            winner = nil,
            started = false,
            finished = false,
            amount = amount,
        }
        if useDebug then print('Race Data:', json.encode(activeRaces[raceId], {indent=true})) end
        if ConfigH2H.SoloRace then
            TriggerEvent('cw-racingapp:h2h:server:startRace', raceId) -- Used for debugging
        else
            TriggerClientEvent('cw-racingapp:h2h:client:checkDistance', source, raceId, amount)
        end
        handleTimeout(raceId)
    else
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("error.failed_to_find_a_waypoint"), "error")
    end
end)

RegisterNetEvent('cw-racingapp:h2h:server:invitePlayer', function(sourceToInvite, raceId, amount, racerName)
    if useDebug then print('[H2H]', racerName, ' is inviting', sourceToInvite,'to', raceId) end
    TriggerClientEvent('cw-racingapp:h2h:client:invite', sourceToInvite, raceId, amount, racerName)
end)

RegisterNetEvent('cw-racingapp:h2h:server:startRace', function(raceId)
    if useDebug then
        print('starting race')
    end
    activeRaces[raceId].started = false
    for _, racer in pairs(activeRaces[raceId].racers) do
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
end)

RegisterNetEvent('cw-racingapp:h2h:server:raceStarted', function(raceId)
    activeRaces[raceId].started = true
end)

RegisterNetEvent('cw-racingapp:h2h:server:joinRace', function(citizenId, racerName, raceId)
    if activeRaces[raceId].started then
        TriggerClientEvent('cw-racingapp:client:notify', source, Lang("error.race_already_started"), "error")
    elseif activeRaces[raceId].amount > 0 then
        if canPay(source, activeRaces[raceId].amount) then
            TriggerClientEvent('cw-racingapp:client:notify', source, Lang("can_not_afford"), "error")
        end

    else
        activeRaces[raceId].racers[#activeRaces[raceId].racers+1] = { citizenId = citizenId, source = source, racerName = racerName }
        if #activeRaces[raceId].racers > 1 then
            TriggerEvent('cw-racingapp:h2h:server:startRace', raceId)
        end
    end
end)

RegisterNetEvent('cw-racingapp:h2h:server:finishRacer', function(raceId, citizenId, finishTime)
    if useDebug then
        print('finishing', citizenId, 'in race', raceId)
    end
    if activeRaces[raceId].winner == nil then
        activeRaces[raceId].winner = citizenId
        TriggerClientEvent('cw-racingapp:h2h:client:notifyFinish', source, Lang('info.winner'))
        if activeRaces[raceId].amount > 0 then
            addMoney(ConfigH2H.MoneyType, activeRaces[raceId].amount*2)
        end
    else
        activeRaces[raceId].finished = true
        TriggerClientEvent('cw-racingapp:h2h:client:notifyFinish', source, Lang('info.loser'))
    end
end)

registerCommand('h2hsetup', 'Setup Impromptu',{}, false, function(source)
    TriggerClientEvent('cw-racingapp:h2h:client:setupRace', source)
end, true)

registerCommand('h2hjoin', 'join impromtu',{}, false, function(source)
    TriggerClientEvent('cw-racingapp:h2h:client:joinRace', source)
end, true)

registerCommand('impdebugmap', 'Show H2H locations',{}, false, function(source)
    TriggerClientEvent('cw-racingapp:h2h:client:debugMap', source)
end, true)

registerCommand('cwdebughead2head', 'toggle debug for head2head', {}, true, function(source, args)
    useDebug = not useDebug
    print('debug is now:', useDebug)
    TriggerClientEvent('cw-racingapp:h2h:client:toggleDebug',source, useDebug)
end, true)
