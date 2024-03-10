<template>
  <div class="results-container page-container">
    <div class="inline standardGap header">
      <h3>Crew rankings</h3>
    </div>
    <v-table v-if="crews && crews.length>0"  class="scrollable">
      <thead>
        <tr>
          <th class="text-left">
          </th>
          <th class="text-left">
            Rank
          </th>
          <th class="text-left">
            Wins
          </th>
          <th class="text-left">
            Races
          </th>
          <th class="text-left">
            Founder
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in crews"
          :key="item.crewName"
        >
          <td> {{ index +1 }}. {{ item.crewName }}</td>
          <td>{{ item.rank }}</td>
          <td>{{ item.wins }}</td>
          <td>{{ item.races }}</td>
          <td>{{ item.founderName }}</td>
        </tr>
      </tbody>
    </v-table>
    <div v-else>
      <InfoText title="No Data Yet"></InfoText>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { Crew } from "@/store/types";
import { Ref, onMounted, ref } from "vue";
import InfoText from "./InfoText.vue";
import api from "@/api/axios";

const crews: Ref<Crew[] | undefined> = ref(undefined)

  const getAllCrews = async () => {
  const response = await api.post("UiGetAllCrews");
  if (response.data)  {
    let res = response.data;
    res.sort((a:Crew, b:Crew) => b.rank - a.rank);
    crews.value = res
    
  }

};

onMounted(() => {
  getAllCrews();
});

</script>

<style scoped lang="scss">
.header{
  margin-bottom: 1em;
}
</style>
