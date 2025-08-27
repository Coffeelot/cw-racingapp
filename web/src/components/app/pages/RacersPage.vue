<template>
  <div id="RacersPage" class="page-container">
    <div class="subheader inline gap-2">
      <h3 class="header-text">{{ translate('my_racers') }}</h3>
      <CreateRacerDialog v-if="globalStore.baseData?.data?.auth?.controlAll || globalStore.baseData.data.auth.control"/>
      <Input
        class="w-md"
        :placeholder="translate('search_dot')"
        v-model="search"
      />
    </div>
    <div class="flex pagecontent">
      <div class="item-flex-container" v-if="filteredRacers && filteredRacers.length > 0">
        <MyRacerCard
          v-for="racer in filteredRacers"
          :key="racer.id"
          @triggerReload="getMyRacers()"
          :racer="racer"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { MyRacer } from "@/store/types";
import { Ref, computed, onMounted, ref } from "vue";
import MyRacerCard from "../items/RacerCard.vue";
import { translate } from "@/helpers/translate";
import { Input } from "@/components/ui/input";
import CreateRacerDialog from "../components/dialogs/CreateRacerDialog.vue";
import { mockRacersResult } from "@/mocking/testState";

const globalStore = useGlobalStore();
const myRacers: Ref<MyRacer[] | undefined> = ref(undefined);
const search = ref('');

const filteredRacers = computed(() => {
  if (myRacers.value && search.value !== '')
    return myRacers.value.filter(
      (racer) =>
        racer.racername.toLowerCase().includes(search.value.toLowerCase()) ||
        racer.citizenid.toLowerCase().includes(search.value.toLowerCase())
    );
  return myRacers.value;
});

const getMyRacers = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    myRacers.value = mockRacersResult;
    return
  }
  
  const response = await api.post('UiGetRacersCreatedByUser');
  if (response.data) {
    myRacers.value = response.data;
  }
};

onMounted(() => {
  getMyRacers();
});
</script>

<style scoped>

.card {
  flex-grow: 1;
  height: fit-content;
}
.create-options {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 1em;
}
</style>