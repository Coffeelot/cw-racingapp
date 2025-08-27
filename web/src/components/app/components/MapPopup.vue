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
      <Button variant="ghost" @click="close()">
        {{ translate('close') }}
      </Button>
      <SetupRaceDialog :key="track.TrackId" :track="track" />
      <Button variant="default" @click="setWaypoint()">
        {{ translate('set_waypoint') }}
      </Button>
    </CardFooter>
  </Card>
</template>

<script setup lang="ts">
import { translate } from '@/helpers/translate';
import { Track } from '@/store/types';
import SetupRaceDialog from './dialogs/SetupRaceDialog.vue';
import { closeApp } from '@/helpers/closeApp';
import api from '@/api/axios';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { CompassIcon, RulerIcon, StarIcon } from 'lucide-vue-next';
import TrackIcon from '@/assets/icons/TrackIcon.vue';


const props = defineProps<{
  track: Track,
  closePopup?: () => void
}>()
const emits = defineEmits(["closePopup"]);

const close = () => {
    if (props.closePopup) props.closePopup();
};

const setWaypoint = () => {
  api.post('UiSetWaypoint', JSON.stringify(props.track))
  closeApp()
};

</script>

<style scoped>

</style>
