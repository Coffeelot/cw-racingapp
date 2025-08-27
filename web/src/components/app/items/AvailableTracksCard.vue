<template>
  <Card class="available-card rounded-xl border">
    <CardHeader>
      <CardTitle>{{ track.RaceName }}</CardTitle>
      <CardDescription v-if="track.Metadata?.description" class="subtitle-text">
        {{ track.Metadata.description }}
      </CardDescription>
    </CardHeader>
    <CardContent>
      <div class="inline standardGap flex flex-wrap gap-2">
        <Badge v-if="track.Curated" variant="outline" class="flex items-center gap-1">
          <StarIcon />
          {{ translate('curated') }}
        </Badge>
        <Badge
            variant="outline" class="flex items-center gap-1">
          <CompassIcon />
          {{ translate('creator') }} : {{ track.CreatorName }}
        </Badge>
        <Badge
            variant="outline" class="flex items-center gap-1">
            <RulerIcon />
          {{ translate('length') }} : {{ track.Distance }}
        </Badge>
        <Badge
        variant="outline"
          v-if="track.Metadata?.raceType && track.Metadata.raceType !== 'any_type'"
          class="flex items-center gap-1"
        >
          <TrackIcon />
          {{ translate(track.Metadata.raceType) }}
        </Badge>
      </div>
    </CardContent>
    <CardFooter class="flex gap-2 justify-end">
      <div class="flex-1"></div>
      <Button  variant="ghost" @click="showRace">
        {{ translate('show_track') }}
      </Button>
      <SetupRaceDialog :key="track.TrackId" :track="track" />
      <Button :disabled="globalStore.activeRace?.raceName" variant="default" @click="quickHost">
        {{ translate('quick_host') }}
      </Button>
    </CardFooter>
  </Card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { Track } from "@/store/types";
import { translate } from "@/helpers/translate";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { CompassIcon, RulerIcon, StarIcon } from "lucide-vue-next";
import TrackIcon from "@/assets/icons/TrackIcon.vue";
import SetupRaceDialog from "../components/dialogs/SetupRaceDialog.vue";
import { useGlobalStore } from "@/store/global";

const globalStore = useGlobalStore();
const props = defineProps<{
  track: Track
}>()
const emits = defineEmits(['select'])

const showRace = async () => {
  const res = await api.post("UiShowTrack", JSON.stringify(props.track.TrackId));
  if (res.data) closeApp()
}

const quickHost = async () => {
  const res = await api.post("UiQuickHost", JSON.stringify(props.track));
  if (res.data){
    globalStore.$state.currentTab.racing = "current";
    closeApp()
  }
}

const startRace = async () => {
  emits('select', props.track)
}
</script>

<style scoped>
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
