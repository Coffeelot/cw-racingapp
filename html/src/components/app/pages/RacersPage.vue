<template>
  <div id="RacersPage" class="pagecontent">
    <v-tabs color="primary" v-model="tab">
      <v-tab value="myRacers">{{ translate('my_racers') }} </v-tab>
      <v-tab value="create" v-if="globalStore.baseData?.data?.auth?.create">{{ translate('create_racer') }} </v-tab>
    </v-tabs>

    <v-window v-model="tab" class="page-container">
      <v-window-item value="myRacers" class="tabcontent">
        <div class="subheader inline">
          <v-text-field
            class="text-field"
            hideDetails
            density="compact"
            color="primary"
            :placeholder="translate('search_dot')"
            v-model="search"
          ></v-text-field>
        </div>
        <div class="myRacers-items-container scrollable" v-if="myRacers && myRacers.length>0">
          <MyRacerCard v-for="racer in filteredRacers" :key="racer.id" @triggerReload="getMyRacers()"  :racer="racer"></MyRacerCard>
        </div>
      </v-window-item>
      <v-window-item value="create" class="tabcontent">
        <div  v-if="globalStore.baseData?.data?.auth?.create" class="create-options">
          <v-card class="card">
            <v-card-title>{{ translate('create_racer') }} </v-card-title>
            <v-card-text>
              <v-text-field
                color="primary"
                density="compact"
                :placeholder="translate('racer_name')"
                v-model="create.racerName"
              />
              <v-text-field
                color="primary"
                density="compact"
                :placeholder="translate('racer_id')"
                v-model="create.racerId"
              />
              <v-select
                  v-if="creationTypes && creationTypes.length>0"
                  color="primary"
                  density="compact"
                  hide-details
                  :items="Object.values(creationTypes)"
                  return-object
                  item-title="label"
                  v-model="selectedAuth"
              ></v-select>
              <InfoText v-else :title="translate('not_auth')"></InfoText>
            </v-card-text>
            <v-card-actions>
              <v-btn
                block
                color="success"
                variant="flat"
                type="submit"
                @click="createUser()"
                :loading="loading"
                :disabled="shouldDisableButton"
              >
                {{ translate('confirm') }} 
              </v-btn>
            </v-card-actions>
          </v-card>
        </div>
        <InfoText v-else :title="translate('not_auth')"></InfoText>
      </v-window-item>
    </v-window>
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
import InfoText from "../components/InfoText.vue";
import { translate } from "@/helpers/translate";

const globalStore = useGlobalStore();
const tab = ref(globalStore.currentPage);
const myRacers: Ref<MyRacer[] | undefined> = ref(undefined);
const creationTypes: Ref<any | undefined> = ref(undefined);
const search = ref('');
const selectedAuth = ref(undefined);

const filteredRacers = computed(() => {
  if (myRacers.value && search.value !== '') return myRacers.value.filter((racer) => racer.racername.toLowerCase().includes(search.value.toLowerCase()) || racer.citizenid.toLowerCase().includes(search.value.toLowerCase()) )
  return myRacers.value
})


const create = ref({
  racerName: '',
  racerId: ''
})
const loading = ref(false)

const shouldDisableButton = computed(() => {
  if (loading.value ) return true
  if (create.value.racerName === '') return true
  if (!selectedAuth.value) return true

  return false
})

const getMyRacers = async () => {
  const response = await api.post('UiGetRacersCreatedByUser')
  if (response.data) {
    myRacers.value = response.data
  }
  const typeResults = await api.post('UiGetPermissionedUserTypes')
  if (typeResults.data) {
    creationTypes.value = typeResults.data
  }
}

const createUser = async () => {
  loading.value = true
  const response = await api.post("UiCreateUser", JSON.stringify({ racerName: create.value.racerName, racerId: create.value.racerId, selectedAuth: selectedAuth.value }));
  setTimeout(() => {
    loading.value = false
    if (response.data) create.value.racerName = '';  create.value.racerId = '' 
  }, 1000);
};
const createUserClosest = async () => {
  loading.value = true
  const response = await api.post("UiCreateUserClosest", JSON.stringify({ racerName: create.value.racerName, selectedAuth: selectedAuth.value}));
  setTimeout(() => {
    if (response.data) create.value.racerName = '';  create.value.racerId = '' 
    loading.value = false
  }, 1000);
};

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
}

.create-options {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 1em
}
.card {
  flex-grow: 1;
  height: fit-content;
}
</style>
