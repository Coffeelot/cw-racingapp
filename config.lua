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

Config.StartAndFinishModel = `prop_golfflag`
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

Config.AllowedJobs = {  -- Wont matter unless you activate "jobRequirement in Config.Trader/Config.Laptop"
    ['tuner'] = { basic = 2, master = 4},
    ['spongebob'] = { basic = 1 },
}

Config.Trader = {
    active = true,
    jobRequirement = { basic = false, master = true},
    requireToken = false,
    model = 'csb_paige',
    animation = 'csb_paige_dual',
    location = vector4(195.48, -3167.38, 5.79, 92.36),
    moneyType = 'cash',
    racingFobCost = 2500,
    racingFobMasterCost = 10000,
}

Config.Laptop = {
    active = true,
    jobRequirement = { basic = false, master = true},
    requireToken = false,
    model = 'xm_prop_x17_laptop_lester_01',
    location = vector4(241.10, -2941.14, 6.03, -262.82),
    moneyType = 'crypto',
    racingFobCost = 25,
    racingFobMasterCost = 100,
}