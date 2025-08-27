<template>
  <div class="page-container" v-if="allResults">
    <InfoHeader :title="translate('race_results')" :subtitle="translate('select_track_to_view')" />
    <div class="inline standardGap header">
      <Select v-model="selectedRace" class="w-50">
        <SelectTrigger class="w-64">
          <SelectValue :placeholder="translate('select_track')" />
        </SelectTrigger>
        <SelectContent class="dark">
          <SelectItem
            v-for="race in resultsWithTitle"
            :key="race?.title"
            :value="race"
          >
            {{ race?.title }}
          </SelectItem>
        </SelectContent>
      </Select>
    </div>
    <div class="pagecontent">
      <div v-if="!selectedRace">
        <InfoText :title="translate('select_track_to_view')" />
      </div>
      <div v-else class="flex flex-col h-full">
        <Table v-if="selectedRace.results.length > 0" class="w-full">
          <TableHeader>
            <TableRow>
              <TableHead class="text-left"></TableHead>
              <TableHead class="text-left">{{ translate('elo_rank') }}</TableHead>
              <TableHead class="text-left">{{ translate('time') }}</TableHead>
              <TableHead class="text-left" v-if="selectedRace.laps > 0">{{ translate('best_lap') }}</TableHead>
              <TableHead class="text-left">{{ translate('vehicle') }}</TableHead>
              <TableHead class="text-left">{{ translate('class') }}</TableHead>
              <TableHead class="text-left" v-if="selectedRace.ranked">{{ translate('rank_change') }}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="(item, index) in racerResultsSorted" :key="item.RacerName">
              <TableCell>
                {{ index + 1 }}. {{ item.RacerName }} {{ item.RacingCrew ? '[' + item.RacingCrew + ']' : '' }}
              </TableCell>
              <TableCell>{{ item.Ranking }}</TableCell>
              <TableCell>{{ msToHMS(item.TotalTime) }}</TableCell>
              <TableCell v-if="selectedRace.laps > 0">{{ msToHMS(item.BestLap) }}</TableCell>
              <TableCell>{{ item.VehicleModel }}</TableCell>
              <TableCell>{{ item.CarClass }}</TableCell>
              <TableCell v-if="selectedRace.ranked">{{ item.TotalChange }}</TableCell>
            </TableRow>
          </TableBody>
        </Table>
        <div v-else>
          <InfoText :title="translate('no_data')" />
        </div>
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
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Table, TableBody, TableRow } from "@/components/ui/table";
import TableHeader from "@/components/ui/table/TableHeader.vue";
import TableHead from "@/components/ui/table/TableHead.vue";
import TableCell from "@/components/ui/table/TableCell.vue";
import { mockRacingResults } from "@/mocking/testState";
import InfoHeader from "./InfoHeader.vue";

const allResults: Ref<TrackResult[] | undefined> = ref(undefined);

export type TrackResultWithTitle = TrackResult & {
  title: string;
};

const resultsWithTitle = computed(() => {
  const results = allResults.value?.map((trackResult) => {
    const mappedResult = trackResult as TrackResultWithTitle;
    const date = new Date(trackResult.timestamp);
    const hours = date.getHours().toString().padStart(2, "0");
    const minutes = date.getMinutes().toString().padStart(2, "0");
    const timeStr = `${hours}:${minutes}`;
    mappedResult.title = `${trackResult.raceName} (${timeStr})`;
    return mappedResult;
  });
  return results;
});

const selectedRace: Ref<TrackResultWithTitle | undefined> = ref(undefined);

const racerResultsSorted = computed(() => {
  if (!selectedRace.value) return undefined;
  const raceResults = JSON.parse(selectedRace.value.results) as Result[];
  return raceResults.sort((res1, res2) =>
    res1.TotalTime < res2.TotalTime ? -1 : 1
  );
});

const getResults = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    allResults.value = mockRacingResults as unknown as TrackResult[];
  } else {
    const response = await api.post("UiGetRacingResults");
    if (response.data) allResults.value = response.data as TrackResult[];
  }

  if (allResults.value && allResults.value.length > 0) {
    selectedRace.value = allResults.value[0] as TrackResultWithTitle;

  }
};

onMounted(() => {
  getResults();
});
</script>

<style scoped>
.header {
  margin-bottom: 1em;
}
</style>