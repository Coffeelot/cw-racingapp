<template>
  <div id="ResultsPage" class="pagecontent">
    <v-tabs color="primary" v-model="tab">
      <v-tab value="results">{{ translate('race_results') }} </v-tab>
      <v-tab value="crewRank">{{ translate('crew_rankings') }} </v-tab>
      <v-tab value="racerRank">{{ translate('racer_rankings') }} </v-tab>
      <v-tab value="records">{{ translate('track_records') }} </v-tab>
    </v-tabs>

    <v-window v-model="tab">
      <v-window-item value="results" class="tabcontent">
        <RaceResults v-if="allResults" :allResults="allResults"></RaceResults>
        <InfoText v-else :title="translate('no_data')" />
      </v-window-item>
      <v-window-item value="crewRank" class="tabcontent">
        <CrewTable></CrewTable>
      </v-window-item>
      <v-window-item value="racerRank" class="tabcontent">
        <RacersTable></RacersTable>
      </v-window-item>
      <v-window-item value="records" class="tabcontent">
        <RaceRecords v-if="allRecords" :allRecords="allRecords"></RaceRecords>
        <InfoText v-else :title="translate('no_data')" />
      </v-window-item>
    </v-window>
  </div>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { Ref, onMounted, ref } from "vue";
import RaceResults from "../components/RaceResults.vue";
import { Track, ResultData } from "@/store/types";
import RaceRecords from "../components/RaceRecords.vue";
import InfoText from "../components/InfoText.vue";
import CrewTable from "../components/CrewTable.vue";
import RacersTable from "../components/RacersTable.vue";
import { translate } from "@/helpers/translate";

const allResults: Ref<ResultData | undefined> = ref(undefined);
const allRecords: Ref<Track[] | undefined> = ref(undefined);
const globalStore = useGlobalStore();
const tab = ref(globalStore.currentTab);

const getResults = async () => {
  const response = await api.post("UiGetRacingResults");
  if (response.data) allResults.value = response.data as ResultData;
};
const getRecords = async () => {
  const response = await api.post("UiGetRaces");
  if (response.data) allRecords.value = response.data;
};

onMounted(() => {
  getResults();
  getRecords();
});
</script>

<style scoped lang="scss"></style>
