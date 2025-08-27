<template>
  <div class="page-container">
    <InfoHeader
      :title="translate('bounties')"
      :subtitle="translate('bounties_desc')"
      :subsubtitle="translate('bounties_desc_2')"
    />
    <div v-if="globalStore.bounties.length > 0" class="flex pagecontent">
      <div class="item-flex-container">
        <BountyItem v-for="bounty in globalStore.bounties" :key="bounty.id" :bounty="bounty" />
      </div>
    </div>
    <div v-else>
      <InfoText :title="translate('no_bounties')" />
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
import InfoHeader from "./InfoHeader.vue";

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

onMounted(() => {
  getBounties()
})
</script>

<style scoped>
.bounty-list {
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
}
</style>
