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
            <FlagIcon />
          </div>
          <div class="row">
            <span id="race-time">{{
              msToHMS(globalStore.activeRace.time)
            }}</span>
            <TimerIcon />
          </div>
          <div class="row">
            <span id="race-time">{{
              msToHMS(globalStore.activeRace.totalTime)
            }}</span>
            <HourglassIcon />
          </div>
          <div class="row">
            <span id="race-time">{{
              msToHMS(globalStore.activeRace.bestLap)
            }}</span>
            <StarIcon />
          </div>
          <div id="race-ghosted-span" v-if="globalStore.activeRace.ghosted">
            <GhostIcon />
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
import { FlagIcon, HourglassIcon, StarIcon, TimerIcon } from "lucide-vue-next";
import GhostIcon from "@/assets/icons/GhostIcon.vue";

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

<style scoped >
span {
  text-shadow:1px 1px 18px black;
}

#race-ghosted-span {
  display: flex;
  justify-content: end;
}

#race-time {
  /* color: #ffffffc7; */
}
.race {
  position: absolute;
  pointer-events: none;
  top: 5vh;
  left: 0;
  z-index: 10;
}
.boxes {
  color: #ffffffc7;
  font-family: "Teko", sans-serif;
  font-optical-sizing: auto;
  font-style: normal;
  text-transform: uppercase;
  display: flex;
  justify-content: v-bind(placement);
  flex-direction: v-bind(direction);
  width: 100vw;
}
.blocks-container {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 1em;
}

.positions-container {
  display: flex;
  flex-direction: column;
  gap: 1em;
  margin: 2em;
  transform: rotate(355deg);
}

.blocks {
  flex-grow: 4;
  display: flex;
  flex-direction: column;
  align-items: end;
  gap: 5px;
  margin-right: 1em;
  margin-left: 1em;
}

.hud-text {
  text-align: right;
  padding: 10px;
  padding-right: 15px;
  padding-left: 15px;
  font-weight: 600;
  width: 100%;
  text-transform: uppercase;
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
  align-items: flex-start;
}

#position {
  margin-left: 0.1em;
  font-size: 5em;
  line-height: 85%;
}

#checkpoint {
  font-size: 2em;
  line-height: 85%;
  text-align: end;
}
</style>
