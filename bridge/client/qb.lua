if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end
if Config.Debug then print('Using QB bridge') end


local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    initialSetup()
end)

function getRacerData()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return {
        name = PlayerData.metadata.selectedRacerName,
        auth = PlayerData.metadata.selectedRacerAuth,
        crew = PlayerData.metadata.selectedCrew
    }
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

-- Fix New qb-inventory only server side

-- function hasGps()
--     if Config.Inventory == 'qb' then
--         if QBCore.Functions.HasItem(Config.ItemName.gps) then
--             return true
--         end
--     elseif Config.Inventory == 'ox' then
--         if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then
--             return true
--         end
--     end
--     return false
-- end

function hasGps()
    TriggerServerEvent('check:hasGps')
end

RegisterNetEvent('hasGps:result')
AddEventHandler('hasGps:result', function(hasItem)
    if hasItem then
        print("El jugador tiene un GPS.")
        return true
    else
        print("El jugador no tiene un GPS.")
        return false
    end
end)

--

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
