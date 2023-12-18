<template>
  <div class="results-container page-container">
    <div class="inline standardGap header">
      <h3 style="width: 160px">Select Race</h3>
      <v-select
        density="compact"
        hide-details
        :items="Object.values(allRecords)"
        return-object
        item-title="RaceName"
        v-model="selectedRace"
      ></v-select>
    </div>
    <div class="loading-container" id="results-items-loader">
      <span class="loader"></span>
    </div>
    <div v-if="!selectedRace">
      <InfoText title="Select a track to view results"></InfoText>
    </div>
    <div v-else >
      <v-table v-if="selectedRace.Records.length>0">
        <thead>
          <tr>
            <th class="text-left">
            </th>
            <th class="text-left">
              Time
            </th>
            <th class="text-left">
              Vehicle
            </th>
            <th class="text-left">
              Class
            </th>
            <th class="text-left">
              Type
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in selectedRace.Records"
            :key="`${item.Holder}-${item.Class}`"
          >
            <td>{{ item.Holder }}</td>
            <td>{{ secondsToHMS(item.Time) }}</td>
            <td>{{ item.Vehicle }}</td>
            <td>{{ item.Class }}</td>
            <td>{{ item.RaceType }}</td>
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
import { Ref, ref } from "vue";
import InfoText from "./InfoText.vue";
import { Track } from "@/store/types";
import { secondsToHMS } from "@/helpers/secondsToHMS";

const props = defineProps<{
  allRecords: Track[];
}>();
const globalStore = useGlobalStore();
const selectedRace: Ref<Track | undefined> = ref(undefined)
</script>

<style scoped lang="scss">
.header {
  margin-bottom: 1em;
}</style>
