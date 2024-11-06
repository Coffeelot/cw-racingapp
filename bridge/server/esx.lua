if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()
ESX.RegisterUsableItem(Config.ItemName.gps, function(source)
    openRacingApp(source)
end)

-- Adds money to user
function addMoney(src, moneyType, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.addAccountMoney(moneyType, math.floor(amount))
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    local xPlayer = ESX.GetPlayerFromId(src)
    if canPay(src, moneyType, amount) then
        xPlayer.removeAccountMoney(moneyType, math.floor(amount))
        return true
    end
    return false
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
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

-- Fetches the CitizenId by Source
function getCitizenId(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer.identifier
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.identifier == citizenId then
            return playerId
        end
    end
end
