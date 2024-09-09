---------------------
--- CORE FUNCTIONS --
---------------------
local QBCore = nil

if Config.Core == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
    
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
        setup()
    end)
end

function getPlayerRacerName()
    if Config.Core =='qb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.metadata.selectedRacerName then
            return PlayerData.metadata.selectedRacerName
        end
    end

    return nil
end

function getPlayerAuth()
    if Config.Core =='qb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.metadata.selectedRacerAuth then
            return PlayerData.metadata.selectedRacerAuth
        end
    end

    return nil

end

function getPlayerCrew()
    if Config.Core =='qb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.metadata.selectedCrew then
            return PlayerData.metadata.selectedCrew
        end
    end

    return nil

end

function getPlayerJobName()
    if Config.Core =='qb' then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.job then
            return playerData.job.name
        end
    end

    return nil
end

function getPlayerJobLevel()
    if Config.Core =='qb' then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.job and playerData.job.grade then
            return playerData.job.grade.level
        end
    end

    return nil
end

function hasGps()
    if Config.Inventory == 'qb' then
        if QBCore.Functions.HasItem(Config.ItemName.gps) then return true end
    elseif Config.Inventory == 'ox' then
        if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then return true end
    end
    return false
end

function getCitizenId()
    if Config.Core =='qb' then
        return QBCore.Functions.GetPlayerData().citizenid -- returns a string containing the citizenid
    end
end

function getVehicleList()
    if Config.Core =='qb' then
        return QBCore.Shared.Vehicles -- returns list of all vehicles
    end
end

function getClosestPlayer()
    if Config.Core =='qb' then
        return QBCore.Functions.GetClosestPlayer() -- returns player, distance
    end
end

function notify(text, type)
    if Config.OxLibNotify then
        lib.notify({
            title = text,
            type = type,
        })
    else 
        QBCore.Functions.Notify(text, type)
    end
end


------------------------
-- CALLBACK FUNCTIONS --
------------------------

cwCallback = {}
local callbackId = 0
local callbacks = {}

function cwCallback.await(name, ...)
    local p = promise.new()
    
    local id = callbackId
    callbackId = callbackId + 1
    
    callbacks[id] = p
    
    TriggerServerEvent('server:triggerServerCallback', name, id, ...)
    
    return Citizen.Await(p)[1]
end

RegisterNetEvent('client:serverCallback')
AddEventHandler('client:serverCallback', function(id, ...)
    if callbacks[id] then
        callbacks[id]:resolve({...})
        callbacks[id] = nil
    end
end)