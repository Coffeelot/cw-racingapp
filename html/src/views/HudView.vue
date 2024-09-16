<template>
  <v-container class="d-flex fill-height">
    <EditorHud v-if="globalStore.creatorData && globalStore.activeHudData.InCreator"></EditorHud>
    <RaceHud v-if="globalStore.activeRace && globalStore.activeHudData.InRace"></RaceHud>
    <CountdownHud v-if="globalStore.countdown > -1" :countdownNumber="globalStore.countdown"></CountdownHud>
  </v-container>
</template>

<script setup lang="ts">
import { useGlobalStore } from "../store/global";
import EditorHud from "../components/hud/EditorHud.vue";
import RaceHud from "../components/hud/RaceHud.vue";
import CountdownHud from "../components/hud/CountdownHud.vue";

const globalStore = useGlobalStore();

</script>

<style scoped>
</style>
