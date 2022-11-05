Config = Config or {}
Config.Debug = false

Config.Permissions = {
    ['fob_racing_basic'] = {
        ['join'] = true,
        ['records'] = true,
        ['setup'] = true,
        ['create'] = false,
    },
    ['fob_racing_master'] = {
        ['join'] = true,
        ['records'] = true,
        ['setup'] = true,
        ['create'] = true,
    }
}

Config.FlareTime = 10000 -- How long the flares are lit

Config.StartAndFinishModel = `xm_prop_base_tripod_lampa`
Config.CheckpointPileModel = `xm_prop_base_tripod_lampa` --`prop_flare_01b`
Config.Classes = {
    ['D'] = true,
    ['C'] = true,
    ['B'] = true,
    ['A'] = true,
    ['S'] = true
}

Config.MinRacerNameLength = 3
Config.MaxRacerNameLength = 24

Config.MinimumCheckpoints = 10 -- Minimum Checkpoints required for a race

Config.MinTireDistance = 2.0 -- Min distance between checkpoint tire piles
Config.MaxTireDistance = 30.0 -- Max distance between checkpoint tire piles

Config.MinTrackNameLength = 3 -- Min track name length to submit
Config.MaxTrackNameLength = 24 -- Max track name length to submit