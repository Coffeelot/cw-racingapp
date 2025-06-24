<template>
  <div class="results-container page-container">
    <div class="inline standardGap header" v-if="!loadingTracks && allTracks">
      <v-select
          color="primary"
          density="compact"
          hide-details
          :items="Object.values(allTracks)"
          return-object
          item-title="RaceName"
          v-model="selectedRace"
          :placeholder="translate('select_track')"
          class="w-50"
          :loading="loadingRecords"
          @update:modelValue="getRecordsForTrack"
          ></v-select>

    </div>
    <div class="inline standardGap header">
      <v-select
        class="record-filter"
        color="primary"
        density="compact"
        :items="globalStore.baseData.data.classes"
        item-value="value"
        item-title="text"
        :label="translate('class')"
        hideDetails
        v-model="vehClass"
      ></v-select>
      <v-select
        class="record-filter"
        color="primary"
        density="compact"
        hide-details
        :items="raceTypes"
        :label="translate('race_type')"
        v-model="raceType"
      ></v-select>
        <v-switch
        class="record-filter"
        color="primary"
        :loading="loadingRecords"
        density="compact"
        :label="translate('reversed')"
        v-model="reversed"
        @update:modelValue="getRecordsForTrack"
        hide-details
        >
      </v-switch>
    </div>
    <div v-if="!selectedRace">
      <InfoText :title="translate('select_track_to_view')"></InfoText>
    </div>
    <div v-else-if="loadingRecords" class="circular-loading-container">
      <v-progress-circular
        color="primary"
        indeterminate
      ></v-progress-circular>
    </div>
    <div v-else-if="selectedRace && !loadingRecords" class="scrollable">
      <v-table v-if="filteredRecords?.length">
        <thead>
          <tr>
            <th class="text-left">
            </th>
            <th class="text-left">
              {{ translate('time') }}
            </th>
            <th class="text-left">
              {{ translate('vehicle') }}
            </th>
            <th class="text-left">
              {{ translate('class') }}
            </th>
            <th class="text-left">
              {{ translate('type') }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in filteredRecords"
            :key="`${item.racerName}-${item.carClass}`"
          >
            <td>{{ index +1 }}. {{ item.racerName }}</td>
            <td>{{ msToHMS(item.time) }} </td>
            <td>{{ item.vehicleModel }}</td>
            <td>{{ item.carClass }}</td>
            <td>{{ item.raceType }} {{ item.reversed ? '(' + translate('reversed') + ')' :'' }} </td>
          </tr>
        </tbody>
      </v-table>
      <div v-else>
        <InfoText :title="translate('no_data')"></InfoText>
      </div>
    </div>
    <div v-else class="circular-loading-container">
      <v-progress-circular
        color="primary"
        indeterminate
      ></v-progress-circular>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, Ref, ref } from "vue";
import InfoText from "./InfoText.vue";
import { Record, Track } from "@/store/types";
import { msToHMS } from "@/helpers/msToHMS";
import { computed } from "vue";
import { translate } from "@/helpers/translate";
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";

const globalStore = useGlobalStore()

const selectedRace: Ref<Track | undefined> = ref(undefined)
const reversed: Ref<boolean> = ref(false)
const allTracks: Ref<Track[] | undefined> = ref(undefined)
const allRecordsForTrack: Ref<Record[] | undefined> = ref(undefined)

const loadingTracks = ref(false)
const loadingRecords = ref(false)

const raceTypes = [ undefined, 'Sprint', 'Circuit', 'Elimination']

const vehClass = ref(undefined)
const raceType = ref(undefined)


const filteredRecords = computed(() => {
  let recordsToDisplay = allRecordsForTrack.value || []

  if (vehClass.value) {
    recordsToDisplay = recordsToDisplay.filter((record) => record.carClass === vehClass.value)
  }

  if (raceType.value) {
    recordsToDisplay = recordsToDisplay.filter((record) => record.raceType === raceType.value)
  }

  recordsToDisplay = recordsToDisplay.filter((record) => Boolean(record.reversed) === reversed.value)
  return recordsToDisplay
})

const getTracks = async () => {
  loadingTracks.value = true
  const response = await api.post("UiGetTracksTrimmed");
  if (response.data) allTracks.value = response.data;
  loadingTracks.value = false
};

const getRecordsForTrack = async () => {
  if (selectedRace.value?.TrackId) {
    loadingRecords.value = true
    const response = await api.post("UiGetRaceRecordsForTrack", JSON.stringify(
      { trackId: selectedRace.value?.TrackId }
    ));
    if (response.data) allRecordsForTrack.value = response.data;
    loadingRecords.value = false
  }
};


onMounted(() => {
  getTracks();
});

</script>

<style scoped lang="scss">
.header {
  align-items: center;
  margin-bottom: 1em;
  width: 100%;
  justify-content: space-between;
  gap: 2em;
}

.record-filter {
  width: 20%;
}
</style>
