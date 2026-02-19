Config.Bounties = {
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'A',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 31787,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 3,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'D',                 -- Max Class
        reversed = true,               -- reversed track or not
        timeToBeat = 44000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 2,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'E',                 -- Max Class
        reversed = true,               -- reversed track or not
        timeToBeat = 48000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 2,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-7666',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'C',                 -- Max Class
        reversed = true,               -- reversed track or not
        timeToBeat = 43000,             -- time you have to beat in milliseconds
        extraTime = 1000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 3,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-3232',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'B',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 91787,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 3,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-3232',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'D',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 120000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 2,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-3232',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'E',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 140000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 4,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
    },
    {
        trackId = 'CW-4267',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'X',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 801787,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 4,                    -- Price money
        sprint = true,                  -- require race to be a sprint to claim bounty
        rankRequired = 15,                -- Rank required to claim
    },
    {
        trackId = 'CW-9030',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'A',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 130000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 4,                    -- Price money
        sprint = false,                  -- require race to be a sprint to claim bounty
        rankRequired = 2,                -- Rank required to claim

    },
    {
        trackId = 'CW-4267',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'B',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 130000,             -- time you have to beat in milliseconds
        extraTime = 5000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 5,                    -- Price money
        sprint = true,                  -- require race to be a sprint to claim bounty
        rankRequired = 2,                -- Rank required to claim

    },
    {
        trackId = 'CW-3610',            -- TrackId. Found in your tracks in racingapp or in DB
        maxClass = 'E',                 -- Max Class
        reversed = false,               -- reversed track or not
        timeToBeat = 114000,             -- time you have to beat in milliseconds
        extraTime = 1000,               -- max time (in milliseconds) that can be added ontop of timeToBeat when generated
        price = 5,                    -- Price money
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
    consecutiveMultiplier = 0.3, -- this times the price for how much players get when they beat their own time for a bounty, so if this is 0.5 you get 50% of the original bounty after the first one
}