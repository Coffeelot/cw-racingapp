<template>
    <v-card rounded="lg" class="available-card">
        <v-card-title>{{ props.track.RaceName}} {{ props.track.Curated? '⭐':'' }}</v-card-title>
        <v-card-text class="inline standardGap">
            <v-chip>{{ translate('creator') }} : {{ props.track.CreatorName }} </v-chip>
            <v-chip>{{ translate('length') }} : {{ props.track.Distance }}</v-chip>
        </v-card-text>
        <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn rounded="lg" variant="text" @click='showRace()'>{{ translate('show_track') }} </v-btn>
            <v-btn rounded="lg" variant="flat" color="primary" @click='startRace()'>{{ translate('setup_race') }} </v-btn>
        </v-card-actions>
        
    </v-card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { Track } from "@/store/types";
import { translate } from "@/helpers/translate";

const props = defineProps<{
  track: Track
}>()
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
    width: 49%;
    height: fit-content;
}
</style>
