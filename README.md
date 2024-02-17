# CW rework of [QB-Racing](https://github.com/ItsANoBrainer/qb-racing)
### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐

[Images here](#Images)

**Some of the added features:**
- Integration with [cw-performance](https://github.com/Coffeelot/cw-performance) to create class based racing
- ELO system for ranking racers
- Crew system
- Advanced leaderboard for each track and class showing everyones best times
- By-class leaderboard
- Replacement of tire-piles lamps
- Increased size of checkpoints
- Not as harsh checkpoint-pass detection compared to qb-racing
- Remove race tracks you have created
- See your position in the race
- Real time positioning (can be toggled off if performance issue)
- Updated HUD
- Accurate time (old one would vary depending on computer performance) **NOW IN MS!**
- Ability to reset/run the SQL scripts from in game
- Phasing/Ghosting of racers
- Ability to lock tracks down to people by citizen ID
- Support for Renewed Crypto
- Participation payouts
- Post race leaderboard
- Custom UI
- Track curation
- Ability to select Racing HUD position *(see HUDSettings in Config file)*

**Original features by ItsANoBrainer:**
- Standalone racing script not requiring qb-phone to utilize
- Items to immerse your racing scene with Racer Names
- Config options to adjust item permissions to your liking
- Config options to adjust different options
- (Limited) Locale Support
- Create Custom Races Tracks

> As of update posted on 1st July -23, racer names are unique. The max limit is by default 3 but can be set individually. If you want to remove names from DB without openign it up, an admin can use `/remracename <racerName>`

> As of update posted on 26th August -23 we will no longer support qb-menu usage. 


# Developed by Coffeelot and Wuggie
[More scripts by us](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈

**Support, updates and script previews**:

[![Join The discord!](https://cdn.discordapp.com/attachments/977876510620909579/1013102122985857064/discordJoin.png)](https://discord.gg/FJY4mtjaKr )

**All our scripts are and will remain free**. If you want to support what we do, you can buy us a coffee here:

[![Buy Us a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/cwscriptbois )

# Racing App

Options:
 - Join a race
 - View race records
 - Setup a new race
 - Create a new race track
 - Modify old tracks
 - List your own tracks
 - Manage racer users (for master and god rank users)
 - Create and manage crews

### GPS settings
At the bottom left corner there's a cog wheel. Clicking this brings up the options menu (more stuff to come). But here you can toggle using the GPS route and the style of it.

### Track Curation
Our idea with this feature is to allow admins to flag a track as "DONE". The track can no longer be edited. Additional features of curated tracks might be only allowing participation money to be paid out on those tracks, for example.

Currently you can only curate/uncurate a track via admin command: `/racingappcurated "<race-id>" true/false` **QUOTATION MARKS AROUND RACE ID IS IMPORTANT**

### Track Creation
The key to this script working is making GOOD tracks. If you're trying to do 200 checkpoint style races with checkpoints randomly thrown around the map, this is not the script for you. There is a max checkpoint variable in the config that will warn users when they reached the level. Some PCs might struggle with different lower/higher amounts tho, so keep that in mind.

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

# Preview 📽
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

# Setup

### Installation
1. Download ZIP
2. Update or insert the database tables. These are found in the `cw-racingapp.sql` and `cw-racingcrews.sql` files
3. Adjust values in the `config.lua` file to your liking (Hot tip: GO OVER THIS FILE BEFORE REPORTING ISSUES)
4. Add the item to your `qb-core/shared/items.lua`
```lua
['racing_gps'] = {['name'] = 'racing_gps', ['label'] = 'Racing GPS', ['weight'] = 500, ['type'] = 'item', ['image'] = 'racing_gps.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['description'] = 'Wroom wroom.'},
```
4. Add the item image to your inventory image folder

### Setup Notes
> You only need both this resource and [cw-performance](https://github.com/Coffeelot/cw-performance).

> Depending on how you're setting it up, you might want to spawn yourself a racingapp item and create an account. This can be done in 4 ways: Via the trader or laptop (See respetive config option for more info), the racingapp ui (requires an already existing account - BY DEFAULT THIS ALSO REQUIRES A JOB. SEE LAPTOP CONFIG SETTINGS) or the command.

### Use in game
Use the command `createracinguser` to do this. For example:
`/createracinguser god 1 IReadTheReadme`
This will create a god account for the user with serverID 1 (probably you if you're on your dev server) called IReadTheReadme. 
Spawn the item `racing_gps` normally and use it. 
> Some users have reported this not working and throwing an error. It seems this is related to Core issues. The order of the input might differ for some cores for some reason. The server side printout should help you determine the order. Just type it in according to that instead.

# Want to change the look?
RacingApp is built in VUE, this means you can't just edit the files directly. This requires some more know-how than just developing with basic html/js. You can find out more information in this [Boilerplate Repo](https://github.com/alenvalek/fivem-vuejs-boilerplate).

# Updating?
If you're updating from a previous version these might be for you

### New User Management - 30th November 2023
You need to update one of your database tables. Run this:
```sql
ALTER TABLE racer_names
ADD COLUMN auth TEXT DEFAULT 'racer',
ADD COLUMN createdby TEXT,
ADD COLUMN revoked TINYINT DEFAULT 0;
```
You also need to change out the old GPS/fob items to the new one, see setup section. 
You might also want to read up on the new system, see User Management section.

### VUE update 18th December 2023
See [setup](#setup) section for instructions on how to build a dist

### Racing Crews and Racing Rank update 14th February 2024
1) Make sure to run the sql in `cw-racingcrews.sql`
2) Run this in your Database to update your `racer_names`: 
```sql
ALTER TABLE racer_names 
ADD COLUMN ranking INT(11) NULL DEFAULT '0';
```

# Dependencies
* [cw-performance](https://github.com/Coffeelot/cw-performance)

## Images

**Track Setup**

![Track Selection](https://media.discordapp.net/attachments/1003220513038016573/1186384407444062300/image.png?ex=65930d94&is=65809894&hm=75a438cff341e99f77671992f2ef1e0ea075bb0218b0b1763e49b2b087abb213&=&format=webp&quality=lossless&width=776&height=557)
![Track Setup](https://media.discordapp.net/attachments/1003220513038016573/1186386707025756200/image.png?ex=65930fb8&is=65809ab8&hm=360e2e75712070284a98ec8184fdcf23affd1fed75d07c854951efeee1d9bbc5&=&format=webp&quality=lossless&width=776&height=533)

**Leaderboards**

![Interface](https://media.discordapp.net/attachments/977876510620909579/1186387463569166357/image.png?ex=6593106d&is=65809b6d&hm=4176fce822f2e10fca301d178bb3f3f3beac4792ca6408459fddcf889cbec82a&=&format=webp&quality=lossless&width=776&height=501)

**Track Creation**

You can create tracks from both using an in-game editor or copy/paste a set of checkpoints.

**Manage Tracks**

![Tracks menu](https://media.discordapp.net/attachments/977876510620909579/1186385557010522262/image.png?ex=65930ea6&is=658099a6&hm=d17a6366a3e098c77611c5dbb1cbe299d96f1d95857df1f63096f57b2f0f1d52&=&format=webp&quality=lossless&width=776&height=573)

![Interface](https://media.discordapp.net/attachments/977876510620909579/1186385557425770496/image.png?ex=65930ea6&is=658099a6&hm=def700ad47d0630293152776f900dca61b5cd9518983b6fb5864d2150f4690bd&=&format=webp&quality=lossless&width=776&height=548)

**Handle your race users**

![Users](https://media.discordapp.net/attachments/977876510620909579/1186385556582707340/image.png?ex=65930ea6&is=658099a6&hm=bc26cad6cde32efcd9bfc5b2ab5e1878c33a4d85002069d81a4795df9bc5680e&=&format=webp&quality=lossless&width=776&height=546)

**Settings**

![Settings](https://media.discordapp.net/attachments/977876510620909579/1186385556129730560/image.png?ex=65930ea6&is=658099a6&hm=4ac2020189634e3cc7c37379ca28647a7a5e596ce6cf9f9dff9c34500147355f&=&format=webp&quality=lossless&width=776&height=553)

# Uninstalling or full reset
## /removeracetracks
Drops the `race_tracks` table. Use this if you're uninstalling (warning: all tracks and records will be gone)
## Developed by Coffeelot#1586, Wuggie#1683
Once upon a time this was a fork of [QB-Racing](https://github.com/ItsANoBrainer/qb-racing), credits to ItsANoBrainer.

# Sponsored Features
## Real Time Racing Positions
@JELLYHITAM | [Quantum Roleplay Indonesia](https://discord.gg/XyP9tPDHX4)
## Ability to create participation rewards from UI and extended auth types
@Rithvikk05 | [HTRP](discord.gg/htrp)