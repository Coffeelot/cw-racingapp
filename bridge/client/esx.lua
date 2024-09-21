if GetResourceState('es_extended') ~= 'started' then return end
if Config.Debug then print('Using ESX bridge') end

ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function()
    initialSetup()
end)

function getRacerData()
    local PlayerData = ESX.GetPlayerData()
    return {
        name = PlayerData.selectedRacerName,
        auth = PlayerData.selectedRacerAuth,
        crew = PlayerData.selectedCrew
    }
end

function hasGps()
    if Config.Inventory == 'esx' then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer and xPlayer.inventory then
            for _, item in pairs(xPlayer.inventory) do
                if item.name == Config.ItemName.gps and item.count >= 1 then
                    return true
                end
            end
        end
    elseif Config.Inventory == 'ox' then
        if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then
            return true
        end
    end
    return false
end

function getCitizenId()
    return ESX.GetPlayerData().identifier
end

function getVehicleModel(vehicle)
    local model = GetEntityModel(vehicle)
    return GetDisplayNameFromVehicleModel(model)
end

function getClosestPlayer()
    return ESX.Game.GetClosestPlayer()
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
        ESX.ShowNotification(text)
    end
end
