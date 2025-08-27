<template>
  <div id="SettingsPage" class="page-container">
    <InfoHeader :title="translate('settings')" />
    <div class="pagecontent">
      <div class="item-flex-container">
        <Card class="flexy-card">
          <CardHeader>
            <CardTitle>{{ translate('user_settings') }}</CardTitle>
          </CardHeader>
          <CardContent class="text-muted-foreground flex flex-col gap-3">
            <div class="flex items-center gap-4">
              <Switch
                :model-value="settings.ShowGpsRoute"
                :id="'show-gps-switch'"
                @update:model-value="() => updateSetting('ShowGpsRoute')"
              />
              <label :for="'show-gps-switch'" class="font-medium cursor-pointer">
                {{ translate('show_gps') }}
              </label>
            </div>
            <div class="flex items-center gap-4">
              <Switch
                :model-value="settings.IgnoreRoadsForGps"
                :id="'ignore-roads-switch'"
                @update:model-value="() => updateSetting('IgnoreRoadsForGps')"
              />
              <label :for="'ignore-roads-switch'" class="font-medium cursor-pointer">
                {{ translate('ignore_roads') }}
              </label>
            </div>
            <div class="flex items-center gap-4">
              <Switch
                :model-value="settings.UseUglyWaypoint"
                :id="'base-wps-switch'"
                @update:model-value="() => updateSetting('UseUglyWaypoint')"
              />
              <label :for="'base-wps-switch'" class="font-medium cursor-pointer">
                {{ translate('base_wps') }}
              </label>
            </div>
            <div class="flex items-center gap-4">
              <Switch
                :model-value="settings.UseDrawTextWaypoint"
                :id="'pillar-columns-switch'"
                @update:model-value="() => updateSetting('UseDrawTextWaypoint')"
              />
              <label :for="'pillar-columns-switch'" class="font-medium cursor-pointer">
                {{ translate('pillar_columns') }}
              </label>
              <span class="text-xs text-muted-foreground ml-2" :title="translate('distance_info')">
                <InfoIcon class="inline w-4 h-4" />
              </span>
            </div>
            <div class="flex items-center gap-4">
              <Switch
                :model-value="settings.CheckDistance"
                :id="'distance-check-switch'"
                @update:model-value="() => updateSetting('CheckDistance')"
              />
              <label :for="'distance-check-switch'" class="font-medium">
                {{ translate('distance_check') }}
              </label>
              <span class="text-xs text-muted-foreground ml-2" :title="translate('distance_info')">
                <InfoIcon class="inline w-4 h-4" />
              </span>
            </div>
            <div class="flex items-center gap-4">
              <label :for="'racer-name-select'" class="font-medium">
                {{ translate('user') }}
              </label>
              <Select
                :id="'racer-name-select'"
                :model-value="racerName"
                :disabled="globalStore.activeHudData.InRace"
                :loading="loading"
                class="w-full"
                @update:model-value="updateRacerName"
              >
                <SelectTrigger>
                  <SelectValue :placeholder="translate('user')" />
                </SelectTrigger>
                <SelectContent class="dark">
                  <SelectItem
                    v-for="name in globalStore.baseData.data.racerNames"
                    :key="name.racername"
                    :value="name.racername"
                  >
                    {{ name.racername }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
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
import { Settings } from "@/store/types";
import { getBaseData } from "@/helpers/getBaseData";
import { translate } from "@/helpers/translate";
import {
  Card,
  CardHeader,
  CardTitle,
  CardContent,
} from "@/components/ui/card";
import Switch from "@/components/ui/switch/Switch.vue";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Info as InfoIcon } from "lucide-vue-next";
import InfoHeader from "../components/InfoHeader.vue";

const globalStore = useGlobalStore();
const settings = ref<Settings>({
  ShowGpsRoute: false,
  IgnoreRoadsForGps: false,
  UseUglyWaypoint: false,
  CheckDistance: false,
  UseDrawTextWaypoint: false,
});
const racerName = ref(globalStore.baseData.data.currentRacerName);
const loading = ref(false);

const updateRacerName = async () => {
  loading.value = true;
  await api.post("UiChangeRacerName", JSON.stringify(racerName.value));
  setTimeout(() => {
    getBaseData();
    loading.value = false;
  }, 1000);
};

const getSettings = async () => {
  const res = await api.post("UiGetSettings");
  settings.value = res.data;
};

const updateSetting = async (setting: string) => {
  loading.value = true;
  settings.value[setting as keyof typeof settings.value] = !settings.value[setting as keyof typeof settings.value];
  await api.post("UiUpdateSettings", JSON.stringify({
    setting: setting,
    value: settings.value[setting as keyof typeof settings.value]
  }));
  setTimeout(() => {
    getSettings();
    loading.value = false;
  }, 200);
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