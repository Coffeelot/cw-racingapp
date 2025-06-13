<template>
  <div class="race">
    <div class="boxes">
      <div class="positions-container">
        <RacerList :racers="globalStore.activeRace.positions" />
      </div>
      <div class="blocks-container">
        <div class="blocks">
          <span id="track-name"> {{ globalStore.activeRace.raceName }}</span>
          <div
            class="position-container"
            v-if="
              globalStore.activeRace.totalRacers &&
              globalStore.activeRace.totalRacers !== 1
            "
          >
            <span id="smaller">{{ translate("pos") }}</span>
            <span id="position">{{
              `${globalStore.activeRace.position}/${globalStore.activeRace.totalRacers}`
            }}</span>
          </div>
          <div class="column">
            <span id="smaller">{{ translate("checkpoints") }}</span>
            <span id="checkpoint">{{
              `${globalStore.activeRace.currentCheckpoint}/${globalStore.activeRace.totalCheckpoints}`
            }}</span>
          </div>
          <div class="row">
            <span id="race-time">{{ lapText }}</span>
            <v-icon icon="mdi-cached"></v-icon>
          </div>
          <div class="row">
            <span id="race-time">{{
              msToHMS(globalStore.activeRace.time)
            }}</span>
            <v-icon icon="mdi-timer-sync-outline"></v-icon>
          </div>
          <div class="row">
            <span id="race-time">{{
              msToHMS(globalStore.activeRace.totalTime)
            }}</span>
            <v-icon icon="mdi-timer-outline"></v-icon>
          </div>
          <div class="row">
            <span id="race-time">{{
              msToHMS(globalStore.activeRace.bestLap)
            }}</span>
            <v-icon icon="mdi-timer-star-outline"></v-icon>
          </div>
          <div id="race-ghosted-span" v-if="globalStore.activeRace.ghosted">
            <v-icon icon="mdi-ghost-outline"></v-icon>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import RacerList from "./RacerList.vue";
import { useGlobalStore } from "@/store/global";
import { msToHMS } from "@/helpers/msToHMS";
import { computed } from "vue";
const globalStore = useGlobalStore();
import { translate } from "@/helpers/translate";

const hudpositionToCss: Record<string, string> = {
  split: "space-between",
  left: "start",
  right: "end",
};

const placement = computed(() =>
  globalStore.baseData?.data?.hudSettings?.location
    ? hudpositionToCss[globalStore.baseData?.data?.hudSettings?.location]
    : "space-between"
);
const direction = computed(() =>
  globalStore.baseData?.data?.hudSettings?.location === "left"
    ? "row-reverse"
    : "row"
);
const lapText = computed(() => {
  if (globalStore.activeRace.totalLaps === 0) return "Sprint";
  else if (globalStore.activeRace.totalLaps === -1)
    return `${globalStore.activeRace.currentLap}/-`;
  return `${globalStore.activeRace.currentLap}/${globalStore.activeRace.totalLaps}`;
});
</script>

<style scoped lang="scss">
@use 'vuetify/settings' as vuetify-settings;

span {
  text-shadow: 1px 1px 18px black;
}

.race {
  position: absolute;
  top: 5vh;
  right: 0.5vw; // Closer to right edge
  z-index: 100;
  padding: 1em;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 1em;
}

#race-time {
  color: rgba(255, 255, 255, 0.8);
}

#race-ghosted-span {
  display: flex;
  justify-content: flex-end;
  margin-right: 0.5vw;
  color: rgb(var(--v-theme-secondary));
}

.boxes {
  font-family: "Oswald", sans-serif;
  text-transform: uppercase;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  width: 100vw;
  padding: 0 0.5vw; // Less horizontal padding
}

.blocks-container {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 1.5em;
  padding: 1em 0.5vw;
}

.positions-container {
  display: flex;
  flex-direction: column;
  gap: 1em;
  padding: 0 0.5vw;
}

.hud-text {
  text-align: right;
  padding: 0.75em 1.25em;
  font-weight: 600;
  width: 100%;
  border-radius: 1em;
  background: rgba(var(--v-theme-primary), 0.15);
  backdrop-filter: blur(10px);
  color: rgb(var(--v-theme-primary));
  box-shadow: 0 0 6px rgba(var(--v-theme-primary), 0.3);
}

.leftAligned {
  text-align: left;
}

.split {
  display: flex;
  justify-content: space-between;
}

#track-name {
  font-size: 1.2em;
  font-weight: 700;
  color: rgb(var(--v-theme-secondary));
}

.row {
  display: flex;
  align-items: center;
  gap: 0.5em;
}

.row-big {
  display: flex;
  align-items: flex-start;
  font-weight: 600;
}

.smaller {
  font-size: 0.5em;
}

.column {
  display: flex;
  flex-direction: column;
}

.position-container {
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(var(--v-theme-secondary), 0.15);
  padding: 0.5em 1em;
  border-radius: 1em;
  font-weight: bold;
}

#position {
  font-size: 5em;
  line-height: 0.85;
  margin-left: 0.1em;
  color: rgb(var(--v-theme-primary));
  text-shadow: 2px 2px 8px black;
}

#checkpoint {
  font-size: 2em;
  line-height: 0.85;
  text-align: right;
  color: rgb(var(--v-theme-secondary));
  text-shadow: 1px 1px 5px black;
}

// ROTATION REMOVED: previously `rotate(355deg)` caused slight tilt.
// If needed, re-enable with transform: rotate(355deg);
</style>
