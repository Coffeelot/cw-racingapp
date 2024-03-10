<template>
    <v-card class="available-card">
        <v-card-title>{{ props.track.RaceName}} {{ props.track.Curated? '⭐':'' }}</v-card-title>
        <v-card-text class="inline standardGap">
            <v-chip>Creator: {{ props.track.CreatorName }} </v-chip>
            <v-chip>Length: {{ props.track.Distance }}</v-chip>
        </v-card-text>
        <v-card-actions>
            <v-btn variant="tonal" @click='showRace()'>Show Track</v-btn>
            <v-btn variant="tonal" @click='startRace()'>Setup Race</v-btn>
        </v-card-actions>
        
    </v-card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { Track } from "@/store/types";

const props = defineProps<{
  track: Track
}>()
const globalStore = useGlobalStore();
const emits = defineEmits(['select'])

const showRace = async () => {
    const res = await api.post("UiShowTrack", JSON.stringify(props.track.RaceId));
    if (res.data) closeApp()
}

const startRace = async () => {
    emits('select', props.track)
}
</script>

<style scoped lang="scss">
.available-card {
    flex-grow: 1;
    height: fit-content;
}
</style>
