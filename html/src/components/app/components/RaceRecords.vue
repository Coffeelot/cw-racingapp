<template>
  <div class="results-container page-container">
    <div class="inline standardGap header">
      <v-select
          color="primary"
          density="compact"
          hide-details
          :items="Object.values(allRecords)"
          return-object
          item-title="RaceName"
          v-model="selectedRace"
          :placeholder="translate('select_track')"
          class="w-50"
        ></v-select>
        <v-switch
          color="primary"
          density="compact"
          :label="translate('reversed')"
          v-model="reversed"
          hide-details
          >
        </v-switch>
    </div>
    <div class="loading-container" id="results-items-loader">
      <span class="loader"></span>
    </div>
    <div v-if="!selectedRace">
      <InfoText :title="translate('select_track_to_view')"></InfoText>
    </div>
    <div v-else class="scrollable">
      <v-table v-if="sortedResults && sortedResults.length>0" >
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
            v-for="(item, index) in sortedResults"
            :key="`${item.Holder}-${item.Class}`"
          >
            <td>{{ index +1 }}. {{ item.Holder }}</td>
            <td>{{ msToHMS(item.Time) }} </td>
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
import { msToHMS } from "@/helpers/msToHMS";
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

const sortedResults = computed(() => {
  if (!filteredRecords.value) return undefined
  const result = filteredRecords.value
  return result.sort((res1, res2) => res1.Time < res2.Time ? -1 : 1 )
})

</script>

<style scoped lang="scss">
.header {
  align-items: center;
  margin-bottom: 1em;
  width: 100%;
  justify-content: space-between;
  gap: 2em;
}</style>
