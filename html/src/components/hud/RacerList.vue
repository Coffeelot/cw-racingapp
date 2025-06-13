<template>
  <div class="racers-holder">
    <TransitionGroup name="position-change">
      <div
        class="box"
        v-for="(racer, index) in shortenedRacers"
        :key="racer.RacerName"
        :class="{
          'me': index === globalStore.activeRace.position-1,
          'finished': racer.Finished
        }"
      >
        <div class="position-wrapper">
          <div class="number">{{ index + 1 }}</div>
          <div class="position-change-indicator" :class="getPositionChangeClass(racer)">
            <i class="fas" :class="getPositionChangeIcon(racer)"></i>
          </div>
        </div>
        <div class="racer-info">
          <span class="name">{{ racer.RacerName }}</span>
          <span class="difference" v-if="index === 0 && racer.Finished">{{ translate('winner') }}</span>
          <span class="difference" v-else-if="racer.Finished">{{ translate('finished') }}</span>
          <span class="difference" v-else-if="index !== globalStore.activeRace.position-1">
            {{ getTimeDifference(racers[globalStore.activeRace.position - 1], racer) }}
          </span>
        </div>
      </div>
    </TransitionGroup>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { ActiveRacer } from "../../store/types";
import { computed, ref, watch } from "vue";
import { translate } from "@/helpers/translate";

const props = defineProps<{
  racers: ActiveRacer[];
}>();

const globalStore = useGlobalStore();
const previousPositions = ref(new Map<string, number>());

const shortenedRacers = computed(() =>
  props.racers?.slice(
    0,
    globalStore.baseData?.data?.hudSettings?.maxPositions || 10
  )
);

watch(() => props.racers, (newRacers) => {
  // Store previous positions before update
  newRacers?.forEach((racer, index) => {
    if (!previousPositions.value.has(racer.RacerName)) {
      previousPositions.value.set(racer.RacerName, index);
    }
  });

  // Update positions for next comparison
  setTimeout(() => {
    previousPositions.value = new Map(
      newRacers?.map((racer, index) => [racer.RacerName, index]) || []
    );
  }, 100);
}, { deep: true });

const getPositionChangeClass = (racer: ActiveRacer) => {
  const currentPos = props.racers?.findIndex(r => r.RacerName === racer.RacerName) || 0;
  const previousPos = previousPositions.value.get(racer.RacerName) || currentPos;
  
  if (currentPos < previousPos) return 'position-up';
  if (currentPos > previousPos) return 'position-down';
  return '';
};

const getPositionChangeIcon = (racer: ActiveRacer) => {
  const currentPos = props.racers?.findIndex(r => r.RacerName === racer.RacerName) || 0;
  const previousPos = previousPositions.value.get(racer.RacerName) || currentPos;
  
  if (currentPos < previousPos) return 'fa-chevron-up';
  if (currentPos > previousPos) return 'fa-chevron-down';
  return '';
};

const formatTimeDifference = (timeDiffMs: number): string => {
  if (timeDiffMs === 0) {
    return "0.000";
  }

  const isAhead = timeDiffMs > 0;
  const absoluteDiffSeconds = Math.abs(timeDiffMs) / 1000;

  // Format to 3 decimal places
  const formattedTime = absoluteDiffSeconds.toFixed(3);

  return isAhead ? `+${formattedTime}` : `-${formattedTime}`;
};

const getTimeDifference = (racer1: ActiveRacer, racer2: ActiveRacer) => {
  const racer1Checkpoints = racer1.CheckpointTimes.length;
  const racer2Checkpoints = racer2.CheckpointTimes.length;

  if (racer1Checkpoints === 0 || racer2Checkpoints === 0) {
    return ''; // Not enough data to compare
  }

  const lastCommonCheckpoint = Math.min(racer1Checkpoints, racer2Checkpoints) - 1;
  const racer1Time = racer1.CheckpointTimes[lastCommonCheckpoint].time;
  const racer2Time = racer2.CheckpointTimes[lastCommonCheckpoint].time;

  const timeDifference = formatTimeDifference(racer2Time - racer1Time);

  return timeDifference;
};
</script>

<style scoped lang="scss">
@import '@/styles/variables.scss';

.racers-holder {
  display: flex;
  flex-direction: column;
  gap: 0.5em;
  padding: 0.5em;
  font-family: 'Formula1', sans-serif;
}

.box {
  background: linear-gradient(
    to right,
    rgba($background-color-lighter, 0.95),
    rgba($background-color-lighter, 0.7)
  );
  width: 100%;
  font-size: 1em;
  height: 3em;
  display: flex;
  align-items: center;
  padding: 0 0.5em;
  border-left: 4px solid $primary-color;
  border-radius: 0 $border-radius $border-radius 0;
  backdrop-filter: blur(5px);
  transition: all 0.3s ease;

  &.me {
    background: linear-gradient(
      to right,
      rgba($primary-color, 0.95),
      rgba($primary-color-dark, 0.8)
    );
    border-left-color: $secondary-color;
    .number {
      background: $secondary-color;
      color: $background-color-dark;
    }
    .name {
      color: $text-color;
    }
  }

  &.finished {
    border-left-color: $positive-color;
    .number {
      background: $positive-color;
    }
  }
}

.position-wrapper {
  display: flex;
  align-items: center;
  gap: 0.5em;
  min-width: 4em;
}

.number {
  background: $primary-color;
  color: $text-color;
  width: 2em;
  height: 2em;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: $border-radius;
  font-weight: bold;
  font-size: 1.1em;
  transition: background-color 0.3s ease;
}

.racer-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex: 1;
  padding: 0 1em;
}

.name {
  color: $text-color;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  max-width: 20em;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.difference {
  color: $text-color;
  font-weight: 500;
  font-size: 0.9em;
  min-width: 5em;
  text-align: right;
}

.position-change-indicator {
  width: 1.2em;
  text-align: center;
  transition: all 0.3s ease;
  
  &.position-up {
    color: $positive-color;
    animation: slideUp 0.3s ease-out;
  }
  
  &.position-down {
    color: $negative-color;
    animation: slideDown 0.3s ease-out;
  }
}

// Position change transition
.position-change-move {
  transition: transform 0.5s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(100%);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes slideDown {
  from {
    transform: translateY(-100%);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

// Add smooth transitions for position changes
.position-change-enter-active,
.position-change-leave-active {
  transition: all 0.5s ease;
}

.position-change-enter-from,
.position-change-leave-to {
  opacity: 0;
  transform: translateX(30px);
}
</style>
