<template>
  <v-dialog v-model="open" persistent width="1024" contained>
    <v-form>
      <v-card>
        <v-card-title class="title-holder">
          {{ translate('selected_track') }} {{ track.RaceName }}
        </v-card-title>
        <v-card-text>
          <v-container>
            <v-row>
              <v-col cols="12" sm="6">
                <v-select
                  color="primary"
                  density="compact"
                  :items="lapsFiltered"
                  item-value="value"
                  item-title="text"
                  :label="translate('laps')"
                  hideDetails
                  v-model="setupData.laps"
                ></v-select>
              </v-col>
              <v-col cols="12" sm="6">
                <v-select
                  color="primary"
                  density="compact"
                  :items="globalStore.baseData.data.buyIns"
                  item-value="value"
                  item-title="text"
                  :label="translate('buy_in')"
                  hideDetails
                  v-model="setupData.buyIn"
                ></v-select>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="12" sm="6">
                <v-select
                  color="primary"
                  density="compact"
                  v-if="globalStore.baseData.data.ghostingEnabled"
                  :items="globalStore.baseData.data.ghostingTimes"
                  item-value="value"
                  item-title="text"
                  :label="translate('ghosting')"
                  hideDetails
                  v-model="setupData.ghosting"
                ></v-select>
              </v-col>
              <v-col cols="12" sm="6">
                <v-select
                  color="primary"
                  density="compact"
                  :items="globalStore.baseData.data.classes"
                  item-value="value"
                  item-title="text"
                  :label="translate('max_class')"
                  hideDetails
                  v-model="setupData.maxClass"
                ></v-select>
              </v-col>
              <v-col cols="12" sm="6">
                <v-switch
                  color="primary"
                  v-if="globalStore.baseData.data.auth.startReversed"
                  class="reverse-switch"
                  :label="translate('reversed')"
                  v-model="setupData.reversed"
                  density="compact"
                  hide-details
                >
                </v-switch>
              </v-col>
              <v-col cols="12" sm="6">
                <v-switch
                  color="primary"
                  class="reverse-switch"
                  :label="translate('first_person')"
                  v-model="setupData.firstPerson"
                  density="compact"
                  hide-details
                >
                </v-switch>
              </v-col>
            </v-row>
            <v-row>
              <v-col
                v-if="globalStore?.baseData?.data?.auth?.setupParticipation"
                cols="12"
                sm="6"
              >
                <v-text-field
                  color="primary"
                  class="text-field"
                  hideDetails
                  :label="translate('participation_amount')"
                  density="compact"
                  type="number"
                  v-model="setupData.participationMoney"
                >
                  <template v-slot:prepend>
                    <v-tooltip location="bottom">
                      <template v-slot:activator="{ props }">
                        <v-icon
                          v-bind="props"
                          icon="mdi-help-circle-outline"
                        ></v-icon>
                      </template>
                      {{ translate('participation_info') }} 
                    </v-tooltip>
                  </template>
                </v-text-field>
              </v-col>
              <v-col
                v-if="globalStore?.baseData?.data?.auth?.setupParticipation"
                cols="12"
                sm="6"
              >
                <v-select
                  :label="translate('currency')"
                  density="compact"
                  :items="['cash', 'bank', 'crypto']"
                  v-model="setupData.participationCurrency"
                ></v-select>
              </v-col>
              <v-col
                v-if="globalStore?.baseData?.data?.auth?.startRanked"
                cols="12"
                sm="6"
              >
                <v-switch
                  color="primary"
                  :label="translate('ranked')"
                  v-model="setupData.ranked"
                  density="compact"
                  hide-details
                  :disabled="setupData.laps === -1"
                >
                </v-switch>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn rounded="lg" variant="text" @click="handleClose()">
            {{ translate('close') }} 
          </v-btn>
          <v-btn
            rounded="lg"
            color="success"
            variant="flat"
            @click="handleConfirm()"
          >
            {{ translate('confirm') }} 
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-form>
  </v-dialog>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { Track } from "@/store/types";
import { computed } from "vue";
import { ref } from "vue";
import { translate } from "@/helpers/translate";

const props = defineProps<{
  track: Track;
  open: boolean;
}>();

const emits = defineEmits(["goBack"]);
const globalStore = useGlobalStore();
const open = ref(props.open);

const lapsFiltered = computed(() =>
  globalStore.baseData.data.laps.filter((lapType) => {
    if (lapType.value === -1) {
      // For elimination
      return globalStore.baseData.data.auth.startElimination;
    }
    return true;
  })
);

const setupData = ref({
  laps: globalStore.baseData.data.laps[1].value,
  buyIn: globalStore.baseData.data.buyIns[0].value,
  ghosting: globalStore.baseData.data.ghostingTimes[0].value,
  maxClass: globalStore.baseData.data.classes[0].value,
  ranked: false,
  reversed: false,
  firstPerson: false,
  participationMoney: 0,
  participationCurrency: "cash",
});

const handleClose = () => {
  open.value = false;
  emits("goBack");
};

const handleConfirm = async () => {
  if (setupData.value.participationMoney < 0)
    setupData.value.participationMoney = 0;
  if (setupData.value.laps === -1) setupData.value.ranked = false;

  let data = {
    track: props.track.RaceId,
    laps: setupData.value.laps,
    buyIn: setupData.value.buyIn,
    maxClass: setupData.value.maxClass,
    ghostingOn: setupData.value.ghosting !== -1,
    ghostingTime: setupData.value.ghosting,
    ranked: setupData.value.ranked,
    participationMoney: setupData.value.participationMoney,
    participationCurrency: setupData.value.participationCurrency,
    reversed: setupData.value.reversed,
    firstPerson: setupData.value.firstPerson,
  };

  const res = await api.post("UiSetupRace", JSON.stringify(data));
  if (res.data) {
    open.value = false;
    closeApp();
    emits("goBack");
  }
};
</script>

<style scoped lang="scss">
.title-holder {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.reverse-switch {
  display: flex;
  justify-content: flex-end;
}
</style>
