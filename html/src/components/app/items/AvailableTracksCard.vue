<template>
    <v-card rounded="lg" class="available-card">
        <v-card-title>{{ track.RaceName}} {{ track.Curated? '⭐':'' }}</v-card-title>
        <v-card-subtitle class="subtitle-text" v-if="track.Metadata?.description">{{ track.Metadata.description }}</v-card-subtitle>
        <v-card-text>
            <div class="inline standardGap">
                <v-chip prepend-icon="mdi-account-star">{{ translate('creator') }} : {{ track.CreatorName }} </v-chip>
                <v-chip>{{ translate('length') }} : {{ track.Distance }}</v-chip>
                <v-chip v-if="track.Metadata?.raceType && track.Metadata.raceType !== 'any_type' " prepend-icon="mdi-go-kart-track">{{ translate(track.Metadata.raceType) }}</v-chip>
            </div>
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
    width: fit-content;
    min-width: 30%;
    max-width: 49%;
    flex-grow: 1;
    height: fit-content;
}
.subtitle-text {
    white-space: pre-wrap;
}
</style>
