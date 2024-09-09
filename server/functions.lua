---------------------
--- CORE FUNCTIONS --
---------------------
local QBCore = nil

if Config.Core == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
    QBCore.Functions.CreateUseableItem(Config.ItemName.gps, function(source, item)
        openRacingApp(source)
    end)
end

-- Adds money to user
function addMoney(src, moneyType, amount)
    if Config.Core =='qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney(moneyType, math.floor(amount))
    end
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    if Config.Core =='qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.Functions.RemoveMoney(moneyType, math.floor(amount))
    end

    return false
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    if Config.Core =='qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player.PlayerData.money[moneyType] >= cost then
            return true
        end
    end

    return false
end

-- Updates Metadata
function updateRacingUserMetadata(src, racerName, auth)
    if Config.Core =='qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        if auth then
            Player.Functions.SetMetaData("selectedRacerAuth", auth)
        else
            Player.Functions.SetMetaData("selectedRacerAuth", 'racer')
        end
        Player.Functions.SetMetaData("selectedRacerName", racerName)
        Player.Functions.SetMetaData("selectedCrew", nil)
    end
end

-- Updates Crew
function updateCrew(src, crewName)
    if Config.Core =='qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.SetMetaData("selectedCrew", crewName)
    end
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    if Config.Core =='qb' then
        local Player = QBCore.Functions.GetPlayer(src)

        return Player.PlayerData.citizenid
    end
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    if Config.Core =='qb' then
        return QBCore.Functions.GetPlayerByCitizenId(citizenId).PlayerData.source
    end
end

-- Fetches the auth of player via metadata
function getPlayerAuth(src)
    if Config.Core =='qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.metadata.selectedRacerAuth
    end

    return nil

end

-- Fetches the racer name of player via metadata
function getPlayerRacerName(src)
    if Config.Core =='qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.metadata.selectedRacerName
    end

    return nil

end

-- Fetches the crew of player via metadata
function getPlayerCrew(src)
    if Config.Core =='qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.metadata.selectedCrew
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
        -- Check if the correct number of arguments are provided
        if #args < argsrequired then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "Insufficient arguments provided."}
            })
            return
        end
        
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
