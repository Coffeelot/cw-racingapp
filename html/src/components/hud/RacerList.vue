<template>
  <div class="racers-holder">
    <div class="box" v-for="(racer, index) in racers" :key="racer.RacerSource" :class="{me: globalStore.baseData?.data?.currentRacerName === racer.RacerName }" >
      <div class="number" >{{ index + 1 }}</div>
      {{ racer.RacerName }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { ActiveRacer } from "../../store/types";
defineProps<{
  racers: ActiveRacer[];
}>();
const globalStore = useGlobalStore();

</script>

<style scoped lang="scss">
.racers-holder {
  display: flex;
  flex-direction: column;
  gap: 0.3em;
}
.number {
  font-size: 1.7em;
  font-weight: bold;
  margin-left: 1rem
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
.me {
  background: $hud-background-light;
  color: black;
}
</style>
