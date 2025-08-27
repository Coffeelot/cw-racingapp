// Utilities
import { defineStore } from 'pinia'
import { ActiveHudData, ActiveRace, BaseData, Bounty, Buttons, CreatorData, Crew, Track, Notification, Head2headData, Race, DashboardSettings} from './types'

export const useGlobalStore = defineStore('global', {
  state: () => ({
    appIsOpen: false,
    hudIsOpen: false,
    currentPage: 'dashboard',
    currentTab: {
      racing : 'current',
      results: 'results'
    },
    showOnlyCurated: true,
    activeRace: {} as ActiveRace,
    // activeRace: {"currentLap":1,"currentCheckpoint":2,"totalTime":8722,"position":1,"bestLap":0,"totalLaps":0,"raceName":"Senora longer","positions":[{"RaceTime":2811,"Finished":false,"Checkpoint":2,"Lap":1,"RacerName":"pizzadeliveryman","CheckpointTimes":[{"lap":1,"checkpoint":2,"time":2811}],"PlayerVehicleEntity":1268482,"RacerSource":1,"Placement":0},{"RaceTime":4375,"Finished":false,"Checkpoint":2,"Lap":1,"RacerName":"idiotSandwichsdd","CheckpointTimes":[{"lap":1,"checkpoint":2,"time":4375}],"PlayerVehicleEntity":586242,"RacerSource":2,"Placement":0}],"time":8722,"totalCheckpoints":11,"totalRacers":2,"raceStarted":true},
    activeHudData: {} as ActiveHudData,
    countdown: -1,
    buttons: {} as Buttons,
    creatorData: {} as CreatorData,
    baseData: {} as BaseData,
    isLoadingBaseData: true,
    settings: {},
    tracks: [] as Track[],
    races: [] as Race[],
    results: {} as Record<string, any>,
    myCrew: {} as Crew,
    notification: undefined as Notification | undefined,
    bounties: [] as Bounty[],
    showCryptoModal: false,
    head2headData: {} as Head2headData,
  })
})
