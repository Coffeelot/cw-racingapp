
---------------------
--- CORE FUNCTIONS --
---------------------
local QBCore = nil
local ESX = nil

if Config.Core == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
    
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
        setup()
    end)
elseif Config.Core == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
    
    RegisterNetEvent('esx:playerLoaded', function()
        setup()
    end)
end

function getPlayerRacerName()
    if Config.Core == 'qb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.metadata.selectedRacerName then
            return PlayerData.metadata.selectedRacerName
        end
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerData()
        return xPlayer.selectedRacerName or nil
    end

    return nil
end

function getPlayerAuth()
    if Config.Core == 'qb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.metadata.selectedRacerAuth then
            return PlayerData.metadata.selectedRacerAuth
        end
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerData()
        return xPlayer.selectedRacerAuth or nil
    end

    return nil
end

function getPlayerCrew()
    if Config.Core == 'qb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.metadata.selectedCrew then
            return PlayerData.metadata.selectedCrew
        end
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerData()
        return xPlayer.selectedCrew or nil
    end

    return nil
end

function getPlayerJobName()
    if Config.Core == 'qb' then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.job then
            return playerData.job.name
        end
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer and xPlayer.job then
            return xPlayer.job.name
        end
    end

    return nil
end

function getPlayerJobLevel()
    if Config.Core == 'qb' then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.job and playerData.job.grade then
            return playerData.job.grade.level
        end
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer and xPlayer.job and xPlayer.job.grade then
            return xPlayer.job.grade
        end
    end

    return nil
end

function hasGps()
    if Config.Inventory == 'qb' then
        if QBCore.Functions.HasItem(Config.ItemName.gps) then 
            return true 
        end
    elseif Config.Inventory == 'ox' then
        if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then 
            return true 
        end
    elseif Config.Core == 'esx' then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer and xPlayer.inventory then
            for _, item in pairs(xPlayer.inventory) do
                if item.name == Config.ItemName.gps and item.count >= 1 then
                    return true
                end
            end
        end
    end

    return false
end

function getCitizenId()
    if Config.Core == 'qb' then
        return QBCore.Functions.GetPlayerData().citizenid
    elseif Config.Core == 'esx' then
        return ESX.GetPlayerData().identifier
    end
end

function getVehicleModel(vehicle)
    local model = GetEntityModel(vehicle)
    if Config.Core == 'qb' then
        for _, v in pairs(QBCore.Shared.Vehicles) do
            if model == joaat(v.hash) then
                return v.name, v.brand
            end
        end
        print('^1It seems like you have not added your vehicle ('..GetDisplayNameFromVehicleModel(hash)..') to the vehicles.lua')    
        return GetDisplayNameFromVehicleModel(model)
    elseif Config.Core == 'esx' then
        return GetDisplayNameFromVehicleModel(model)
    end

    return 'Unknown Model'
end

function getClosestPlayer()
    if Config.Core == 'qb' then
        return QBCore.Functions.GetClosestPlayer()
    elseif Config.Core == 'esx' then
        return ESX.Game.GetClosestPlayer()
    end
end

function notify(text, type)
    -- Remove this block if you dont want in-app notifications
    if uiIsOpen then
        SendNUIMessage({
            type = "notify",
            data = {
                title = text,
                type = type,
            },
        })
        return
    end

    if Config.OxLibNotify then
        lib.notify({
            title = text,
            type = type,
        })
    else
        if Config.Core == 'qb' then
            QBCore.Functions.Notify(text, type)
        elseif Config.Core == 'esx' then
            ESX.ShowNotification(text)
        end
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
