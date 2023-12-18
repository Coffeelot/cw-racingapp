<template>
    <v-card class="big-card">
        <v-card-title>{{ props.race.trackName}}</v-card-title>
        <v-card-text class="inline standardGap">
            <v-chip>Max Class: {{ props.race.class }} </v-chip>
            <v-chip>{{ props.race.laps === 0 ? 'Sprint' : 'Laps: ' + props.race.laps }}</v-chip>
            <v-chip>Current Racers: {{ props.race.racers }}</v-chip>
            <v-chip>Ghosting: {{ props.race.ghosting ? 'On': 'Off' }}</v-chip>
        </v-card-text>
        <v-card-actions>
            <v-btn variant="tonal" @click='leaveRace()'>Leave Race</v-btn>
            <v-btn variant="tonal" @click='startRace()' v-if="!props.race.cantStart">Start Race</v-btn>
        </v-card-actions>
        
    </v-card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { CurrentRace } from "@/store/types";


const props = defineProps<{
  race: CurrentRace
}>()
const globalStore = useGlobalStore();
const emits = defineEmits(['start', 'leave'])

const startRace = async () => {
    emits('start', props.race)
}
const leaveRace = async () => {
    emits('leave', props.race)
}
</script>

<style scoped lang="scss">
.available-card {
    flex-grow: 1;
}
</style>
