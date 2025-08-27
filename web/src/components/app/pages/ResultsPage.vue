<template>
  <div id="ResultsPage" class="page-container">
    <Tabs v-model="tab" class="flex-1">
      <div class=" flex items-center justify-between">
        <TabsList>
          <TabsTrigger @click="setTab('results')" value="results">{{ translate('race_results') }}</TabsTrigger>
          <TabsTrigger @click="setTab('crewRank')" value="crewRank">{{ translate('crew_rankings') }}</TabsTrigger>
          <TabsTrigger @click="setTab('racerRank')" value="racerRank">{{ translate('racer_rankings') }}</TabsTrigger>
          <TabsTrigger @click="setTab('records')" value="records">{{ translate('track_records') }}</TabsTrigger>
        </TabsList>
        <div class="flex items-center gap-2">
          <Label for="curated-switch">{{ translate('curated_only') }}</Label>
          <Switch
            :model-value="globalStore.showOnlyCurated"
            :id="'curated-switch'"
            @update:model-value="() => { globalStore.showOnlyCurated = !globalStore.showOnlyCurated }"
          ></Switch>
        </div>
      </div>
      <TabsContent value="results">
        <RaceResults />
      </TabsContent>
      <TabsContent value="crewRank">
        <CrewTable />
      </TabsContent>
      <TabsContent value="racerRank">
        <RacersTable />
      </TabsContent>
      <TabsContent value="records">
        <RaceRecords />
      </TabsContent>
    </Tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import RaceResults from "../components/RaceResults.vue";
import RaceRecords from "../components/TrackRecords.vue";
import CrewTable from "../components/CrewRankings.vue";
import RacersTable from "../components/RacersRankings.vue";
import { translate } from "@/helpers/translate";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { useGlobalStore } from "@/store/global";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";

const globalStore = useGlobalStore();

const setTab = (newTab: string) => {
  globalStore.currentTab.results = newTab;
};

const tab = ref(globalStore.currentTab.results);
</script>

<style scoped>
</style>