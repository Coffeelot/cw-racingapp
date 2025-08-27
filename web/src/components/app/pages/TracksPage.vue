<template>
  <div id="MyTracksPage" class="page-container">
    <div class="subheader inline gap-2">
      <h3 class="header-text">{{ translate('my_tracks') }}</h3>
      <CreateTrackDialog v-if="globalStore.baseData?.data?.auth?.controlAll || globalStore.baseData.data.auth.create"/>
      <Input
        class="w-md"
        :placeholder="translate('search_dot')"
        v-model="search"
      />
    </div>
    <div class="pagecontent">
      <div class="tracks-flex" v-if="filtereredTracks && filtereredTracks.length > 0">
        <MyTrackCard
          v-for="track in filtereredTracks"
          :key="track.TrackId"
          @update="getMyTracks"
          :track="track"
        />
      </div>
      <InfoText :title="translate('no_data')" v-else />
      <h3 class="header-text mt-3">{{ translate('tracks') }}</h3>
      <div class="tracks-flex" v-if="globalStore.baseData.data.auth.controlAll">
        <MyTrackCard
          v-for="track in filteredAllTracks"
          :key="track.TrackId"
          @update="getMyTracks"
          :track="track"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import MyTrackCard from "../items/TrackCard.vue";
import { onMounted, ref, computed } from "vue";
import api from "@/api/axios";
import { Ref } from "vue";
import { Track } from "@/store/types";
import InfoText from "../components/InfoText.vue";
import { translate } from "@/helpers/translate";
import { Input } from "@/components/ui/input";
import CreateTrackDialog from "../components/dialogs/CreateTrackDialog.vue";
import { testState } from "@/mocking/testState";

const globalStore = useGlobalStore();
const search = ref("");
const tracks: Ref<Track[] | undefined> = ref(undefined);

const filtereredTracks = computed(() => {
  let fTracks = tracks?.value?.filter(
    (track) => track.CreatorName === globalStore.baseData.data.currentRacerName
  );
  if (fTracks && search.value !== "")
    fTracks = fTracks.filter(
      (track) =>
        track.RaceName?.toLowerCase().includes(search.value.toLowerCase()) ||
        track.TrackId?.toLowerCase().includes(search.value.toLowerCase())
    );

  return fTracks;
});

const filteredAllTracks = computed(() => {
  let fTracks = tracks.value;
  if (fTracks && search.value !== "")
    fTracks = fTracks.filter(
      (track) =>
        track.RaceName?.toLowerCase().includes(search.value.toLowerCase()) ||
        track.TrackId?.toLowerCase().includes(search.value.toLowerCase())
    );

  return fTracks;
});

const getMyTracks = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    tracks.value = testState.tracks as unknown as Track[];
    return
  }
  const response = await api.post("UiGetTracks");
  if (response.data) tracks.value = Object.values(response.data);
};


onMounted(() => {
  getMyTracks();
});
</script>

<style scoped>
.tracks-flex {
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
  margin-top: 1em;
}

.card {
  flex-grow: 1;
  height: fit-content;
}
.create {
  display: flex;
  gap: 1em;
}
</style>