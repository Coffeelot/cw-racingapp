### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐

📷 [Images & Video](#Preview) 📺


## NOW SUPPORTS QB AND ESX!
> Note: ESX requires ox_lib and ox_target

> Note: For ESX make sure to change out moneyTypes to corresponding versions in the config (ESX uses "money" instead of "cash" for example)

**Features:**
- [Create tracks](#track-creation)
- Host races
- Buy-Ins
- [Automated Races](#Automated-Races)
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

> Do note, this script has TWO systems for participation money. Make sure to check the readme and read the comments regarding these and how to use them.

> As of update posted on 1st July -23, racer names are unique. The max limit is by default 3 but can be set individually. If you want to remove names from DB without openign it up, an admin can use `/remracename <racerName>`

> As of update posted on 26th August -23 we will no longer support qb-menu usage. 

> As of update posted on 7th August -24 phasing/ghosting no longer has a transperancy, this might make it look different from videos you've seen


# Links
### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐


### [More free scripts](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈

### Support, updates and script previews:

<a href="https://discord.gg/FJY4mtjaKr"> <img src="https://media.discordapp.net/attachments/1202695794537537568/1285652389080334337/discord.png?ex=66eb0c97&is=66e9bb17&hm=b1b2c17715f169f57cf646bb9785b0bf833b2e4037ef47609100ec8e902371df&=&format=webp" width="200"></a>


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


# Preview

## Latest video

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

**Track Setup**

![Track Selection](https://media.discordapp.net/attachments/1202695794537537568/1276957396677431416/image.png?ex=66cb6ac0&is=66ca1940&hm=20eef13f8f901c01833ad31d4f605a0a56b3fb4ec3d6f64bdbe0c76b595f7b2c&=&format=webp&quality=lossless&width=782&height=457)
![Track Setup](https://media.discordapp.net/attachments/1202695794537537568/1276957700118417550/image.png?ex=66cb6b08&is=66ca1988&hm=0eab69671c24ce74ab5c33d6bfc42e2fb5a36ee00c4ccb25079dcd00f914bb4d&=&format=webp&quality=lossless&width=782&height=449)

**Leaderboards**

![Interface](https://media.discordapp.net/attachments/1202695794537537568/1276957700449636453/image.png?ex=66cb6b08&is=66ca1988&hm=85f91895299789c78357dba40acf60bb8d0034c03d16c3188a37c1f9acaafb9f&=&format=webp&quality=lossless&width=782&height=455)
![Interface](https://media.discordapp.net/attachments/1202695794537537568/1276957700722524223/image.png?ex=66cb6b08&is=66ca1988&hm=7b692b8532a70f503885c4c3c83da96034a6d1d01478b2cdedb4a337348840cd&=&format=webp&quality=lossless&width=782&height=456)
![Interface](https://media.discordapp.net/attachments/1202695794537537568/1276957700948889631/image.png?ex=66cb6b08&is=66ca1988&hm=13359ad6b4ddc6aa6addb5e0a06652139b12d7e671f919f5700aca4d362edbc3&=&format=webp&quality=lossless&width=782&height=453)

**Track Creation**

You can create tracks from both using an in-game editor or copy/paste a set of checkpoints.

**Manage Tracks**

![Tracks menu](https://media.discordapp.net/attachments/1202695794537537568/1276957701225844856/image.png?ex=66cb6b08&is=66ca1988&hm=f5f9169f87161c729e7d046bc2e39bde483dba520a83ace50593c4c66471acdb&=&format=webp&quality=lossless&width=782&height=453)

![Interface](https://media.discordapp.net/attachments/1202695794537537568/1276957701468979293/image.png?ex=66cb6b08&is=66ca1988&hm=7fe5372955f21e3e5c072a70fc037ddc86573b36bc63f32ee5b4bb33d1765875&=&format=webp&quality=lossless&width=782&height=460)

**Manage Crew**

![Interface](https://media.discordapp.net/attachments/1202695794537537568/1276957782611857418/image.png?ex=66cb6b1c&is=66ca199c&hm=ab465e525702acf9499a08d23b56b06abc0b40b2e446d14673d521158b055160&=&format=webp&quality=lossless&width=782&height=473)
![Interface](https://media.discordapp.net/attachments/1202695794537537568/1276957782934945812/image.png?ex=66cb6b1c&is=66ca199c&hm=9399c0825a24f0e0e586738976246199a9c4bc5e66e7555eb6ce5463ca8638b1&=&format=webp&quality=lossless&width=782&height=459)
![Interface](https://media.discordapp.net/attachments/1202695794537537568/1276957783224483881/image.png?ex=66cb6b1c&is=66ca199c&hm=a8311e0d10bfde2efef9333e5e761050770d20b8eda10360627070d86c2a6a72&=&format=webp&quality=lossless&width=782&height=470)

**Handle your race users**

![Users](https://media.discordapp.net/attachments/1202695794537537568/1276958004113047573/image.png?ex=66cb6b50&is=66ca19d0&hm=107f3b94d5a0b91741a94186d4744227f34d02884b08f05a44c95fb535ee1595&=&format=webp&quality=lossless&width=782&height=455)
![Users](https://media.discordapp.net/attachments/1202695794537537568/1276958004436140062/image.png?ex=66cb6b50&is=66ca19d0&hm=b0835004148e4c36b89f4fb563d8a337e91c661d735b6158908c122cdbc19631&=&format=webp&quality=lossless&width=782&height=464)

**Settings**

![Settings](https://media.discordapp.net/attachments/1202695794537537568/1276959445729148991/image.png?ex=66cb6ca8&is=66ca1b28&hm=de9240a7be25638c6d302a2a1bddd8d49ebe83590ae0e3b3f6f10dbf563189c3&=&format=webp&quality=lossless&width=782&height=466)

</details>

# Setup and Installation

### Installation
1. Download ZIP
2. Update or insert the database tables. These are found in the `cw-racingapp.sql` and `cw-racingcrews.sql` files
    - Optionally also run `default_tracks.sql` if you want to add the default tracks
3. Adjust values in the `config.lua` file to your liking **(Hot tip: GO OVER THIS FILE BEFORE REPORTING ISSUES)**
4. Add the item to your `qb-core/shared/items.lua` (If you use another inventory/core you obviously might need to change this part)
```lua
['racing_gps'] = {['name'] = 'racing_gps', ['label'] = 'Racing GPS', ['weight'] = 500, ['type'] = 'item', ['image'] = 'racing_gps.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['description'] = 'Wroom wroom.'},
```
4. Add the item image to your inventory image folder
5. If you're not using QBOX then comment out `'@qbx_core/modules/playerdata.lua'` in fxmanifest 
6. Open the game and give yourself the item. When you open the app for the first time you'll be prompted to create a user. The first user to be created will be a `god` user, after that the rest will be `racer` type of whatever you set it to in the config. Optionally you can create a god user with the command (see below)

### Setup Notes
> You only need both this resource and [cw-performance](https://github.com/Coffeelot/cw-performance).


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
}

local success = exports['cw-racingapp']:attemptSetupRace(setupData)
```

# Want to change the look?
RacingApp is built in VUE, this means you can't just edit the files directly. This requires some more know-how than just developing with basic html/js. You can find out more information in this [Boilerplate Repo](https://github.com/alenvalek/fivem-vuejs-boilerplate).

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

# Dependencies
* [cw-performance](https://github.com/Coffeelot/cw-performance)

# Uninstalling or full reset
## /removeracetracks
Drops the `race_tracks` table. Use this if you're uninstalling (warning: all tracks and records will be gone)

# Sponsored Features
## Real Time Racing Positions
@JELLYHITAM | [Quantum Roleplay Indonesia](https://discord.gg/XyP9tPDHX4)
## Participation Rewards in UI | Extended auth types | Reverse Tracks | Elimination Races
@Rithvikk05 | [HTRP](discord.gg/htrp)

# Credits 
- ItsANoBrainer for [QB-Racing](https://github.com/ItsANoBrainer/qb-racing), which this is was once upton a time based on

- Detroit__Tony for ESX conversion