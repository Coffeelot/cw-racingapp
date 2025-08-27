

local attachedProp = nil

local function clearProp()
    if UseDebug then
        print('REMOVING PROP', attachedProp)
    end
    if attachedProp and DoesEntityExist(attachedProp) then
        DeleteEntity(attachedProp)
        attachedProp = 0
    end
end

local function attachProp()
    clearProp()
    local model = 'prop_cs_tablet'
    local boneNumber = 28422
    SetCurrentPedWeapon(cache.ped, 0xA2719263, false)
    local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumber)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    attachedProp = CreateObject(model, 1.0, 1.0, 1.0, 1, 1, 0)
    local x, y, z = 0.0, -0.03, 0.0
    local xR, yR, zR = 20.0, -90.0, 0.0
    AttachEntityToEntity(attachedProp, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, 0, true, false, true, 2, true)
end

local function stopAnimation()
    ClearPedTasks(PlayerPedId())
    clearProp()
end

local function handleAnimation()
    local animDict = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a'
    if not DoesAnimDictExist(animDict) then
        print('animation dict does not exist')
        return false
    end
    RequestAnimDict(animDict)
    while (not HasAnimDictLoaded(animDict)) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, "idle_a", 5.0, 5.0, -1, 51, 0, false, false, false)
    attachProp()
end

function OpenUi()
    DebugLog('opening ui')

    if not UiIsOpen then
        NotifyHandler(Lang("esc"))
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'toggleApp', open = true })
        UiIsOpen = true
        StartScreenEffect('MenuMGIn', 1, true)
        handleAnimation()
    end
end


RegisterNUICallback('GetBaseData', function(_, cb)
    DebugLog('Base data object', json.encode(GetBaseDataObject(), { indent = true }))
    cb(GetBaseDataObject())
end)

local function findRacerByName()
    if #MyRacerNames == 1 and CurrentName == nil then
        CurrentName = MyRacerNames[1].racername
        CurrentAuth = MyRacerNames[1].auth
        cwCallback.await('cw-racingapp:server:changeRacerName', CurrentName)
        return MyRacerNames[1]
    end
    if MyRacerNames then
        for _, user in pairs(MyRacerNames) do
            if CurrentName == user.racername then return user end
        end
    end
    return false
end

local function split(source)
    local str = source:gsub("%s+", "")
    str = string.gsub(str, "%s+", "")
    local result, i = {}, 1
    while true do
        local a, b = str:find(',')
        if not a then break end
        local candidat = str:sub(1, a - 1)
        if candidat ~= "" then
            result[i] = candidat
        end
        i = i + 1
        str = str:sub(b + 1)
    end
    if str ~= "" then
        result[i] = str
    end
    return result
end

local function openRacingApp()
    OpenUi()
end
exports('openRacingApp', openRacingApp)

function CloseUi()
    UiIsOpen = false
    SetNuiFocus(false, false)
    StopScreenEffect('MenuMGIn')
    stopAnimation()
end

RegisterNUICallback('UiCloseUi', function(_, cb)
    CloseUi()
    cb(true)
end)

RegisterNetEvent("cw-racingapp:client:openUi", function()
    OpenUi()
end)

RegisterNUICallback('UiLeaveCurrentRace', function(raceid, cb)
    DebugLog('Leaving race with race id', raceid)
    cb(LeaveCurrentRace())
end)

RegisterNUICallback('UiStartCurrentRace', function(raceid, cb)
    DebugLog('starting race with race id', raceid)
    TriggerServerEvent('cw-racingapp:server:startRace', raceid)
    cb(true)
end)

RegisterNUICallback('UiChangeRacerName', function(racername, cb)
    local result = cwCallback.await('cw-racingapp:server:changeRacerName', racername)
    if result then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNUICallback('UiGetRacerNamesByPlayer', function(racername, cb)
    local playerNames = cwCallback.await('cw-racingapp:server:getRacerNamesByPlayer')

    MyRacerNames = playerNames
    DebugLog('player names', #playerNames, json.encode(playerNames))
    local currentRacer = findRacerByName()
    if currentRacer and currentRacer.revoked == 1 then
        NotifyHandler(Lang("revoked_access"), 'error')
    end
    if currentRacer then
        if currentRacer.ranking then
            CurrentRanking = currentRacer.ranking
            DebugLog('Ranking is', CurrentRanking)
        end
        if currentRacer.crypto then
            CurrentCrypto = currentRacer.crypto
            DebugLog('Crypto is', CurrentCrypto)
        end
    end
    cb(playerNames)
end)

RegisterNUICallback('UiPurchaseCrypto', function(data, cb)
    DebugLog('purchasing crypto', data.cryptoAmount)
    local result = cwCallback.await('cw-racingapp:server:purchaseCrypto', CurrentName, data.cryptoAmount)
    DebugLog('purchasing crypto result', result)
    Wait(1000)
    cb(result)
end)

RegisterNUICallback('UiSellCrypto', function(data, cb)
    DebugLog('selling crypto', data.cryptoAmount)
    local result = cwCallback.await('cw-racingapp:server:sellCrypto', CurrentName, data.cryptoAmount)
    DebugLog('selling crypto result', result)
    Wait(1000)
    cb(result)
end)

RegisterNUICallback('UiTransferCrypto', function(data, cb)
    DebugLog('selling crypto', data.cryptoAmount, 'to', data.recipient)
    local result = cwCallback.await('cw-racingapp:server:transferCrypto', CurrentName, data.cryptoAmount, data.recipient)
    DebugLog('selling crypto result', result)
    Wait(1000)
    cb(result)
end)

RegisterNUICallback('UiChangeAuth', function(data, cb)
    DebugLog('changing auth', json.encode(data, {indent=true}))
    if not Config.Permissions[data.auth] then debugPrint('User type does not exist') return end
    local result = cwCallback.await('cw-racingapp:server:setUserAuth', data)
    cb(result)
end)

RegisterNUICallback('UiRevokeRacer', function(data, cb)
    DebugLog('revoking racename', data.racername, data.status)
    local newStatus = 0
    if data.status == 0 then newStatus = 1 end
    TriggerServerEvent("cw-racingapp:server:setRevokedRacenameStatus", data.racername, newStatus)
    cb(true)
end)

RegisterNUICallback('UiRemoveRecord', function(data, cb)
    DebugLog('permanently removing record', json.encode(data, { indent = true }))
    TriggerServerEvent("cw-racingapp:server:removeRecord", data.record)
    cb(true)
end)

RegisterNUICallback('UiRemoveRacer', function(data, cb)
    DebugLog('permanently removing racename', data.racername)
    TriggerServerEvent("cw-racingapp:server:removeRacerName", data.racername)
    Wait(500)
    cb(true)
end)

RegisterNUICallback('UiGetRacersCreatedByUser', function(_, cb)
    local racerId = getCitizenId()
    local playerNames = cwCallback.await('cw-racingapp:server:getRacersCreatedByUser', racerId, CurrentAuth)

    DebugLog('player names', #playerNames, json.encode(playerNames))
    cb(playerNames)
end)

RegisterNUICallback('UiGetPermissionedUserTypes', function(_, cb)
    local options = {}

    local currency
    if Config.Laptop.moneyType == 'cash' or Config.Laptop.moneyType == 'money' or Config.Laptop.moneyType == 'bank' then
        currency = '$'
    else
        currency = Config.Payments.cryptoType
    end

    for authName, _ in pairs(Config.Permissions) do
        if HasAuth(Config.Laptop, authName) then
            local option = {
                label = authName .. ' user (' .. currency .. Config.Laptop.racingUserCosts[authName] .. ')',
                purchaseType = Config.Laptop,
                fobType = authName,
            }
            options[#options + 1] = option
        end
    end
    print('Available user types:', json.encode(options, { indent = true }))
    cb(options)
end)

RegisterNuiCallback('UiGetPermissionedUserTypeFirstUser', function(_, cb)
    local data = {}
    if IsFirstUser then
        data.fobType = 'god'
    else
        data.fobType = Config.BasePermission
    end
    data.purchaseType = Config.Laptop
    cb(data)
end)

RegisterNuiCallback('UiGetBounties', function(_, cb)
    local bounties = cwCallback.await('cw-racingapp:server:getBounties')
    cb(bounties)
end)

RegisterNuiCallback('UIRerollBounties', function(_, cb)
    TriggerServerEvent('cw-racingapp:server:rerollBounties')
    cb(true)
end)

RegisterNuiCallback('UiToggleHosting', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:toggleHosting')
    cb(result)
end)

RegisterNuiCallback('UiToggleAutoHost', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:toggleAutoHost')
    cb(result)
end)

RegisterNuiCallback('UINewAutoHost', function(_, cb)
    TriggerServerEvent('cw-racingapp:server:newAutoHost')
    cb(true)
end)

RegisterNuiCallback('UiGetAdminData', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:getAdminData')
    cb(result)
end)

local function getRaceByRaceId(Races, raceId)
    for _, race in pairs(Races) do
        if race.RaceId == raceId then
            return race
        end
    end
end

-- Join a race with raceId. Returns false if issue or true if worked
local function joinRace(raceId)
    DebugLog('attempt joining race with race id', raceId)
    if CurrentRaceData.RaceId ~= nil then
        NotifyHandler(Lang("already_in_race"), 'error')
        return false
    end
    local PlayerPed = PlayerPedId()
    local PlayerIsInVehicle = IsPedInAnyVehicle(PlayerPed, false)

    local class
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)
    if PlayerIsInVehicle and IsDriver(vehicle) then
        class = getVehicleClass(vehicle)
    else
        NotifyHandler(Lang('not_in_a_vehicle'), 'error')
        return false
    end

    local result = cwCallback.await('cw-racingapp:server:getRaces')
    local currentRace = getRaceByRaceId(result, raceId)

    if currentRace == nil then
        NotifyHandler(Lang("race_no_exist"), 'error')
    else
        if MyCarClassIsAllowed(currentRace.MaxClass, class) then
            currentRace.RacerName = CurrentName
            currentRace.PlayerVehicleEntity = GetVehiclePedIsIn(PlayerPed, false)
            DebugLog('^2 joining race with race id', raceId)
            TriggerServerEvent('cw-racingapp:server:joinRace', currentRace)
            return true
        else
            NotifyHandler(Lang('incorrect_class'), 'error')
        end
    end
    return false
end
exports('joinRace', joinRace)

RegisterNetEvent("cw-racingapp:client:joinRaceByRaceId", function(raceId)
    joinRace(raceId)
end)

RegisterNUICallback('UiJoinRace', function(raceId, cb)
    cb(joinRace(raceId))
end)

RegisterNUICallback('UiSetWaypoint', function(track, cb)
    if track and track.Checkpoints then
        SetNewWaypoint(
            track.Checkpoints[1].coords.x --[[ number ]],
            track.Checkpoints[1].coords.y --[[ number ]]
        )
    end
    cb(true)
end)

RegisterNUICallback('UiClearLeaderboard', function(track, cb)
    DebugLog('clearing leaderboard for ', track.RaceName)
    NotifyHandler(track.RaceName .. Lang("leaderboard_has_been_cleared"))
    TriggerServerEvent("cw-racingapp:server:clearLeaderboard", track.TrackId)
    cb(true)
end)

RegisterNUICallback('UiDeleteTrack', function(track, cb)
    DebugLog('deleting track', track.RaceName)
    NotifyHandler(track.RaceName .. Lang("has_been_removed"))
    TriggerServerEvent("cw-racingapp:server:deleteTrack", track.TrackId)
    cb(true)
end)

RegisterNUICallback('UiEditTrack', function(track, cb)
    DebugLog('opening track editor for', track.RaceName)
    TriggerEvent("cw-racingapp:client:startRaceEditor", track.RaceName, CurrentName, track.TrackId)
    cb(true)
end)

RegisterNUICallback('UiGetAccess', function(track, cb)
    DebugLog('gettingAccessFor', track.RaceName)

    local result = cwCallback.await('cw-racingapp:server:getAccess', track.TrackId)
    if not result then
        DebugLog('Access table was empty')
        result = { race = '' }
    else
        local raceText = ''
        if result.race then
            for i, v in pairs(result.race) do
                if i == 1 then
                    raceText = v
                else
                    raceText = raceText .. ', ' .. v
                end
            end
            result = { race = raceText }
        else
            result.race = ''
        end
    end
    cb(result)
end)

RegisterNUICallback('UiEditAccess', function(track, cb)
    DebugLog('editing access for', track.RaceName)
    local newAccess = {
        race = split(track.NewAccess.race)
    }
    TriggerServerEvent("cw-racingapp:server:setAccess", track.TrackId, newAccess)
    cb(true)
end)

RegisterNUICallback('UiFetchCurrentRace', function(_, cb)
    local racers = 0
    local maxClass = 'open'
    if CurrentRaceData.RaceId then
        for _ in pairs(CurrentRaceData.Racers) do
            racers = racers + 1
        end
        if (CurrentRaceData.MaxClass ~= nil and CurrentRaceData.MaxClass ~= "") then
            maxClass = CurrentRaceData.MaxClass
        end
        local canStart = false
        if CurrentRaceData.SetupCitizenId then
            canStart = (CurrentRaceData.SetupCitizenId == getCitizenId()) and not CurrentRaceData.Started
        end
        local data = {
            trackName = CurrentRaceData.RaceName,
            racers = racers,
            laps = CurrentRaceData.TotalLaps,
            class = tostring(maxClass),
            canStart = canStart,
            raceId = CurrentRaceData.RaceId,
            ghosting = CurrentRaceData.Ghosting,
            ranked = CurrentRaceData.Ranked,
            reversed = CurrentRaceData.Reversed,
            hostName = CurrentRaceData.SetupRacerName
        }
        DebugLog('Current race', json.encode(data, { indent = true }))
        cb(data)
    else
        cb({})
    end
end)

RegisterNUICallback('UiGetSettings', function(_, cb)
    cb({
        IgnoreRoadsForGps = IgnoreRoadsForGps,
        ShowGpsRoute = ShowGpsRoute,
        UseUglyWaypoint = UseUglyWaypoint,
        CheckDistance =
            CheckDistance,
        UseDrawTextWaypoint = UseDrawTextWaypoint
    })
end)

local function verifyTrackAccess(track, type)
    if track.Access and track.Access[type] ~= nil then
        if track.Access[type][1] == nil then
            print('no values', track.RaceName)
            return true
        end                                                -- if list is added but emptied
        local playerCid = getCitizenId()
        if track.Creator == playerCid then return true end -- if creator default to true
        if UseDebug then
            print('track', track.RaceName, 'has access limitations for', type)
            print('player cid', playerCid)
        end
        for i, citizenId in pairs(track.Access[type]) do
            DebugLog(i, citizenId)
            if citizenId == playerCid then return true end -- if one of the players in the list
        end
        return false
    end
    return true
end

local function sortTracksByName(tracks)
    local temp = {}
    for _, track in pairs(tracks) do
        temp[#temp+1] = track
    end
    table.sort(temp, function(a, b)
        return a.RaceName < b.RaceName
    end)
    return temp
end

local function sortRacesByName(tracks)
    local temp = tracks
    table.sort(temp, function(a, b)
        return a.RaceData.RaceName > b.RaceData.RaceName
    end)
    return temp
end

local function getAvailableTracks()
    local result = cwCallback.await('cw-racingapp:server:getTracks')
    local tracks = {}
    for _, track in pairs(result) do
        if verifyTrackAccess(track, 'race') then
            tracks[#tracks + 1] = track
        end
    end
    return sortTracksByName(tracks)
end
exports('getAvailableTracks', getAvailableTracks)

RegisterNUICallback('UiGetAvailableTracks', function(data, cb)
    cb(getAvailableTracks())
end)

local function getAvailableRaces()
    local result = cwCallback.await('cw-racingapp:server:getAvailableRaces')
    local availableRaces = {}
    if #result > 0 then
        DebugLog('Fetching available races:', json.encode(result))
        for _, race in pairs(result) do
            DebugLog('Race:', json.encode(race))
            local racers = 0
            local PlayerPed = PlayerPedId()
            race.PlayerVehicleEntity = GetVehiclePedIsIn(PlayerPed, false)
            for _ in pairs(race.RaceData.Racers) do
                racers = racers + 1
            end

            race.RacerName = CurrentName

            local maxClass = 'open'
            if (race.RaceData.MaxClass ~= nil and race.RaceData.MaxClass ~= "") then
                maxClass = race.RaceData.MaxClass
            end
            race.maxClass = maxClass
            race.racers = racers
            race.disabled = CurrentRaceData.RaceId
            race.laps = race.Laps
            availableRaces[#availableRaces + 1] = race
        end
    end
    return sortRacesByName(availableRaces)
end
exports('getAvailableRaces', getAvailableRaces)

RegisterNUICallback('UiGetListedRaces', function(_, cb)
    cb(getAvailableRaces())
end)

RegisterNUICallback('UiGetRaceRecordsForTrack', function(queryData, cb)
    DebugLog('Fetching track records for', queryData.trackId)
    local result = cwCallback.await('cw-racingapp:server:getRaceRecordsForTrack', queryData.trackId)
    cb(result)
end)

RegisterNUICallback('UiGetTracks', function(data, cb)
    local result = cwCallback.await('cw-racingapp:server:getTracks')
    cb(sortTracksByName(result))
end)

RegisterNUICallback('UiGetTracksTrimmed', function(data, cb)
    local result = cwCallback.await('cw-racingapp:server:getTracksTrimmed')
    cb(sortTracksByName(result))
end)

RegisterNUICallback('UiGetRacingResults', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:getRaceResults')
    DebugLog('Racing results', json.encode(result, {indent=true}))
    cb(result)
end)

RegisterNUICallback('UiGetDashboardData', function(_, cb)
    local result = cwCallback.await('cw-racingapp:server:getDashboardData')
    DebugLog('Dashboard Data', json.encode(result, {indent=true}))
    cb(result)
end)

RegisterNUICallback('UiKickCrewMember', function(data, cb)
    local citizenId  = data.citizenId
    local memberName  = data.citizenId
    DebugLog('kicking crew member with citizenId', memberName, citizenId)
    local result = cwCallback.await('cw-racingapp:server:kickMemberFromCrew', memberName, citizenId, CurrentCrew)
    cb(result)
end)

-- Setup race. See Racingapp readme for info on what setupData needs to include
local function attemptSetupRace(setupData)
    if not setupData or setupData.track == "none" then
        DebugLog('No setup data or missing track')
        return false
    end
    DebugLog('setup data', json.encode(setupData))
    local PlayerPed = PlayerPedId()
    local PlayerIsInVehicle = IsPedInAnyVehicle(PlayerPed, false)
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)

    if PlayerIsInVehicle and IsDriver(vehicle) then
        local class = getVehicleClass(GetVehiclePedIsIn(PlayerPed, false))
        if MyCarClassIsAllowed(setupData.maxClass, class) then
            local data = {
                trackId = setupData.trackId,
                laps = tonumber(setupData.laps),
                hostName = CurrentName,
                maxClass = setupData.maxClass,
                ghostingEnabled = setupData.ghostingOn,
                ghostingTime = tonumber(setupData.ghostingTime),
                buyIn = tonumber(setupData.buyIn),
                ranked = setupData.ranked,
                reversed = setupData.reversed,
                participationMoney = setupData.participationMoney,
                participationCurrency = setupData.participationCurrency,
                firstPerson = setupData.firstPerson,
                silent = setupData.silent,
                hidden = setupData.hidden
            }
            local res = cwCallback.await('cw-racingapp:server:setupRace', data)
            return res
        else
            NotifyHandler(Lang('incorrect_class'), 'error')
            return false
        end
    else
        NotifyHandler(Lang('not_in_a_vehicle'), 'error')
        return false
    end
end
exports('attemptSetupRace', attemptSetupRace)

RegisterNUICallback('UiSetupRace', function(setupData, cb)
    cb(attemptSetupRace(setupData))
end)

RegisterNUICallback('UiQuickSetupBounty', function(bounty, cb)
    local setupData = {}
    for field, value in pairs(Config.QuickSetupDefaults) do
        setupData[field] = value
    end
    setupData.trackId = bounty.trackId
    setupData.maxClass = bounty.maxClass
    setupData.reversed = bounty.reversed

    if bounty.sprint then
        setupData.laps = 0
    end

    DebugLog('Bounty: Quick setup data', json.encode(setupData, { indent = true }))
    cb(attemptSetupRace(setupData))
end)

RegisterNUICallback('UiQuickHost', function(track, cb)
    local setupData = {}
    for field, value in pairs(Config.QuickSetupDefaults) do
        setupData[field] = value
    end
    setupData.trackId = track.TrackId
    if track.Metadata then
        DebugLog('Track metadata', json.encode(track.Metadata, { indent = true }))
        if track.Metadata.raceType == 'sprint_only' then
            setupData.laps = 0
        end
    end
    
    if track.sprint then
        setupData.laps = 0
    end
    
    DebugLog('Track: Quick setup data', json.encode(setupData, { indent = true }))
    cb(attemptSetupRace(setupData))
end)

local function verifyCheckpoints(checkpoints)
    for _, data in pairs(checkpoints) do
        local coordsExist = data.coords.x and data.coords.y and data.coords.z
        local offsetExists = data.offset.left.x and data.offset.left.y and data.offset.left.z and data.offset.right.x and
            data.offset.right.y and data.offset.right.z
        if coordsExist and offsetExists then return true end
    end
    return false
end

RegisterNUICallback('UiCreateTrack', function(createData, cb)
    if not createData.name then return end
    DebugLog('create data', json.encode(createData))
    if not createData or createData.name == "" then
        return
    end

    local checkpoints = createData.checkpoints
    local decodedCheckpoints = json.decode(checkpoints)
    if checkpoints ~= nil then
        if type(decodedCheckpoints) == 'table' then
            if not verifyCheckpoints(decodedCheckpoints) then
                NotifyHandler(Lang("corrupt_data"))
                return
            end
        else
            NotifyHandler(Lang("cant_decode"))
            return
        end
    end

    local citizenId = getCitizenId()
    local tracks = cwCallback.await('cw-racingapp:server:getAmountOfTracks', citizenId)

    local maxCharacterTracks = Config.MaxCharacterTracks
    if Config.CustomAmountsOfTracks[citizenId] then
        maxCharacterTracks = Config.CustomAmountsOfTracks[citizenId]
    end

    DebugLog('Max allowed for you:', maxCharacterTracks, "You have this many tracks:", tracks)

    if Config.LimitTracks and tracks >= maxCharacterTracks then
        NotifyHandler(Lang("max_tracks") .. maxCharacterTracks)
        return
    else
        if not #createData.name then
            NotifyHandler(Lang("no_name_track"), 'error')
            cb(false)
            return
        end

        if #createData.name < Config.MinTrackNameLength then
            NotifyHandler(Lang("name_too_short"), 'error')
            cb(false)
            return
        end

        if #createData.name > Config.MaxTrackNameLength then
            NotifyHandler(Lang("name_too_long"), 'error')
            cb(false)
            return
        end

        local result = cwCallback.await('cw-racingapp:server:isAuthorizedToCreateRaces', createData.name, CurrentName)

        if not result.permissioned then
            NotifyHandler(Lang("not_auth"), 'error')
            cb(false)
        end
        if not result.nameAvailable then
            NotifyHandler(Lang("race_name_exists"), 'error')
            cb(false)
        end

        TriggerServerEvent('cw-racingapp:server:createTrack', createData.name, CurrentName, decodedCheckpoints)
        cb(true)
    end
end)
RegisterNUICallback('UiSetCurated', function(data, cb)
    DebugLog('Setting curation status for', data.trackId, data.curated)
    local result = cwCallback.await('cw-racingapp:server:curateTrack', data.trackId, data.curated)

    DebugLog('Success: ', result)
    cb(result)
end)

-- Crew stuff
RegisterNUICallback('UiJoinCrew', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:joinCrew', CurrentName, citizenId, data.crewName)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = result
        TriggerServerEvent('cw-racingapp:server:changeCrew', CurrentCrew)
    end
    cb(result)
end)

RegisterNUICallback('UiLeaveCrew', function(data, cb)
    DebugLog('Leaving', data.crewName)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:leaveCrew', CurrentName, citizenId, data.crewName)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = nil
        TriggerServerEvent('cw-racingapp:server:changeCrew', nil)
    end
    cb(result)
end)

RegisterNUICallback('UiDisbandCrew', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:disbandCrew', citizenId, data.crewName)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = nil
        TriggerServerEvent('cw-racingapp:server:changeCrew', nil)
    end
    cb(result)
end)

RegisterNUICallback('UiCreateCrew', function(data, cb)
    local sanitizedName = StrictSanitize(data.crewName)
    if #sanitizedName == 0 then
        NotifyHandler(Lang("name_too_short"), 'error')
        cb(false)
        return
    end
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:createCrew', CurrentName, citizenId, sanitizedName)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = sanitizedName
        TriggerServerEvent('cw-racingapp:server:changeCrew', sanitizedName)
    end
    cb(result)
end)

RegisterNUICallback('UiCreateUser', function(data, cb)
    if data.racerName and data.selectedAuth then
        AttemptCreateUser(data.racerName, data.racerId, data.selectedAuth.fobType, data.selectedAuth.purchaseType)
    else
        NotifyHandler(Lang("bad_input"), 'error')
    end
    cb(true)
end)

RegisterNUICallback('UiSendInvite', function(data, cb)
    if data.citizenId.length == 0 then
        NotifyHandler(Lang("bad_input"), 'error')
        cb(false)
        return
    end
    local myServerID = GetPlayerServerId(PlayerId())

    local result = cwCallback.await('cw-racingapp:server:sendInvite', myServerID, data.citizenId, CurrentCrew)

    DebugLog('Success: ', result)
    cb(result)
end)

RegisterNUICallback('UiSendInviteClosest', function(data, cb)
    local closestP, distance = getClosestPlayer()
    if closestP == nil or distance > 5 then
        NotifyHandler(Lang("prox_error"), 'error')
        cb(false)
        return
    end

    local closestServerID = GetPlayerServerId(closestP)
    local myServerID = GetPlayerServerId(PlayerId())

    local result = cwCallback.await('cw-racingapp:server:sendInviteClosest', myServerID, closestServerID, CurrentCrew)
    DebugLog('Success: ', result)
    cb(result)
end)

RegisterNUICallback('UiAcceptInvite', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:acceptInvite', CurrentName, citizenId)

    DebugLog('Success: ', result)
    if result then
        CurrentCrew = data.crewName
        TriggerServerEvent('cw-racingapp:server:changeCrew', data.crewName)
    end
    cb(result)
end)

RegisterNUICallback('UiDenyInvite', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:denyInvite', citizenId)
    DebugLog('Success: ', result)
    cb(result)
end)

RegisterNUICallback('UiGetAllCrews', function(data, cb)
    local result = cwCallback.await('cw-racingapp:server:getAllCrews')
    DebugLog('All crews: ', json.encode(FlatTable(result)))
    cb(FlatTable(result))
end)

RegisterNUICallback('UiGetAllRacers', function(data, cb)
    local result = cwCallback.await('cw-racingapp:server:getAllRacers')
    DebugLog('All racers: ', json.encode(result))
    cb(result)
end)

RegisterNUICallback('UiConfirmSettings', function(data, cb)
    DebugLog('Settings data for track ' .. data.TrackId, json.encode(data.Metadata, { indent = true }))
    local result = cwCallback.await('cw-racingapp:server:updateTrackMetadata', data.TrackId, data.Metadata)
    cb(result)
end)

RegisterNUICallback('UiGetCrewData', function(data, cb)
    local citizenId = getCitizenId()
    local result = cwCallback.await('cw-racingapp:server:getCrewData', citizenId, CurrentCrew)

    DebugLog('crew data: ', json.encode(result))
    cb(result)
end)

RegisterNUICallback('UiCancelRace', function(trackId, cb)
    DebugLog('Cancelling', trackId)
    local result = cwCallback.await('cw-racingapp:server:cancelRace', trackId)
    Wait(1000)
    CurrentRaceData.RaceId = nil
    cb(result)
end)

RegisterNUICallback('UiFetchRacerHistory', function(racerName, cb)
    DebugLog('Fetching Racer history for racer',racerName or CurrentName )
    local result = cwCallback.await('cw-racingapp:server:fetchRacerHistory', racerName or CurrentName)
    cb(result)
end)

RegisterNUICallback('UiShowTrack', function(trackId, cb)
    DebugLog('displaying track', trackId)
    local result = cwCallback.await('cw-racingapp:server:getTrackData', trackId)
    if not result then NotifyHandler(Lang("no_track_found")..tostring(trackId)) return end


    DisplayTrack(result)
    SetTimeout(20 * 1000, function()
        FinishedUITimeout = false
        HideTrack()
    end)
    cb(true)
    Wait(500)
    NotifyHandler(Lang("display_tracks"))
end)

local function toggleShowRoute(boolean)
    if boolean == nil then
        ShowGpsRoute = not ShowGpsRoute
    else
        ShowGpsRoute = boolean
    end
    if ShowGpsRoute then
        NotifyHandler(Lang("toggled_gps_route_on"), 'success')
    else
        NotifyHandler(Lang("toggled_gps_route_off"), 'error')
    end
end

RegisterCommand('showroute', function()
    toggleShowRoute()
end)

local function toggleIgnoreRoadsForGps(boolean)
    if boolean == nil then
        IgnoreRoadsForGps = not IgnoreRoadsForGps
    else
        IgnoreRoadsForGps = boolean
    end
    if IgnoreRoadsForGps then
        NotifyHandler(Lang("gps_straight_on"), 'error')
    else
        NotifyHandler(Lang("gps_straight_off"), 'success')
    end
end

RegisterCommand('ignoreroads', function()
    toggleIgnoreRoadsForGps()
end)

local function toggleUglyWaypoint(boolean)
    if boolean == nil then
        UseUglyWaypoint = not UseUglyWaypoint
    else
        UseUglyWaypoint = boolean
    end
    if UseUglyWaypoint then
        NotifyHandler(Lang("basic_wps_on"), 'success')
    else
        NotifyHandler(Lang("basic_wps_off"), 'error')
    end
end

local function toggleDrawTextWaypoint(boolean)
    if boolean == nil then
        UseDrawTextWaypoint = not UseDrawTextWaypoint
    else
        UseDrawTextWaypoint = boolean
    end
    if UseDrawTextWaypoint then
        NotifyHandler(Lang("draw_text_wps_on"), 'success')
    else
        NotifyHandler(Lang("draw_text_wps_off"), 'error')
    end
end

RegisterCommand('basicwaypoint', function()
    toggleUglyWaypoint()
end)

RegisterNUICallback('UiUpdateSettings', function(data, cb)
    if data.setting == 'IgnoreRoadsForGps' then
        toggleIgnoreRoadsForGps(data.value)
    elseif data.setting == 'ShowGpsRoute' then
        toggleShowRoute(data.value)
    elseif data.setting == 'UseDrawTextWaypoint' then
        toggleDrawTextWaypoint(data.value)
    elseif data.setting == 'UseUglyWaypoint' then
        toggleUglyWaypoint(data.value)
    elseif data.setting == 'CheckDistance' then
        CheckDistance = data.value
        if CheckDistance then
            NotifyHandler(Lang("distance_on"), 'success')
        else
            NotifyHandler(Lang("distance_off"), 'error')
        end
    end
end)


