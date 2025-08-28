if GetResourceState('ox_core') ~= 'started' then return end
local Ox = require '@ox_core.lib.init'

if Config.Debug then print('Using OX Core bridge') end

-- Get vehicle data from ox_core
local VEHICLEHASHES = Ox.GetVehicleData()

-- Listen for player loaded event
RegisterNetEvent('ox:playerLoaded', function()
    initialSetup()
end)

function getPlayerJobName()
    local player = Ox.GetPlayer()
    if player and player.job then
        return player.job.name
    end
end

function getPlayerJobLevel()
    local player = Ox.GetPlayer()
    if player and player.job and player.job.grade then
        return player.job.grade
    end
end

function hasGps()
    if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then
        return true
    end
    return false
end

function getCitizenId()
    local player = Ox.GetPlayer()
    return player.stateId
end

function getVehicleModel(vehicle)
    -- Paradym shii
    local model = GetEntityModel(vehicle)

    local vehData = exports['prdm_vehicledata']:getVehicleDataByHash(model)
    return vehData.name

    -- local vehData = VEHICLEHASHES[model]
    -- if vehData then
    --     return vehData.name, vehData.make
    -- end
    -- return GetDisplayNameFromVehicleModel(model)
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