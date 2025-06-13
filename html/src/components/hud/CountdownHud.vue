<template>
  <div class="countdown-container">
    <div class="countdown-holder">
      <transition name="scale" mode="out-in">
        <span id="countdown-text" v-if="countdownNumber === 0">{{ translate('go') }} </span>
        <span id="countdown-text" v-else-if="countdownNumber === 10">{{ translate('get_ready') }} </span>
        <div v-else :key="countdownNumber" class="number-holder">
          <span id="countdown-number">{{ countdownNumber }}</span>
        </div>
      </transition>
    </div>
  </div>
</template>

<script setup lang="ts">
import { translate } from "@/helpers/translate";
defineProps<{
  countdownNumber?: number;
}>();

</script>

<style scoped lang="scss">
.countdown-container {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: absolute;
  top: 0;
  left: 0;
  z-index: 999;
  background: radial-gradient(
    ellipse at center,
    rgba(var(--v-theme-primary), 0.3) 0%,
    rgba(var(--v-theme-primary), 0.2) 40%,
    rgba(var(--v-theme-primary), 0) 100%
  );
  border-radius: 1vh;
}

.countdown-holder {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1vh 2vh;
  width: 100%;
  box-shadow: 0 0 20px rgba(var(--v-theme-primary), 0.1);
}

.number-holder {
  width: 20vh;
  height: 20vh;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 2vh;
  background: rgba(var(--v-theme-secondary), 0.25);
}

#countdown-number {
  font-size: 18vh;
  font-family: var(--countdown-font, 'Oswald');
  font-weight: 900;
  color: var(--font-color, white);
  text-transform: uppercase;
  text-shadow: 2px 2px 20px rgba(0, 0, 0, 0.9);
}

#countdown-text {
  font-size: 5vh;
  font-family: var(--text-font, 'Oswald');
  font-weight: bold;
  color: var(--font-color, white);
  text-transform: uppercase;
  margin-top: 1vh;
  text-shadow: 1px 1px 15px rgba(0, 0, 0, 0.7);
}

.scale-enter-active,
.scale-leave-active {
  transition: all 0.2s ease;
}

.scale-enter-from,
.scale-leave-to {
  opacity: 0;
  transform: scale(0.85);
}
</style>