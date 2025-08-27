<template>
  <div id="SettingsPage" class="page-container">
    <InfoHeader :title="translate('race_admin')">
    </InfoHeader>
    <div class="pagecontent">
      <div class="item-flex-container">
        <Card class="flexy-card" v-if="globalStore.baseData.data.auth.handleHosting || globalStore.baseData.data.auth.handleAutoHost">
          <CardHeader>
            <CardTitle>{{ translate('hosting') }}</CardTitle>
          </CardHeader>
          <CardContent class="text-muted-foreground flex flex-col gap-3">
        <div v-if="globalStore.baseData.data.auth.handleHosting" class="flex items-center gap-4">
          <Switch
           :model-value="settings.hostingIsEnabled"
            :id="'hosting-switch'"
             @update:model-value="updateHosting"
          />
          <label :for="'hosting-switch'" class="font-medium cursor-pointer">
            {{ translate('enable_hosting') }}
          </label>
        </div>
        <div v-if="globalStore.baseData.data.auth.handleAutoHost" class="flex flex-col gap-2">
          <div class="flex items-center gap-4 flex-wrap">
            <Switch
             :model-value="settings.autoHostIsEnabled"
              :id="'autohost-switch'"
               @update:model-value="updateAutoHost"
            />
            <label :for="'autohost-switch'" class="font-medium cursor-pointer">
              {{ translate('enable_auto_hosting') }}
            </label>
            <Button @click="newAutoHost" :loading="loading" variant="default">
              {{ translate('trigger_new_autohost') }}
            </Button>
  
          </div>
        </div>
          </CardContent>
        </Card>
        <Card class="flexy-card" v-if="globalStore.baseData.data.auth.handleBounties">
          <CardHeader>
            <CardTitle>{{ translate('bounties') }}</CardTitle>
          </CardHeader>
          <CardContent class="text-muted-foreground gap-3">
            <Button @click="rerollBounties" :loading="loading" variant="default">
              {{ translate('reroll_bounties') }}
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
    </div>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { ref, onMounted } from "vue";
import { translate } from "@/helpers/translate";
import {
  Card,
  CardHeader,
  CardTitle,
  CardContent,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import Switch from "@/components/ui/switch/Switch.vue";
import InfoHeader from "../components/InfoHeader.vue";

const loading = ref(false);
const globalStore = useGlobalStore();

const settings = ref({
  autoHostIsEnabled: false,
  hostingIsEnabled: false,
});


const getSettings = async () => {
  loading.value = true;
  const res = await api.post("UiGetAdminData");
  settings.value = res.data;
  loading.value = false;
};

const updateAutoHost = async () => {
  loading.value = true;
  await api.post("UiToggleAutoHost");
  settings.value.autoHostIsEnabled = !settings.value.autoHostIsEnabled
  loading.value = false;
};

const updateHosting = async () => {
  loading.value = true;
  await api.post("UiToggleHosting");
  settings.value.hostingIsEnabled = !settings.value.hostingIsEnabled
  loading.value = false;
};

const rerollBounties = () => {
  api.post('UIRerollBounties');
};

const newAutoHost = () => {
  api.post('UINewAutoHost');
};

onMounted(() => {
  getSettings();
});
</script>

<style scoped>
.max-w-2xl {
  max-width: 42rem;
}
</style>