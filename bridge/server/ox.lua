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
        return account.addBalance({ amount, 'Racing' })
    end    
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return false end
    if moneyType == 'cash' or moneyType == 'money' then
        return exports.ox_inventory:RemoveItem(src, 'money', amount)
    else
        local account = player.getAccount()
        return account.removeBalance({ amount, reason or 'Racing', true })
    end   
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return false end
    if moneyType == 'cash' or moneyType == 'money' then
        print(src,moneyType,cost)
        return exports.ox_inventory:Search(src, 'count', 'money') >= cost
    else
        local account = player.getAccount()
        return account.balance >= tonumber(cost)
    end  
end

-- Updates Crew
function updateCrew(src, crewName)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return end
    
    player.setMetadata('selectedCrew', crewName)
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return nil end
    
    return player.charId
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    local player = Ox.GetPlayerFromUserId(citizenId)
    if not player then return nil end
    
    return player.source
end
