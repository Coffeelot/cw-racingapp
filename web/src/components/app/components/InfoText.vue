<template>
  <div class="infotext">
    <h1 class="text-xl">{{ props.title }}</h1>
    <h3 v-if="props.text" class="text-muted-foreground">{{ props.text }}</h3>
  </div>
</template>

<script setup lang="ts">

const props = defineProps<{
  title: string,
  text?: string
}>();
</script>

<style scoped >
.infotext {
  width: 100%;
  display: flex;
  align-items: center;
  flex-direction: column;
  justify-content: center;
  margin-left: auto;
  margin-right: auto;
}
</style>
