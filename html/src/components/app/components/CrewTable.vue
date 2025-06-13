<template>
  <div class="results-container page-container">
    <v-table rounded="lg" v-if="crews && crews.length>0"  class="scrollable">
      <thead>
        <tr>
          <th class="text-left">
          </th>
          <th class="text-left">
            {{ translate('rank') }}
          </th>
          <th class="text-left">
            {{ translate('wins') }}
          </th>
          <th class="text-left">
            {{ translate('races') }}
          </th>
          <th class="text-left">
            {{  translate('founder') }}
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
      <InfoText :title="translate('no_data')"></InfoText>
    </div>
  </div>
</template>

<script setup lang="ts">
import { translate } from "@/helpers/translate";
import { Crew, CrewList } from "@/store/types";
import { Ref, onMounted, ref } from "vue";
import InfoText from "./InfoText.vue";
import api from "@/api/axios";

const crews: Ref<Crew[] | undefined> = ref(undefined)

const getAllCrews = async () => {
  const response = await api.post("UiGetAllCrews");
  if (response.data)  {
    let res: CrewList = response.data ;
    crews.value = Object.values(res).sort((crewA, crewB) => crewB.rank - crewA.rank);
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
