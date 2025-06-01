Config = Config or {}
Config.Debug = false
Config.EnableCommands = false

Config.Locale = TranslationsEN -- This must match one of the variables in your locales/x.lua
Lang = function(phrase)
    if not Config.Locale then print("^1YOU MESSED UP THE TRANSLATION IMPORT") end
    return Config.Locale[phrase] or phrase
end

Config.UseResetTimer = true
Config.RaceResetTimer = 300000
Config.DoOffsetGps = true               -- Set to true if you want the gps to slighlty offset the point (helps with route)

Config.FirstBountiesGenerateStartTime = 5 * 1000 -- This is the time until the script creates bounties. Increase if you have problem with bounties being problematic.

Config.Inventory = 'ox'                 -- set to 'ox' if you want ox inventory support. Only 'ox' or 'qb' works.
Config.UseNameValidation = true         -- set to true if you use the name validation - HAVING THIS ON MEANS UNIQUE RACERNAMES
Config.MaxRacerNames = 2                -- Maximum allowed amount of unique names per character
Config.MaxCheckpoints = 60              -- This is just for the warning to show up. You can still go above it, but the script WILL crash clients if there's to many checkpoints. Test higher values at own risk.
Config.AllowCreateFromShare = true      -- toggle this to allow using the share track creation
Config.CheckDistance = true             -- If enabled, distances to checkpoints are compared for position tracking (If you got alot of racers this might affect client performance)
Config.TimeOutTimerInMinutes = 5        -- Default = 5 minutes
Config.NotifyRacers = true              -- set to true and anyone holding a racing gps will get a notification when races are hosted

Config.UseOxLibForKeybind = true       -- YOU HAVE TO ENABLE OXLIB IN FXMANIFEST TO USE THIS!!!!!!!!!!!!!!!!!!!!!!!!! Use oxlib for keybinds instead of natives.
Config.UseOxTarget = true              -- Require ox target. Obviously
Config.OxInput = false                  -- If you want Oxlib input menus Same as above with fxmanifest ^
Config.OxLibNotify = true              -- If you want Oxlib notify Same as above with fxmanifest ^

Config.LimitTopListTo = 10              -- If this is nil, the Racers Ranking will list all racers that exist, if set to a number it will limit to the top of that amount
Config.DontShowRankingsUnderZero = true -- If this is true, the top rank list will not show player with with 0 or lower ranking
Config.UseVehicleModelInsteadOfClassForRecords = false -- if this is true then players can have multiple records per class, but only once per vehicle model
Config.PositionCheatBuffer = 10.0 -- add meters to the position cheat check. This means there's some leeway before it kicks you

Config.AllowAnyoneToCreateUserInApp = true -- If True then anyone can create their own user in the app. If there are no users in the DB the user will automatically be a GOD type
Config.BasePermission = 'racer' -- this is the base user type your racingapp users can create if you allow creation in app. Should match the user you want from Config.Permissions

Config.UseCustomClassSystem = false -- If this is true then you opt in to make your own custom class system. There will be no support for this.
Config.HideMapInTablet = false -- if true then no map for players :(
Config.ShowH2H = true -- if false then dont show or allow players do to head 2 head races

Config.Sounds = {
    Countdown = {
        start = { lib = "10_SEC_WARNING", sound = "HUD_MINI_GAME_SOUNDSET" },         -- sound that plays when race is readied
        number = { lib = "Beat_Pulse_Default", sound = "GTAO_Dancing_Sounds" },       -- sound that plays when numbers show
        go = { lib = "Checkpoint_Finish", sound = "DLC_Stunt_Race_Frontend_Sounds" }, -- sound that plays when race starts
    },
    Checkpoint = { lib = "Beat_Pulse_Default", sound = "GTAO_Dancing_Sounds" },       -- sound that plays when hitting a checkpoint
    Finish = { lib = "FIRST_PLACE", sound = "HUD_MINI_GAME_SOUNDSET" }                -- sound that plays when you finish race
}                                                                                     -- sounds: https://gist.github.com/Sainan/021bd2f48f1c68d3eb002caab635b5a4

Config.EloPunishments = {                                                             -- these determine how much is removed when player leaves a ranked and started race
    leaving = -1,                                                                     -- if players leaves an ongoing race
    idling = -2,                                                                      -- if player idles and gets kicked
    positionCheat = -1,                                                               -- if player tries to start across the starting line
    cheeseing = -6                                                                    -- if player tries to cheese
}

Config.PrimaryUiColor = '#f07800' -- Primary color in UI, default is orange

-- GPS stuff
Config.IgnoreRoadsForGps = false  -- EXPERIMENTAL. Will make GPS ignore roads. DOES NOT DRAW A LINE BETWEEN LAST CHECKPOINT AND FINISH FOR LAP RACES!!!
Config.ShowGpsRoute = true        -- Default for showing GPS route
Config.UseUglyWaypoint = false    -- Use the standard gta waypoint. It will target 2 checkpoints ahead unless finish line is next.
Config.UseDrawTextWaypoint = true -- Show Drawtext pillars at the 3 upcoming checkpoints

Config.DrawTextSetup = {
    markerType = 1,                                       -- Vertical cylinder
    markerColor = { r = 255, g = 255, b = 255, a = 200 }, --Color on the pillar
    distanceColor = { r = 255, g = 255, b = 255, a = 255 }, -- Color on distance text
    primaryColor = { r = 227, g = 106, b = 0, a = 255 },  -- Color on indicator text
    minHeight = 0.5,                                      -- Height when closest
    maxHeight = 30.0,                                     -- Height furthest away
    baseSize = 0.1,                                       -- Pillar size
}

Config.CustomAmounts = { -- custom max amout of racer names
    ['PX6944'] = 100,
    ['FMN22732'] = 100,
    ['SYY99260'] = 100,
}

Config.LimitTracks = true        -- set to true to limit tracks per citizenid. Below two fields are irrelevent if this is false
Config.MaxCharacterTracks = 2    -- Amount of tracks allowed per citizenid
Config.CustomAmountsOfTracks = { -- custom max amout of tracks per citizenid
    ['PX6944'] = 100,
    ['FMN22732'] = 100,
    ['SYY99260'] = 100,
}

Config.HUDSettings = {
    location = 'split', -- Position of the Racing Hud. Values that work: 'split', 'right' or 'left'.
    maxPositions = 5,   -- this will be the max amount of racers shown in the positions list. So if set to 5, the top 5 will be shown
}

Config.ItemName = {
    gps = 'racing_gps'
}

Config.AllowRacerCreationForAnyone = true -- set to false if you don't want to allow everyone to create new users with the base permissions
-- I advice you to not change these name unless you want to start changing out code and database values.
-- If you change these and run in to issues THEN THIS IS VERY LIKELY THE REASON. But if you do. ALWAYS USE LOWERCASE FOR THE NAMES
Config.Permissions = {
    racer = {
        join = true,                -- join races
        records = true,             -- see records
        setup = true,               -- setup races
        create = false,             -- create races
        control = false,            -- control users
        controlAll = false,         -- control all users
        createCrew = false,         -- create crews
        startRanked = false,        -- can start ranked races
        startElimination = false,   -- can start elimination races
        startReversed = true,       -- can start races with reversed track (It makes NO sense that this is even needed as an auth, but it was paid for so here it is. Leave it as true)
        setupParticipation = false, -- will see an option to hand out free cash to all participants. Crypto type is same as Config.Options
        curateTracks = false,       -- Can set track curated status
        handleBounties = false,     -- Can manage bounties
        handleAutoHost = false,     -- Can handle auto host
        handleHosting = false,      -- can pause hosting
        adminMenu = false,           -- can see admin menu
        cancelAll = false,          -- Can cancel any race (that they've joined)
        startAll = false,           -- Can start any race (that they've joined)
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
        setupParticipation = false,
        curateTracks = false,
        handleBounties = false,
        handleAutoHost = false,
        handleHosting = false,
        adminMenu = false,
        cancelAll = false,
        startAll = false,
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
        setupParticipation = false,
        curateTracks = true,
        handleBounties = true,
        handleAutoHost = true,
        handleHosting = true,
        adminMenu = true,
        cancelAll = true,
        startAll = false,
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
        setupParticipation = true,
        curateTracks = true,
        handleBounties = true,
        handleAutoHost = true,
        handleHosting = true,
        adminMenu = true,
        cancelAll = true,
        startAll = true,
    }
}

Config.MarkAmountOfCheckpointsAhead = 5
Config.FlareTime = 10000                                 -- How long the flares are lit
Config.KickTime = 10 * 60 * 1000                         -- How long (in ms) until you get kicked if not being at race
Config.StartAndFinishModel = 'prop_beachflag_le'         -- comment this line out if you dont want props for start/finish line
Config.CheckpointPileModel =
'xm_prop_base_tripod_lampa'                              --good alternative: 'prop_flare_01b' - comment this line out if you dont want entities for checkpoints
Config.CheckpointBuffer = 1.0                            -- Distance (in meters) of how much outside of a checkpoints size (size is determined by the checkpoint edges) you can be to still pass it

Config.Classes = {
    ['C'] = true,
    ['B'] = true,
    ['A'] = true,
    ['S'] = true
} -- These classes can be used (notice X missing for example). Only use classes from cw-performance here.

-- Racer name limits
Config.MinRacerNameLength = 3
Config.MaxRacerNameLength = 40

-- Track Creation stuff
Config.MinimumCheckpoints = 10 -- Minimum Checkpoints required for a race
Config.MinTireDistance = 2.0   -- Min distance between checkpoint tire piles
Config.MaxTireDistance = 30.0  -- Max distance between checkpoint tire piles
Config.MinTrackNameLength = 3  -- Min track name length to submit
Config.MaxTrackNameLength = 24 -- Max track name length to submit


Config.JoinDistance = 200 -- Distance (in meters) of how close you need to be to join a race

Config.Gps = {
    color = 12,
}
Config.Blips = {
    Generic = { Size = 1.0, Color = 55 },
    Next = { Size = 1.3, Color = 47 },
    Passed = { Size = 0.6, Color = 62 }
}

-- Colors for blips: https://docs.fivem.net/docs/game-references/blips/


Config.AllowedJobs = { -- Wont matter unless you activate "jobRequirement in Config.Trader/Config.Laptop"
    ['tuner'] = { racer = 1, creator = 4, master = 5, god = 5 },
    ['spongebob'] = { racer = 1 },
}

Config.Options = {
    Laps = {
        { value = -1, text = 'Elimination' },
        { value = 0,  text = 'Sprint' },
        { value = 1,  text = 1 },
        { value = 2,  text = 2 },
        { value = 3,  text = 3 },
        { value = 4,  text = 4 },
        { value = 5,  text = 5 },
        { value = 6,  text = 6 },
        { value = 7,  text = 7 },
        { value = 8,  text = 8 },
        { value = 9,  text = 9 },
        { value = 10, text = 10 },
    },
    BuyIns = {
        { value = 0,    text = 'Nothing' },
        { value = 10,   text = 10 },
        { value = 20,   text = 20 },
        { value = 50,   text = 50 },
        { value = 100,  text = 100 },
        { value = 200,  text = 200 },
        { value = 500,  text = 500 },
        { value = 1000, text = 1000 }
    },
    participationCurrencyOptions = {
        { title= 'RAC', value= 'racingcrypto' },
        { title= 'Cash', value = 'cash' },
        { title= 'Bank', value= 'bank'}, 
    },
    conversionRate = 0.1, -- money * conversionRate = crypto amount, so if this is 0.1 and you pay $10 you get 1 Racing App Crypto.

    -- NOTE: IF ALL THE FOLLOWING 3 ARE SET TO FALSE THEN THERES NO WAY TO OPEN THE CRYPTO MENU
    allowBuyingCrypto = true, -- if false the buying option wont appear
    allowSellingCrypto = true, -- if false the selling option wont appear
    allowTransferCrypto = true, -- if false the transfering option wont appear

    sellCharge = 0.05, -- How much is lost upon selling. If 0.05 then you will lose 5% when the crypto is converted to cash
}

-- You can use any payment systems your core support (cash/money/bank). Use 'racingcrypto' to use the built in racing crypto
Config.Payments = {
    useRacingCrypto = true, -- set to false if you dont want to use the built in Racing Crypto
    cryptoType = 'RAC',  -- name of your crypto

    racing = 'racingcrypto', -- what money is used for buyins and payots in racing
    automationPayout = 'racingcrypto', -- what money is used  to payouts in automation races
    participationPayout = 'racingcrypto', -- what money the participation rewards give out
    bountyPayout = 'racingcrypto', -- what money bounties pay out
    createRacingUser = 'cash', -- what money is used to create racing users
    crypto = 'cash', -- what money type is used to buy Racing App Crypto
}

Config.Trader = {
    active = true,
    jobRequirement = { racer = false }, -- tied to Config.AllowedJobs
    requireToken = false,
    model = 'csb_paige',
    animation = 'WORLD_HUMAN_SEAT_WALL_TABLET',
    location = vector4(852.58, -1543.87, 29.12, 230.19),
    moneyType = Config.Payments.createRacingUser, -- cash/bank/crypto
    racingUserCosts = {
        racer = 1000,
        creator = 5000,
        master = 10000,
        god = 1000000
    },
    useSlimmed = true -- set to true if you want menu to cut out cid input
}

Config.Laptop = {
    active = true,                                                                -- If the laptop spawns
    jobRequirement = { racer = true, creator = true, master = true, god = true }, -- Tied to Config.AllowedJobs
    requireToken = false,                                                         -- using cw tokens?
    model = 'xm_prop_x17_laptop_mrsr',                                            -- entity model
    location = vector4(938.56, -1549.8, 34.37, 163.59),                           -- world location
    moneyType = Config.Payments.createRacingUser,                                                           -- cash/bank/crypto
    racingUserCosts = {                                                           -- cost of creating an account
        racer = 1000,
        creator = 5000,
        master = 10000,
        god = 1000000
    },
}

Config.Ghosting = {
    Enabled = true,          --adding ability to toggle per started race soon
    Timer = 60000,               -- Default timer, in milliseconds. SET TO 0 TO HAVE ON FOR ENTIRE RACE. This is what's used if you leave the field blank when setting up a race
    DistanceLoopTime = 10, -- in ms. Time until the ghosting script rechecks positions. Higher will be less accurate but will be more performance friendly.
    DeGhostDistance = 50,
    Alpha = 254, -- see https://docs.fivem.net/natives/?_0x658500AE6D723A7E for info
    Options = {
        { value = -1,       text = 'Off' },
        { value = 0,        text = 'Always' },
        { value = 10 * 1000, text = "10 s" },
        { value = 30 * 1000, text = "30 s" },
        { value = 60 * 1000, text = "60 s" },
        { value = 120 * 1000, text = "120 s" },
    }
}

Config.QuickSetupDefaults = {
    ghostingOn = true,
    ghostingTime = 0,
    buyIn = 0,
    ranked = false,
    reversed = false,
    laps = 2,
    maxClass = nil,
    participationMoney = 0,
    participationCurrency = Config.Payments.participationPayout,
    firstPerson = false,
}

-- Splits work as follows: [x] = y means position x gets y % of the profit
Config.Splits = {
    three = { [1] = 0.7, [2] = 0.3 },          -- If three racers
    more = { [1] = 0.6, [2] = 0.3, [3] = 0.1 } -- If more than 3
}

Config.ParticipationTrophies = {                                                                                    -- Different from ParticipationAmounts. These are automated
    requireCurated = true,                                                                                          -- Only give out Participation money if track is marked as curated (admin command '/racingappcurated "<race-id>" true/false')
    requireRanked = true,                                                                                           -- Only give out Participation money if track is marked as curated (admin command '/racingappcurated "<race-id>" true/false')
    requireBuyIns = true,                                                                                           -- If this is true, participation money will only be handed out if the race had a buyin
    buyInMinimum = 200,                                                                                             -- If the above is true, this will be the minimum limit of when participation money is handed out
    enabled = true,                                                                                                 -- false if you dont want players getting Participation trophies
    minimumOfRacers = 6,                                                                                            -- minimum of racers to hand out Participation trophies
    amount = { [1] = 15, [2] = 10, [3] = 10, [4] = 10, [5] = 10, [6] = 10, [7] = 10, [8] = 10, [9] = 10, [10] = 10 }, -- [<position>] = <amount>
    minumumRaceLength = 3000
}

Config.ParticipationAmounts = {                          -- Different from ParticipationTrophies. These are manual
    positionBonuses = { [1] = 0.3, [2] = 0.2, [3] = 0.1 } -- in percentages. example: 0.3 = 30% extra ontop. Set this to empty "{}" if you dont want these
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

Config.AutoMatedRacesHostName = 'AutoMate'

Config.AutomatedRaces = {
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        laps = 2,                       -- Laps. 0 for sprint
        racerName = 'AutoMate',         -- Name on the Automation
        maxClass = 'A',                 -- Max Class
        ghostingEnabled = true,        -- Use Ghosting
        ghostingTime = 0,               -- Ghosting Time
        buyIn = 1,                   -- amount to participate
        ranked = true,                  -- ranked or not
        reversed = false,               -- reversed track or not
        participationMoney = 1,       -- how much players get for participating
        participationCurrency = Config.Payments.participationPayout, -- currency
        firstPerson = false             -- forced first person
    },
}

Config.AutomatedOptions = {
    timeBetweenRaces = 2 * 60 * 1000, -- Default = every 20 minutes - change 20 to whateer minutes you wanna use or go look up minutes to milliseconds and learn something
    minimumParticipants = 1,      -- The least amount of participants that are needed for the race to start
    payouts = {                   -- Extra payouts from Automated Races
        participation = 500,
        winner = 1000,
        perRacer = 50, -- Extra payment per racer, so if it's 50 then if 10 racers show you everyone gets 500 extra for finishing
    }
}

Config.Bounties = {
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'A',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 31787,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 300,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'D',                 -- Max Class
        reversed = true,               -- reversed track or not
        timeToBeat = 49000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 200,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'C',                 -- Max Class
        reversed = true,               -- reversed track or not
        timeToBeat = 43000,             -- time you have to beat in milliseconds
        extraTime = 1000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 300,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-3232',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'B',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 91787,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 300,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-3232',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'D',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 240000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 400,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-4267',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'X',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 801787,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 1000,                    -- Price money
        sprint = true,                  -- require race to be a sprint to claim bounty
        rankRequired = 15,                -- Rank required to claim
    },
    {
        trackId = 'CW-9030',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'A',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 130000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 500,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
        rankRequired = 2,                -- Rank required to claim

    },
    {
        trackId = 'CW-4267',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'B',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 130000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 500,                    -- Price money
        sprint = true,                  -- require race to be a sprint to claim bounty
        rankRequired = 2,                -- Rank required to claim

    },
    {
        trackId = 'CW-3610',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'E',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 114000,             -- time you have to beat in milliseconds
        extraTime = 1000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 500,                    -- Price money
        sprint = true,                  -- require race to be a sprint to claim bounty
        rankRequired = 0,                -- Rank required to claim

    },
    -- {
    --     trackId = 'LR-9238',            -- TrackId. Found in your tracks in racingapp or in DB
    --     maxClass = 'S',                 -- Max Class
    --     reversed = false,               -- reversed track or not
    --     timeToBeat = 801787,             -- time you have to beat in milliseconds
    --     extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
    --     price = 500,                    -- Price money
    --     sprint = true,                  -- require race to be a sprint to claim bounty
    --     rankRequired = 5,                -- Rank required to claim
    -- },
}

Config.BountiesOptions = {
    defaultRankRequirement = 0, -- Default rank requirement to see and claim bounties. Can be overrided by assigning a rankRequired in the bounty.
    maxAmount = 6, -- Max amount of bounties that can be generated
    minAmount = 2, -- min amount of bounties that can be generated
    allowMultipleOnSameTrack = true, -- if set to false, only allow one bounty per track
    allowMultipleInSameClass = true, -- if set to false, only allow one per class
    consecutiveMultiplier = 0.5, -- this times the price for how much players get when they beat their own time for a bounty, so if this is 0.5 you get 50% of the original bounty after the first one
}