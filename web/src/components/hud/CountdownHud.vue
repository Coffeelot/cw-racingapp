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

<style scoped >
.countdown-container {
  color: #fff;
  text-shadow:1px 1px 18px black;
  font-family: "Bebas Neue", sans-serif;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.countdown-holder {
  text-align: center;
}

.number-holder {
  width: 15vh;
  height: 15vh;
  text-align: center;
  display: flex;
  align-items: center;
  justify-content: center;
}

#countdown-number {
  font-size: 20em;
  /* font-weight:900; */
  /* -webkit-text-stroke: 1px #000000; */
  text-transform: uppercase;
}

#countdown-text {
  font-size: 7vh;
  text-transform: uppercase;
  font-weight: bold;
}

.scale-enter-active,
.scale-leave-active {
  transition: all 0.1s ease;
}

.scale-enter-from,
.scale-leave-to {
  opacity: 0;
  transform: scale(0.9);
}
</style>
