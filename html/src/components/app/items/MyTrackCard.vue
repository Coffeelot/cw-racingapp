<template>
  <v-card class="big-card">
    <v-card-title class="title">
      <span>{{ track.RaceName }} {{ track.Curated ? " | " + "⭐" : "" }}</span>
      <v-btn small variant="text" @click="copyToClipboard()"
        >Copy Checkpoints</v-btn
      >
    </v-card-title>
    <v-card-text class="text">
      <v-chip>Track ID: {{ track.RaceId }} </v-chip>
      <v-chip>Lenght: {{ track.Distance }}m </v-chip>
      <v-chip>Checkpoints: {{ track.Checkpoints.length }}</v-chip>
      <v-chip>Made By: {{ track.CreatorName }}</v-chip>
      <v-chip v-if="track.Access?.race && track.Access.race.length > 0">Shared with: {{ track.Access.race.length }} racers</v-chip>
    </v-card-text>
    <v-card-actions>
      <v-btn variant="tonal" @click="lbDialog = true">Clear Leaderboard</v-btn>
      <v-btn variant="tonal" v-if="!track.Curated" @click="editDialog = true"
        >Edit Track</v-btn
      >
      <v-btn variant="tonal" @click="openEditAccess()">Edit Access</v-btn>
      <v-btn variant="tonal" @click="deleteDialog = true">Delete Track</v-btn>
    </v-card-actions>
  </v-card>
  <v-dialog contained v-model="lbDialog" width="auto">
    <v-card>
      <v-card-title>Clear Leaderboard for {{ track.RaceName }}?</v-card-title>
      <v-card-text> This can not be reverted. </v-card-text>
      <v-card-actions>
        <v-btn @click="lbDialog = false">
            Close Dialog
        </v-btn>
        <v-btn color="red" @click="clearLB()">
            Confirm
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog contained v-model="editDialog" width="auto">
    <v-card>
      <v-card-title>Open track editor for {{ track.RaceName }}?</v-card-title>
      <v-card-actions>
        <v-btn @click="editDialog = false">
            Close Dialog
        </v-btn>
        <v-btn @click="editTrack()">
            Confirm
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog contained v-model="accessDialog" width="auto">
    <v-card>
        <v-card-title>Access for {{ track.RaceName }}?</v-card-title>
        <v-card-text> 
            <v-text-field label="Access" v-model="access.race"></v-text-field>
            <small> *Racer Names, separated by commas</small>
        </v-card-text>
        <v-card-actions>
        <v-btn @click="accessDialog = false">
            Close Dialog
        </v-btn>
        <v-btn @click="editAccess()">
            Save
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog contained v-model="deleteDialog" width="auto">
    <v-card>
      <v-card-title>Delete track {{ track.RaceName }}?</v-card-title>
      <v-card-text> THIS IS PERMANTENT!!! </v-card-text>
      <v-card-actions>
        <v-btn @click="deleteDialog = false">
            Close Dialog
        </v-btn>
        <v-btn color="red" @click="deleteTrack()">
            Confirm
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { Track } from "@/store/types";
import { trace } from "console";
import { ref } from "vue";

const props = defineProps<{
  track: Track;
}>();
const lbDialog = ref(false);
const editDialog = ref(false);
const accessDialog = ref(false);
const deleteDialog = ref(false);
const access: any = ref(undefined)

const copyToClipboard = () => {
  const el = document.createElement("textarea");
  el.value = JSON.stringify(props.track.Checkpoints);
  document.body.appendChild(el);
  el.select();
  document.execCommand("copy");
  document.body.removeChild(el);
};

const clearLB = () => {
    api.post('UiClearLeaderboard', JSON.stringify({ RaceName: props.track.RaceName, RaceId: props.track.RaceId }))
    lbDialog.value = false;
};
const editTrack = () => {
    api.post('UiEditTrack', JSON.stringify({ RaceName: props.track.RaceName, RaceId: props.track.RaceId }))
    editDialog.value = false;
    closeApp()
};
const openEditAccess = async () => {
    const response = await api.post('UiGetAccess',  JSON.stringify({ RaceName: props.track.RaceName, RaceId: props.track.RaceId }))
    console.log('yo', JSON.stringify(response.data))
    access.value = response.data
    accessDialog.value = true;
};

const editAccess = () => {
    api.post('UiEditAccess', JSON.stringify({RaceName: props.track.RaceName, RaceId: props.track.RaceId, NewAccess: access.value}))
    accessDialog.value = false;
}

const deleteTrack = () => {
    api.post('UiDeleteTrack', JSON.stringify({ RaceName: props.track.RaceName, RaceId: props.track.RaceId }))
    deleteDialog.value = false;
};
</script>

<style scoped lang="scss">
.text {
    display: flex;
    gap: 0.5em;
    flex-wrap: wrap;
}
.title {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.available-card {
  flex-grow: 1;
}
</style>
