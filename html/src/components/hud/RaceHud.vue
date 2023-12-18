<template>
  <div class="race">
    <div class="boxes">
      <div class="positions-container">
        <div id="race-ghosted-span">
          <span id="race-ghosted-value">{{
            globalStore.activeRace.ghosted ? "👻" : ""
          }}</span>
        </div>
        <RacerList :racers="globalStore.activeRace.positions" />
      </div>
      <div class="blocks-container">
        <div class="blocks">
          <div class="box" v-if="globalStore.activeRace.totalRacers && globalStore.activeRace.totalRacers !== 1">
            <span class="hud-text split big"
              ><span class="leftAligned">POS:</span
              ><span id="race-position">{{
                `${globalStore.activeRace.position}/${globalStore.activeRace.totalRacers}`
              }}</span></span
            >
          </div>
          <div class="box">
            <span class="hud-text split"
              ><span class="leftAligned">CHECKPOINTS:</span
              ><span id="race-checkpoints">
                {{
                  `${globalStore.activeRace.currentCheckpoint}/${globalStore.activeRace.totalCheckpoints}`
                }}</span
              ></span
            >
          </div>
          <div class="box">
            <span class="hud-text split"
              ><span class="leftAligned">LAP:</span
              ><span id="race-lap">
                {{ globalStore.activeRace.totalLaps === 0 ? 'Sprint' : `${globalStore.activeRace.currentLap}/${globalStore.activeRace.totalLaps}` }}</span
              ></span
            >
          </div>
          <div class="box">
            <span class="hud-text split"
              ><span class="leftAligned">CURRENT:</span>
              <span id="race-time">{{ secondsToHMS(globalStore.activeRace.time) }}</span></span
            >
          </div>
          <div class="box">
          <span class="hud-text split"
            ><span class="leftAligned">BEST:</span>
            <span id="race-besttime"> {{ secondsToHMS(globalStore.activeRace.bestLap) }}</span></span
          >
        </div>
        <div class="box">
          <span class="hud-text split"
            ><span class="leftAligned">TOTAL:</span>
            <span id="race-totaltime">{{ secondsToHMS(globalStore.activeRace.totalTime) }}</span></span
          >
        </div>
    <div class="box">
          <span class="hud-text split"
            ><span class="leftAligned">TRACK:</span>
            <span id="race-racename">{{ globalStore.activeRace.raceName }}</span></span
          >
        </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Racer } from "../../store/types";
import RacerList from "./RacerList.vue";
import { ref } from "vue";
import { useGlobalStore } from "@/store/global";
import { secondsToHMS } from "@/helpers/secondsToHMS";
const globalStore = useGlobalStore();
</script>

<style scoped lang="scss">
.race {
    position: absolute;
    top: 10px;
    right: 10px;
}
.boxes {
  display: flex;
  justify-content: end;
}
.blocks-container {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 20px;
  margin: 10px;
}

.positions-container {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 20px;
  margin: 10px;
}

.blocks {
  width: 25em;
  flex-grow: 4;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.box {
  background: $hud-background;
  width: 100%;
  font-size: 1.5em;
  display: flex;
  gap: 1em;
  align-items: center;
  padding-right: 1rem;
}

.hud-text {
    text-align: right;
    padding: 10px;
    padding-right: 15px;
    padding-left: 15px;
    font-weight: 600;
    width: 100%;
}

.leftAligned {
    text-align: left;
}

.split {
    display: flex;
    justify-content: space-between;
}


</style>
