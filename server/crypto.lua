-- crypto.lua
-- Handles cryptocurrency operations for racing app
-- Function to fetch crypto balance for a racer
local function getRacerCrypto(racerName)
    local cryptoBalance = RADB.getCryptoForRacer(racerName)
    return cryptoBalance or 0
end exports('getRacerCrypto', getRacerCrypto)

-- Function to check if user has enought
local function hasEnoughCrypto(racerName, amount)
    local cryptoBalance = RADB.getCryptoForRacer(racerName)
    return (cryptoBalance or 0) >= amount
end exports('hasEnoughCrypto', hasEnoughCrypto)

-- Function to add crypto to a racer's balance
local function addRacerCrypto(racerName, amount)
    if not amount or amount <= 0 then return false end
    
    local success = RADB.addCryptoToRacer(racerName, amount)
    return success
end exports('addRacerCrypto', addRacerCrypto)

-- Function to remove crypto from a racer's balance
local function removeCrypto(racerName, amount)
    if not amount or amount <= 0 then return false end
    
    local currentBalance = getRacerCrypto(racerName)
    if currentBalance < amount then
        return false  -- Not enough crypto
    end
    
    local success = RADB.removeCryptoFromRacer(racerName, amount)
    return success
end exports('removeCrypto', removeCrypto)

-- Function to get all racing users by citizenid
local function getRacingUsersByCitizenId(citizenId)
    local racingUsers = RADB.getRacingUsersByCitizenId(citizenId)
    return racingUsers or {}
end  exports('getRacingUsersByCitizenId', getRacingUsersByCitizenId)

-- Function to get all racing users by citizenid
local function getRacingUsersBySrc(src)
    local citizenId = getCitizenId(tonumber(src))
    local racingUsers = RADB.getRacingUsersByCitizenId(citizenId)
    return racingUsers or {}
end  exports('getRacingUsersBySrc', getRacingUsersBySrc)

RacingCrypto = {
    getRacerCrypto = getRacerCrypto,
    addRacerCrypto = addRacerCrypto,
    hasEnoughCrypto = hasEnoughCrypto,
    removeCrypto = removeCrypto,
    getRacingUsersByCitizenId = getRacingUsersByCitizenId,
    getRacingUsersBySrc = getRacingUsersBySrc,
}
