<template>
  <div class="results-container page-container">
    <v-table v-if="racers && racers.length>0" class="scrollable">
      <thead>
        <tr>
          <th class="text-left">
          </th>
          <th class="text-left">
            {{translate('rank')}}
          </th>
          <th class="text-left">
            {{translate('wins')}}
          </th>
          <th class="text-left">
            {{translate('races')}}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in racers"
          :key="item.racername"
        >
          <td> {{ index +1 }}. {{ item.racername }}</td>
          <td>{{ item.ranking }}</td>
          <td>{{ item.wins }}</td>
          <td>{{ item.races }}</td>
        </tr>
      </tbody>
    </v-table>
    <div v-else>
      <InfoText :title="translate('no_data')"></InfoText>
    </div>
  </div>
</template>

<script setup lang="ts">
import { MyRacer } from "@/store/types";
import { Ref, onMounted, ref } from "vue";
import InfoText from "./InfoText.vue";
import api from "@/api/axios";
import { translate } from "@/helpers/translate";

const racers: Ref<MyRacer[] | undefined> = ref(undefined)

const getAllRacers = async () => {
  const response = await api.post("UiGetAllRacers");
  if (response.data)  {
    let res = response.data;
    res.sort((a:MyRacer, b:MyRacer) => b.ranking - a.ranking);
    racers.value = res
    
  }

};

onMounted(() => {
  getAllRacers();
});

</script>

<style scoped lang="scss">
.header{
  margin-bottom: 1em;
}
</style>
