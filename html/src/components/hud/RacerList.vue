<template>
  <div class="racers-holder">
    <div
      class="box"
      v-for="(racer, index) in shortenedRacers"
      :key="racer.RacerSource"
      :class="{
        me: globalStore.baseData?.data?.currentRacerName === racer.RacerName,
      }"
    >
      <div class="number">{{ index + 1 }}</div>
      <span class="name">{{ racer.RacerName }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { ActiveRacer } from "../../store/types";
import { computed } from "vue";
const props = defineProps<{
  racers: ActiveRacer[];
}>();

const globalStore = useGlobalStore();
const shortenedRacers = computed(() => props.racers?.slice(0, globalStore.baseData?.data?.hudSettings?.maxPositions || 10))
</script>

<style scoped lang="scss">
.name {
  text-overflow: ellipsis;
  max-width: 20em;
  max-lines: 1;
  overflow: hidden;
  white-space: nowrap;
  padding: 0.5em;
}
.racers-holder {
  display: flex;
  flex-direction: column;
  gap: 0.3em;
}
.number {
  font-size: 1.1em;
  font-weight: bold;
  margin-left: 1rem;
}
.box {
  background: $hud-background;
  width: 100%;
  font-size: 1em;
  display: flex;
  gap: 1em;
  align-items: center;
}
.me {
  background: $hud-background-light;
  color: black;
}
</style>
