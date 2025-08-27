<template>
  <div class="pagecontent">
    <InfoHeader :title="translate('track_records')" />
    <div class="flex flex-wrap gap-4 mb-4" v-if="!loadingTracks && filteredTracks">
      <Select
        v-model="selectedRace"
        :items="Object.values(filteredTracks)"
        :placeholder="translate('select_track')"
        :loading="loadingRecords"
        @update:model-value="getRecordsForTrack"
        item-title="RaceName"
        return-object
      >
        <SelectTrigger class="w-64">
          <SelectValue :placeholder="translate('select_track')" />
        </SelectTrigger>
        <SelectContent class="dark">
          <SelectItem
            v-for="track in filteredTracks"
            :key="track.TrackId"
            :value="track"
          >
            {{ track.RaceName }}
          </SelectItem>
        </SelectContent>
      </Select> 
      <Select
        v-model="vehClass"
        class="record-filter "
        item-value="value"
        item-title="text"
        :placeholder="translate('class')"
      >
        <SelectTrigger class="w-64">
          <SelectValue :placeholder="translate('class')" />
        </SelectTrigger>
        <SelectContent class="dark">
          <SelectItem
            v-for="cls in globalStore.baseData.data.classes"
            :key="cls.value"
            :value="cls.value || 'ANY_CLASS'"
          >
            {{ cls.text }}
          </SelectItem>
        </SelectContent>
      </Select>
      <Select
        v-model="raceType"
        :items="raceTypes"
        class="record-filter"
        :placeholder="translate('race_type')"
      >
        <SelectTrigger class="w-64">
          <SelectValue :placeholder="translate('race_type')" />
        </SelectTrigger>
        <SelectContent class="dark">
          <SelectItem
            v-for="type in raceTypes"
            :key="type"
            :value="type || 'ANY_TYPE'"
          >
            {{ type || translate('any') }}
          </SelectItem>
        </SelectContent>
      </Select>

      <div class="flex items-center gap-2">
        <Switch
          v-model:checked="reversed"
          :id="'reversed-switch'"
          :loading="loadingRecords"
          @update:model-value="getRecordsForTrack"
        />
        <label :for="'reversed-switch'" class="font-medium cursor-pointer">
          {{ translate('reversed') }}
        </label>
      </div>
    </div>

    <div v-if="!selectedRace">
      <InfoText :title="translate('select_track_to_view')" />
    </div>
    <div v-else-if="loadingRecords" class="circular-loading-container">
      <Skeleton />
    </div>
    <div v-else-if="selectedRace && !loadingRecords" class="pagecontent">
      <Table v-if="filteredRecords?.length">
        <TableHeader>
          <TableRow>
            <TableHead class="text-left"></TableHead>
            <TableHead class="text-left">{{ translate('time') }}</TableHead>
            <TableHead class="text-left">{{ translate('vehicle') }}</TableHead>
            <TableHead class="text-left">{{ translate('class') }}</TableHead>
            <TableHead class="text-left">{{ translate('type') }}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow
            v-for="(item, index) in filteredRecords"
            :key="`${item.racerName}-${item.carClass}`"
          >
            <TableCell>{{ index + 1 }}. {{ item.racerName }} <span v-if="item.crew">[{{ item.crew }}]</span> </TableCell>
            <TableCell>{{ msToHMS(item.time) }}</TableCell>
            <TableCell>{{ item.vehicleModel }}</TableCell>
            <TableCell>{{ item.carClass }}</TableCell>
            <TableCell>
              {{ item.raceType }} <span v-if="item.reversed">({{ translate('reversed') }})</span>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
      <div v-else>
        <InfoText :title="translate('no_data')" />
      </div>
    </div>
    <div v-else class="circular-loading-container">
      <Skeleton />
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, Ref, ref, computed } from "vue";
import InfoText from "./InfoText.vue";
import { RaceRecord, Track } from "@/store/types";
import { msToHMS } from "@/helpers/msToHMS";
import { translate } from "@/helpers/translate";
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import Switch from "@/components/ui/switch/Switch.vue";
import { Skeleton } from "@/components/ui/skeleton";
import { mockTrimmedTracks } from "@/mocking/testState";
import InfoHeader from "./InfoHeader.vue";
import { mockRandomTrackResults } from "@/mocking/mockHelpers";

const globalStore = useGlobalStore();

const selectedRace: Ref<Track | undefined> = ref(undefined);
const reversed: Ref<boolean> = ref(false);
const allTracks: Ref<Track[] | undefined> = ref(undefined);
const allRecordsForTrack: Ref<RaceRecord[] | undefined> = ref(undefined);

const filteredTracks = computed(() => {
  let tracksToDisplay = allTracks?.value || [];

  if (tracksToDisplay.length > 0 && globalStore.showOnlyCurated) {
    tracksToDisplay = tracksToDisplay.filter((track) => track.Curated === 1);
  }

  return tracksToDisplay;
});

const loadingTracks = ref(false);
const loadingRecords = ref(false);

const raceTypes = [undefined,'Sprint', 'Circuit', 'Elimination'];

const vehClass = ref('ANY_CLASS');
const raceType = ref('ANY_TYPE');

const filteredRecords = computed(() => {
  let recordsToDisplay = allRecordsForTrack.value || [];

  if (vehClass.value !== 'ANY_CLASS') {
    recordsToDisplay = recordsToDisplay.filter((record) => record.carClass === vehClass.value);
  }

  if (raceType.value !== 'ANY_TYPE') {
    recordsToDisplay = recordsToDisplay.filter((record) => record.raceType === raceType.value);
  }

  recordsToDisplay = recordsToDisplay.filter((record) => Boolean(record.reversed) === reversed.value);
  return recordsToDisplay;
});

const getTracks = async () => {
  loadingTracks.value = true;
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    allTracks.value = mockTrimmedTracks;
    loadingTracks.value = false;
    return
  }
  const response = await api.post("UiGetTracksTrimmed");
  if (response.data) allTracks.value = response.data;
  loadingTracks.value = false;
};

const getRecordsForTrack = async () => {
  if (selectedRace.value?.TrackId) {
    loadingRecords.value = true;
    if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
      allRecordsForTrack.value = mockRandomTrackResults() as unknown as RaceRecord[];
      loadingRecords.value = false;
      return
    }
    const response = await api.post("UiGetRaceRecordsForTrack", JSON.stringify(
      { trackId: selectedRace.value?.TrackId }
    ));
    if (response.data) allRecordsForTrack.value = response.data;
    loadingRecords.value = false;
  }
};

onMounted(() => {
  getTracks();
});
</script>

<style scoped>
.header {
  align-items: center;
  margin-bottom: 1em;
  width: 100%;
  justify-content: space-between;
  gap: 2em;
}

</style>