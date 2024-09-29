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

--------------
-- COMMANDS --
--------------

function registerCommand(command, description, arguments, argsrequired, callback, restricted)
    -- Register the command
    RegisterCommand(command, function(source, args, rawCommand)
        -- Call the callback function
        callback(source, args, rawCommand)
    end, restricted)
    
    -- Prepare suggestions for the command
    local suggestions = {}
    for _, arg in ipairs(arguments) do
        table.insert(suggestions, {
            name = arg.name,
            help = arg.help
        })
    end
    
    -- Register command suggestion for clients
    TriggerClientEvent('chat:addSuggestion', -1, '/' .. command, description, suggestions)
end
