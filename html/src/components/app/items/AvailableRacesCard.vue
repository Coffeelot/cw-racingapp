<template>
    <v-card rounded="lg" class="small-card">
        <v-card-title>{{ props.race.RaceData.RaceName }}</v-card-title>
        <v-card-text class="inline standardGap">
            <v-chip prepend-icon="mdi-podium-gold" color="orange" v-if="props.race?.Ranked">{{ translate('ranked') }} </v-chip>
            <v-chip prepend-icon="mdi-hand-coin" color="green" v-if="race.ParticipationAmount"> {{ participationText }} 
                <v-tooltip location="top" activator="parent" :text="translate('participation_info')">
                </v-tooltip>
            </v-chip>
            <v-chip prepend-icon="mdi-go-kart-track">{{ `${lapsText} ${props.race.RaceData.Distance} m`}}</v-chip>
            <v-chip prepend-icon="mdi-cash" v-if="buyInText">{{ buyInText }}</v-chip>
            <v-chip prepend-icon="mdi-cash-multiple" v-if="potText && props.race.racers > 1">{{ potText }}</v-chip>
            <v-chip prepend-icon="mdi-account-group">{{ `${props.race.racers} ${translate('racers')}` }}</v-chip>
            <v-chip prepend-icon="mdi-car-info" v-if="props.race.MaxClass">{{ `${translate('class')}: ${props.race.MaxClass}` }}</v-chip>
            <v-chip prepend-icon="mdi-ghost" v-if="props.race.Ghosting">{{ ghostingText }}</v-chip>
            <v-chip prepend-icon="mdi-eye-lock" v-if="props.race.FirstPerson">{{ translate('first_person') }}</v-chip>
            <v-chip prepend-icon="mdi-robot-dead">{{ `${props.race.RaceData.Automated ? translate('starts') : `${translate('expires')}:`} ${expirationTimeString}` }}</v-chip>
            <v-chip v-if="props.race.Reversed" prepend-icon="mdi-backup-restore" >{{ translate('reversed') }} </v-chip>
            <v-chip prepend-icon="mdi-account-star">{{ translate('hosted_by') }} {{ props.race.SetupRacerName }}</v-chip>
        </v-card-text>
        <v-card-actions v-if="!props.race.disabled">
            <v-spacer></v-spacer>
            <v-btn rounded="lg" variant="text" @click='showRace()'>{{ translate('show_track') }} </v-btn>
            <v-btn rounded="lg" variant="flat" color="success" @click='joinRace()'>{{ translate('join_race') }} </v-btn>
        </v-card-actions>
    </v-card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { translate } from "@/helpers/translate";
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
    if(props.race.ParticipationCurrency === 'crypto') {
        return  props.race.ParticipationAmount + ' ' + globalStore.baseData.data.cryptoType
    }

    return '$' + props.race.ParticipationAmount

})

const lapsText = computed(() => {
    let lapsText = 'Sprint | '
    if (props.race.laps == -1) {
        lapsText = 'Elimination | '
    }
    else if (props.race.laps > 0) {
        lapsText = props.race.Laps + " "+  translate('laps') + ' | '
    }
    return lapsText
})

const buyInText = computed(() => {
    let text = undefined
    if (props.race.BuyIn > 0 ) {
        text = '$' + props.race.BuyIn + " " + translate('buy_in')
    }
    return text
})

const potText = computed(() => {
    let text = undefined
    if (props.race.BuyIn > 0 ) {
        text = translate('pot') + ': ' + props.race.racers * props.race.BuyIn
    }
    return text
})

const ghostingText = computed(() => {
    let ghostingText = ''
    if (props.race.Ghosting) {
        ghostingText = translate('active')
        if (props.race.GhostingTime) {
            ghostingText = props.race.GhostingTime+'s)'
        }
    }
    return ghostingText
})

const showRace = async () => {
    const res = await api.post("UiShowTrack", JSON.stringify(props.race.RaceId));
    if (res.data) closeApp()
}


const expirationTimeString = computed(() => {
    const time = new Date(props.race.ExpirationTime)
    return time.getHours() + ':' + (time.getMinutes() > 10 ? time.getMinutes() : '0'+ time.getMinutes())
})

</script>

<style scoped lang="scss"></style>
