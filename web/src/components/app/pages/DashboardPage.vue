<template>
  <div id="DashboardPage" class="page-container">
    <div class="flex gap-4 justify-between">
      <InfoHeader
        :title="translate('dashboard_page')"
        :subtitle="translate('welcome', globalStore.baseData?.data?.currentRacerName || '')"
      >
      </InfoHeader>
      <div class="flex flex-col">
        <Badge variant="outline" class="w-full mb-2" v-if="globalStore.baseData?.data?.currentCrewName">
          <CrewIcon />
          {{ globalStore.baseData?.data?.currentCrewName || translate('no_crew') }}
        </Badge>
        <span class="flex items-center gap-1 mb-2">
          <Badge v-if="globalStore.baseData?.data?.currentRacerAuth" variant="outline">
            <UserSpecificIcon />
            {{ translate("auth_type_" + globalStore.baseData?.data?.currentRacerAuth) }}
          </Badge>
          <Badge
            v-if="globalStore.baseData?.data?.currentVehicle?.model && globalStore.baseData?.data?.currentVehicle?.class"
            variant="outline"
          >
            <CarIcon />
            {{ globalStore.baseData?.data?.currentVehicle?.model }}
            [{{ globalStore.baseData?.data?.currentVehicle?.class }}]
          </Badge>
        </span>
        <div class="flex flex-col md:flex-row gap-2 mb-4 max-w-40">
          <CryptoDialog
            v-if="
              globalStore.baseData.data.currentRacerName &&
              !!globalStore.baseData?.data?.isUsingRacingCrypto
            "
          ></CryptoDialog>
        </div>
      </div>
    </div>

    <h3 class="font-semibold mb-2">{{ translate('quick_actions') }}</h3>
    <div class="mt-4 flex flex-row gap-2 mb-2">
      <Button
        class="btn btn-primary"
        @click="toggleCasualDrifting()"
      >
        {{ translate('toggle_casual_drifting') }}
      </Button>
      <Button
        class="btn btn-primary"
        @click="goToRacing('current')"
      >
        {{ translate('go_to_current_races') }}
      </Button>
      <Button
        class="btn btn-primary"
        @click="goToRacing('bounties')"
      >
        {{ translate('go_to_bounties') }}
      </Button>
      <Button
        class="btn btn-primary"
        @click="goToRacing('setup')"
      >
        {{ translate('go_to_setup_race') }}
      </Button>
    </div>
    <div class="pagecontent dashboard-content">
      <Transition name="quick-slide" mode="out-in">
        <div class="graphs-container" v-if="trackStats && trackStats.length > 0">
          <div class="item-flex-container graphs-row">
            <MostUsedTrackGraph :trackStats="trackStats" />
            <RankedGraph :trackStats="trackStats" />
            <ClassGraph :trackStats="trackStats" />
          </div>
          <div class="item-flex-container">
            <TimesGraph :trackStats="trackStats" />
          </div>
        </div>
        <InfoText v-else :title="translate('no_track_stats')" :text="translate('no_track_stats_description')" />
      </Transition>
        <div v-if="topRacerStats" class="top-racer-list flex ml-4">
          <TopRacerList :topRacerStats="topRacerStats" />
        </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import InfoHeader from "../components/InfoHeader.vue";
import { translate } from "@/helpers/translate";
import { TopRacerStats, TrackRaceStats } from "@/store/types";
import { onMounted, ref } from "vue";
import api from "@/api/axios";
import MostUsedTrackGraph from "../components/graphs/MostUsedTrackGraph.vue";
import RankedGraph from "../components/graphs/RankedGraph.vue";
import TimesGraph from "../components/graphs/TimesGraph.vue";
import ClassGraph from "../components/graphs/ClassGraph.vue";
import { useGlobalStore } from "@/store/global";
import { Button } from "@/components/ui/button";
import TopRacerList from "../components/TopRacerList.vue";
import { mockTopRacerStats, mockTrackRaceStatsForWeek } from "@/mocking/mockHelpers";
import InfoText from "../components/InfoText.vue";
import { closeApp } from "@/helpers/closeApp";
import Badge from "@/components/ui/badge/Badge.vue";
import UserSpecificIcon from "../components/UserSpecificIcon.vue";
import { CarIcon } from "lucide-vue-next";
import CryptoDialog from "../components/dialogs/CryptoDialog.vue";
import CrewIcon from "@/assets/icons/CrewIcon.vue";

const globalStore = useGlobalStore();
const trackStats = ref<TrackRaceStats[]>([]);
const topRacerStats = ref<TopRacerStats | undefined>(undefined);


const getDashboardData = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    trackStats.value = mockTrackRaceStatsForWeek() as unknown as TrackRaceStats[];
    topRacerStats.value = mockTopRacerStats();
    return
  }
  const response = await api.post("UiGetDashboardData");
  if (response.data) {
      trackStats.value = response.data.trackStats as TrackRaceStats[];
      topRacerStats.value = response.data.topRacerStats as TopRacerStats;
  }
};

const goToRacing = (tab: string) => {
  globalStore.currentTab.racing = tab;
  globalStore.$state.currentPage = 'racing';
}

const toggleCasualDrifting = () => {
  api.post('UiToggleCasualDrift');
  closeApp()
}

onMounted(() => {
  getDashboardData();
});

</script>

<style scoped>
.dashboard-content {
  display: flex;
  flex-direction: row;
  width: 100%;
  height: 100%;
  flex: 1 1 0;
  min-width: 0;
  flex-wrap: wrap;
}

.graphs-container {
  flex: 1 1 0;
  min-width: 0;
  display: flex;
  flex-direction: column;
}
.graphs-row {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
  gap: 1rem;
  width: 100%;
  flex: 1 1 0;
  min-width: 0;
}

.graphs-row > * {
  flex: 1 1 0;
  min-width: 0;
}

.top-racer-list {
  margin-top: 1em;
}
</style>