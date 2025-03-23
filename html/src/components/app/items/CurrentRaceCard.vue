<template>
    <v-card border rounded="xl">
        <v-card-title>{{ props.race.trackName}}</v-card-title>
        <v-card-text class="inline standardGap">
            <v-chip prepend-icon="mdi-podium-gold" color="orange" v-if="props.race.ranked" :text="translate('ranked')"></v-chip>
            <v-chip prepend-icon="mdi-go-kart-track">{{ lapsText }}</v-chip>
            <v-chip prepend-icon="mdi-account-group">{{ translate('racers') }}  {{ props.race.racers }}</v-chip>
            <v-chip prepend-icon="mdi-ghost">{{ translate('ghosting') }} : {{ props.race.ghosting ? translate('on'): translate('off') }}</v-chip>
            <v-chip prepend-icon="mdi-car-info">{{ translate('max_class') }} : {{ props.race.class }} </v-chip>
            <v-chip prepend-icon="mdi-account-star">{{ translate('hosted_by') }} {{ props.race.hostName }}</v-chip>
            <v-chip v-if="props.race.reversed" prepend-icon="mdi-backup-restore" >{{ translate('reversed') }} </v-chip>
        </v-card-text>
        <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn rounded="xl" variant="flat" :loading="loadingCancel" color="red" @click='cancelRace()' v-if="props.race.canStart">{{ translate('cancel_race') }} </v-btn>
            <v-btn rounded="xl" variant="flat" :loading="loadingCancel" color="red" @click='cancelRace()' v-if="!props.race.canStart && globalStore.baseData.data.auth.cancelAll">{{ translate('cancel_race_forced') }} </v-btn>
            <v-btn rounded="xl" variant="flat" color="red" @click='leaveRace()'>{{ translate('leave_race') }} </v-btn>
            <v-btn rounded="xl" variant="flat" color="success" @click='startRace()' v-if="props.race.canStart">{{ translate('start_race') }} </v-btn>
            <v-btn rounded="xl" variant="flat" color="success" @click='startRace()' v-if="!props.race.canStart && globalStore.baseData.data.auth.startAll">{{ translate('start_race_forced') }} </v-btn>
        </v-card-actions>
        
    </v-card>
</template>

<script setup lang="ts">
import { CurrentRace } from "@/store/types";
import { computed, ref } from "vue";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import api from "@/api/axios";
const globalStore = useGlobalStore();

const props = defineProps<{
  race: CurrentRace
}>()
const emits = defineEmits(['start', 'leave', 'cancel'])

const lapsText = computed(() => {
    let lapsText = translate('sprint')
    if (props.race.laps == -1) {
        lapsText = translate('elimination') + ' '
    }
    else if (props.race.laps > 0) {
        lapsText = props.race.laps + ' ' + translate('laps')
    }
    return lapsText
})

const startRace = async () => {
    emits('start', props.race)
}

const leaveRace = async () => {
    emits('leave', props.race)
}

const loadingCancel = ref(false)

const cancelRace = async () => {
    loadingCancel.value = true
    const res = await api.post("UiCancelRace", JSON.stringify(props.race.raceId));
    if (res && res.data) {
        emits('cancel')
    }
    loadingCancel.value = false
}

</script>

<style scoped lang="scss">
</style>
