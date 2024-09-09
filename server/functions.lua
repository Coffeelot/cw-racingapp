------------------------
-- CALLBACK FUNCTIONS --
------------------------

local serverCallbacks = {}

RegisterServerEvent('server:triggerServerCallback')
AddEventHandler('server:triggerServerCallback', function(name, id, ...)
    local src = source
    if serverCallbacks[name] then
        local result = {serverCallbacks[name](src, ...)}
        TriggerClientEvent('client:serverCallback', src, id, table.unpack(result))
    else
        print('Server callback not found:', name)
    end
end)

function RegisterServerCallback(name, cb)
    serverCallbacks[name] = cb
end