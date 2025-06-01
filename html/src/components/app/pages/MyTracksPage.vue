<template>
  <div id="MyTracksPage" class="pagecontent">
    <v-tabs color="primary" v-model="tab">
      <v-tab value="myTracks">{{ translate('my_tracks') }} </v-tab>
      <v-tab value="create">{{ translate('create_track') }} </v-tab>
    </v-tabs>

    <v-window v-model="tab" class="page-container">
      <v-window-item value="myTracks" class="tabcontent mt">
        <div class="subheader inline">
          <h3 class="header-text">{{ translate('my_tracks') }} </h3>
          <v-text-field
            class="text-field"
            hideDetails
            :placeholder="translate('search_dot')"
            density="compact"
            v-model="search"
          ></v-text-field>
        </div>
        <div class="mytracks-items scrollable" v-if="filtereredTracks && filtereredTracks.length>0">
          <MyTrackCard
            v-for="track in filtereredTracks"
            @update="getMyTracks"
            :track="track"
          ></MyTrackCard>
        </div>
        <InfoText :title="translate('no_data')" v-else />
        <div class="mytracks-items scrollable" v-if="globalStore.baseData.data.auth.controlAll">
          <h3 class="header-text">{{ translate('tracks') }} </h3>
          <MyTrackCard
            v-for="track in filteredAllTracks"
            @update="getMyTracks"
            :track="track"
          ></MyTrackCard>
        </div>
      </v-window-item>
      <v-window-item value="create" class="tabcontent create mt">
        <v-card class="card">
          <v-card-title> {{ translate('create_with_editor') }}  </v-card-title>
          <v-card-text>
            <v-text-field
              density="compact"
              :placeholder="translate('track_name')"
              v-model="trackName"
            />
          </v-card-text>
          <v-card-actions>
            <v-btn
              block
              color="success"
              variant="elevated"
              type="submit"
              @click="openRaceEditor()"
            >
              {{ translate('confirm') }} 
            </v-btn>
          </v-card-actions>
        </v-card>
        <v-card class="card">
          <v-card-title> {{ translate('create_with_share') }}  </v-card-title>
          <v-card-text>
            <v-text-field
              density="compact"
              :placeholder="translate('track_name')"
              v-model="trackNameShare"
            />
            <v-text-field
              density="compact"
              placeholder="Paste Checkpoints Here"
              v-model="checkpoints"
            />
          </v-card-text>
          <v-card-actions>
            <v-btn
              block
              color="success"
              variant="elevated"
              type="submit"
              @click="createRaceFromShare()"
            >
              {{ translate('confirm') }} 
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-window-item>
    </v-window>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import MyTrackCard from "../items/MyTrackCard.vue";
import { onMounted, ref } from "vue";
import api from "@/api/axios";
import { Ref } from "vue";
import { Track } from "@/store/types";
import { computed } from "vue";
import InfoText from "../components/InfoText.vue";
import { closeApp } from "@/helpers/closeApp";
import { translate } from "@/helpers/translate";

const globalStore = useGlobalStore();
const search = ref("");
const tab = ref(globalStore.currentPage);
const trackName: Ref<string | undefined> = ref(undefined);
const trackNameShare: Ref<string | undefined> = ref(undefined);
const tracks: Ref<Track[] | undefined> = ref(undefined);
const checkpoints: Ref<any | undefined> = ref(undefined);
const filtereredTracks = computed(() => {
  let fTracks = tracks?.value?.filter(
    (track) => track.CreatorName === globalStore.baseData.data.currentRacerName
  );
  if (fTracks && search.value !== "")
    fTracks = fTracks.filter(
      (track) =>
        track.RaceName.toLowerCase().includes(search.value.toLowerCase()) ||
        track.TrackId.toLowerCase().includes(search.value.toLowerCase())
    );

  return fTracks;
});

const filteredAllTracks = computed(() => {
  let fTracks = tracks.value
  if (fTracks && search.value !== "")
    fTracks = fTracks.filter(
      (track) =>
        track.RaceName.toLowerCase().includes(search.value.toLowerCase()) ||
        track.TrackId.toLowerCase().includes(search.value.toLowerCase())
    );

  return fTracks;
})

const getMyTracks = async () => {
  const response = await api.post("UiGetMyTracks");
  if (response.data) tracks.value = Object.values(response.data);
};

const openRaceEditor = async () => {
  const response = await api.post(
    "UiCreateTrack",
    JSON.stringify({ name: trackName.value })
  );
  if (response.data) closeApp();
};

const createRaceFromShare = async () => {
  const response = await api.post(
    "UiCreateTrack",
    JSON.stringify({
      name: trackNameShare.value,
      checkpoints: checkpoints.value,
    })
  );
  if (response.data) closeApp();
};

onMounted(() => {
  getMyTracks();
});
</script>

<style scoped lang="scss">
.mytracks-items {
  display: flex;
  flex-direction: column;
  margin-top: 1em;
  gap: 1em;
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
