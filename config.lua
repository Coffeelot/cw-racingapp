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
    ['C'] = true,
    ['B'] = true,
    ['A'] = true,
    ['S'] = true
} -- These classes can be used (notice X missing for example). Only use classes from cw-performance here. 

Config.MinRacerNameLength = 3
Config.MaxRacerNameLength = 24

Config.MinimumCheckpoints = 10 -- Minimum Checkpoints required for a race

Config.MinTireDistance = 2.0 -- Min distance between checkpoint tire piles
Config.MaxTireDistance = 30.0 -- Max distance between checkpoint tire piles

Config.MinTrackNameLength = 3 -- Min track name length to submit
Config.MaxTrackNameLength = 24 -- Max track name length to submit

Config.JoinDistance = 200

Config.AllowedJobs = {  -- Wont matter unless you activate "jobRequirement in Config.Trader/Config.Laptop"
    ['tuner'] = { basic = 2, master = 4},
    ['spongebob'] = { basic = 1 },
}

Config.Options = {
    Laps = {
        { value = 0, text = 'Sprint' },
        { value = 1, text = 1 },
        { value = 2, text = 2 },
        { value = 3, text = 3 },
        { value = 4, text = 4 },
        { value = 5, text = 5 },
        { value = 6, text = 6 },
        { value = 7, text = 7 },
        { value = 8, text = 8 },
        { value = 9, text = 9 },
        { value = 10, text = 10 },
    },
    BuyIns = {
        { value = 0, text = 'Nothing' },
        { value = 100, text = 100 },
        { value = 200, text = 200 },
        { value = 500, text = 500 },
        { value = 1000, text = 1000 },
        { value = 2000, text = 2000 },
        { value = 5000, text = 5000 },
        { value = 10000, text = 10000 }
    },
    MoneyType = 'cash'
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

Config.Ghosting = {
    Enabled = true, --adding ability to toggle per started race soon
    NearestDistanceLimit = 20, -- Distance (in meters) a racer needs to be to a non-racer for the ghosting to turn off
    Timer = 0, -- Default timer, in seconds. SET TO 0 TO HAVE ON FOR ENTIRE RACE. This is what's used if you leave the field blank when setting up a race
    DistanceLoopTime = 1000, -- in ms. Time until the ghosting script rechecks positions. Higher will be less accurate but will be more performance friendly. 
    Options = {
        { value = '', text = 'Never' },
        { value = 10, text = 10 },
        { value = 30, text = 30 },
        { value = 60, text = 60 },
        { value = 120, text = 120 },
    }
}