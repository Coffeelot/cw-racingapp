<template>
  <div class="page-container" v-if="racers && racers.length > 0">
    <InfoHeader :title="translate('racer_rankings')" />
    <div class="flex pagecontent">
      <Table v-if="racers && racers.length > 0" class="w-full">
        <TableHeader>
          <TableRow>
            <TableHead class="text-left"></TableHead>
            <TableHead class="text-left">{{ translate('elo_rank') }}</TableHead>
            <TableHead class="text-left">{{ translate('wins') }}</TableHead>
            <TableHead class="text-left">{{ translate('races') }}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="(item, index) in racers" :key="item.racername">
            <TableCell>
              <span>{{ index + 1 }}. {{ item.racername }}</span> 
              <span v-if="item.crew"> [{{ item.crew }}]</span>
            </TableCell>
            <TableCell>{{ item.ranking }}</TableCell>
            <TableCell>{{ item.wins }}</TableCell>
            <TableCell>{{ item.races }}</TableCell>
          </TableRow>
        </TableBody>
      </Table>
      <div v-else>
        <InfoText :title="translate('no_data')" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { MyRacer } from "@/store/types";
import { Ref, onMounted, ref } from "vue";
import InfoText from "./InfoText.vue";
import api from "@/api/axios";
import { translate } from "@/helpers/translate";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table";
import { mockRacersResults } from "@/mocking/testState";
import InfoHeader from "./InfoHeader.vue";

const racers: Ref<MyRacer[] | undefined> = ref(undefined);

const getAllRacers = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    racers.value = mockRacersResults as unknown as MyRacer[];
    return
  }
  const response = await api.post("UiGetAllRacers");
  if (response.data) {
    let res = response.data;
    res.sort((a: MyRacer, b: MyRacer) => b.ranking - a.ranking);
    racers.value = res;
  }
};

onMounted(() => {
  getAllRacers();
});
</script>

<style scoped>
.header {
  margin-bottom: 1em;
}
</style>