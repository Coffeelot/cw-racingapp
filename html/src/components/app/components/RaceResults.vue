<template>
  <div class="results-container page-container">
    <div class="inline standardGap header">
      <v-select
        color="primary"
        density="compact"
        hide-details
        :items="resultsWithTitle"
        return-object
        item-title="title"
        v-model="selectedRace"
        :placeholder="translate('select_track')"
        class="w-50"
      ></v-select>
    </div>
    <div v-if="!selectedRace">
      <InfoText :title="translate('select_track_to_view')"></InfoText>
    </div>
    <div v-else >
      <v-table v-if="selectedRace.Result.length>0">
        <thead>
          <tr>
            <th class="text-left">
            </th>
            <th class="text-left">
              {{translate('rank')}}
            </th>
            <th class="text-left">
              {{ translate('time') }}
            </th>
            <th class="text-left" v-if="selectedRace.Data.Laps > 0">
              {{  translate('best_lap') }}
            </th>
            <th class="text-left">
              {{ translate('vehicle') }}
            </th>
            <th class="text-left">
              {{  translate('class') }}
            </th>
            <th class="text-left" v-if="selectedRace.Data.RaceData.Ranked">
              {{ translate('rank_change') }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in sortedResults"
            :key="item.RacerName"
          >
            <td> {{ index +1 }}. {{ item.RacerName }} {{ item.RacingCrew ? '[' + item.RacingCrew + ']' : '' }}</td>
            <td>{{ item.Ranking }}</td>
            <td>{{ msToHMS(item.TotalTime) }}</td>
            <td v-if="selectedRace.Data.Laps > 0">{{ msToHMS(item.BestLap) }}</td>
            <td>{{ item.VehicleModel }}</td>
            <td>{{ item.CarClass }}</td>
            <td  v-if="selectedRace.Data.RaceData.Ranked">{{ item.TotalChange}}</td>
          </tr>
        </tbody>
      </v-table>
      <div v-else>
        <InfoText :title="translate('no_data')"></InfoText>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ResultData, TrackResult } from "@/store/types";
import { computed, Ref, ref } from "vue";
import InfoText from "./InfoText.vue";
import { msToHMS } from "@/helpers/msToHMS";
import { translate } from "@/helpers/translate";

export type TrackResultWithTitle = TrackResult & {
  title: string;
};
const props = defineProps<{
  allResults: ResultData;
}>();

const resultsWithTitle = computed(() => {
  const results = [] as TrackResultWithTitle[];
  for (const key in props.allResults) {
    const trackResult = props.allResults[key];
    
    const newTrackResult = trackResult as TrackResultWithTitle;
    const raceName = newTrackResult.Data.RaceData.RaceName;
    if (newTrackResult.Data.FinishTime) {
      const date = new Date(newTrackResult.Data.FinishTime * 1000);
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      const timeStr = `${hours}:${minutes}`;
      newTrackResult.title = `${raceName} (${timeStr})`;
  
      // Clone the track result and add a title
      results.push(newTrackResult)
    }
  }
  return results
})


const selectedRace: Ref<TrackResultWithTitle | undefined> = ref(undefined)
const sortedResults = computed(() => {
  if (!selectedRace.value) return undefined
  const result = selectedRace.value.Result
  return result.sort((res1, res2) => res1.TotalTime < res2.TotalTime ? -1 : 1 )
})
</script>

<style scoped lang="scss">
.header{
  margin-bottom: 1em;
}
</style>
