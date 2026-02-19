<template>
  <Card class="invite-card mb-3">
    <CardHeader>
      <CardTitle>{{ translate('driftChallenge_title') }}</CardTitle>
    </CardHeader>
    <CardContent>
      {{ translate('driftChallenge_subtitle') }}
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
import { onMounted, ref } from "vue";
import {
  Card,
  CardHeader,
  CardTitle,
  CardContent,
  CardFooter,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { DriftChallengeData } from "@/store/types";

const globalStore = useGlobalStore();
const loading = ref(false);

const fetchLatestData = async () => {
  const res = await api.post("UiFetchDriftChallengeData");
  globalStore.driftChallengeData = res.data as DriftChallengeData;
};

const invite = async () => {
  loading.value = true;
  await api.post("UiSetupDriftChallenge");
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