<template>
    <v-card class="small-card">
        <v-card-title>{{ props.race.RaceData.RaceName + ' | Hosted by ' + props.race.SetupRacerName }}</v-card-title>
        <v-card-text class="inline standardGap">
            <v-chip prepend-icon="mdi-podium-gold" color="orange" v-if="props.race?.Ranked">Ranked</v-chip>
            <v-chip prepend-icon="mdi-go-kart-track">{{ `${lapsText} ${props.race.RaceData.Distance} m`}}</v-chip>
            <v-chip v-if="buyInText">{{ buyInText }}</v-chip>
            <v-chip prepend-icon="mdi-account-group">{{ `${props.race.racers} racer(s)` }}</v-chip>
            <v-chip  prepend-icon="mdi-car-info">{{ `Class: ${props.race.MaxClass}` }}</v-chip>
            <v-chip prepend-icon="mdi-ghost" v-if="props.race.Ghosting">{{ ghostingText }}</v-chip>
            <v-chip prepend-icon="mdi-robot-dead">{{ `${props.race.RaceData.Automated ? 'Starts: ': `Expires:`} ${expirationTimeString}` }}</v-chip>
        </v-card-text>
        <v-card-actions>
            <v-btn variant="tonal" v-if="!props.race.disabled" @click='joinRace()'>Join Race</v-btn>
        </v-card-actions>
        
    </v-card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { computed } from "vue";
const props = defineProps<{
  race: any
}>()
const globalStore = useGlobalStore();

const joinRace = async () => {
    const res = await api.post("UiJoinRace", JSON.stringify(props.race.RaceData.RaceId));
    if (res.data) closeApp()
}
const lapsText = computed(() => {
    let lapsText = 'Sprint | '
    if (props.race.laps > 0) {
        lapsText = props.race.Laps + ' lap(s) | '
    }
    return lapsText
})

const buyInText = computed(() => {
    let buyInText = ''
    if (props.race.BuyIn > 0 ) {
        buyInText = '$' + props.race.BuyIn + ' Buy In'
    }
    return buyInText
})

const ghostingText = computed(() => {
    let ghostingText = ''
    if (props.race.Ghosting) {
        ghostingText = ' | 👻'
        if (props.race.GhostingTime) {
            ghostingText = ghostingText + ' ('+props.race.GhostingTime+'s)'
        }
    }
    return ghostingText
})

const expirationTimeString = computed(() => {
    const time = new Date(props.race.ExpirationTime)
    return time.getHours() + ':' + (time.getMinutes() > 10 ? time.getMinutes() : '0'+ time.getMinutes())
})

</script>

<style scoped lang="scss"></style>
