<template>
  <div class="results-container page-container" v-if="allResults" :allResults="allResults">
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
      <v-table v-if="selectedRace.results.length>0">
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
            <th class="text-left" v-if="selectedRace.laps > 0">
              {{  translate('best_lap') }}
            </th>
            <th class="text-left">
              {{ translate('vehicle') }}
            </th>
            <th class="text-left">
              {{  translate('class') }}
            </th>
            <th class="text-left" v-if="selectedRace.ranked">
              {{ translate('rank_change') }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in racerResultsSorted"
            :key="item.RacerName"
          >
            <td> {{ index +1 }}. {{ item.RacerName }} {{ item.RacingCrew ? '[' + item.RacingCrew + ']' : '' }}</td>
            <td>{{ item.Ranking }}</td>
            <td>{{ msToHMS(item.TotalTime) }}</td>
            <td v-if="selectedRace.laps > 0">{{ msToHMS(item.BestLap) }}</td>
            <td>{{ item.VehicleModel }}</td>
            <td>{{ item.CarClass }}</td>
            <td  v-if="selectedRace.ranked">{{ item.TotalChange}}</td>
          </tr>
        </tbody>
      </v-table>
      <div v-else>
        <InfoText :title="translate('no_data')"></InfoText>
      </div>
    </div>
  </div>
  <InfoText v-else :title="translate('no_data')" />
</template>

<script setup lang="ts">
import { Result, TrackResult } from "@/store/types";
import { computed, onMounted, Ref, ref } from "vue";
import InfoText from "./InfoText.vue";
import { msToHMS } from "@/helpers/msToHMS";
import { translate } from "@/helpers/translate";
import api from "@/api/axios";

const allResults: Ref<TrackResult[] | undefined> = ref(undefined);

export type TrackResultWithTitle = TrackResult & {
  title: string;
};

const resultsWithTitle = computed(() => {
  const results = allResults.value?.map((trackResult) => {
    const mappedResult  = trackResult as TrackResultWithTitle

    const date = new Date(trackResult.timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const timeStr = `${hours}:${minutes}`;
    mappedResult.title = `${trackResult.raceName} (${timeStr})`;
    return mappedResult
  })
  return results
})


const selectedRace: Ref<TrackResultWithTitle | undefined> = ref(undefined)
const racerResultsSorted = computed(() => {
  if (!selectedRace.value) return undefined
  const raceResults = JSON.parse(selectedRace.value.results) as Result[]
  return raceResults.sort((res1, res2) => res1.TotalTime < res2.TotalTime ? -1 : 1 )
})

const getResults = async () => {
  const response = await api.post("UiGetRacingResults");
  if (response.data) allResults.value = response.data as TrackResult[];
};


onMounted(() => {
  getResults();
});

</script>

<style scoped lang="scss">
.header{
  margin-bottom: 1em;
}
</style>
