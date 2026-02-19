<template>
  <div class="dark racers-holder" v-if="globalStore.showDriftResults">
    <div class="title-holder">
      <h1 class="title">{{ translate('driftResults') }}</h1>
      <Progress :progress="progressValue"></Progress>
    </div>
    <div
    class="box"
    v-for="(racer, index) in (globalStore.driftChallengeResults?.scores || [])"
    :style="getBoxStyle(index)"
    :key="racer.RacerSource"
    >
      <div class="number">{{ index + 1 }}</div>
      <span class="name">{{ racer.RacerName }}</span>
      <span class="difference" v-if="index === 0">{{ translate('winner') }}</span>
      <span class="difference" v-else-if="racer.Finished">{{ translate('finished') }}</span>
      <span class="score">{{ racer.DriftScore }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { translate } from "@/helpers/translate";
import { computed, onMounted, onUnmounted, ref } from "vue";
import Progress from "@/components/ui/progress/Progress.vue";

const globalStore = useGlobalStore();

const getBoxStyle = (index: number) => {
  // highlight the winner (first item) as primary
  const isPrimary = index === 0;
  return {
    background: isPrimary ? 'var(--primary)' : 'var(--secondary)',
    color: isPrimary ? 'var(--primary-foreground)' : 'var(--secondary-foreground)',
  };
}

const elapsed = ref(0);
let intervalId: number | null = null;

// get a computed value for circular progress from 0-100 based on the scoreboardtimeout
const progressValue = computed(() => {
  const timeoutMs = globalStore.baseData.data.driftChallengeSettings.scoreBoardTimeout * 1000;
  // Count down from 100 to 0
  const progress = 100 - Math.min((elapsed.value / timeoutMs) * 100, 100);
  return Math.round(progress);
});

onMounted(() => {
  const startTime = Date.now();
  const timeoutMs = globalStore.baseData.data.driftChallengeSettings.scoreBoardTimeout * 1000;
  
  // Update elapsed time every 50ms for smooth animation
  intervalId = window.setInterval(() => {
    elapsed.value = Date.now() - startTime;
    
    // Stop interval when countdown is complete
    if (elapsed.value >= timeoutMs) {
      if (intervalId) clearInterval(intervalId);
      globalStore.showDriftResults = false;
    }
  }, 50);
});

// onUnmounted(() => {
//   if (intervalId) clearInterval(intervalId);
// });

</script>
<style scoped >
.title-holder {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  transform: rotate(355deg);
  margin-bottom: 1em;
}
.title {
  color: #ffffffc7;
  font-family: "Teko", sans-serif;
  font-optical-sizing: auto;
  font-style: normal;
  font-weight: 600;
  width: 100%;
  text-transform: uppercase;
  text-shadow:1px 1px 18px black;
  font-size: 2em;
}
.name {
  text-overflow: ellipsis;
  max-width: 20em;
  max-lines: 1;
  overflow: hidden;
  white-space: nowrap;
  padding: 0.5em;
  margin-right: 1em;
}
.racers-holder {
  display: flex;
  flex-direction: column;
  gap: 0.3em;
  max-width: fit-content;
  margin-top: 10em;
  margin-left: 2em
}
.number {
  font-size: 1.1em;
  font-weight: bold;
}
.box {
  width: 100%;
  font-size: 1em;
  font-weight: 600;
  display: flex;
  border-radius: 2em;
  gap: 1em;
  align-items: center;
  clip-path: polygon(5% 100%,100% 100%,95% 0%,0% 0%,calc(100% - 88px) 0%,0% 0%);
  padding-right: 2em;
  padding-left: 2em;
  transform: rotate(355deg);
}
.score {
  margin-left: auto;
  font-weight: 700;
}
</style>
