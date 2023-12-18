<template>
  <div id="RacersPage" class="pagecontent">
    <v-tabs v-model="tab">
      <v-tab value="myRacers">My Racers</v-tab>
      <!-- <v-tab value="create">Create Racer</v-tab> -->
    </v-tabs>

    <v-window v-model="tab">
      <v-window-item value="myRacers" class="tabcontent">
        <div class="subheader inline">
          <h3 class="header-text">My Racers</h3>
          <v-text-field
            class="text-field"
            hideDetails
            placeholder="Search with racer name or citizenid"
            density="compact"
            v-model="search"
          ></v-text-field>
        </div>
        <div class="myRacers-items-container" v-if="myRacers && myRacers.length>0">
          <MyRacerCard @triggerReload="getMyRacers()" v-for="racer in filteredRacers" :racer="racer"></MyRacerCard>
        </div>
      </v-window-item>
    </v-window>
    <div id="RacersTab" class="tabcontent">
      <div class="myRacers-container page-container">
        <div class="loading-container" id="myRacers-items-container-loader">
          <span class="loader"></span>
        </div>
        <div id="myRacers-items-container-none">
          <h3 class="inline centered">
            Seems like you haven't created any racers
          </h3>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { MyRacer } from "@/store/types";
import { Ref } from "vue";
import { computed, onMounted } from "vue";
import { ref } from "vue";
import MyRacerCard from "../items/MyRacerCard.vue";
const globalStore = useGlobalStore();
const tab = ref(globalStore.currentPage);
const myRacers: Ref<MyRacer[] | undefined> = ref(undefined);
const search = ref('');
const filteredRacers = computed(() => {
  if (myRacers.value && search.value !== '') return myRacers.value.filter((racer) => racer.racername.toLowerCase().includes(search.value.toLowerCase()) || racer.citizenid.toLowerCase().includes(search.value.toLowerCase()) )
  return myRacers.value
})

const getMyRacers = async () => {
  const response = await api.post('UiGetRacersCreatedByUser')
  if (response.data) {
    myRacers.value = response.data
  }
}

onMounted(() => {
  getMyRacers();
});

</script>

<style scoped lang="scss">
.header-text {
  flex-grow: 1;
}
.text-field {
  flex-grow: 1;
}
.myRacers-items-container {
  margin-top: 1em;
  display: flex;
  flex-direction: column;
  gap: 0.5em
}</style>
