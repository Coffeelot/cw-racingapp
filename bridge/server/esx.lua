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
    if xPlayer.getAccount(moneyType).money >= cost then
        return true
    end

    return false
end

-- Updates Metadata
function updateRacingUserMetadata(src, racerName, auth)
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.set("selectedRacerAuth", auth or 'racer')
    xPlayer.set("selectedRacerName", racerName)
    xPlayer.set("selectedCrew", nil)
end

-- Updates Crew
function updateCrew(src, crewName)
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.set("selectedCrew", crewName)
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

-- Fetches the auth of player via metadata
function getPlayerAuth(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer.get("selectedRacerAuth")
end

-- Fetches the racer name of player via metadata
function getPlayerRacerName(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer.get("selectedRacerName")
end

-- Fetches the crew of player via metadata
function getPlayerCrew(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer.get("selectedCrew")
end
