<template>
  <div id="SettingsPage" class="pagecontent">
    <v-window >
      <v-window-item value="current" class="tabcontent">
        <v-form>
          <v-card>
            <v-card-title>
              {{ translate('race_admin') }} 
            </v-card-title>
            <v-card-text>
              <v-container>
                <v-row v-if="globalStore.baseData.data.auth.handleHosting" >
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-switch
                      color="primary"
                      :label="translate('enable_hosting')"
                      v-model="settings.hostingIsEnabled"
                      @change="updateHosting"
                    ></v-switch>
                  </v-col>
                </v-row>
                <v-row v-if="globalStore.baseData.data.auth.handleAutoHost" >
                                    <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-btn @click="newAutoHost" variant="flat" color="primary">{{ translate('trigger_new_autohost') }}</v-btn>
                  </v-col>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-switch
                      color="primary"
                      :label="translate('enable_auto_hosting')"
                      v-model="settings.autoHostIsEnabled"
                      @change="updateAutoHost"
                    ></v-switch>
                  </v-col>
                </v-row>
                <v-row v-if="globalStore.baseData.data.auth.handleBounties">
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-btn @click="rerollBounties" variant="flat" color="primary">{{ translate('reroll_bounties') }}</v-btn>
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
import { translate } from "@/helpers/translate";

const settings = ref({
  autoHostIsEnabled: false,
  hostingIsEnabled: false,
})

const globalStore = useGlobalStore();
const loading = ref(false)

const updateAutoHost = async (setting: string) => {
  loading.value = true
  await api.post("UiToggleAutoHost");
  loading.value = false

};

const updateHosting = async (setting: string) => {
  loading.value = true
  await api.post("UiToggleHosting");
  loading.value = false

};

const rerollBounties = () => {
  api.post('UIRerollBounties')
}

const newAutoHost = () => {
  api.post('UINewAutoHost')
}

const getSettings = async () => {
  loading.value = true
  const res = await api.post("UiGetAdminData");
  settings.value = res.data
  loading.value = false
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
