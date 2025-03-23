<template>
  <v-card rounded="xl" border>
    <v-card-title>
      {{ bounty.trackName }} <v-chip variant="outlined" :color="hasBeenCompleted ? 'green' : 'primary'">{{  msToHMS(bounty.timeToBeat) }}</v-chip>
    </v-card-title>
    <v-card-text class="text">
      <v-chip  color="green">{{ translate('price') }}: {{ translate('currency_text') }}{{ bounty.price }} </v-chip>
      <v-chip  color="primary">{{ translate('class') }}: {{ bounty.maxClass }} </v-chip>
      <v-chip  :color="meetsRequiredRank ?'green' :'error'">{{ translate('required_rank') }}: {{ bounty.rankRequired }} </v-chip>
      <v-chip v-if="bounty.reversed" color="primary">{{ translate('reversed') }}</v-chip>
      <v-chip v-if="bounty.sprint" color="primary">{{ translate('sprint') }}</v-chip>
      <v-chip v-else color="primary">{{ translate('circuit') }}</v-chip>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn rounded="xl" @click="recordsDialog = true">{{ translate('records') }} </v-btn>
      <v-btn variant="flat" color="primary" :disabled="!meetsRequiredRank || loading" rounded="xl" @click="quickHost">
            {{ translate('quick_host') }} 
        </v-btn>
    </v-card-actions>
  </v-card>
  <v-dialog attach=".app-container" contained v-model="recordsDialog" width="auto">
    <v-card  rounded="xl">
      <v-card-title>{{ bounty.trackName }}</v-card-title>
      <v-card-text>
        <div class="d-flex ga-1">
          <v-chip  color="primary">{{ translate('class') }}: {{ bounty.maxClass }} </v-chip>
          <v-chip v-if="bounty.reversed" color="primary">{{ translate('reversed') }}</v-chip>
          <v-chip v-if="bounty.sprint" color="primary">{{ translate('sprint') }}</v-chip>
          <v-chip v-else color="primary">{{ translate('circuit') }}</v-chip>
          <v-chip  :color="meetsRequiredRank ?'green' :'error'">{{ translate('required_rank') }}: {{ bounty.rankRequired }} </v-chip>
        </div>
        <v-table v-if="times && times.length>0">
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
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(item, index) in times"
              :key="index"
            >
              <td> {{ index +1 }}. {{ item.racerName }}</td>
              <td>{{ msToHMS(item.time) }}</td>
              <td>{{ item.vehicleModel }}</td>
            </tr>
          </tbody>
        </v-table>
        <InfoText v-else :title="translate('no_data')"></InfoText>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="recordsDialog = false">
            {{ translate('close') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

</template>

<script setup lang="ts">

import { msToHMS } from "@/helpers/msToHMS";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import { Bounty } from "@/store/types";
import { computed, ref } from "vue";
import InfoText from "../components/InfoText.vue";
import api from "@/api/axios";

const props = defineProps<{
  bounty: Bounty;
}>();

const loading = ref(false)
const recordsDialog = ref(false)
const globalStore = useGlobalStore()
const times = computed(() => {
  const claims = props.bounty.claimed
  const timearray = Object.values(claims).sort((res1, res2) => res1.time < res2.time ? -1 : 1 )
  return timearray
})


const hasBeenCompleted = computed(() => {
  return times.value.filter((time) => time.racerName === globalStore.baseData.data.currentRacerName).length > 0
})

const meetsRequiredRank = computed(() => {
  return props.bounty.rankRequired <= globalStore.baseData.data.currentRanking
})


const quickHost = async () => {
  loading.value = true
  const res = await api.post("UiQuickSetupBounty", JSON.stringify(props.bounty));
  if (res.data) {
    loading.value = false
  }
}

</script>

<style scoped lang="scss">
.text {
    display: flex;
    gap: 0.5em;
    flex-wrap: wrap;
}
.title {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.available-card {
  flex-grow: 1;
}
.text-area {
  min-width: 30em;
}
</style>
