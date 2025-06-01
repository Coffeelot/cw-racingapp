<template>
  <v-sheet class="topbar">
    <div class="d-flex ga-1">
      <v-chip>{{ translate('user') }}: {{ globalStore.baseData?.data?.currentRacerName ? globalStore.baseData.data.currentRacerName: translate('user_no') }} </v-chip> 
      <v-chip>{{ translate('auth') }}: {{ globalStore.baseData?.data?.currentRacerAuth ? globalStore.baseData.data.currentRacerAuth: translate('auth_no') }} </v-chip>
      <v-chip v-if="globalStore.baseData?.data?.currentCrewName">{{ translate('crew') }}: {{ globalStore.baseData.data.currentCrewName }}</v-chip>
      <v-chip v-if="!!globalStore.baseData?.data?.currentRanking">{{ translate('rank') }}: {{ globalStore.baseData.data.currentRanking }}  </v-chip>
      <v-chip v-if="!!globalStore.baseData?.data?.currentVehicle">{{ translate('vehicle') }}: {{ globalStore.baseData.data.currentVehicle.model }} [{{ globalStore.baseData.data.currentVehicle.class }}]  </v-chip>
      <v-chip color="orange" @click="allowOpenRacingCrypto ? globalStore.showCryptoModal = true : undefined" v-if="globalStore.baseData.data.currentRacerName && !!globalStore.baseData?.data?.isUsingRacingCrypto">{{ globalStore.baseData.data.currentCrypto }} {{ globalStore.baseData.data.cryptoType }} </v-chip>
    </div>
    <div class="inline">
      <v-icon icon="mdi-signal"></v-icon>
      <v-icon icon="mdi-battery-70"></v-icon> 75%
    </div>
  </v-sheet>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { translate } from "@/helpers/translate";
import { computed } from "vue";
const globalStore = useGlobalStore();

const allowOpenRacingCrypto = computed(() => {
  return globalStore.baseData.data.allowBuyingCrypto || globalStore.baseData.data.allowSellingCrypto || globalStore.baseData.data.allowTransferCrypto
})

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
  color: $text-color;
  box-shadow: rgba(0, 0, 0, 0.15) 1.95px 1.95px 2.6px;
  user-select: none; /* Standard syntax */
  font-size: 14px;
  color: $text-color-disabled;
}

</style>
