if GetResourceState('ox_core') ~= 'started' then return end
local Ox = require '@ox_core/lib/init'

AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
    if UseDebug then print('opening ui') end

    if name == Config.ItemName.gps then
        openRacingApp(playerId)
    end
end)

-- Adds money to user
function addMoney(src, moneyType, amount)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return false end
    if moneyType == 'cash' or moneyType == 'money' then
        return exports.ox_inventory:AddItem(src, 'money', amount)
    else
        local account = player.getAccount()
        local result = account.addBalance({ amount = amount, message = 'RacingApp Payout' })
        if Config.Debug then print('Ox Banking result for adding:', json.encode(result, {indent=true})) end
        return result.sucess
    end
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return false end
    if amount == 0 then return true end
    if moneyType == 'cash' or moneyType == 'money' then
        return exports.ox_inventory:RemoveItem(src, 'money', amount)
    else
        local account = player.getAccount()
        local result = account.removeBalance({ amount = amount, message = reason or 'RacingApp Charge' })
        if Config.Debug then print('Account balance', account.get('balance')) print('Ox Banking result for removing:', json.encode(result, {indent=true})) end
        return result.success
    end
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return false end
    if moneyType == 'cash' or moneyType == 'money' then
        return exports.ox_inventory:Search(src, 'count', 'money') >= cost
    else
        local account = player.getAccount()
        if not account then return false end
        return account.get('balance') >= tonumber(cost)
    end
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return nil end

    return player.stateId
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    local player = Ox.GetPlayerFromFilter({ stateId = citizenId })
    if not player then return nil end

    return player.source
end
