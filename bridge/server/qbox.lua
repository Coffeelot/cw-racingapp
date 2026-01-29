if GetResourceState('qbx_core') ~= 'started' then return end

AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
    if UseDebug then print('opening ui') end

    if name == Config.ItemName.gps then
        openRacingApp(playerId)
    end
end)

-- Adds money to user
function addMoney(src, moneyType, amount)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    player.Functions.AddMoney(moneyType, math.floor(amount))
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    return player.Functions.RemoveMoney(moneyType, math.floor(amount))
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    return player.PlayerData.money[moneyType] >= cost
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    return player.PlayerData.citizenid
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    return exports.qbx_core:GetPlayerByCitizenId(citizenId).PlayerData.source
end
