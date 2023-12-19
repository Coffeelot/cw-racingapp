<template>
  <v-card class="big-card">
    <v-card-title class="title">{{ racer.racername }}</v-card-title>
    <v-card-text class="text">
      <v-chip>CitizenID: {{ racer.citizenid }} </v-chip>
      <v-chip>Tracks: {{ racer.tracks }} </v-chip>
      <v-chip>Races: {{ racer.races }} </v-chip>
      <v-chip>Wins: {{ racer.wins }} </v-chip>
      <v-chip>Auth: {{ racer.auth }} </v-chip>
      <v-chip>Created By: {{ racer.createdby ? racer.createdby : 'Unknown' }} </v-chip>
    </v-card-text>
    <v-card-actions>
      <v-btn variant="tonal" @click="revokeDialog = true">{{ revokedBool? 'Activate': 'Revoke' }}</v-btn>
      <v-btn variant="tonal" v-if="globalStore.baseData.data.auth.controlAll" @click="deleteDialog = true">Delete User</v-btn>
    </v-card-actions>
  </v-card>
  <v-dialog contained v-model="revokeDialog" width="auto">
    <v-card>
      Setting to {{  revokedBool ? 0 : 1 }}
      <v-card-title>{{ revokedBool ? 'Activate':'Revoke' }} access for {{ racer.racername }}?</v-card-title>
      <v-card-text> This can be reverted. </v-card-text>
      <v-card-actions>
        <v-btn @click="revokeDialog = false">
            Close Dialog
        </v-btn>
        <v-btn @click="revokeUser()">
            Confirm
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog contained v-model="deleteDialog" width="auto">
    <v-card>
      <v-card-title>Delete user {{ racer.racername }}?</v-card-title>
      <v-card-text> This <b>can not</b> be reverted. </v-card-text>
      <v-card-actions>
        <v-btn @click="deleteDialog = false">
            Close Dialog
        </v-btn>
        <v-btn color="red" @click="deleteUser()">
            Confirm
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import RacerList from "@/components/hud/RacerList.vue";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { MyRacer } from "@/store/types";
import { computed } from "vue";
import { ref } from "vue";

const props = defineProps<{
  racer: MyRacer;
}>();
const globalStore = useGlobalStore();

const revokeDialog = ref(false);
const deleteDialog = ref(false);
const emits = defineEmits(['triggerReload'])
const revokedBool = computed(() => props.racer.revoked == 1 ? true : false)

const revokeUser = () => {
    api.post('UiRevokeRacer', JSON.stringify({racername: props.racer.racername, status: props.racer.revoked }))
    revokeDialog.value = false;
    setTimeout(() => {
      emits('triggerReload')
    }, 1000);
};
const deleteUser = async () => {
    api.post('UiRemoveRacer',  JSON.stringify({racername: props.racer.racername}))
    deleteDialog.value = false;
    setTimeout(() => {
      emits('triggerReload')
    }, 1000);
};


</script>

<style scoped lang="scss">
.text {
    display: flex;
    gap: 0.5em;
    flex-wrap: wrap;
}
.title {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.available-card {
  flex-grow: 1;
}
</style>
