<template>
  <div class="results-container page-container">
    <div class="inline standardGap header">
      <h3 style="width: 160px">Select Race</h3>
      <v-select
        density="compact"
        hide-details
        :items="Object.values(props.allResults)"
        return-object
        item-title="Data.RaceData.RaceName"
        v-model="selectedRace"
      ></v-select>
    </div>
    <div v-if="!selectedRace">
      <InfoText title="Select a track to view results"></InfoText>
    </div>
    <div v-else >
      <v-table v-if="selectedRace.Result.length>0">
        <thead>
          <tr>
            <th class="text-left">
            </th>
            <th class="text-left">
              Rank
            </th>
            <th class="text-left">
              Time
            </th>
            <th class="text-left">
              Best Lap
            </th>
            <th class="text-left">
              Vehicle
            </th>
            <th class="text-left">
              Class
            </th>
            <th class="text-left" v-if="selectedRace.Data.RaceData.Ranked">
              Rank Change
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in selectedRace.Result"
            :key="item.RacerName"
          >
            <td> {{ index +1 }}. {{ item.RacerName }} {{ item.RacingCrew ? '[' + item.RacingCrew + ']' : '' }}</td>
            <td>{{ item.Ranking }}</td>
            <td>{{ secondsToHMS(item.TotalTime) }}</td>
            <td>{{ secondsToHMS(item.BestLap) }}</td>
            <td>{{ item.VehicleModel }}</td>
            <td>{{ item.CarClass }}</td>
            <td  v-if="selectedRace.Data.RaceData.Ranked">{{ item.TotalChange}}</td>
          </tr>
        </tbody>
      </v-table>
      <div v-else>
        <InfoText title="No Data Yet"></InfoText>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { ResultData } from "@/store/types";
import { Ref, ref } from "vue";
import InfoText from "./InfoText.vue";
import { secondsToHMS } from "@/helpers/secondsToHMS";

const props = defineProps<{
  allResults: ResultData[];
}>();

const globalStore = useGlobalStore();
const selectedRace: Ref<ResultData | undefined> = ref(undefined)
</script>

<style scoped lang="scss">
.header{
  margin-bottom: 1em;
}
</style>
