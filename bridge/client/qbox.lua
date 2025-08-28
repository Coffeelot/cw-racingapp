if GetResourceState('qbx_core') ~= 'started' then return end

if Config.Debug then print('Using QBOX bridge') end

local VEHICLEHASHES = exports.qbx_core:GetVehiclesByHash()

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    initialSetup()
end)

function getPlayerJobName()
    local playerData = QBX.PlayerData
    if playerData and playerData.job then
        return playerData.job.name
    end
end

function getPlayerJobLevel()
    local playerData = QBX.PlayerData
    if playerData and playerData.job and playerData.job.grade then
        return playerData.job.grade.level
    end
end

function hasGps()
    if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then
        return true
    end
    return false
end

function getCitizenId()
    return QBX.PlayerData.citizenid
end

function getVehicleModel(vehicle)
    local model = GetEntityModel(vehicle)
    local vehData = VEHICLEHASHES[model]
    if vehData then
        return vehData.name, vehData.brand
    end
    return GetDisplayNameFromVehicleModel(model)
end

function getClosestPlayer()
    local coords = GetEntityCoords(cache.ped)
    local playerId, _, playerCoords = lib.getClosestPlayer(coords, 50, false)
    local closestDistance = playerCoords and #(playerCoords - coords) or nil
    return playerId, closestDistance
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

    lib.notify({
        title = Config.NotifyTitle or 'RacingApp',
        description = text,
        type = type,
    })
end
