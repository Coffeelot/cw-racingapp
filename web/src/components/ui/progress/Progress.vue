<script setup lang="ts">
import { computed } from "vue";

const props = defineProps<{ progress: number, class?: string }>();

const barWidth = computed(() => {
  // Clamp between 0 and 100
  return Math.max(0, Math.min(100, props.progress));
});
</script>

<template>
  <div :class="['progress-bar-outer', props.class]">
    <div class="progress-bar-inner" :style="{ width: barWidth + '%' }"></div>
  </div>
</template>

<style scoped>
.progress-bar-outer {
  width: 100%;
  height: 12px;
  background: var(--primary, #eee)20;
  border-radius: 6px;
  overflow: hidden;
}
.progress-bar-inner {
  height: 100%;
  background: var(--primary, #4f46e5);
  transition: width 0.2s;
}
</style>
