<template>
  <div id="RacingPage" class="pagecontent">
    <v-tabs
      color="primary"
      v-model="tab"
      v-if="tab !== 'setup2'"
      v-on:update:model-value="fetchRelevantData()"
    >
      <v-tab value="current">{{ translate('current') }} </v-tab>
      <v-tab value="available">{{ translate('available') }} </v-tab>
      <v-tab value="setup">{{ translate('setup') }} </v-tab>
    </v-tabs>
    <v-window v-model="tab" class="page-container">
      <v-window-item  value="current" class="tabcontent">
        <div class="current-race-container page-container">
          <div id="current-race-selection" v-if="currentRace">
            <CurrentRaceCard
              :race="currentRace"
              @leave="leaveRace()"
              @start="startRace()"
            ></CurrentRaceCard>
          </div>
          <div id="current-race-none" v-else>
            <h3 class="inline centered">{{ translate('no_races') }} </h3>
          </div>
        </div>
      </v-window-item>
      <v-window-item value="available" class="tabcontent">
        <div class="subheader">
          <h3>{{ translate('available_races') }} </h3>
          <v-btn variant="text" @click="getListedRaces"> {{ translate('refresh') }}  </v-btn>
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
            v-for="race in races"
            :race="race"
          ></AvailableRacesCard>
        </div>
        <InfoText
          v-if="races.length === 0"
          :title="translate('no_races')"
        ></InfoText>
      </v-window-item>
      <v-window-item value="setup" class="tabcontent">
        <div class="subheader">
          <h3 class="header-text">{{ translate('pick_track') }} </h3>
          <v-switch
            color="primary"
            v-model="globalStore.showOnlyCurated"
            hide-details
            density="compact"
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
        <div v-else class="page-container available-races">
          <AvailableTracksCard
            v-for="track in filteredTracks"
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
import { CurrentRace, Track } from "@/store/types";
import { closeApp } from "@/helpers/closeApp";
import { computed } from "vue";
import InfoText from "../components/InfoText.vue";
import { translate } from "@/helpers/translate";

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
        track.RaceId.toLowerCase().includes(search.value.toLowerCase())
    );

  return tracks.sort((a: Track, b: Track) =>
    a.RaceName.toLowerCase() > b.RaceName.toLowerCase() ? 1 : -1
  );
});

const resetTrackSetup = () => {
  tab.value = "setup";
  selectedTrack.value = undefined;
};

const getListedRaces = async () => {
  isLoading.value = true;
  const res = await api.post("UiGetListedRaces");
  races.value = res.data;
  isLoading.value = false;
};

const selectTrack = (track: Track) => {
  dialog.value = true;
  selectedTrack.value = track;
};

const getTracks = async () => {
  isLoading.value = true;
  const res = await api.post("UiGetAvailableTracks");
  globalStore.$state.tracks = res.data;
  isLoading.value = false;
};

const getCurrent = async () => {
  const res = await api.post("UiFetchCurrentRace");
  if (res.data.raceId) currentRace.value = res.data;
};

const leaveRace = async () => {
  if (currentRace?.value?.raceId) {
    await api.post(
      "UiLeaveCurrentRace",
      JSON.stringify(currentRace.value.raceId)
    );
    currentRace.value = undefined;
  }
};

const startRace = async () => {
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
  if (tab.value === "current") getCurrent();
  else if (tab.value === "setup") getTracks();
  else if (tab.value === "available") getListedRaces();
};

onMounted(() => {
  fetchRelevantData();
  selectedTrack.value = undefined;
});

</script>

<style scoped lang="scss">
.available-races {
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
