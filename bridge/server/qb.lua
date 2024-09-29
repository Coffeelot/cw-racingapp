if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()
QBCore.Functions.CreateUseableItem(Config.ItemName.gps, function(source, item)
    openRacingApp(source)
end)


-- Adds money to user
function addMoney(src, moneyType, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney(moneyType, math.floor(amount))
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.Functions.RemoveMoney(moneyType, math.floor(amount))
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.money[moneyType] >= cost
end

-- Updates Metadata
function updateRacingUserMetadata(src, racerName, auth)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("selectedRacerAuth", auth)
    Player.Functions.SetMetaData("selectedRacerName", racerName)
    Player.Functions.SetMetaData("selectedCrew", nil)
end

-- Updates Crew
function updateCrew(src, crewName)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("selectedCrew", crewName)
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.citizenid
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    return QBCore.Functions.GetPlayerByCitizenId(citizenId).PlayerData.source
end

-- Fetches the racer data
function getRacerData(src)
    local PlayerData = QBCore.Functions.GetPlayer(src).PlayerData
    return {
        name = PlayerData.metadata.selectedRacerName,
        auth = PlayerData.metadata.selectedRacerAuth,
        crew = PlayerData.metadata.selectedCrew,
    }
end
