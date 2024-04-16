Config = Config or {}
Config.Debug = false

Config.UseResetTimer = true 
Config.RaceResetTimer = 300000
Config.ShowMechToolOption = true -- set to false if you dont use cw-mechtool
Config.DoOffsetGps = true -- Set to true if you want the gps to slighlty offset the point (helps with route)
Config.Inventory = 'qb' -- set to 'ox' if you want ox inventory support. Only 'ox' or 'qb' works.
Config.UseRenewedCrypto = false -- set to true if you use Renewed crypto
Config.UseRenewedBanking = false -- set this to true if you use Renewed Banking
Config.UseNameValidation = true -- set to true if you use the name validation - HAVING THIS ON MEANS UNIQUE RACERNAMES
Config.MaxRacerNames = 2 -- Maximum allowed amount of unique names per character
Config.MaxCheckpoints = 60 -- This is just for the warning to show up. You can still go above it, but the script WILL crash clients if there's to many checkpoints. Test higher values at own risk.
Config.AllowCreateFromShare = true -- toggle this to allow using the share track creation
Config.CheckDistance = true -- If enabled, distances to checkpoints are compared for position tracking (If you got alot of racers this might affect client performance)
Config.UseOxLibForKeybind = false -- YOU HAVE TO ENABLE OXLIB IN FXMANIFEST TO USE THIS!!!!!!!!!!!!!!!!!!!!!!!!! Use oxlib for keybinds instead of natives.
Config.TimeOutTimerInMinutes = 5 -- Default = 5 minutes
Config.NotifyRacers = true -- set to true and anyone holding a racing gps will get a notification when races are hosted

Config.OxInput = false -- If you want Oxlib input menus Same as above with fxmanifest ^ 
Config.LimitTopListTo = 10 -- If this is nil, the Racers Ranking will list all racers that exist, if set to a number it will limit to the top of that amount
Config.DontShowRankingsUnderZero = true -- If this is true, the top rank list will not show player with with 0 or lower ranking

Config.Sounds = {
    Countdown = {
        start = { lib = "10_SEC_WARNING", sound = "HUD_MINI_GAME_SOUNDSET" }, -- sound that plays when race is readied
        number = { lib = "Beat_Pulse_Default", sound = "GTAO_Dancing_Sounds" }, -- sound that plays when numbers show
        go = { lib = "Checkpoint_Finish", sound = "DLC_Stunt_Race_Frontend_Sounds" }, -- sound that plays when race starts
    },
    Checkpoint = { lib = "Beat_Pulse_Default", sound = "GTAO_Dancing_Sounds" }, -- sound that plays when hitting a checkpoint
    Finish = { lib = "FIRST_PLACE", sound = "HUD_MINI_GAME_SOUNDSET" } -- sound that plays when you finish race
} -- sounds: https://gist.github.com/Sainan/021bd2f48f1c68d3eb002caab635b5a4

Config.EloPunishments = { -- these determine how much is removed when player leaves a ranked and started race
    leaving = -1, -- if players leaves an ongoing race
    idling = -2, -- if player idles and gets kicked
    positionCheat = -1, -- if player tries to start across the starting line
    cheeseing = -6 -- if player tries to cheese
}

-- GPS stuff
Config.IgnoreRoadsForGps = false -- EXPERIMENTAL. Will make GPS ignore roads. DOES NOT DRAW A LINE BETWEEN LAST CHECKPOINT AND FINISH FOR LAP RACES!!!
Config.ShowGpsRoute = true -- Default for showing GPS route
Config.UseUglyWaypoint = false -- Use the standard gta waypoint. It will target 2 checkpoints ahead unless finish line is next.

Config.CustomAmounts = { -- custom max amout of racer names
    ['QBQ16539'] = 100,
    ['FMN22732'] = 100,
    ['SYY99260'] = 100,
}

Config.LimitTracks = true -- set to true to limit tracks per citizenid. Below two fields are irrelevent if this is false
Config.MaxCharacterTracks = 2 -- Amount of tracks allowed per citizenid
Config.CustomAmountsOfTracks = { -- custom max amout of tracks per citizenid
    ['QBQ16539'] = 100,
    ['FMN22732'] = 100,
    ['SYY99260'] = 100,
}

Config.HUDSettings = { 
    location = 'split', -- Position of the Racing Hud. Values that work: 'split', 'right' or 'left'.
    maxPositions = 5, -- this will be the max amount of racers shown in the positions list. So if set to 5, the top 5 will be shown
}

Config.ItemName = {
    gps = 'racing_gps'
}

Config.AllowRacerCreationForAnyone = true -- set to false if you don't want to allow everyone to create new users with the base permissions
-- I advice you to not change these name unless you want to start changing out code and database values.
-- If you change these and run in to issues THEN THIS IS VERY LIKELY THE REASON. But if you do. ALWAYS USE LOWERCASE FOR THE NAMES
Config.Permissions = {
    racer = { 
        join = true, -- join races
        records = true, -- see records
        setup = true, -- setup races
        create = false, -- create races
        control = false, -- control users
        controlAll = false, -- control all users
        createCrew = false, -- create crews
        startRanked = false, -- can start ranked races
        startElimination = false, -- can start elimination races
        startReversed = true, -- can start races with reversed track (It makes NO sense that this is even needed as an auth, but it was paid for so here it is. Leave it as true)
        setupParticipation = false -- will see an option to hand out free cash to all participants. Crypto type is same as Config.Options
    },
    creator = {
        join = true,
        records = true,
        setup = true,
        create = true,
        control = false,
        controlAll = false,
        createCrew = false,
        startRanked = false, 
        startElimination = false,
        startReversed = true,
        setupParticipation = false 
    },
    master = {
        join = true,
        records = true,
        setup = true,
        create = true,
        control = true,
        controlAll = false,
        createCrew = true,
        startRanked = true,
        startElimination = true,
        startReversed = true,
        setupParticipation = false 
    },
    god = {
        join = true,
        records = true,
        setup = true,
        create = true,
        control = true,
        controlAll = true,
        createCrew = true,
        startRanked = true,
        startElimination = true,
        startReversed = true,
        setupParticipation = true 
    }
}

Config.FlareTime = 10000 -- How long the flares are lit
Config.KickTime = 10*60*1000 -- How long (in ms) until you get kicked if not being at race
Config.StartAndFinishModel = `prop_beachflag_le` -- comment this line out if you dont want props for start/finish line
Config.CheckpointPileModel = `xm_prop_base_tripod_lampa` --good alternative: `prop_flare_01b` - comment this line out if you dont want entities for checkpoints

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

Config.Blips = {
    Generic = { Size = 1.0, Color = 55 },
    Next = { Size = 1.3, Color = 47 },
    Passed = { Size = 0.6, Color = 62 }
}

-- Colors for blips: https://docs.fivem.net/docs/game-references/blips/


Config.AllowedJobs = {  -- Wont matter unless you activate "jobRequirement in Config.Trader/Config.Laptop"
    ['tuner'] = { racer = 1, creator = 4, master = 5, god = 5},
    ['spongebob'] = { racer = 1 },
}

Config.Options = {
    Laps = {
        { value = -1, text = 'Elimination' },
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
        { value = 10, text = 10 },
        { value = 20, text = 20 },
        { value = 50, text = 50 },
        { value = 100, text = 100 },
        { value = 200, text = 200 },
        { value = 500, text = 500 },
        { value = 1000, text = 1000 }
    },
    MoneyType = 'crypto', --Determines buyins and payouts. cash/bank/crypto
    cryptoType = 'cdc' -- rname of your crypto
}

Config.Trader = {
    active = true,
    jobRequirement = { racer = false }, -- tied to Config.AllowedJobs
    requireToken = false,
    model = 'csb_paige',
    animation = 'WORLD_HUMAN_SEAT_WALL_TABLET',
    location = vector4(852.58, -1543.87, 29.12, 230.19),
    moneyType = 'cash', -- cash/bank/crypto
    -- cryptoType = 'cdc', -- name of your crypto
    racingUserCosts = {
        racer = 1000,
        creator = 5000,
        master = 10000,
        god = 1000000
    },
    -- profiteer = { job = 'tuner', cut = 0.01 }, -- if you use Renewed Banking you can set this to allow money to go to businesses, wont work with crypto (yet), UseRenewedBanking in top of this file NEEDS TO BE TRUE
    useSlimmed = true -- set to true if you want menu to cut out cid input
}

Config.Laptop = {
    active = true, -- If the laptop spawns
    jobRequirement = { racer = true, creator = true, master = true, god = true }, -- Tied to Config.AllowedJobs
    requireToken = false, -- using cw tokens?
    model = 'xm_prop_x17_laptop_mrsr', -- entity model
    location = vector4(938.56, -1549.8, 34.37, 163.59), -- world location
    moneyType = 'crypto', -- cash/bank/crypto
    cryptoType = 'cdc', -- name of your crypto
    racingUserCosts = { -- cost of creating an account
        racer = 1000,
        creator = 5000,
        master = 10000,
        god = 1000000
    },
}

Config.Ghosting = {
    Enabled = true, --adding ability to toggle per started race soon
    NearestDistanceLimit = 20, -- Distance (in meters) a racer needs to be to a non-racer for the ghosting to turn off
    Timer = 0, -- Default timer, in milliseconds. SET TO 0 TO HAVE ON FOR ENTIRE RACE. This is what's used if you leave the field blank when setting up a race
    DistanceLoopTime = 1000, -- in ms. Time until the ghosting script rechecks positions. Higher will be less accurate but will be more performance friendly.
    Options = {
        { value = -1, text = 'Off' },
        { value = 0, text = 'Always' },
        { value = 10*1000, text = "10 s" },
        { value = 30*1000, text = "30 s" },
        { value = 60*1000, text = "60 s" },
        { value = 120*1000, text = "120 s" },
    }
}

-- Splits work as follows: [x] = y means position x gets y % of the profit
Config.Splits = {
    three = { [1] = 0.7, [2] = 0.3 }, -- If three racers
    more = { [1] = 0.6, [2] = 0.3, [3] = 0.1 } -- If more than 3
}

Config.ParticipationTrophies = { -- Different from ParticipationAmounts. These are automated
    requireCurated = true, -- Only give out Participation money if track is marked as curated (admin command '/racingappcurated "<race-id>" true/false')
    requireRanked = true, -- Only give out Participation money if track is marked as curated (admin command '/racingappcurated "<race-id>" true/false')
    requireBuyIns = true, -- If this is true, participation money will only be handed out if the race had a buyin
    buyInMinimum = 200, -- If the above is true, this will be the minimum limit of when participation money is handed out
    enabled = true, -- false if you dont want players getting Participation trophies
    minimumOfRacers = 6, -- minimum of racers to hand out Participation trophies
    type = 'crypto', -- cash, bank or crypto
    amount = { [1] = 15, [2] = 10, [3] = 10, [4] = 10,  [5] = 10, [6] = 10, [7] = 10,[8] = 10,[9] = 10,[10] = 10 }, -- [<position>] = <amount>
    cryptoType = 'cdc', -- name of your crypto
    minumumRaceLength = 3000
}

Config.ParticipationAmounts = { -- Different from ParticipationTrophies. These are manual
    positionBonuses = { [1] = 0.3, [2] = 0.2, [3] = 0.1} -- in percentages. example: 0.3 = 30% extra ontop. Set this to empty "{}" if you dont want these 
}

Config.Buttons = {
    AddCheckpoint = 'INSERT',
    DeleteCheckpoint = 'DELETE',
    MoveCheckpoint = 'HOME',
    SaveRace = '0',
    IncreaseDistance = 'PAGEUP',
    DecreaseDistance = 'PAGEDOWN',
    Exit = '9'
}

Config.AutomatedRaces = {
    {
        trackId = 'LR-7666', -- TrackId. Found in your tracks in racingapp or in DB
        laps = 2, -- Laps. 0 for sprint
        racerName = 'AutoMate', -- Name on the Automation
        maxClass = 'A', -- Max Class
        ghostingEnabled = false, -- Use Ghosting
        ghostingTime = 0, -- Ghosting Time
        buyIn = 2000, -- amount to participate
    },
    -- {
    --     trackId = 'LR-1575',
    --     laps = 2,
    --     racerName = 'AutoMate',
    --     maxClass = 'A',
    --     ghostingEnabled = false,
    --     ghostingTime = 0,
    --     buyIn = 2000,
    -- }
}

Config.AutomatedOptions = {
    timeBetweenRaces = 2*60*1000, -- Default = every 20 minutes - change 20 to whateer minutes you wanna use or go look up minutes to milliseconds and learn something
    minimumParticipants = 1, -- The least amount of participants that are needed for the race to start
    payouts = { -- Extra payouts from Automated Races
        participation = 500,
        winner = 1000,
        perRacer = 50, -- Extra payment per racer, so if it's 50 then if 10 racers show you everyone gets 500 extra for finishing
    }
}
