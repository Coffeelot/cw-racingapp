<template>
  <div id="MyTracksPage" class="pagecontent">
    <v-tabs v-model="tab">
      <v-tab value="myTracks">My Tracks</v-tab>
      <v-tab value="create">Create Track</v-tab>
    </v-tabs>

    <v-window v-model="tab">
      <v-window-item value="myTracks" class="tabcontent mt">
        <div class="subheader inline">
          <h3 class="header-text">My Tracks</h3>
          <v-text-field
            class="text-field"
            hideDetails
            placeholder="Search..."
            density="compact"
            v-model="search"
          ></v-text-field>
        </div>
        <div class="mytracks-items" v-if="filtereredTracks">
          <MyTrackCard
            v-for="track in filtereredTracks"
            :track="track"
          ></MyTrackCard>
        </div>
        <InfoText title="No Tracks" v-else />
      </v-window-item>
      <v-window-item value="create" class="tabcontent create mt">
        <v-card class="card">
          <v-card-title> Create With Race Editor </v-card-title>
          <v-card-text>
            <v-text-field
              density="compact"
              placeholder="Track Name"
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
              Confirm
            </v-btn>
          </v-card-actions>
        </v-card>
        <v-card class="card">
          <v-card-title> Create With track Share </v-card-title>
          <v-card-text>
            <v-text-field
              density="compact"
              placeholder="Track Name"
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
              Confirm
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
  if (fTracks && search.value !== '') fTracks = fTracks.filter((track) => track.RaceName.toLowerCase().includes(search.value.toLowerCase()) || track.RaceId.toLowerCase().includes(search.value.toLowerCase()) )

  return fTracks;
});

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
