<template>
  <Card class="invite-card mb-3">
    <CardHeader>
      <CardTitle>{{ translate('head2head_title') }}</CardTitle>
    </CardHeader>
    <CardContent>
      {{ translate('head2head_subtitle') }}
    </CardContent>
    <CardFooter class="flex justify-end">
      <Button rounded="xl" :loading="loading" @click="invite" variant="default">
        {{ translate('invite_closest') }}
      </Button>
    </CardFooter>
  </Card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import { Head2headData } from "@/store/types";
import { onMounted, ref } from "vue";
import {
  Card,
  CardHeader,
  CardTitle,
  CardContent,
  CardFooter,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const globalStore = useGlobalStore();
const loading = ref(false);

const fetchLatestData = async () => {
  const res = await api.post("UiFetchH2HData");
  globalStore.head2headData = res.data as Head2headData;
};

const invite = async () => {
  loading.value = true;
  await api.post("UiSetupHead2Head");
  loading.value = false;
  fetchLatestData();
};

onMounted(() => {
  fetchLatestData();
});
</script>

<style scoped>
.invite-card {
  max-width: 60em;
}
</style>