<template>
  <div class="dark drift text-primary-foreground">
    <div class="box">
      <div class="top-data">
        <div class="flex flex-col">
          <small>{{ translate('latest') }}</small>
          <span class="score-text" >{{ globalStore.driftData?.latestDriftScore ?? 0 }}</span>
        </div>
        <CircularProgress :duration="0.3" :value="globalStore.driftData?.multiplier === 10 ? 100: globalStore.driftData?.multiplierPercent" :textInCenter="globalStore.driftData?.multiplier">
        </CircularProgress>
        <div class="flex flex-col">
          <small>{{ translate('angle') }}</small>
          <span class="score-text" >{{ globalStore.driftData?.driftAngle ?? 0 }}°</span>
        </div>
      </div>
      <div class="bottom-data">
        <span :class="['score-text text-5xl', { bump: bumpValues }]"> {{ globalStore.driftData?.score || 0 }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { ref, watch } from "vue";
const globalStore = useGlobalStore();
import { translate } from "@/helpers/translate";
import CircularProgress from "../ui/circular-progress/CircularProgress.vue";

const bumpValues = ref(false);
const ANIM_MS = 360;

watch(
  () => globalStore.driftData?.latestDriftScore ?? 0,
  (newVal, oldVal) => {
    if (newVal === oldVal) return;
    bumpValues.value = true;
    // auto-remove after animation
    setTimeout(() => (bumpValues.value = false), ANIM_MS);
  }
);


</script>

<style scoped >
.drift {
  position: absolute;
  top: 5vh;
  width: 100vw;
  display: flex;
  justify-content: center;
  align-items: center;
  text-transform: uppercase;
  font-family: "Teko", sans-serif;
  text-shadow:1px 1px 18px black;
}
.box {
  width: 20em;
  font-size: 1em;
  font-weight: 600;
  display: flex;
  border-radius: 0.2em;
  padding: 1em;
  align-items: center;
  /* background: var(--primary); */
  display: flex;
  flex-direction: column;
}

.top-data {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5em;
  margin-bottom: 0.5em;
}

.bottom-data {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5em;
}

.score-text {
  display: inline-block; /* needed for transform */
  transform-origin: center;
}
.score-text.bump {
  animation: value-bounce 360ms cubic-bezier(0.22,1,0.36,1);
}
@keyframes value-bounce {
  0%   { transform: translateY(0) scale(1); }
  30%  { transform: translateY(-1px) scale(1.01); }
  60%  { transform: translateY(0) scale(0.998); }
  100% { transform: translateY(0) scale(1); }
}

</style>
