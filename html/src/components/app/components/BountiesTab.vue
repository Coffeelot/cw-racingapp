<template>
  <div class="results-container">
    <v-card class="mb-3">
      <v-card-title>{{ translate("bounties") }} </v-card-title>
      <v-card-text class="text">
        <p>{{ translate('bounties_desc') }}</p>
        <p>{{ translate('bounties_desc_2') }}</p>
      </v-card-text>
    </v-card>
    
    <div v-if="globalStore.bounties.length>0" class="bounty-list">
      <BountyItem v-for="bounty in globalStore.bounties" :key="bounty.id" :bounty="bounty"></BountyItem>
    </div>
    <div v-else>
      <InfoText :title="translate('no_bounties')"></InfoText>
    </div>
  </div>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { translate } from "@/helpers/translate";
import { onMounted } from "vue";
import BountyItem from "../items/BountyItem.vue";
import InfoText from "./InfoText.vue";
import { useGlobalStore } from "@/store/global";

const globalStore = useGlobalStore();

const getBounties = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    console.log('MOCK DATA ACTIVE. SKIPPING FETCH')
    return
  }
  const response = await api.post('UiGetBounties')
  if (response.data) {
    globalStore.bounties = response.data
  }
}

onMounted(()=> {
  getBounties()
})
</script>

<style scoped lang="scss">
.bounty-list {
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
}
</style>
