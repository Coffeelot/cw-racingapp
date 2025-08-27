<template>
  <div>
    <Transition name="slide-up" mode="out-in">
      <RaceAppView v-if="globalStore.appIsOpen" />
      <HudView v-else/>
    </Transition>
  </div>
</template>

<script lang="ts" setup>
import './style.css';
import RaceAppView from "./views/RaceAppView.vue";
import HudView from "./views/HudView.vue";
import {
  onMounted,
  onUnmounted,
} from "vue";
import { useGlobalStore } from "./store/global";
import { activeRaceMock, testState } from "./mocking/testState";
import api from "./api/axios";
import { raceTestState } from "./store/inRaceTest";
const globalStore = useGlobalStore();

const toggleApp = (show: boolean): void => {
  if (show) {
    getBaseData()
  }
  globalStore.$state.appIsOpen = show
};

const handleHudUpdate = (itemData: any) => {
  if (itemData.action == 'update') {
    globalStore.$state.hudIsOpen = itemData
    globalStore.$state.activeRace = itemData.data
    globalStore.$state.activeHudData = itemData.racedata
  } else {
    globalStore.$state.countdown = itemData.data.value
    if (itemData.data.value === 0 ) {
      setTimeout(() => {
        globalStore.$state.countdown = -1
      }, 2000);
    }
  }
}

const handleCreator = (itemData:any) => {
  if (itemData.action == 'update') {
    globalStore.$state.buttons = itemData.buttons
    globalStore.$state.creatorData = itemData.data
    globalStore.$state.activeHudData.InCreator = itemData.active

  }
}

const handleDataUpdate = (itemData: any) => {
  switch (itemData.dataType) {
    case 'bounties':
      globalStore.bounties = itemData.data
      break;
    case 'crypto':
      globalStore.baseData.data.currentCrypto = itemData.data
      break;
    default:
      break;
  }
}

const handleHead2HeadUpdate = (data: any) => {
  globalStore.head2headData = data
}

const handleMessageListener = (event: MessageEvent) => {
  const itemData: any = event?.data;
  if (itemData?.type) {
    switch (itemData.type) {
      case 'race': 
        handleHudUpdate(itemData)
        break;
      case 'creator':
        handleCreator(itemData)
        break;
      case 'toggleApp':
        toggleApp(itemData.open)
        break;
      case 'notify': 
        globalStore.$state.notification = itemData.data
        break;
      case 'updateBaseData':
        getBaseData()
        break;
      case 'dataUpdate':
        handleDataUpdate(itemData);
        break;
      case 'head2head':
        handleHead2HeadUpdate(itemData.data)
      default:
        break;
    }

  }
  
};

const getBaseData = async () => {
  const res = await api.post("GetBaseData");
  if (res) {
    globalStore.$state.baseData = res
    if (!globalStore.baseData.data?.dashboardSettings?.enabled && globalStore.currentPage === 'dashboard') {
      globalStore.$state.currentPage = 'racing';
    }
  }
}

onMounted(() => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    globalStore.$state = testState as unknown as typeof globalStore.$state;
  }
  if (import.meta.env.VITE_MOCK_UI === 'true') {
    globalStore.$state = raceTestState as unknown as typeof globalStore.$state;
    globalStore.$state.activeRace = activeRaceMock;
    globalStore.$state.countdown = 10;
  }
  if (import.meta.env.VITE_MOCK_CREATOR === 'true') {
    globalStore.$state.creatorData = {
      Checkpoints: [],
      ConfirmDelete: false,
      ClosestCheckpoint: 0,
      IsEdit: false,
      RaceDistance: 0,
      RaceId: '',
      RaceName: 'Mock Race',
      RacerName: "Made Up Name",
      TireDistance: 20,
    };
    globalStore.$state.activeHudData.InCreator = true;
  }
  window.addEventListener("message", handleMessageListener);
});

onUnmounted(() => {
  window.removeEventListener("message", handleMessageListener, false);
});

</script>

<style>
@import './styles/global.css';
@import './style.css';

::-webkit-scrollbar {
  width: 0;
  display: inline !important;
}
.v-application {
  background: rgb(0, 0, 0, 0.0) !important;
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}
.slide-up-enter-from,
.slide-up-leave-to {
  opacity: 0;
  transform: translateY(40px);
}
.slide-up-enter-to,
.slide-up-leave-from {
  opacity: 1;
  transform: translateY(0);
}

/* .scale-enter-active,
.scale-leave-active {
  transition: all 0.5s ease;
}

.scale-enter-from,
.scale-leave-to {
  opacity: 0;
  transform: scale(0.9);
} */
</style>
