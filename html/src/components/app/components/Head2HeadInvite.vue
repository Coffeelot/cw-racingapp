<template>
    <v-card  border rounded="xl" class="invite-card mb-3">
      <v-card-title>{{ translate('head2head_title')}}</v-card-title>
      <v-card-text>{{ translate('head2head_subtitle') }}</v-card-text>
      <v-card-actions >
        <v-spacer></v-spacer>
        <v-btn rounded="xl" :loading="loading" @click="invite" variant="flat" color="primary">{{ translate('invite_closest') }}</v-btn>
      </v-card-actions>
    </v-card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import { Head2headData } from "@/store/types";
import { onMounted, ref } from "vue";

const globalStore = useGlobalStore();
const loading = ref(false);

const fetchLatestData = async () => {
  const res = await api.post("UiFetchH2HData");
  globalStore.head2headData = res.data as Head2headData
}

const invite = () => {
  loading.value = true
  api.post("UiSetupHead2Head");
  loading.value = false
  fetchLatestData();
}

onMounted(() => {
  fetchLatestData();
});
</script>


<style lang="scss">
@use 'vuetify/settings' as vuetify-settings;
.invite-card {
  max-width: 60em;
}

</style>