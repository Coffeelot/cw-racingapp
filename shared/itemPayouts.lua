-- ============================================================================
-- ITEM PAYOUT SYSTEM
-- ============================================================================
-- Define named sets of items that can be awarded to racers at the end of a race.
-- Each set is a named table containing a list of items with weighted random selection.
--
-- USAGE: When setting up a race, include `itemPayoutData` in the setup:
--   itemPayoutData = { itemList = 'low', payoutStyle = 'topThree' }
--
-- This will randomly pick one item from the 'low' list and give it to
-- the top 3 finishers (based on the 'topThree' payout style).
-- ============================================================================

-- Item Lists
-- Each named list contains items that can be randomly awarded.
-- Fields per item:
--   name     (string)         - Item name/id (must match your inventory item registry, e.g. ox_inventory items)
--   amount   (table, optional) - { min, max } range for random amount. Defaults to { 1, 1 } if omitted.
--   weight   (number)         - Selection weight (higher = more likely). Does not need to sum to 100.
--   metadata (table, optional) - Metadata to attach to the item when given (e.g. { quality = 'rare' })
Config.ItemPayouts = {
    enabled = false, -- Master toggle for the entire item payout system. Set to false to disable all item payouts.

    lists = {
        ['low'] = {
            { name = 'water',         weight = 50 },
            { name = 'lockpick',      weight = 15, amount = { 1, 2 } },
            { name = 'repairkit',     weight = 5 },
        },
        ['long_race'] = {
            { name = 'repairkit',     weight = 40 },
            { name = 'lockpick',      weight = 20, amount = { 1, 2 } },
            { name = 'screwdriver',   weight = 10 },
            { name = 'mustard',       weight = 5,  amount = { 1, 1 }, metadata = { description = 'Custom Mustard' } },
        },
        -- Add your own lists here following the same pattern
    },

    -- Payout Styles
    -- Determines WHICH finishing positions receive an item payout.
    -- Built-in styles: 'all', 'topThree', 'onlyOne'
    -- 'custom' allows you to define an explicit list of positions.
    styles = {
        ['all'] = {
            type = 'all', -- Everyone who finishes and receives payouts
        },
        ['topThree'] = {
            type = 'positions',
            positions = { 1, 2, 3 },
        },
        ['onlyOne'] = {
            type = 'positions',
            positions = { 1 },
        },
        ['custom'] = {
            type = 'positions',
            positions = { 1, 2, 3, 4, 5 }, -- Customize this list as needed
        },
        -- Add your own styles here following the same pattern
    },

    -- Default Item Payout
    -- If set, this applies to ALL races automatically unless overridden by a race-specific itemPayoutData.
    -- Set to nil/false to disable default item payouts.
    default = {
        itemList = 'low',              -- Which item list to use (key from lists above)
        payoutStyle = 'topThree',      -- Which payout style to use (key from styles above)
        minimumRaceLength = 3000,      -- Minimum total race distance in meters (track distance * laps for circuit races)
                                       -- Set to 0 to disable the distance check
    },
}

if Config.Debug then print("item payouts is enabled:", Config.ItemPayouts.enabled) end