<template>
  <Card class="rounded-xl border">
    <CardHeader>
      <CardTitle>{{ race.trackName }}</CardTitle>
      <CardDescription>
       {{ translate('hosted_by') }} {{ race.hostName }}
      </CardDescription>
    </CardHeader>
    <CardContent class="inline standardGap flex flex-wrap gap-2">
      <Badge v-if="race.ranked" class="bg-orange-500 text-white flex items-center gap-1">
        <RankedIcon />
        {{ translate('ranked') }}
      </Badge>
      <Badge class="flex items-center gap-1">
        <TrackIcon />
        {{ lapsText }}
      </Badge>
      <Badge v-if="props.race.drift" variant="outline" class="flex items-center gap-1">
        <DriftIcon />
        {{ translate("drift_race") }}
      </Badge>
      <Badge variant="outline" class="flex items-center gap-1">
        <UsersIcon />
         {{ race.racers }} {{ translate('racers') }}
      </Badge>
      <Badge variant="outline" class="flex items-center gap-1">
        <GhostIcon />
        {{ translate('ghosting') }} : {{ race.ghosting ? translate('on') : translate('off') }}
      </Badge>
      <Badge variant="outline" class="flex items-center gap-1">
        <InfoIcon />
        {{ translate('max_class') }} : {{ race.class }}
      </Badge>
      <Badge v-if="race.reversed" variant="outline" class="flex items-center gap-1">
        <RotateCcw />
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
import RankedIcon from "@/assets/icons/RankedIcon.vue";
import GhostIcon from "@/assets/icons/GhostIcon.vue";
import { InfoIcon, RotateCcw, Users, UsersIcon } from "lucide-vue-next";
import DriftIcon from "@/assets/icons/DriftIcon.vue";
import TrackIcon from "@/assets/icons/TrackIcon.vue";
import CardDescription from "@/components/ui/card/CardDescription.vue";
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
