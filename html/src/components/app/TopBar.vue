<template>
  <div class="topbar">
    <div>
      User: <span id="racer-name"> {{ globalStore.baseData?.data?.currentRacerName ? globalStore.baseData.data.currentRacerName: 'no user' }}</span> | Auth:
      <span id="racer-auth"> {{ globalStore.baseData?.data?.currentRacerAuth ? globalStore.baseData.data.currentRacerAuth: 'no auth' }}</span>
    </div>
    <div class="inline">
      <v-icon icon="mdi-signal"></v-icon>
      <v-icon icon="mdi-battery-70"></v-icon> 75%
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
const globalStore = useGlobalStore();


</script>

<style scoped lang="scss">

.topbar {
  user-select: none; /* Standard syntax */
  display: flex;
  justify-content: space-between;
  padding-top: 5px;
  padding-bottom: 5px;
  padding-left: 10px;
  padding-right: 10px;
  background-color: $background-color-dark;
  color: $text-color;
  box-shadow: rgba(0, 0, 0, 0.15) 1.95px 1.95px 2.6px;
}

#racer-name,
#racer-auth {
  user-select: none; /* Standard syntax */
  font-size: 14px;
  color: $text-color-disabled;
}

</style>
