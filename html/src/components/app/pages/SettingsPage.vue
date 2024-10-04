<template>
  <div id="RacingPage" class="pagecontent">
    <v-window >
      <v-window-item value="current" class="tabcontent">
        <v-form>
          <v-card>
            <v-card-title>
              {{ translate('settings') }} 
            </v-card-title>
            <v-card-text>
              <v-container>
                <v-row>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-switch
                      color="primary"
                      :label="translate('show_gps')"
                      v-model="settings.ShowGpsRoute"
                      @change="updateSetting('ShowGpsRoute')"
                    ></v-switch>
                  </v-col>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-switch
                      color="primary"
                      :label="translate('ignore_roads')"
                      v-model="settings.IgnoreRoadsForGps"
                      @change="updateSetting('IgnoreRoadsForGps')"
                    ></v-switch>
                  </v-col>
                </v-row>
                <v-row>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-switch
                      color="primary"
                      :label="translate('base_wps')"
                      v-model="settings.UseUglyWaypoint"
                      @change="updateSetting('UseUglyWaypoint')"
                    ></v-switch>
                  </v-col>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                        <v-switch
                          color="primary"
                          :label="translate('distance_check')"
                          v-model="settings.CheckDistance"
                          @change="updateSetting('CheckDistance')"
                        >
                      </v-switch>
                      <v-tooltip location="top" activator="parent" :text="translate('distance_info')">
                      </v-tooltip>
                  </v-col>
                </v-row>
                <v-row>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                        <v-switch
                          color="primary"
                          :label="translate('pillar_columns')"
                          v-model="settings.UseDrawTextWaypoint"
                          @change="updateSetting('UseDrawTextWaypoint')"
                        >
                      </v-switch>
                      <v-tooltip location="top" activator="parent" :text="translate('distance_info')">
                      </v-tooltip>
                  </v-col>
                </v-row>
                <v-row>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-select
                      color="primary"
                      hide-details
                      :items="globalStore.baseData.data.racerNames"
                      item-value="racername"
                      item-title="racername"
                      :label="translate('user')"
                      v-model="racerName"
                      :loading="loading"
                      :disabled="globalStore.activeHudData.InRace"
                      @update:model-value="updateRacerName()"
                    ></v-select>
                  </v-col>
                </v-row>
              </v-container>
            </v-card-text>
          </v-card>
        </v-form>
      </v-window-item>
    </v-window>
  </div>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { ref } from "vue";
import { onMounted } from "vue";
import { Settings } from "@/store/types";
import { Ref } from "vue";
import { getBaseData } from "@/helpers/getBaseData";
import { translate } from "@/helpers/translate";

const globalStore = useGlobalStore();
const settings: Ref<Settings> = ref({
    ShowGpsRoute: false,
    IgnoreRoadsForGps: false,
    UseUglyWaypoint: false,
    CheckDistance: false,
    UseDrawTextWaypoint: false,
})
const racerName = ref(globalStore.baseData.data.currentRacerName)
const loading = ref(false)
const updateSetting = async (setting: string) => {
  await api.post("UiUpdateSettings", JSON.stringify({setting: setting, value: settings.value[setting as unknown as keyof typeof settings.value] }));
};

const updateRacerName = async () => {
  loading.value = true
  await api.post("UiChangeRacerName", JSON.stringify(racerName.value));
  setTimeout(() => {
    getBaseData()
    loading.value = false
  }, 1000);
};

const getSettings = async () => {
  const res = await api.post("UiGetSettings");
  settings.value = res.data
};

onMounted(() => {
  getSettings();
});
</script>

<style scoped lang="scss">
.available-races {
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
}
</style>
