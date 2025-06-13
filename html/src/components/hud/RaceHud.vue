<template>
  <div class="race">
    <div class="race__content">
      <Transition name="slide-fade">
        <div class="race__positions left-side">
          <RacerList :racers="globalStore.activeRace.positions" />
        </div>
      </Transition>

      <Transition name="slide-fade">
        <div class="race__info right-side">
          <div class="info-group">
            <div class="track-name">
              <div class="track-name__value">{{ globalStore.activeRace.raceName }}</div>
            </div>

            <div class="position-badge" v-if="globalStore.activeRace.totalRacers && globalStore.activeRace.totalRacers !== 1">
              <div class="position-badge__value">
                <TransitionGroup name="number-change" tag="div" class="number-wrapper">
                  <span :key="'pos' + globalStore.activeRace.position" class="current">
                    {{ globalStore.activeRace.position }}
                  </span>
                </TransitionGroup>
                <span class="separator">/</span>
                <span class="total">{{ globalStore.activeRace.totalRacers }}</span>
              </div>
            </div>
          </div>

          <div class="info-group compact">
            <div class="metric-compact checkpoint">
              <v-icon icon="mdi-flag-checkered" class="metric-icon"></v-icon>
              <div class="metric-value">
                <TransitionGroup name="number-change" tag="div" class="number-wrapper">
                  <span :key="'cp' + globalStore.activeRace.currentCheckpoint">
                    {{ globalStore.activeRace.currentCheckpoint }}
                  </span>
                </TransitionGroup>
                <span>/{{ globalStore.activeRace.totalCheckpoints }}</span>
              </div>
            </div>

            <div class="metric-compact lap">
              <v-icon icon="mdi-cached" :class="['metric-icon', { 'spin': globalStore.activeRace.currentLap > 1 }]"></v-icon>
              <div class="metric-value">
                <TransitionGroup name="number-change" tag="div" class="number-wrapper">
                  <span :key="'lap' + globalStore.activeRace.currentLap">
                    {{ lapText }}
                  </span>
                </TransitionGroup>
              </div>
            </div>

            <div class="time-group">
              <div class="time-item">
                <v-icon icon="mdi-timer-sync-outline" class="pulse time-icon"></v-icon>
                <TransitionGroup name="number-change" tag="div" class="number-wrapper">
                  <span :key="'time' + globalStore.activeRace.time" class="time-value">
                    {{ msToHMS(globalStore.activeRace.time) }}
                  </span>
                </TransitionGroup>
              </div>
              <div class="time-item">
                <v-icon icon="mdi-timer-outline" class="time-icon"></v-icon>
                <TransitionGroup name="number-change" tag="div" class="number-wrapper">
                  <span :key="'total' + globalStore.activeRace.totalTime" class="time-value">
                    {{ msToHMS(globalStore.activeRace.totalTime) }}
                  </span>
                </TransitionGroup>
              </div>
              <div class="time-item best-lap">
                <v-icon icon="mdi-timer-star-outline" class="glow time-icon"></v-icon>
                <TransitionGroup name="number-change" tag="div" class="number-wrapper">
                  <span :key="'best' + globalStore.activeRace.bestLap" class="time-value">
                    {{ msToHMS(globalStore.activeRace.bestLap) }}
                  </span>
                </TransitionGroup>
              </div>
            </div>
          </div>

          <div class="ghost-indicator" v-if="globalStore.activeRace.ghosted">
            <v-icon icon="mdi-ghost-outline" class="float ghost-icon"></v-icon>
          </div>
        </div>
      </Transition>
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

const lapText = computed(() => {
  if (globalStore.activeRace.totalLaps === 0) return "Sprint";
  else if (globalStore.activeRace.totalLaps === -1)
    return `${globalStore.activeRace.currentLap}/-`;
  return `${globalStore.activeRace.currentLap}/${globalStore.activeRace.totalLaps}`;
});
</script>

<style scoped lang="scss">
@import '@/styles/variables.scss';

.race {
  position: fixed;
  top: 2vh;
  left: 0;
  right: 0;
  z-index: 100;
  font-family: 'Rajdhani', sans-serif;
  pointer-events: none;
}

.race__content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 0 1vw;
  max-width: 100vw;
}

.left-side {
  pointer-events: auto;
  margin-left: 1vw;
}

.right-side {
  pointer-events: auto;
  margin-right: 1vw;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.info-group {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 1rem;

  &.compact {
    gap: 0.75rem;
  }
}

.track-name {
  text-align: right;
  
  &__value {
    font-size: 1.1rem;
    color: $text-color;
    font-weight: 600;
    letter-spacing: 0.05em;
    text-shadow: 0 0 10px rgba($primary-color, 0.5);
  }
}

.position-badge {
  background: linear-gradient(
    135deg,
    rgba($primary-color, 0.9),
    rgba($primary-color-dark, 0.8)
  );
  padding: 0.25rem 0.75rem;
  border-radius: $border-radius;
  border: 1px solid rgba($primary-color-light, 0.3);
  box-shadow: 0 0 15px rgba($primary-color, 0.2);
  animation: pulse 2s infinite;

  &__value {
    font-size: 1.5rem;
    font-weight: 700;
    color: $text-color;
    line-height: 1;
    text-shadow: 0 0 10px rgba($text-color, 0.5);

    .current {
      color: $text-color;
    }

    .separator {
      opacity: 0.5;
      margin: 0 0.2em;
      font-size: 0.9em;
    }

    .total {
      opacity: 0.7;
      font-size: 0.9em;
    }
  }
}

.metric-compact {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.25rem 0.5rem;
  border-radius: $border-radius;
  background: rgba($background-color-lighter, 0.3);
  backdrop-filter: blur(5px);

  .metric-icon {
    color: $primary-color;
    font-size: 1.2rem;
  }

  .metric-value {
    color: $text-color;
    font-weight: 600;
    font-size: 1rem;
  }
}

.time-group {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  align-items: flex-end;
}

.time-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.15rem 0.5rem;
  border-radius: $border-radius;
  background: rgba($background-color-lighter, 0.2);
  backdrop-filter: blur(5px);

  .time-icon {
    color: $primary-color;
    font-size: 1rem;
  }

  .time-value {
    color: $text-color;
    font-size: 0.9rem;
    font-weight: 500;
  }

  &.best-lap {
    color: $primary-color-light;
    .time-value {
      color: $primary-color-light;
    }
  }
}

.ghost-indicator {
  align-self: flex-end;
  padding: 0.25rem;
  color: rgba($text-color, 0.7);
  
  .ghost-icon {
    font-size: 1.2rem;
  }
}

// Animations
@keyframes pulse {
  0% { box-shadow: 0 0 15px rgba($primary-color, 0.2); }
  50% { box-shadow: 0 0 20px rgba($primary-color, 0.4); }
  100% { box-shadow: 0 0 15px rgba($primary-color, 0.2); }
}

@keyframes float {
  0% { transform: translateY(0px); }
  50% { transform: translateY(-3px); }
  100% { transform: translateY(0px); }
}

@keyframes glow {
  0% { filter: drop-shadow(0 0 2px rgba($primary-color-light, 0.5)); }
  50% { filter: drop-shadow(0 0 5px rgba($primary-color-light, 0.8)); }
  100% { filter: drop-shadow(0 0 2px rgba($primary-color-light, 0.5)); }
}

.spin {
  animation: spin 2s linear infinite;
}

.pulse {
  animation: pulse 2s infinite;
}

.float {
  animation: float 3s ease infinite;
}

.glow {
  animation: glow 2s infinite;
}

// Transitions
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: all 0.3s ease;
}

.slide-fade-enter-from {
  opacity: 0;
  transform: translateX(-50px);
}

.slide-fade-leave-to {
  opacity: 0;
  transform: translateX(50px);
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

// Add these new styles for number transitions
.number-wrapper {
  display: inline-flex;
  position: relative;
  overflow: hidden;
  vertical-align: bottom;
}

.number-change-enter-active,
.number-change-leave-active {
  transition: all 0.3s ease;
}

.number-change-enter-from {
  opacity: 0;
  transform: translateY(-100%);
}

.number-change-leave-to {
  opacity: 0;
  transform: translateY(100%);
  position: absolute;
  left: 0;
}

.number-change-move {
  transition: transform 0.3s ease;
}

// Update position badge styles
.position-badge {
  // ... existing styles ...

  &__value {
    // ... existing styles ...
    
    .number-wrapper {
      display: inline-flex;
      min-width: 1.2em;
      justify-content: center;
    }
    
    .current {
      position: relative;
      display: inline-block;
    }
  }
}

// Update metric value styles
.metric-value {
  .number-wrapper {
    display: inline-flex;
    min-width: 1.2em;
    justify-content: center;
  }
}

// Update time value styles
.time-value {
  .number-wrapper {
    display: inline-flex;
    min-width: 3.5em;
    justify-content: flex-end;
  }
}

// Add flash animation for value changes
@keyframes flash {
  0% { color: $primary-color-light; }
  100% { color: $text-color; }
}

.flash {
  animation: flash 0.5s ease-out;
}

// ... rest of existing styles ...
</style>
