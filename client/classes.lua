--- Returns the class of a vehicle.
-- Should only return the class as a string, ei A, B etc.
function getVehicleClass(vehicle)
    if Config.UseCustomClassSystem then
        print('^1USING CUSTOM CLASS SYSTEM. THIS NEEDS MANUAL IMPLEMENTATION. REMOVE THIS PRINT WHEN YOU HAVE DONE SO YOURSELF^0')
        return 'SOMEONE DIDNT READ THE README'
    else
        local _, class, _ = exports['cw-performance']:getVehicleInfo(vehicle)
        return class
    end
end

--- Returns a list of all vehicle classes.
-- Needs to be formatted as a table with <letter> = <number>
-- For example: { A = 100, B = 50 }
function getVehicleClasses()
    if Config.UseCustomClassSystem then
        print('^1USING CUSTOM CLASS SYSTEM. THIS NEEDS MANUAL IMPLEMENTATION. REMOVE THIS PRINT WHEN YOU HAVE DONE SO YOURSELF^0')
        return { ['SOMEONE DIDNT READ THE README'] = 100 }
    else
        return exports['cw-performance']:getPerformanceClasses()
    end
end

