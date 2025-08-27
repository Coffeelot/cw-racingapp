<template>
  <Card class="rounded-xl border">
    <CardHeader>
      <CardTitle>{{ race.trackName }}</CardTitle>
    </CardHeader>
    <CardContent class="inline standardGap flex flex-wrap gap-2">
      <Badge v-if="race.ranked" class="bg-orange-500 text-white flex items-center gap-1">
        <i class="mdi mdi-podium-gold"></i>
        {{ translate('ranked') }}
      </Badge>
      <Badge class="flex items-center gap-1">
        <i class="mdi mdi-go-kart-track"></i>
        {{ lapsText }}
      </Badge>
      <Badge class="flex items-center gap-1">
        <i class="mdi mdi-account-group"></i>
        {{ translate('racers') }} {{ race.racers }}
      </Badge>
      <Badge class="flex items-center gap-1">
        <i class="mdi mdi-ghost"></i>
        {{ translate('ghosting') }} : {{ race.ghosting ? translate('on') : translate('off') }}
      </Badge>
      <Badge class="flex items-center gap-1">
        <i class="mdi mdi-car-info"></i>
        {{ translate('max_class') }} : {{ race.class }}
      </Badge>
      <Badge class="flex items-center gap-1">
        <i class="mdi mdi-account-star"></i>
        {{ translate('hosted_by') }} {{ race.hostName }}
      </Badge>
      <Badge v-if="race.reversed" class="flex items-center gap-1">
        <i class="mdi mdi-backup-restore"></i>
        {{ translate('reversed') }}
      </Badge>
    </CardContent>
    <CardFooter class="flex gap-2 justify-end">
      <Button
        variant="destructive"
        :loading="loadingCancel"
        @click="cancelRace()"
        v-if="race.canStart"
        class="rounded-xl"
      >
        {{ translate('cancel_race') }}
      </Button>
      <Button
        variant="destructive"
        :loading="loadingCancel"
        @click="cancelRace()"
        v-if="!race.canStart && globalStore.baseData.data.auth.cancelAll"
        class="rounded-xl"
      >
        {{ translate('cancel_race_forced') }}
      </Button>
      <Button
        variant="destructive"
        @click="leaveRace()"
        class="rounded-xl"
      >
        {{ translate('leave_race') }}
      </Button>
      <Button
        @click="startRace()"
        v-if="race.canStart"
        class="rounded-xl"
      >
        {{ translate('start_race') }}
      </Button>
      <Button
        @click="startRace()"
        v-if="!race.canStart && globalStore.baseData.data.auth.startAll"
        class="rounded-xl"
      >
        {{ translate('start_race_forced') }}
      </Button>
    </CardFooter>
  </Card>
</template>

<script setup lang="ts">
import { CurrentRace } from "@/store/types";
import { computed, ref } from "vue";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import api from "@/api/axios";
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
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

<style scoped >
</style>
