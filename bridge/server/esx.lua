if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()
ESX.RegisterUsableItem(Config.ItemName.gps, function(source)
    openRacingApp(source)
end)

-- Adds money to user

function addMoney(src, moneyType, amount)
    if src == nil or src == -1 or src == 0 then
        print("^1[ERROR][cw-racingapp] Invalid src in addMoney: " .. tostring(src) .. "^0")
        return
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.addAccountMoney(moneyType, math.floor(amount))
end

-- Removes money from user

function removeMoney(src, moneyType, amount, reason)
    if src == nil or src == -1 or src == 0 then
        print("^1[ERROR][cw-racingapp] Invalid src in removeMoney: " .. tostring(src) .. "^0")
        return false
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    if canPay(src, moneyType, amount) then
        xPlayer.removeAccountMoney(moneyType, math.floor(amount))
        return true
    end
    return false
end

-- Checks that user can pay

function canPay(src, moneyType, cost)
    if src == nil or src == -1 or src == 0 then
        print("^1[ERROR][cw-racingapp] Invalid src in canPay: " .. tostring(src) .. "^0")
        return false
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local account = xPlayer.getAccount(moneyType)
        if account and account.money >= cost then
            return true
        else
            return false
        end
    else
        print("Player not found for source: " .. tostring(src))
        return false
    end
end

-- Gives an item to a player

function giveItem(src, itemName, amount, metadata)
    if src == nil or src == -1 or src == 0 then
        print("^1[ERROR][cw-racingapp] Invalid src in giveItem: " .. tostring(src) .. "^0")
        return false
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    xPlayer.addInventoryItem(itemName, amount, metadata)
    return true
end

-- Fetches the CitizenId by Source

function getCitizenId(src)
    if src == nil or src == -1 or src == 0 then
        print("^1[ERROR][cw-racingapp] Invalid src in getCitizenId: " .. tostring(src) .. "^0")
        return nil
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer.identifier
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    if citizenId == nil then
        print("^1[ERROR][cw-racingapp] Invalid citizenId in getSrcOfPlayerByCitizenId: " .. tostring(citizenId) .. "^0")
        return nil
    end
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.identifier == citizenId then
            return playerId
        end
    end
    print("^1[ERROR][cw-racingapp] Player not found for citizenId: " .. tostring(citizenId) .. "^0")
    return nil
end
