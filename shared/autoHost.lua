
Config.AutoMatedRacesHostName = 'AutoMate'

Config.AutomatedRaces = {
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        laps = 2,                       -- Laps. 0 for sprint
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
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        laps = 2,                       -- Laps. 0 for sprint
        maxClass = 'B',                 -- Max Class
        ghostingEnabled = true,        -- Use Ghosting
        ghostingTime = 0,               -- Ghosting Time
        buyIn = 10,                   -- amount to participate
        ranked = true,                  -- ranked or not
        reversed = false,               -- reversed track or not
        participationMoney = 10,       -- how much players get for participating
        participationCurrency = Config.Payments.participationPayout, -- currency
        firstPerson = true             -- forced first person
    },
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        laps = 2,                       -- Laps. 0 for sprint
        maxClass = 'S',                 -- Max Class
        ghostingEnabled = true,        -- Use Ghosting
        ghostingTime = 0,               -- Ghosting Time
        buyIn = 5,                   -- amount to participate
        ranked = true,                  -- ranked or not
        reversed = false,               -- reversed track or not
        participationMoney = 5,       -- how much players get for participating
        participationCurrency = Config.Payments.participationPayout, -- currency
        firstPerson = false             -- forced first person
    },
    {
        trackId = 'CW-3232',            -- TrackId. Found in your tracks in racingapp or in DB
        laps = 2,                       -- Laps. 0 for sprint
        maxClass = 'B',                 -- Max Class
        ghostingEnabled = true,        -- Use Ghosting
        ghostingTime = 0,               -- Ghosting Time
        buyIn = 1,                   -- amount to participate
        ranked = true,                  -- ranked or not
        reversed = false,               -- reversed track or not
        participationMoney = 1,       -- how much players get for participating
        participationCurrency = Config.Payments.participationPayout, -- currency
        firstPerson = false             -- forced first person
    },
    {
        trackId = 'CW-3232',            -- TrackId. Found in your tracks in racingapp or in DB
        laps = 2,                       -- Laps. 0 for sprint
        maxClass = 'S',                 -- Max Class
        ghostingEnabled = true,        -- Use Ghosting
        ghostingTime = 0,               -- Ghosting Time
        buyIn = 10,                   -- amount to participate
        ranked = true,                  -- ranked or not
        reversed = false,               -- reversed track or not
        participationMoney = 10,       -- how much players get for participating
        participationCurrency = Config.Payments.participationPayout, -- currency
        firstPerson = false             -- forced first person
    },
    {
        trackId = 'CW-4925',            -- TrackId. Found in your tracks in racingapp or in DB
        laps = 2,                       -- Laps. 0 for sprint
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
    {
        trackId = 'CW-4925',            -- TrackId. Found in your tracks in racingapp or in DB
        laps = 2,                       -- Laps. 0 for sprint
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
    minimumParticipants = 2,      -- The least amount of participants that are needed for the race to start
    payouts = {                   -- Extra payouts from Automated Races
        participation = 1,
        winner = 2,
        perRacer = 50, -- Extra payment per racer, so if it's 50 then if 10 racers show you everyone gets 500 extra for finishing
    }
}
