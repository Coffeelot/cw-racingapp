if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    initialSetup()
end)

function getPlayerRacerName()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.metadata.selectedRacerName then
        return PlayerData.metadata.selectedRacerName
    end
end

function getPlayerAuth()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.metadata.selectedRacerAuth then
        return PlayerData.metadata.selectedRacerAuth
    end
end

function getPlayerCrew()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.metadata.selectedCrew then
        return PlayerData.metadata.selectedCrew
    end
end

function getPlayerJobName()
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData and playerData.job then
        return playerData.job.name
    end
end

function getPlayerJobLevel()
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData and playerData.job and playerData.job.grade then
        return playerData.job.grade.level
    end
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
    end
    return false
end

function getCitizenId()
    return QBCore.Functions.GetPlayerData().citizenid
end

function getVehicleModel(vehicle)
    local model = GetEntityModel(vehicle)
    for vmodel, vdata in pairs(QBCore.Shared.Vehicles) do
        if model == joaat(vmodel) then
            return vdata.name, vdata.brand
        end
    end
    print('^1It seems like you have not added your vehicle (' ..
    GetDisplayNameFromVehicleModel(joaat(vmodel)) .. ') to the vehicles.lua')
    return GetDisplayNameFromVehicleModel(model)
end

function getClosestPlayer()
    return QBCore.Functions.GetClosestPlayer()
end

function notify(text, type)
    -- Remove this block if you dont want in-app notifications
    if UiIsOpen then
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
        QBCore.Functions.Notify(text, type)
    end
end
