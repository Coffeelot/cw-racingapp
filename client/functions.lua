------------------------
-- CALLBACK FUNCTIONS --
------------------------

cwCallback = {}
local callbackId = 0
local callbacks = {}

function cwCallback.await(name, ...)
    local p = promise.new()

    local id = callbackId
    callbackId = callbackId + 1

    callbacks[id] = p

    TriggerServerEvent('server:triggerServerCallback', name, id, ...)

    return Citizen.Await(p)[1]
end

RegisterNetEvent('client:serverCallback')
AddEventHandler('client:serverCallback', function(id, ...)
    if callbacks[id] then
        callbacks[id]:resolve({ ... })
        callbacks[id] = nil
    end
end)

function strictSanitize(input)
    if type(input) ~= "string" then
        return input
    end

    -- Remove leading/trailing spaces and collapse multiple spaces into single spaces
    input = input:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")

    -- Keep only allowed characters
    input = input:gsub("[^%w%s%-_]", "")

    return input
end