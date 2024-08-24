<template>
  <div class="results-container">
    <div class="inline standardGap header">
      <h3 style="width: 160px">{{ translate('select_race') }}</h3>
      <v-select
        color="primary"
        density="compact"
        hide-details
        :items="Object.values(allRecords)"
        return-object
        item-title="RaceName"
        v-model="selectedRace"
      ></v-select>
    </div>
    <v-switch
      color="primary"
      density="compact"
      :label="translate('reversed')"
      v-model="reversed"
      hide-details
      >
    </v-switch>
    <div class="loading-container" id="results-items-loader">
      <span class="loader"></span>
    </div>
    <div v-if="!selectedRace">
      <InfoText :title="translate('select_track_to_view')"></InfoText>
    </div>
    <div v-else class="scrollable">
      <v-table v-if="filteredRecords && filteredRecords.length>0" >
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
            :key="`${item.Holder}-${item.Class}`"
          >
            <td>{{ index +1 }}. {{ item.Holder }}</td>
            <td>{{ secondsToHMS(item.Time) }}</td>
            <td>{{ item.Vehicle }}</td>
            <td>{{ item.Class }}</td>
            <td>{{ item.RaceType }}</td>
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
import { Ref, ref } from "vue";
import InfoText from "./InfoText.vue";
import { Track } from "@/store/types";
import { secondsToHMS } from "@/helpers/secondsToHMS";
import { computed } from "vue";
import { translate } from "@/helpers/translate";

const props = defineProps<{
  allRecords: Track[];
}>();
const selectedRace: Ref<Track | undefined> = ref(undefined)
const reversed: Ref<boolean> = ref(false)
const filteredRecords = computed(() => selectedRace.value?.Records.filter((record) => {
  if (record.Reversed === undefined) return !reversed.value

  return record.Reversed === reversed.value
}))

</script>

<style scoped lang="scss">
.header {
  align-items: center;
  margin-bottom: 1em;
}</style>
