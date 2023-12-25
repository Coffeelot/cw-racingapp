// Utilities
import { defineStore } from 'pinia'
import { ActiveHudData, ActiveRace, Auth, BaseData, Buttons, CreatorData, CurrentRace, Race, RacerName, Track } from './types'

export const useGlobalStore = defineStore('global', {
  state: () => ({
    appIsOpen: false,
    hudIsOpen: false,
    currentPage: 'racing',
    currentTab: 'current',
    showOnlyCurated: true,
    activeRace: {} as ActiveRace,
    activeHudData: {} as ActiveHudData,
    countdown: -1,
    buttons: {} as Buttons,
    creatorData: {} as CreatorData,
    baseData: {} as BaseData,
    isLoadingBaseData: true,
    settings: {},
    tracks: {} as Track[],
    results: {} as Record<string, any>
  })
})
