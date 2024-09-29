if GetResourceState('qbx_core') ~= 'started' then return end

exports.qbx_core:CreateUseableItem(Config.ItemName.gps, function(source, item)
    openRacingApp(source)
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

-- Updates Metadata
function updateRacingUserMetadata(src, racerName, auth)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    player.Functions.SetMetaData("selectedRacerAuth", auth)
    player.Functions.SetMetaData("selectedRacerName", racerName)
    player.Functions.SetMetaData("selectedCrew", nil)
end

-- Updates Crew
function updateCrew(src, crewName)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    player.Functions.SetMetaData("selectedCrew", crewName)
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

-- Fetches the player data
function getRacerData(src)
    local PlayerData = exports.qbx_core:GetPlayer(tonumber(src)).PlayerData
    return {
        name = PlayerData.metadata.selectedRacerName,
        auth = PlayerData.metadata.selectedRacerAuth,
        crew = PlayerData.metadata.selectedCrew,
    }
end
