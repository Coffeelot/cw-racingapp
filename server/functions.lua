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

function NotifyHandler(src, message, messageType)
    messageType = messageType or 'primary'
TriggerClientEvent('cw-racingapp:client:notify', src, message, messageType)
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

-- Other functions --

-- Function to copy a table deeply
function DeepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[DeepCopy(key)] = DeepCopy(value)
        end
        setmetatable(copy, DeepCopy(getmetatable(original)))
    else
        -- Base case: non-table values
        copy = original
    end
    return copy
end

function DebugLog(message, message2, message3, message4)
    if Config.Debug then
        print('^2CW-RACINGAPP DEBUG:^0')
        print(message)
        if message2 then
            print(message2)
        end
        if message3 then
            print(message3)
        end
        if message4 then
            print(message4)
        end
    end
end