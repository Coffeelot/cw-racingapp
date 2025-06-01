<template>
  <v-snackbar
    z-index="2000"
    v-model="showActive"
    attach=".app-container"
    transition="slide-y-transition"
    location="top right"
    contained
    :timeout="-1"
    variant="tonal"
    color="surface"
  >
    <h3>{{ translate("in_h2h") }}</h3>
    <p class="text-subtitle-1 pt-2" v-if="globalStore.notification?.text">
      {{ globalStore.notification.text }}
    </p>
    <template v-slot:actions>
      <v-btn rounded="xl" :loading="loading" @click="leave" color="red">{{
        translate("leave_h2h")
      }}</v-btn>
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
const showActive = computed(() => !!globalStore.head2headData.opponentId);

const fetchLatestData = async () => {
  const res = await api.post("UiFetchH2HData");
  globalStore.head2headData = res.data as Head2headData;
};

const leave = async () => {
  loading.value = true;
  await api.post("UiLeaveHead2Head");
  loading.value = false;
  fetchLatestData();
  closeApp();
};

onMounted(() => {
  fetchLatestData();
});
</script>

<style lang="scss">
@use "vuetify/settings" as vuetify-settings;
.head2head-container {
  display: flex;
  flex-wrap: wrap;
  flex-direction: column;
  align-items: start;
}
</style>
