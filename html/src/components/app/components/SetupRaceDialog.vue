<template>
  <v-dialog
          v-model="open"
          persistent
          width="1024"
          contained
        >
        <v-form>
          <v-card>
            <v-card-title>
              Track selected: {{ track.RaceName }}
            </v-card-title>
            <v-card-text>
              <v-container>
                <v-row>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-select
                    density="compact"

                      :items="globalStore.baseData.data.laps"
                      item-value="value"
                      item-title="text"
                      label="Laps"
                      v-model="setupData.laps"
                    ></v-select>
                  </v-col>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-select
                    density="compact"

                      :items="globalStore.baseData.data.buyIns"
                      item-value="value"
                      item-title="text"
                      label="Buy In"
                      v-model="setupData.buyIn"
                    ></v-select>
                  </v-col>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-select
                    density="compact"

                      v-if="globalStore.baseData.data.ghostingEnabled"
                      :items="globalStore.baseData.data.ghostingTimes"
                      item-value="value"
                      item-title="text"
                      label="Ghosting"
                      v-model="setupData.ghosting"
                    ></v-select>
                  </v-col>
                  <v-col
                    cols="12"
                    sm="6"
                  >
                    <v-select
                    density="compact"

                     :items="globalStore.baseData.data.classes"
                      item-value="value"
                      item-title="text"
                      label="Max Class"
                      v-model="setupData.maxClass"
                    ></v-select>
                  </v-col>
                  <v-col
                    v-if="globalStore?.baseData?.data?.auth?.setupParticipation"
                    cols="12"
                    sm="6"
                  >
                    <v-text-field
                      class="text-field"
                      hideDetails
                      label="Participation Amount"
                      density="compact"
                      type="number"
                      v-model="setupData.participationMoney"
                    ></v-text-field>
                  </v-col>
                  <v-col
                    v-if="globalStore?.baseData?.data?.auth?.setupParticipation"
                    cols="12"
                    sm="6"
                  >
                    <v-select
                      label="Participation currency"
                      density="compact"
                      :items="['cash', 'debit', 'crypto']"
                      v-model="setupData.participationCurrency"
                    ></v-select>
                  </v-col>
                  <v-col
                    v-if="globalStore?.baseData?.data?.auth?.startRanked"
                    cols="12"
                    sm="6"
                  >
                    <v-switch
                      label="Ranked"
                      v-model="setupData.ranked"
                      density="compact"
                    >
                    </v-switch>
                  </v-col>
                </v-row>
              </v-container>
            </v-card-text>
            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn
                variant="text"
                @click="handleClose()"
              >
                Close
              </v-btn>
              <v-btn
                variant="tonal"
                color="primary"
                @click="handleConfirm()"
              >
                Confirm
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
import { ref } from "vue";

const props = defineProps<{
  track: Track;
  open: boolean;
}>();

const emits = defineEmits(["goBack"]);
const globalStore = useGlobalStore();
const open = ref(props.open)
const setupData = ref({
  laps: globalStore.baseData.data.laps[0].value,
  buyIn: globalStore.baseData.data.buyIns[0].value,
  ghosting: globalStore.baseData.data.ghostingTimes[0].value,
  maxClass: globalStore.baseData.data.classes[0].value,
  ranked: false,
  participationMoney: 0,
  participationCurrency: 'cash'
})

const handleClose = () => {
  open.value = false
  emits('goBack')
}


const handleConfirm = async () => {
  let data = {
        track: props.track.RaceId,
        laps: setupData.value.laps,
        buyIn: setupData.value.buyIn,
        maxClass: setupData.value.maxClass,
        ghostingOn: setupData.value.ghosting !== -1,
        ghostingTime: setupData.value.ghosting,
        ranked: setupData.value.ranked,
        participationMoney: setupData.value.participationMoney,
        participationCurrency: setupData.value.participationCurrency
    }

  const res = await api.post("UiSetupRace", JSON.stringify(data));
  if (res) {
    open.value = false
    closeApp()
    emits('goBack')
  }
}

</script>

<style scoped lang="scss"></style>
