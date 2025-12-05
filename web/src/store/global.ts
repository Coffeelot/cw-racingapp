// Utilities
import { defineStore } from 'pinia'
import { ActiveHudData, ActiveRace, BaseData, Bounty, Buttons, CreatorData, Crew, Track, Notification, Head2headData, Race, DashboardSettings, DriftInfo} from './types'

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
    showDriftHud: false,
    driftData: {} as DriftInfo
  })
})
