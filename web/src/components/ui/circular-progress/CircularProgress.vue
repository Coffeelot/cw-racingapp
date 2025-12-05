<template>
  <div
    class="progress-circle-base"
    :class="cn('relative size-40 text-2xl font-semibold', props.class)"
  >
    <svg
      fill="none"
      class="size-full"
      stroke-width="2"
      viewBox="0 0 100 100"
    >
      <circle
        v-if="currentPercent <= 90 && currentPercent >= 0"
        cx="50"
        cy="50"
        r="45"
        :stroke-width="circleStrokeWidth"
        stroke-dashoffset="0"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="gauge-secondary-stroke opacity-100"
      />
      <circle
        cx="50"
        cy="50"
        r="45"
        :stroke-width="circleStrokeWidth"
        stroke-dashoffset="0"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="gauge-primary-stroke opacity-100"
      />
    </svg>
    <span
      v-if="showPercentage"
      :data-current-value="currentPercent"
      :class="['multiplier absolute inset-0 m-auto size-fit delay-0 text-4xl mt-4', { bump: bumpMulti }]"
    >
      x{{ textInCenter ?? currentPercent }}
    </span>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { cn } from "@/lib/utils";

interface Props {
  max?: number;
  value?: number;
  min?: number;
  gaugePrimaryColor?: string;
  gaugeSecondaryColor?: string;
  class?: string;
  circleStrokeWidth?: number;
  showPercentage?: boolean;
  duration?: number;
  textInCenter?: number
}

const props = withDefaults(defineProps<Props>(), {
  max: 100,
  min: 0,
  value: 0,
  gaugePrimaryColor: "rgb(79 70 229)",
  gaugeSecondaryColor: "rgba(0, 0, 0, 0.1)",
  circleStrokeWidth: 10,
  showPercentage: true,
  duration: 1,
});

const circumference = 2 * Math.PI * 45;
const percentPx = circumference / 100;

const currentPercent = computed(() => ((props.value - props.min) / (props.max - props.min)) * 100);
const percentageInPx = computed(() => `${percentPx}px`);
const durationInSeconds = computed(() => `${props.duration}s`);

const bumpMulti = ref(false);
const ANIM_MS = 360;

watch(
  () => props.textInCenter ?? 0,
  (newVal, oldVal) => {
    if (newVal === oldVal) return;
    bumpMulti.value = true;
    setTimeout(() => (bumpMulti.value = false), ANIM_MS);
  }
);


</script>

<style scoped lang="css">
.progress-circle-base {
  --circle-size: 100px;
  --circumference: v-bind(circumference);
  --percent-to-px: v-bind(percentageInPx);
  --gap-percent: 5;
  --offset-factor: 0;
  --transition-step: 200ms;
  --percent-to-deg: 3.6deg;
  transform: translateZ(0);
  width: 3em;
  height: 3em;
}

.gauge-primary-stroke {
  stroke: var(--primary);
  --stroke-percent: v-bind(currentPercent);
  stroke-dasharray: calc(var(--stroke-percent) * var(--percent-to-px)) var(--circumference);
  transition:
    v-bind(durationInSeconds) ease,
    stroke v-bind(durationInSeconds) ease;
  transition-property: stroke-dasharray, transform;
  transform: rotate(
    calc(-90deg + var(--gap-percent) * var(--offset-factor) * var(--percent-to-deg))
  );
  transform-origin: calc(var(--circle-size) / 2) calc(var(--circle-size) / 2);
}

.gauge-secondary-stroke {
  stroke: v-bind(gaugeSecondaryColor);
  --stroke-percent: 90 - v-bind(currentPercent);
  --offset-factor-secondary: calc(1 - var(--offset-factor));
  stroke-dasharray: calc(var(--stroke-percent) * var(--percent-to-px)) var(--circumference);
  transform: rotate(
      calc(
        1turn - 90deg -
          (var(--gap-percent) * var(--percent-to-deg) * var(--offset-factor-secondary))
      )
    )
    scaleY(-1);
  transition: all v-bind(durationInSeconds) ease;
  transform-origin: calc(var(--circle-size) / 2) calc(var(--circle-size) / 2);
}

.multiplier {
  display: inline-block; /* needed for transform */
  transform-origin: center;
}
.multiplier.bump {
  animation: value-bounce-more 360ms cubic-bezier(0.22,1,0.36,1);
}
@keyframes value-bounce-more {
  0%   { transform: translateY(0) scale(1); }
  30%  { transform: translateY(-3px) scale(1.01); }
  60%  { transform: translateY(0) scale(0.998); }
  100% { transform: translateY(0) scale(1); }
}


</style>