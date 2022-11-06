# CW rework of [QB-Racing](https://github.com/ItsANoBrainer/qb-racing)

This is a rework of the superb free resource [QB-Racing](https://github.com/ItsANoBrainer/qb-racing) by ItsANoBrainer.

Some of the added features:
- Integration with [cw-performance](https://github.com/Coffeelot/cw-performance) to create class based racing
- Top 3 leaderboard for each track instead of only the best
- By-class leaderboard
- Safer leaderboard updates (through refetches)
- Replacement of tire-piles lamps
- Increased size of checkpoints
- Not as harsh checkpoint-pass detection


# Developed by Coffeelot and Wuggie
[More scripts by us](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈\
[Support, updates and script previews](https://discord.gg/FJY4mtjaKr) 👈

# Racing App

This script lets you manage your racing scene in a better way using items and custom racer names instead of player names! There are two items involved, the `master racing fob`, and the `basic racing fob`. At the moment, these are created using the `createracingfob` command by a qb-core admin, but you can implement any system you want. When created, the fob is bound to the citizenid it was created for, and has a racer name attached to it. Only the citizenid created for it can use it. Using the fob brings up the racing options menu (examples below) which is where you do all the interacting with the script. Each fob has an entry in the Config to tune it to your server to allow or deny certain usage abilities (listed below). By default the master racing fob is required to CREATE new race tracks, and both dongles allow you to do everything else.

Config Options per Dongle:
 - Join a race
 - View race records
 - Setup a new race
 - Create a new race track

## Setup
You only need either this resource and [cw-performance](https://github.com/Coffeelot/cw-performance).

1. Update or insert the database table. Instructions are found in the `racing.sql` file
* Option 1: Updating from qb-lapraces must follow OPTION 1 to update their database table and preserve their race tracks
* Option 2: NOT updating from qb-lapraces must follow OPTION 2 to create the database table 
2. Adjust values in the `config.lua` file to your likings
3. Add the items to your `qb-core/shared/items.lua`
```lua
['fob_racing_basic'] = {['name'] = 'fob_racing_basic', ['label'] = 'Basic Racing Fob', ['weight'] = 500, ['type'] = 'item', ['image'] = 'fob_racing_basic.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['description'] = 'This basic fob allows someone to join custom races.'},
['fob_racing_master'] = {['name'] = 'fob_racing_master', ['label'] = 'Master Racing Fob', ['weight'] = 500, ['type'] = 'item', ['image'] = 'fob_racing_master.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['description'] = 'This master fob allows someone to create custom races.'},
```
4. Add the item images to your inventory image folder

## Dependencies
* [qb-menu](https://github.com/qbcore-framework/qb-menu)
* [qb-input](https://github.com/qbcore-framework/qb-input)
* [cw-performance](https://github.com/Coffeelot/cw-performance)

## Features
* Standalone racing script not requiring qb-phone to utilize
* Items to immerse your racing scene with Racer Names
* Config options to adjust item permissions to your liking
* Config options to adjust different options
* Locale Support
* Create Custom Races Tracks

## Example Usage
### Interface Images

**Main Menu**

![Interface](https://i.imgur.com/49027bo.png)

**Leaderboards**
Change from normal qb-racing: Sorted by track, added classes and added full list of laptimes. Each person can have one entry per class + track, so you can have multiple times on a track, with different classes, but the script keeps track of your best times.

![Interface](https://i.imgur.com/8480LVX.png)
![Interface](https://i.imgur.com/H7Trlzz.png)
![Interface](https://i.imgur.com/5FthsBY.png)

**Setting up a Race**
Change from normal qb-racing: Added classes to list. If you set up a race with A class, people can join with A and lower, but not higher.

![Interface](https://i.imgur.com/4r6iriO.png)


### Video Example
#### Creating a Race
[![Video Example](https://i.imgur.com/DCFUJw9.png)](https://i.imgur.com/WoSxall.mp4)
#### Race Interface, Joining a Race, Finishing a Race
[![Video Example](https://i.imgur.com/hsZVHeL.png)](https://i.imgur.com/oYgHBdj.mp4)

## Future ToDos
* Ability to delete race tracks ingame

## Developed by Coffeelot#1586, Wuggie#1683