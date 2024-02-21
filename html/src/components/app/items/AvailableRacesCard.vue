<template>
    <v-card class="small-card">
        <v-card-title>{{ props.race.RaceData.RaceName }}</v-card-title>
        <v-card-text class="inline standardGap">
            <v-chip prepend-icon="mdi-podium-gold" color="orange" v-if="props.race?.Ranked">Ranked</v-chip>
            <v-chip prepend-icon="mdi-hand-coin" color="green" v-if="participationText"> {{ participationText }} 
                <v-tooltip location="top" activator="parent" text="This amount is given to each participant">
                </v-tooltip>
            </v-chip>
            <v-chip prepend-icon="mdi-go-kart-track">{{ `${lapsText} ${props.race.RaceData.Distance} m`}}</v-chip>
            <v-chip prepend-icon="mdi-cash" v-if="buyInText">{{ buyInText }}</v-chip>
            <v-chip prepend-icon="mdi-cash-multiple" v-if="potText && props.race.racers > 1">{{ potText }}</v-chip>
            <v-chip prepend-icon="mdi-account-group">{{ `${props.race.racers} racer(s)` }}</v-chip>
            <v-chip prepend-icon="mdi-car-info">{{ `Class: ${props.race.MaxClass}` }}</v-chip>
            <v-chip prepend-icon="mdi-ghost" v-if="props.race.Ghosting">{{ ghostingText }}</v-chip>
            <v-chip prepend-icon="mdi-robot-dead">{{ `${props.race.RaceData.Automated ? 'Starts: ': `Expires:`} ${expirationTimeString}` }}</v-chip>
            <v-chip prepend-icon="mdi-account-star">Hosted by{{ props.race.SetupRacerName }}</v-chip>
        </v-card-text>
        <v-card-actions v-if="!props.race.disabled">
            <v-btn variant="tonal" @click='joinRace()'>Join Race</v-btn>
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

const participationText = computed(() => {
    if(props?.race?.ParticipationAmount === 0) return undefined

    if(props.race.ParticipationCurrency === 'crypto') {
        return  props.race.ParticipationAmount + ' ' + globalStore.baseData.data.cryptoType
    }

    return '$' + props.race.ParticipationAmount

})

const lapsText = computed(() => {
    let lapsText = 'Sprint | '
    if (props.race.laps > 0) {
        lapsText = props.race.Laps + ' lap(s) | '
    }
    return lapsText
})

const buyInText = computed(() => {
    let text = undefined
    if (props.race.BuyIn > 0 ) {
        text = '$' + props.race.BuyIn + ' Buy In'
    }
    return text
})

const potText = computed(() => {
    let text = undefined
    if (props.race.BuyIn > 0 ) {
        text = 'Pot: $' + props.race.racers * props.race.BuyIn
    }
    return text
})

const ghostingText = computed(() => {
    let ghostingText = ''
    if (props.race.Ghosting) {
        ghostingText = 'Active'
        if (props.race.GhostingTime) {
            ghostingText = props.race.GhostingTime+'s)'
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
