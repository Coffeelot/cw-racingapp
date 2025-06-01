<template>
    <v-snackbar
    z-index="2000"
    v-model="showInvite"
    attach=".app-container"
    transition="slide-y-transition"
    location="top right"
    contained
    :timeout="10000"
    variant="flat"
    color="surface"
  >
    <h3>{{ translate('head2head_invite') }} {{ globalStore.head2headData.invitee }}</h3>
    <p class="text-subtitle-1 pt-2" v-if="globalStore.notification?.text">
      {{ globalStore.notification.text }}
    </p>
    <template v-slot:actions>
        <v-btn rounded="xl" :loading="loading" @click="deny" color="red" >{{ translate('deny') }}</v-btn>
        <v-btn rounded="xl" :loading="loading" @click="accept" variant="flat" color="green">{{ translate('accept') }}</v-btn>  
      </template>
  </v-snackbar>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import { Head2headData } from "@/store/types";
import { computed, onMounted, ref } from "vue";

const globalStore = useGlobalStore();
const loading = ref(false);
const showInvite = computed(() => !!globalStore.head2headData.inviteRaceId)

const fetchLatestData = async () => {
  const res = await api.post("UiFetchH2HData");
  globalStore.head2headData = res.data as Head2headData
}

const accept = () => {
  loading.value = true;
  api.post("UiJoinHead2Head");
  loading.value = false;
  fetchLatestData();
  closeApp()
}

const deny = () => {
  loading.value = true;
  api.post("UiDenyHead2Head");
  loading.value = false;
  fetchLatestData();
}

onMounted(() => {
  fetchLatestData();
});
</script>


<style lang="scss">
@use 'vuetify/settings' as vuetify-settings;
.head2head-container {
  display: flex;
  flex-wrap: wrap;
  flex-direction: column;
  align-items: start;
}

</style>