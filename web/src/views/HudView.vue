<template>
  <div class="hud-view">
    <EditorHud  v-if="!!globalStore.creatorData && globalStore.activeHudData.InCreator" />
    <RaceHud v-if="globalStore.activeRace && globalStore.activeHudData.InRace" />
    <DriftHud v-if="globalStore.showDriftHud" />
    <CountdownHud v-if="globalStore.countdown > -1" :countdownNumber="globalStore.countdown" />
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "../store/global";
import EditorHud from "../components/hud/EditorHud.vue";
import RaceHud from "../components/hud/RaceHud.vue";
import CountdownHud from "../components/hud/CountdownHud.vue";
import DriftHud from "@/components/hud/DriftHud.vue";

const globalStore = useGlobalStore();
</script>

<style scoped>
.hud-view {
  position: absolute;
  width: 100vw;
}
</style>