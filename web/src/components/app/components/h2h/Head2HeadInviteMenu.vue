<template>
  <Popover v-model:open="menu">
    <PopoverTrigger as-child>
      <Button :variant=" globalStore.head2headData?.inviteRaceId ? 'default' : 'outline'" @click="menu = true" class="float-right">
        <CircleAlertIcon v-if="globalStore.head2headData?.inviteRaceId" />
        {{ translate('h2h') }}
      </Button>
    </PopoverTrigger>
    <PopoverContent align="end" class="dark w-96">
      <div class="flex flex-col gap-2" v-if="!globalStore.head2headData?.inviteRaceId">
        <div class="font-bold text-lg mb-1">{{ translate('head2head_title') }}</div>
        <div class="mb-2">{{ translate('head2head_subtitle') }}</div>
        <div class="flex gap-2 justify-end">
          <Button variant="ghost" :loading="loading" @click="menu = false">
            {{ translate('close') }}
          </Button>
          <Button variant="default" :loading="loading" @click="invite">
            {{ translate('invite_closest') }}
          </Button>
        </div>
      </div>
      <div v-if="globalStore.head2headData?.opponentId" class="flex flex-col gap-2">
        <div class="font-bold text-lg mb-1">{{ translate('in_h2h') }}</div>
        <div class="mb-2" v-if="globalStore.notification?.text">{{ globalStore.notification.text }}</div>
        <div class="flex gap-3 justify-end">
          <Button variant="default" @click="leave()">
            {{ translate('leave_h2h') }}
          </Button>
        </div>
      </div>
      <div v-else-if="globalStore.head2headData?.inviteRaceId" class="flex flex-col gap-2">
        <div class="font-bold text-lg mb-1">{{ translate('head2head_invite') }}</div>
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
import { ref, onMounted } from "vue";
import { translate } from "@/helpers/translate";
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { Head2headData } from "@/store/types";
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
  const res = await api.post("UiFetchH2HData");
  globalStore.head2headData = res.data as Head2headData;
};

const invite = async () => {
  loading.value = true;
  await api.post("UiSetupHead2Head");
  loading.value = false;
  fetchLatestData();
  menu.value = false;
};

const accept = () => {
  loading.value = true;
  api.post("UiJoinHead2Head");
  loading.value = false;
  fetchLatestData();
  closeApp()
}

const leave = async () => {
  loading.value = true;
  await api.post("UiLeaveHead2Head");
  loading.value = false;
  fetchLatestData();
  closeApp();
};


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

<style scoped>
</style>