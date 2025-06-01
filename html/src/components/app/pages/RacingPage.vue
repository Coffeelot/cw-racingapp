<template>
  <div id="RacingPage" class="pagecontent">
   <div class="tab-bar">
      <v-tabs
        color="primary"
        v-model="tab"
        v-if="tab !== 'setup2'"
        v-on:update:model-value="fetchRelevantData()"
      >
        <v-tab value="current">{{ translate('available_races') }} </v-tab>
        <v-tab value="map" v-if="!globalStore.baseData.data.hideMap">{{ translate('racing_map') }}</v-tab>
        <v-tab value="bounties">{{ translate('bounties') }} </v-tab>
        <v-tab value="setup" v-if="globalStore.baseData.data.auth.setup">{{ translate('setup') }} </v-tab>
      </v-tabs>
      <Head2HeadInviteMenu v-if="globalStore.baseData.data.showH2H"></Head2HeadInviteMenu>
    </div>
    <v-window v-model="tab" class="page-container">
      <v-window-item  value="current" class="tabcontent">

        <div class="current-race-container">
          <div id="current-race-selection" v-if="currentRace">
            <div class="mb-1" id="subheader">
              <h3>{{ translate('active') }} </h3>
            </div>
            <CurrentRaceCard
              :race="currentRace"
              @leave="leaveRace()"
              @start="startRace()"
              @cancel="cancelRace()"
            ></CurrentRaceCard>
          </div>
        </div>
        <div class="subheader mt-2">
          <h3>{{ translate('available_races') }} </h3>
        </div>

        <div
          v-if="isLoading"
          class="loading-container"
          id="available-races-loader"
        >
          <span class="loader"></span>
        </div>
        <div v-else class="available-races">
          <AvailableRacesCard
            v-for="race in racesToDisplay"
            :key="race"
            :race="race"
          ></AvailableRacesCard>
        </div>
        <InfoText
          v-if="races.length === 0"
          :title="translate('no_races')"
        ></InfoText>
      </v-window-item>
      <v-window-item  value="map" class="tabcontent">
        <RacingMapTab></RacingMapTab>
      </v-window-item>
      <v-window-item  value="bounties" class="tabcontent">
        <BountiesTab></BountiesTab>
      </v-window-item>
      <v-window-item value="setup" class="tabcontent">
        <div class="subheader">
          <h3 class="header-text">{{ translate('pick_track') }} </h3>
          <v-switch
            color="primary"
            v-model="globalStore.showOnlyCurated"
            hide-details
            density="compact"
            class="mr-1"
          >
            <template #label>
              {{
                globalStore.showOnlyCurated
                  ? translate('showing_curated')
                  : translate('showing_all')
              }}
            </template>
          </v-switch>
          <v-text-field
            color="primary"
            class="text-field"
            hideDetails
            :placeholder="translate('search_dot')"
            density="compact"
            v-model="search"
          ></v-text-field>
        </div>
        <div
          v-if="isLoading"
          class="loading-container"
          id="available-races-loader"
        >
          <span class="loader"></span>
        </div>
        <div v-else class="page-container available-tracks">
          <AvailableTracksCard
            v-for="track in filteredTracks"
            :key="track.TrackId"
            :track="track"
            @select="(track) => selectTrack(track)"
          ></AvailableTracksCard>
        </div>
      </v-window-item>
    </v-window>
  </div>
  <SetupRaceDialog
    v-if="selectedTrack"
    :open="!!selectedTrack"
    :track="selectedTrack"
    @goBack="resetTrackSetup()"
  ></SetupRaceDialog>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { Ref, ref } from "vue";
import AvailableRacesCard from "../items/AvailableRacesCard.vue";
import AvailableTracksCard from "../items/AvailableTracksCard.vue";
import CurrentRaceCard from "../items/CurrentRaceCard.vue";
import SetupRaceDialog from "../components/SetupRaceDialog.vue";
import { onMounted } from "vue";
import { CurrentRace, Race, Track } from "@/store/types";
import { closeApp } from "@/helpers/closeApp";
import { computed } from "vue";
import InfoText from "../components/InfoText.vue";
import { translate } from "@/helpers/translate";
import BountiesTab from "../components/BountiesTab.vue";
import RacingMapTab from "../components/RacingMapTab.vue";
import Head2HeadInvite from "../components/Head2HeadInvite.vue";
import Head2HeadInviteMenu from "../components/Head2HeadInviteMenu.vue";

const globalStore = useGlobalStore();
const tab = ref(globalStore.currentPage);
const isLoading = ref(false);
const races = ref([]);
const dialog = ref(false);
const search = ref("");
const selectedTrack: Ref<Track | undefined> = ref(undefined);
const currentRace: Ref<CurrentRace | undefined> = ref(undefined);

const filteredTracks = computed(() => {
  let tracks = globalStore.tracks;
  if (globalStore.showOnlyCurated)
    tracks = tracks?.filter((track: Track) => !!track.Curated);
  if (tracks && search.value !== "")
    tracks = tracks.filter(
      (track) =>
        track.RaceName.toLowerCase().includes(search.value.toLowerCase()) ||
        track.TrackId.toLowerCase().includes(search.value.toLowerCase()) ||
        track.CreatorName.toLocaleLowerCase().includes(search.value.toLowerCase())
    );

  return tracks.sort((a: Track, b: Track) =>
    a.RaceName.toLowerCase() > b.RaceName.toLowerCase() ? 1 : -1
  );
});

const resetTrackSetup = () => {
  tab.value = "setup";
  selectedTrack.value = undefined;
};

const racesToDisplay = computed(() => races.value.filter((race: Race) => !race.Started && !race.Hidden))

const getListedRaces = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    console.log('MOCK DATA ACTIVE. SKIPPING FETCH')
    return
  }
  isLoading.value = true;
  const res = await api.post("UiGetListedRaces");
  races.value = res.data ;
  isLoading.value = false;
};

const selectTrack = (track: Track) => {
  dialog.value = true;
  selectedTrack.value = track;
};

const getTracks = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    console.log('MOCK DATA ACTIVE. SKIPPING FETCH')
    return
  }
  isLoading.value = true;
  const res = await api.post("UiGetAvailableTracks");
  globalStore.$state.tracks = res.data;
  isLoading.value = false;
};

const getCurrent = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    console.log('MOCK DATA ACTIVE. SKIPPING FETCH')
    return
  }
  const res = await api.post("UiFetchCurrentRace");
  if (res.data.raceId) {
    currentRace.value = res.data;
  } else {
    currentRace.value = undefined
  }
};

const leaveRace = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    console.log('MOCK DATA ACTIVE. SKIPPING POST')
    return
  }
  if (currentRace?.value?.raceId) {
    await api.post(
      "UiLeaveCurrentRace",
      JSON.stringify(currentRace.value.raceId)
    );
    currentRace.value = undefined;
  }
};

const startRace = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    console.log('MOCK DATA ACTIVE. SKIPPING FETCH')
    return
  }
  if (currentRace?.value?.raceId) {
    await api.post(
      "UiStartCurrentRace",
      JSON.stringify(currentRace.value.raceId)
    );
    currentRace.value = undefined;
    closeApp();
  }
};

const fetchRelevantData = () => {
  if (tab.value === "current"){ 
    getListedRaces();
    getCurrent();
  }
  else if (tab.value === "setup") getTracks();
};

const cancelRace = ()  => {
  getCurrent();
  getListedRaces();
}

onMounted(() => {
  fetchRelevantData();
  selectedTrack.value = undefined;
});

</script>

<style scoped lang="scss">
.tab-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-right: 0.4em;
}
.available-races {
  display: flex;
  flex-direction: column;
  flex-wrap: wrap;
  overflow-y: auto;
  gap: 1em;
  margin-top: 1em;
  margin-left: 0;
  margin-right: 0;
  width: fit-content;
}

.available-tracks {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  overflow-y: auto;
  gap: 1em;
  margin-top: 1em;
  margin-left: 0;
  margin-right: 0;
  width: 100%;
}
</style>
