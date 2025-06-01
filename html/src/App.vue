<template>
  <v-app theme="dark">
    <transition name="scale" mode="out-in">
      <RaceAppView v-if="globalStore.appIsOpen"></RaceAppView>
    </transition>
    <HudView></HudView>
  </v-app>
</template>

<script lang="ts" setup>
import RaceAppView from "./views/RaceAppView.vue";
import HudView from "./views/HudView.vue";
import {
  onMounted,
  onUnmounted,
} from "vue";
import { useGlobalStore } from "./store/global";
import api from "@/api/axios";
import { useTheme } from "vuetify/lib/framework.mjs";
import { testState } from "./store/testState";
const theme = useTheme()

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
  }
  if (res.data.primaryColor) {
      theme.themes.value.dark.colors.primary = res.data.primaryColor;
  }
}

onMounted(() => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    globalStore.$state = testState;
  }
  window.addEventListener("message", handleMessageListener);
});

onUnmounted(() => {
  window.removeEventListener("message", handleMessageListener, false);
});

</script>

<style>
@import './styles/global.scss';

::-webkit-scrollbar {
  width: 0;
  display: inline !important;
}
.v-application {
  background: rgb(0, 0, 0, 0.0) !important;
}

.scale-enter-active,
.scale-leave-active {
  transition: all 0.5s ease;
}

.scale-enter-from,
.scale-leave-to {
  opacity: 0;
  transform: scale(0.9);
}
</style>
