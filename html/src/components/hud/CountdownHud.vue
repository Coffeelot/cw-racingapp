<template>
  <Transition name="fade-scale">
    <div class="countdown" v-if="globalStore.countdown !== -1">
      <div class="countdown__wrapper">
        <TransitionGroup name="countdown-number">
          <div v-if="globalStore.countdown > 0" :key="globalStore.countdown" class="countdown__number">
            {{ globalStore.countdown }}
          </div>
          <div v-else :key="'go'" class="countdown__go">
            GO!
          </div>
        </TransitionGroup>

        <!-- Circular Progress -->
        <svg class="countdown__progress" v-if="globalStore.countdown > 0" viewBox="0 0 100 100">
          <circle class="countdown__progress-bg" cx="50" cy="50" r="45" />
          <circle
            class="countdown__progress-bar"
            cx="50"
            cy="50"
            r="45"
            :style="{
              strokeDashoffset: progressOffset,
              stroke: countdownColor
            }"
          />
        </svg>

        <!-- Decorative Elements -->
        <div class="countdown__rays" :class="{ 'animate-go': globalStore.countdown === 0 }"></div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { computed } from "vue";

const globalStore = useGlobalStore();

// Compute the progress circle offset
const progressOffset = computed(() => {
  const circumference = 2 * Math.PI * 45;
  const progress = (globalStore.countdown / 3) * circumference;
  return circumference - progress;
});

// Compute color based on countdown value
const countdownColor = computed(() => {
  switch (globalStore.countdown) {
    case 3:
      return "#ff0000";
    case 2:
      return "#ffa500";
    case 1:
      return "#ffff00";
    default:
      return "#00ff00";
  }
});
</script>

<style scoped lang="scss">
@use '@/styles/variables' as v;

.countdown {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  background: rgba(v.$background-color-dark, 0.3);
  backdrop-filter: blur(4px);
}

.countdown__wrapper {
  position: relative;
  width: 200px;
  height: 200px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.countdown__number,
.countdown__go {
  position: absolute;
  font-family: "Rajdhani", sans-serif;
  font-weight: 700;
  text-align: center;
  color: v.$text-color;
  text-shadow: 0 0 20px rgba(v.$primary-color, 0.8);
  z-index: 2;
}

.countdown__number {
  font-size: 8rem;
  background: linear-gradient(180deg, v.$text-color 0%, rgba(v.$text-color, 0.7) 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  filter: drop-shadow(0 0 15px rgba(v.$primary-color, 0.5));
}

.countdown__go {
  font-size: 6rem;
  color: v.$positive-color;
  text-shadow: 0 0 30px rgba(v.$positive-color, 0.8);
  letter-spacing: 0.1em;
  transform: scale(1.2);
}

.countdown__progress {
  position: absolute;
  width: 100%;
  height: 100%;
  transform: rotate(-90deg);

  circle {
    fill: none;
    stroke-width: 4;
    stroke-linecap: round;
    transition: stroke-dashoffset 0.95s linear;
  }
}

.countdown__progress-bg {
  stroke: rgba(v.$text-color, 0.1);
}

.countdown__progress-bar {
  stroke-dasharray: 283;
  stroke-dashoffset: 283;
  transition: stroke-dashoffset 0.95s linear, stroke 0.3s ease;
}

.countdown__rays {
  position: absolute;
  width: 300%;
  height: 300%;
  background: radial-gradient(
    circle,
    transparent 30%,
    rgba(v.$primary-color, 0) 31%,
    rgba(v.$primary-color, 0.1) 32%,
    transparent 33%
  );
  background-size: 50px 50px;
  animation: rotateRays 20s linear infinite;
  opacity: 0.3;

  &.animate-go {
    background: radial-gradient(
      circle,
      transparent 30%,
      rgba(v.$positive-color, 0) 31%,
      rgba(v.$positive-color, 0.1) 32%,
      transparent 33%
    );
    animation: rotateRaysGo 1s linear infinite;
    opacity: 0.5;
  }
}

// Animations
@keyframes rotateRays {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

@keyframes rotateRaysGo {
  from {
    transform: rotate(0deg) scale(1);
    opacity: 0.5;
  }
  to {
    transform: rotate(360deg) scale(1.5);
    opacity: 0;
  }
}

// Transition Animations
.fade-scale-enter-active,
.fade-scale-leave-active {
  transition: all 0.5s ease;
}

.fade-scale-enter-from,
.fade-scale-leave-to {
  opacity: 0;
  transform: scale(0.9);
}

.countdown-number-enter-active,
.countdown-number-leave-active {
  transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.countdown-number-enter-from {
  opacity: 0;
  transform: scale(2);
}

.countdown-number-leave-to {
  opacity: 0;
  transform: scale(0);
}

.countdown-number-move {
  transition: transform 0.5s ease;
}
</style>