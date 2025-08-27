<template>
    <Tabs v-model="tab" class="flex-1" @update:model-value="fetchRelevantData">
    <div class="tab-bar flex items-center justify-between">
        <TabsList>
          <TabsTrigger @click="setTab('current')" value="current">{{ translate('available_races') }}</TabsTrigger>
          <TabsTrigger @click="setTab('map')" value="map" v-if="!globalStore.baseData.data.hideMap">{{ translate('racing_map') }}</TabsTrigger>
          <TabsTrigger @click="setTab('bounties')" value="bounties">{{ translate('bounties') }}</TabsTrigger>
          <TabsTrigger @click="setTab('setup')" value="setup" v-if="globalStore.baseData.data.auth.setup">{{ translate('setup') }}</TabsTrigger>
        </TabsList>
      <Head2HeadInviteMenu v-if="globalStore.baseData.data.showH2H" />
    </div>
    <TabsContent value="current">
      <div class="current-race-container">
        <div id="current-race-selection" v-if="currentRace">
          <div class="mb-1" id="subheader">
            <h2>{{ translate('active') }}</h2>
          </div>
          <CurrentRaceCard
            :race="currentRace"
            @leave="leaveRace"
            @start="startRace"
            @cancel="cancelRace"
          />
        </div>
      </div>
      <div class="subheader mt-2">
        <h2>{{ translate('available_races') }}</h2>
      </div>
      <div v-if="isLoading" class="circular-loading-container flex justify-center items-center">
        <span class="loader"></span>
      </div>
      <div v-else class="available-races pagecontent">
        <AvailableRacesCard
          v-for="race in racesToDisplay"
          :key="race"
          :race="race"
        />
      </div>
      <InfoText
        v-if="races.length === 0"
        :title="translate('no_races')"
      />
    </TabsContent>

    <TabsContent value="map" v-if="tab === 'map'" >
      <RacingMapTab />
    </TabsContent>

    <TabsContent value="bounties" v-if="tab === 'bounties'" >
      <BountiesTab />
    </TabsContent>

    <TabsContent value="setup" v-if="tab === 'setup'" >
      <div class="subheader flex items-center gap-2">
        <h3 class="header-text">{{ translate('pick_track') }}</h3>
        <Label for="show-curated">
            {{ translate('curated_only') }}
        </Label>
        <Switch
          id="show-curated"
          :model-value="globalStore.showOnlyCurated"
          class="mr-1"
          @update:model-value="toggleCurated"
        >
        </Switch>
        <Input
          class="text-field w-64"
          :placeholder="translate('search_dot')"
          v-model="search"
        />
      </div>
      <div v-if="isLoading" class="loading-container flex justify-center items-center" id="available-races-loader">
        <span class="loader"></span>
      </div>
      <div v-else class="pagecontent available-tracks">
        <AvailableTracksCard
          v-for="track in filteredTracks"
          :key="track.TrackId"
          :track="track"
          @select="selectTrack"
        />
      </div>
    </TabsContent>
    </Tabs>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, Ref } from "vue";
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import AvailableRacesCard from "../items/AvailableRacesCard.vue";
import AvailableTracksCard from "../items/AvailableTracksCard.vue";
import CurrentRaceCard from "../items/CurrentRaceCard.vue";
import InfoText from "../components/InfoText.vue";
import { translate } from "@/helpers/translate";
import BountiesTab from "../components/BountiesTab.vue";
import RacingMapTab from "../components/RacingMapTab.vue";
import Head2HeadInviteMenu from "../components/h2h/Head2HeadInviteMenu.vue";
import { CurrentRace, Race, Track } from "@/store/types";
import { closeApp } from "@/helpers/closeApp";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Switch } from "@/components/ui/switch";
import { fakeRaces } from "@/mocking/testState";
import Label from "@/components/ui/label/Label.vue";
import { Input } from "@/components/ui/input";

const globalStore = useGlobalStore();
const tab = ref(globalStore.currentTab.racing);
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
        track.RaceName?.toLowerCase().includes(search.value.toLowerCase()) ||
        track.TrackId?.toLowerCase().includes(search.value.toLowerCase()) ||
        track.CreatorName?.toLocaleLowerCase().includes(search.value.toLowerCase())
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

    const mapped = fakeRaces.map((race) => ({...race, ExpirationTime: Date.now()}))
    races.value = mapped  as any
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

const toggleCurated = () => {
  globalStore.$state.showOnlyCurated = !globalStore.$state.showOnlyCurated;
  fetchRelevantData();
};

const cancelRace = ()  => {
  getCurrent();
  getListedRaces();
}

const setTab = (newTab: string) => {
  globalStore.currentTab.racing = newTab;
};


onMounted(() => {
  fetchRelevantData();
  selectedTrack.value = undefined;
});
</script>

<style scoped>
.tab-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-right: 0.4em;
}
.available-races {
  display: flex;
  flex-wrap: wrap;
  overflow-y: auto;
  gap: 1em;
  margin-top: 1em;
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