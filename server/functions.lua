
---------------------
--- CORE FUNCTIONS --
---------------------
local QBCore = nil
local ESX = nil

if Config.Core == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
    QBCore.Functions.CreateUseableItem(Config.ItemName.gps, function(source, item)
        openRacingApp(source)
    end)
elseif Config.Core == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
    ESX.RegisterUsableItem(Config.ItemName.gps, function(source)
        openRacingApp(source)
    end)
end

-- Adds money to user
function addMoney(src, moneyType, amount)
    if Config.Core == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney(moneyType, math.floor(amount))
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addAccountMoney(moneyType, math.floor(amount))
    end
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    if Config.Core == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.Functions.RemoveMoney(moneyType, math.floor(amount))
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if canPay(src, moneyType, amount) then
            xPlayer.removeAccountMoney(moneyType, math.floor(amount))
            return true
        end
    end

    return false
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    if Config.Core == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player.PlayerData.money[moneyType] >= cost then
            return true
        end
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.getAccount(moneyType).money >= cost then
            return true
        end
    end

    return false
end

-- Updates Metadata
function updateRacingUserMetadata(src, racerName, auth)
    if Config.Core == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        if auth then
            Player.Functions.SetMetaData("selectedRacerAuth", auth)
        else
            Player.Functions.SetMetaData("selectedRacerAuth", 'racer')
        end
        Player.Functions.SetMetaData("selectedRacerName", racerName)
        Player.Functions.SetMetaData("selectedCrew", nil)
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.set("selectedRacerAuth", auth or 'racer')
        xPlayer.set("selectedRacerName", racerName)
        xPlayer.set("selectedCrew", nil)
    end
end

-- Updates Crew
function updateCrew(src, crewName)
    if Config.Core == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.SetMetaData("selectedCrew", crewName)
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.set("selectedCrew", crewName)
    end
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    if Config.Core == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.citizenid
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.identifier
    end
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    if Config.Core == 'qb' then
        return QBCore.Functions.GetPlayerByCitizenId(citizenId).PlayerData.source
    elseif Config.Core == 'esx' then
        local players = ESX.GetPlayers()
        for _, playerId in ipairs(players) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer.identifier == citizenId then
                return playerId
            end
        end
    end
end

-- Fetches the auth of player via metadata
function getPlayerAuth(src)
    if Config.Core == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.metadata.selectedRacerAuth
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.get("selectedRacerAuth")
    end

    return nil
end

-- Fetches the racer name of player via metadata
function getPlayerRacerName(src)
    if Config.Core == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.metadata.selectedRacerName
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.get("selectedRacerName")
    end

    return nil
end

-- Fetches the crew of player via metadata
function getPlayerCrew(src)
    if Config.Core == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.metadata.selectedCrew
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.get("selectedCrew")
    end

    return nil
end

------------------------
-- CALLBACK FUNCTIONS --
------------------------

local serverCallbacks = {}

RegisterServerEvent('server:triggerServerCallback')
AddEventHandler('server:triggerServerCallback', function(name, id, ...)
    local src = source
    if serverCallbacks[name] then
        local result = {serverCallbacks[name](src, ...)}
        TriggerClientEvent('client:serverCallback', src, id, table.unpack(result))
    else
        print('Server callback not found:', name)
    end
end)

function RegisterServerCallback(name, cb)
    serverCallbacks[name] = cb
end

--------------
-- COMMANDS --
--------------

function registerCommand(command, description, arguments, argsrequired, callback, restricted)
    -- Register the command
    RegisterCommand(command, function(source, args, rawCommand)
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "Insufficient arguments provided."}
            })
            return
        
        -- Call the callback function
        callback(source, args, rawCommand)
    end, restricted)
    
    -- Prepare suggestions for the command
    local suggestions = {}
    for i, arg in ipairs(arguments) do
        table.insert(suggestions, {
            name = arg.name,
            help = arg.help
        })
    end
    
    -- Register command suggestion for clients
    TriggerClientEvent('chat:addSuggestion', -1, '/' .. command, description, suggestions)
end
