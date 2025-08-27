### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐

📷 [Images & Video](#Preview) 📺

## If you are updating make sure to check [Updating](#updating) for relevant SQL updates

## NOW SUPPORTS QB, QBOX, OX AND ESX!
> Note: ESX requires ox_lib and ox_target

> Note: For ESX make sure to change out moneyTypes to corresponding versions in the config (ESX uses "money" instead of "cash" for example)

**Features:**
- [Create tracks](#track-creation)
- Host races
- Buy-Ins
- [Automated Races](#Automated-Races)
- [Time Trial Bounties](#Time-Trial-Bounties)
- Built in Crypto system
- Buy-Ins and automated splits
- Phasing/Ghosting
- Reversed tracks
- Participation payouts
- Elmination races
- [Racing user system with customizeable auth](#user-management)
- ELO system for ranked racing
- Crew system with rankings
- Elmination Races
- Advanced leaderboards
- [Customizeable checkpoints](#gps-settings)
- Race positions
- [Curated tracks](#track-curation) (mark tracks as verified good)
- Split times
- Translateable
- [Track Sharing](#track-sharing)
- Optional default tracks
- Forced first person mode
- Vehicle Performance Class limits
- Support for Renewed Crypto

> 5.0 was released on 27th Aug, 2025. It's HIGHLY encouraged to do a clean install for this version.

> Do note, this script has TWO systems for participation money. Make sure to check the readme and read the comments regarding these and how to use them.

# Links
### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐


### [More free scripts](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈

### Support, updates and script previews:

### <a href="https://discord.gg/FJY4mtjaKr">CW DISCORD</a>


### If you want to support what we do, you can buy us a coffee here:

[![Buy Us a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/cwscriptbois )

# Racing App

### GPS settings
At the bottom left corner there's a cog wheel. Clicking this brings up the options menu (more stuff to come). But here you can toggle using the GPS route and the style of it.

### Track Curation
Our idea with this feature is to allow admins to flag a track as "DONE". The track can no longer be edited. Additional features of curated tracks might be only allowing participation money to be paid out on those tracks, for example.

### Track Creation
The key to this script working is making tracks that works well. If you're trying to do 200 checkpoint style races with checkpoints randomly thrown around the map, this is not the script for you. There is a max checkpoint variable in the config that will warn users when they reached the level. Some PCs might struggle with different lower/higher amounts tho, so keep that in mind.

- Avoid placing checkpoints on/under/near bridges/overpasses. 
- GTA GPS can't handle opposite-directions on roads: Place checkpoints on the correct side of the road
- Intersections can be tricky for the GPS. We advice to not put checkpoints in the middle of them, but before or after, in the correct lane.
- Alleys can cause issues. Use with caution.
- The script spawns 2 entities + 1 emitter for EVERY checkpoint. If you have 100 checkpoints that might just crash peoples games. 

### Track Sharing
You can grab the checkpoints from either My Tracks tab in game, by using the copy button or directly from the database entry and then pasting to something like https://pastebin.com/
There's an import function (if enabled in config) in the Create Track tab to import via paste.

Hop into the [CW Discord](https://discord.gg/FJY4mtjaKr) and share some tracks in the racingapp-tracks channel! 

### Automated Races
The script offers automated races. You can set these up in the config (`Config.AutomatedRaces`, `Config.AutomatedOptions`). If any of these are commented out/removed the automation will not start.

The Automation will, at random, try to grab one of the tracks from the `Config.AutomatedRaces` table at the interval of what you set in `Config.AutomatedOptions.timeBetweenRaces`, by default this is 20 minutes. The races start after 5 minutes of popping up.

### Time Trial Bounties
As of 16th November 2024 the script has cuztomizeable time trial bounties that players can collect. These are defined in the config in `Config.Bounties` and `Config.BountiesOptiones`. The config has most things explained in comments, but a bounty is defined like this example:
```lua
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
```
These are randomized upon server start (~5 seconds after script start/restart). You can modify how many of these are added in the Bounties Options. If your auth type has the `handleBounties` auth you should be able to re-roll the bounties from the bounties menu.

### RacingApp Crypto [RAC]
RacingApp has a built in crypto system tied to the racing user. To use this you can set your payment methods to `'racingcrypto'` and it will use the custom Racing Crypto System instead of your core payment system. The crypto is tied to a racinguser, so make sure you have a way to buy one of those with normal money if you don't want to have racing masters handle your users. 

The system allows for buying, selling and transfering. There's a fee for selling (can be customized).

Want to use the Racing Crypto from other script? Check out [Adding Racing Crypto To Other Scripts](#Adding-Racing-Crypto-To-Other-Scripts)



### User Management
The script offers user management now. We've moved away from the basic/master fob and instead users are saved in the database.
To swap your user, open the racingapp and press the cog-icon to open the settings.
To create users you can either buy a user account from a trader/laptop (if this is enabled in the config) or have someone create one for you.

The tiers are racer < creator < master < god and are defined as follows:
```lua
    racer = { 
        join = true, -- join races
        records = true, -- see records
        setup = true, -- setup races
        create = false, -- create races
        control = false, -- control users
        controlAll = false, -- control all users
    }
    ...
```

*join* means you can join races\
*records* means you can access records\
*setup* means you can set up races\
*create* means you can create tracks\
*control* means you can manage users you create\
*controllAll* allows you to control all users, and also permanently delete users

Basically, any racer name/user created by another player will be tied to them. So if person X buys an account from player Y, player Y can also revoke player Xs account via the in game menus, as long as player Y has a user with the *control* authorization.

## Opening the racing app
### Using the Racing GPS
The easiest way. Just use the Racing GPS that's included in the script.
### Exports 
If you want to open racingapp from another script you can use the exports

Client side:
```lua
    exports['cw-racingapp']:openRacingApp()
```
Server side:
```lua
    exports['cw-racingapp']:openRacingApp(source)
```

## Adding Racing Crypto To Other Scripts
> ALL EXPORTS ARE SERVER SIDE ONLY!
### Get Crypto

You'll need to know the name of the race user you want to check for here. Swap out 'RacerName' for whatever name you want to use
```lua
    local racerName = 'This Is Just An Example String You Have To Change This'

    local cryptoAmount = exports['cw-racingapp']:getRacerCrypto(racerName)
    print(racerName, 'has ', cryptoAmount)
```

### Check if user has enough
```lua
    local racerName = 'This Is Just An Example String You Have To Change This'

    local hasEnough = exports['cw-racingapp']:hasEnoughCrypto(racerName, 20)
    print(racerName, 'has 20 or more crypto:', hasEnough )
```

### Add crypto
```lua
    local racerName = 'This Is Just An Example String You Have To Change This'

    local success = exports['cw-racingapp']:addRacerCrypto(racerName, 20)
    print('successfully gave', racerName, ' 20 crypto: ', success)
```

### Remove crypto
```lua
    local racerName = 'This Is Just An Example String You Have To Change This'

    local success = exports['cw-racingapp']:removeCrypto(racerName, 20)
    print('successfully charged', racerName, ' 20 crypto: ', success)
```

### Get all racing users for a player by citizenId
This one is usefull if you want to get all users for a player so you can list them in other scripts

```lua
    -- With CitizenID
    local citizenId = 'ThisIsJustAnExampleStringYouHaveToChangeThis123'

    local result = exports['cw-racingapp']:getRacingUsersByCitizenId(citizenId)
    print('All racing users belonging to citizenid', citizenId, json.encode(result, {indent=true}) )
```

```lua
    -- with Source
    -- OBVIOUSLY YOU NEED TO HAVE A DEFINED SOURCE IN THIS ONE!!

    local result = exports['cw-racingapp']:getRacingUsersBySrc(source)
    print('All racing users belonging to source', source, json.encode(result, {indent=true}) )
```

# Preview

## Latest video

> OLD UI:

[![YOUTUBE VIDEO](http://img.youtube.com/vi/nRuM03co7Mk/0.jpg)](https://youtu.be/nRuM03co7Mk)

<details>
  <summary>Older Videos</summary>
  
### Might not represent current looks/design/features
### Note: Before new UI was added

[![YOUTUBE VIDEO](http://img.youtube.com/vi/APtMydz4gF8/0.jpg)](https://youtu.be/APtMydz4gF8)

Update to track editor:
### Note: Before new UI was added

[![YOUTUBE VIDEO](http://img.youtube.com/vi/N_HI0jAsgbg/0.jpg)](https://youtu.be/N_HI0jAsgbg)

### UI Update:

[![YOUTUBE VIDEO](http://img.youtube.com/vi/j0KKvy-2VWc/0.jpg)](https://youtu.be/j0KKvy-2VWc)

### User Management Update:

[![YOUTUBE VIDEO](http://img.youtube.com/vi/YzJjRs2rv2s/0.jpg)](https://youtu.be/YzJjRs2rv2s)

### UI update 2:

[![YOUTUBE VIDEO](http://img.youtube.com/vi/ZAUrmS63ZaM/0.jpg)](https://youtu.be/ZAUrmS63ZaM)

### Ranked, ELO and Crew systems
[![YOUTUBE VIDEO](http://img.youtube.com/vi/gyt_EqFqfds/0.jpg)](https://youtu.be/gyt_EqFqfds)

### Latest UI rework + translations 

[![YOUTUBE VIDEO](http://img.youtube.com/vi/8Vkj0o8VvCY/0.jpg)](https://youtu.be/8Vkj0o8VvCY)

</details>

<details>
<summary>Images</summary>

**Dashboard**

![Dashboard](https://i.imgur.com/PitA9ts.png)

**Map**

![Dashboard](https://i.imgur.com/c9eoqUz.png)

**Track Setup**

![Track Selection](https://i.imgur.com/2VWfpD5.png)
![Track Setup](https://i.imgur.com/ap2P6R2.png)


**Bounties**

![Bounties](https://i.imgur.com/VwEbeoc.png)

**Leaderboards**

![Interface](https://i.imgur.com/ea3Wvbm.png)
![Interface](https://i.imgur.com/NxXGfGu.png)
![Interface](https://i.imgur.com/v9Dpaaq.png)

**Track Creation**

You can create tracks from both using an in-game editor or copy/paste a set of checkpoints.

**Manage Tracks**

![Tracks menu](https://i.imgur.com/XhpqpYy.png)

![Interface](https://i.imgur.com/6ugenRV.png)

**Settings**

![Settings](https://i.imgur.com/TnRFxg7.png)

**Admin Menu**

![Settings](https://i.imgur.com/sQpkfSn.png)

**Crypto Menu**

![Settings](hhttps://i.imgur.com/P2uNEwp.png)


</details>

# Setup and Installation

### Installation
1. Get [cw-performance](https://github.com/Coffeelot/cw-performance) and install (if you plan to code your own class system see [Custom Vehicle Classes](#custom-vehicle-classes))
2. Download Racingapp
3. Add the cw-racingapp folder to you resources (if it has a "-main" in the name: remove the "-main")
4. Update or insert the database tables. These are found in the `cw-racingapp.sql` and `cw-racingcrews.sql` files
    - Optionally also run `default_tracks.sql` if you want to add the default tracks
5. Adjust values in the `config.lua` file to your liking **(Hot tip: GO OVER THIS FILE BEFORE REPORTING ISSUES)**
6. Add the item to your `qb-core/shared/items.lua` (If you use another inventory/core you obviously might need to change this part)
```lua
['racing_gps'] = {['name'] = 'racing_gps', ['label'] = 'Racing GPS', ['weight'] = 500, ['type'] = 'item', ['image'] = 'racing_gps.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['description'] = 'Wroom wroom.'},
```
7. Add the item image to your inventory image folder
8. If you're not using QBOX then comment out `'@qbx_core/modules/playerdata.lua'` in fxmanifest 
9. Open the game and give yourself the item. When you open the app for the first time you'll be prompted to create a user. The first user to be created will be a `god` user, after that the rest will be `racer` type of whatever you set it to in the config. Optionally you can create a god user with the command (see below)



### Setup Notes
> [cw-performance](https://github.com/Coffeelot/cw-performance) is required unless you know how to code your own class system.

### Custom Vehicle Classes
So, you want to make your own class system? Well, good luck. 

1. You can find the functions in `client/classes.lua`. You will need to code the functionality yourself.
2. To use these, set `Config.UseCustomClassSystem` to `true` in the Config. 
3. Remove `'cw-performance'` from the dependancies in `fxmanifest.lua`

The file should be left fairly untouched in the future so for any future updates it will be easy for you to check if the file had any changes.


>  Support on this feature will be limited - if you require help to set your system up then expect to do so via a comission

### Use in game
Use the command `createracinguser` to do this. For example:
`/createracinguser god 1 IReadTheReadme`
This will create a god account for the user with serverID 1 (probably you if you're on your dev server) called IReadTheReadme. 
Spawn the item `racing_gps` normally and use it. 
> Some users have reported this not working and throwing an error. It seems this is related to Core issues. The order of the input might differ for some cores for some reason. The server side printout should help you determine the order. Just type it in according to that instead.

# Exports
RacingApp does not come with a phone app, but maybe you want to create one! Now, including everything from racingapp would be insanity, but at least you can join, leave and setup race via exports now! So you can create your own Phone App an just use these exports to get some of the basic features out of Racingapp.

## Get tracks
This will get all the existing tracks for you to display
```lua
    local tracks = exports['cw-racingapp']:getAvailableTracks()
    print(json.encode(tracks, {indent=true})) -- This will be the data returned. Do what you will with it
```

## Get posted races
This will get all the posted races for you to display
```lua
    local races = exports['cw-racingapp']:getAvailableRaces()
    print(json.encode(races, {indent=true})) -- This will be the data returned. Do what you will with it
```


## Joining a race
```lua
local success = exports['cw-racingapp']:joinRace(raceId)
```
Where `raceId` is replaced by the id of a race you want to join (same id as track id)

## Leaving a race
```lua
local success = exports['cw-racingapp']:leaveRace(raceId)
```
Where `raceId` is replaced by the id of a race you want to join (same id as track id)

## Setup a race
```lua

local setupData = {
    track = 'TR-IMADETHISUP', -- Track Id. Same as the ID of the track in DB or what you fetched earlier.
    laps = 2, -- number, amount of laps. 0 = sprint,
    maxClass = nil, -- nil or a class, if you want to limit vehicle class with cw-performance,
    ghostingOn = false, -- true of false, if ghosting should be on or not
    ghostingTime = 0, -- number, how long ghosting stays on. zero for entire race
    buyIn = 0, -- number, cost to enter race,
    ranked = false,-- true or false, if you want ranked or not
    reversed = false, -- true or false, if you want the race to be reversed
    participationMoney = 0, -- Money users get for just being there (this is normally an admin setup thing)
    participationCurrency = 'cash', -- Money type of users get for just being there (this is normally an admin setup thing)
    firstPerson = false, -- true or false, if you want to force first person
    silent = true, -- If true, will not show race in racingapp. This means you need to programatically join the race for the users.
    hidden = true, -- If true, will not show race in racingapp. This means you need to programatically join the race for the users.
}

-- Races hosted from server side will be treated as automated
local success = exports['cw-racingapp']:setupRace(setupData)
if raceId then
    -- race setup successful! Use the raceId to track it
else
    -- failed to set up the race
end
```

## Joining a race
```lua
    local success = exports['cw-racingapp']:joinRaceByRaceId(raceId, src)
```
Where `raceId` is replaced by the id of a race you want to join (same id as track id). All this does is call the client side joinRace export so you could also use that. Using the client side export also lets you see if it was possible to join or not, while the server side version only verifies the input.

## Leaving a race
```lua
    exports['cw-racingapp']:leaveCurrentRace(src)
```
Where the `src` is the source of a player. Does not return anything. If you want verification that the racer is in a race do this from client side instead.

## Get tracks
This will get all the existing tracks for you to display or verify with
```lua
    local tracks = exports['cw-racingapp']:getAvailableTracks()
    print(json.encode(tracks, {indent=true})) -- This will be the data returned. Do what you will with it
```

## Get posted races
This will get all the races for you to display
```lua
    local races = exports['cw-racingapp']:getRaces()
    print(json.encode(races, {indent=true})) -- This will be the data returned. Do what you will with it
```

# Want to change the look?
RacingApp is built in VUE, this means you can't just edit the files directly. This requires some more know-how than just developing with basic html/js. You can find out more information in this [Boilerplate Repo](https://github.com/alenvalek/fivem-vuejs-boilerplate).

## There will be **NO** support for this. Figure out node dev yourself or pay for a reskin comission kthx bye!

# Updating?
If you're updating from a previous version these might be for you

## New User Management - 30th November 2023
You need to update one of your database tables. Run this:
```sql
ALTER TABLE racer_names
ADD COLUMN auth TEXT DEFAULT 'racer',
ADD COLUMN createdby TEXT,
ADD COLUMN revoked TINYINT DEFAULT 0;
```
You also need to change out the old GPS/fob items to the new one, see setup section. 
You might also want to read up on the new system, see User Management section.

## VUE update 18th December 2023
See [setup](#setup) section for instructions on how to build a dist

## Racing Crews and Racing Rank update 14th February 2024
1) Make sure to run the sql in `cw-racingcrews.sql`
2) Run this in your Database to update your `racer_names`: 
```sql
ALTER TABLE racer_names 
ADD COLUMN ranking INT(11) NULL DEFAULT '0';
```

## Track table update 
A new column was added. If you're updating you can run this script to add it to your database
```sql
ALTER TABLE `race_tracks`
ADD COLUMN `metadata` TEXT NULL DEFAULT NULL COLLATE 'utf8_general_ci' AFTER `checkpoints`;
```

## Race User Update - 25th Oct 2024
Two new columns were added to the race user table. You can run this to update an existing table
```sql
ALTER TABLE `racer_names`
ADD COLUMN `crew` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
ADD COLUMN `active` INT(11) NOT NULL DEFAULT '0';
```

This **WILL** break your crews, so to fix this, after you've run the above, you can run this:
> note:  This is for QBOX/QB, not sure if the table names are the same for ESX so make sure to check that
```sql
UPDATE racer_names rn
JOIN players p ON JSON_UNQUOTE(JSON_EXTRACT(p.metadata, '$.selectedRacerName')) = rn.racername
SET rn.crew = JSON_UNQUOTE(JSON_EXTRACT(p.metadata, '$.selectedCrew'))
WHERE JSON_UNQUOTE(JSON_EXTRACT(p.metadata, '$.selectedCrew')) IS NOT NULL;
```

## Ox changes 6th Nov, 2024
I messed some stuff up initial and used charId instead of stateId cause I'm 🥔 fix by running this:
```sql
UPDATE racer_names
SET citizenid = (
    SELECT stateId 
    FROM characters 
    WHERE characters.charId = racer_names.citizenid
);
```

## Crypto addition, 20th Dec, 2024
Added a built in crypto system (Sorry Renewed Users)
```sql
ALTER TABLE racer_names
ADD COLUMN crypto INT DEFAULT 0 NOT NULL;
```

# Dependencies
* [cw-performance](https://github.com/Coffeelot/cw-performance)

# Uninstalling or full reset
## /removeracetracks
Drops the `race_tracks` table. Use this if you're uninstalling (warning: all tracks and records will be gone)
