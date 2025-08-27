<template>
  <div class="flex flex-col gap-1 mb-4">
    <div class="flex flex-row items-center justify-between">
      <h1 class="text-2xl font-bold">{{ title }}</h1>
      <div v-if="$slots.actions">
        <slot name="actions" />
      </div>
    </div>
    <div v-if="subtitle" class="text-muted-foreground text-base">{{ subtitle }}</div>
    <div v-if="subsubtitle" class="text-muted-foreground text-sm">{{ subsubtitle }}</div>
    <div v-if="$slots.default" class="flex flex-row gap-2 mt-2">
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  title: string
  subtitle?: string
  subsubtitle?: string
}>();
</script>
<style scoped>
h1 {
  text-transform: capitalize;
}
</style>