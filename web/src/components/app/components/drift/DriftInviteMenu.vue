<template>
  <Popover v-model:open="menu">
    <PopoverTrigger as-child>
      <Button :variant=" globalStore.driftChallengeData?.latestChallengeId ? 'default' : 'outline'" @click="menu = true" class="float-right">
        <CircleAlertIcon v-if="globalStore.driftChallengeData?.latestChallengeId" />
        {{ translate('drift') }}
      </Button>
    </PopoverTrigger>
    <PopoverContent align="end" class="dark w-96">
      <div class="flex flex-col gap-2" v-if="!hasActiveChallenge && !isInChallenge">
        <div class="font-bold text-lg mb-1">{{ translate('driftChallenge_title') }}</div>
        <div class="mb-2">{{ translate('driftChallenge_subtitle') }}</div>
        <div class="flex gap-2 justify-end">
          <Button variant="ghost" :loading="loading" @click="menu = false">
            {{ translate('close') }}
          </Button>
          <Button variant="default" :loading="loading" @click="invite">
            {{ translate('invite_closest') }}
          </Button>
        </div>
      </div>
      <div v-else-if="isInChallenge" class="flex flex-col gap-2">
        <div class="font-bold text-lg mb-1">{{ translate('in_driftChallenge') }}</div>
        <div class="mb-2" v-if="globalStore.notification?.text">{{ globalStore.notification.text }}</div>
        <div class="flex gap-3 justify-end">
          <Button variant="default" @click="leave()">
            {{ translate('leave_driftChallenge') }}
          </Button>
        </div>
      </div>
      <div v-else-if="hasActiveChallenge" class="flex flex-col gap-2">
        <div class="font-bold text-lg mb-1">{{ translate('driftChallenge_invite') }}</div>
        <div class="mb-2" v-if="globalStore.notification?.text">{{ globalStore.notification.text }}</div>
        <div class="flex gap-3 justify-end">
          <Button variant="destructive"  @click="deny">
            {{ translate('deny') }}
          </Button>
          <Button variant="default"  @click="accept">
            {{ translate('accept') }}
          </Button>
        </div>
      </div>

    </PopoverContent>
  </Popover>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import { translate } from "@/helpers/translate";
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { DriftChallengeData } from "@/store/types";
import {
  Popover,
  PopoverTrigger,
  PopoverContent,
} from "@/components/ui/popover";
import { Button } from "@/components/ui/button";
import { CircleAlertIcon } from "lucide-vue-next";
import { closeApp } from "@/helpers/closeApp";

const globalStore = useGlobalStore();
const loading = ref(false);
const menu = ref(false);

const fetchLatestData = async () => {
  const res = await api.post("UiFetchDriftChallengeData");
  globalStore.driftChallengeData = res.data as DriftChallengeData;
};

const hasActiveChallenge = computed((): boolean => {
  return !!globalStore.driftChallengeData?.latestChallengeId;
})

const isInChallenge = computed((): boolean => {
  return !!globalStore.driftChallengeData?.activeDriftChallengeId;
})

const invite = async () => {
  loading.value = true;
  await api.post("UiSetupDriftChallenge");
  loading.value = false;
  fetchLatestData();
  menu.value = false;
};

const accept = () => {
  loading.value = true;
  api.post("UiJoinDriftChallenge");
  loading.value = false;
  fetchLatestData();
  closeApp()
}

const leave = async () => {
  loading.value = true;
  await api.post("UiLeaveDriftChallenge");
  loading.value = false;
  fetchLatestData();
  closeApp();
};


const deny = () => {
  loading.value = true;
  api.post("UiDenyDriftChallenge");
  loading.value = false;
  fetchLatestData();
}

onMounted(() => {
  fetchLatestData();
});
</script>

<style scoped>
</style>