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
      default:
        break;
    }

  }
  
};

const getBaseData = async () => {
  const res = await api.post("GetBaseData");
  globalStore.$state.baseData = res
  if (res.data.primaryColor) {
      theme.themes.value.dark.colors.primary = res.data.primaryColor;
  }
}

onMounted(() => {
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
