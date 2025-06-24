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
        <RaceResults></RaceResults>
      </v-window-item>
      <v-window-item value="crewRank" class="tabcontent">
        <CrewTable></CrewTable>
      </v-window-item>
      <v-window-item value="racerRank" class="tabcontent">
        <RacersTable></RacersTable>
      </v-window-item>
      <v-window-item value="records" class="tabcontent">
        <RaceRecords></RaceRecords>
      </v-window-item>
    </v-window>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { ref } from "vue";
import RaceResults from "../components/RaceResults.vue";
import RaceRecords from "../components/RaceRecords.vue";
import CrewTable from "../components/CrewTable.vue";
import RacersTable from "../components/RacersTable.vue";
import { translate } from "@/helpers/translate";

const globalStore = useGlobalStore();
const tab = ref(globalStore.currentTab);

</script>

<style scoped lang="scss"></style>
