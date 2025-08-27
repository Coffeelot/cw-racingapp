<template>
  <div class="page-container" v-if="crews && crews.length > 0">
    <InfoHeader :title="translate('crew_rankings')" />
    <div class="flex pagecontent">
      <Table class="w-full">
        <TableHeader>
          <TableRow>
            <TableHead class="text-left"></TableHead>
            <TableHead class="text-left">{{ translate('elo_rank') }}</TableHead>
            <TableHead class="text-left">{{ translate('wins') }}</TableHead>
            <TableHead class="text-left">{{ translate('races') }}</TableHead>
            <TableHead class="text-left">{{ translate('founder') }}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="(item, index) in crews" :key="item.crewName">
            <TableCell>
              {{ index + 1 }}. {{ item.crewName }}
            </TableCell>
            <TableCell>{{ item.rank }}</TableCell>
            <TableCell>{{ item.wins }}</TableCell>
            <TableCell>{{ item.races }}</TableCell>
            <TableCell>{{ item.founderName }}</TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>
  </div>
  <div v-else>
    <InfoText :title="translate('no_data')" />
  </div>
</template>

<script setup lang="ts">
import { translate } from "@/helpers/translate";
import { Crew } from "@/store/types";
import { Ref, onMounted, ref } from "vue";
import InfoText from "./InfoText.vue";
import api from "@/api/axios";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table";
import { mockCrewResults } from "@/mocking/testState";
import InfoHeader from "./InfoHeader.vue";

const crews: Ref<Crew[] | undefined> = ref(undefined);

const getAllCrews = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    crews.value = (mockCrewResults as unknown as Crew[]).sort((crewA, crewB) => crewB.rank - crewA.rank);
    return
  }
  const response = await api.post("UiGetAllCrews");
  if (response.data) {
    let res = response.data as Crew[];
    crews.value = res.sort((crewA, crewB) => crewB.rank - crewA.rank);
  }
};

onMounted(() => {
  getAllCrews();
});
</script>

<style scoped>
.header {
  margin-bottom: 1em;
}
</style>