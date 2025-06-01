<template>
  <v-card border rounded="xl" class="big-card">
    <v-card-title class="title">{{ racer.racername }}</v-card-title>
    <v-card-text class="text">
      <v-chip color="primary" class="allow-select">{{ translate('citizen_id') }} : {{ racer.citizenid }} </v-chip>
      <v-chip color="primary">{{ translate('tracks') }} : {{ racer.tracks }} </v-chip>
      <v-chip color="primary">{{ translate('races') }} : {{ racer.races }} </v-chip>
      <v-chip color="primary">{{ translate('wins') }} : {{ racer.wins }} </v-chip>
      <v-chip color="primary">{{ translate('auth') }} : {{ racer.auth }} </v-chip>
      <v-chip color="primary">{{ translate('created_by') }} : {{ racer.createdby ? racer.createdby : translate('unknown') }} </v-chip>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn rounded="xl" v-if="globalStore.baseData.data.auth.controlAll" @click="authDialog = true">{{ translate('auth') }}</v-btn>
      <v-btn rounded="xl" @click="revokeDialog = true">{{ revokedBool? translate('activate'):  translate('revoke') }}</v-btn>
      <v-btn rounded="xl" v-if="globalStore.baseData.data.auth.controlAll" @click="deleteDialog = true">{{ translate('delete_user') }} </v-btn>
    </v-card-actions>
  </v-card>
  <v-dialog attach=".app-container" contained v-model="authDialog" width="auto">
    <v-card  rounded="lg">
      <v-card-title>{{ translate('change_auth') }}?</v-card-title>
      <v-card-text>
        <v-select
          color="primary"
          density="compact"
          :items="allAuths"
          item-value="value"
          item-title="text"
          :label="translate('auth')"
          hideDetails
          v-model="authority"
        ></v-select>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="authDialog = false">
            {{ translate('close') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="primary" @click="confirmAuth()">
            {{ translate('confirm') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog attach=".app-container" contained v-model="revokeDialog" width="auto">
    <v-card  rounded="lg">
      <v-card-title>{{ revokedBool ? translate('activate'): translate('revoke') }} {{ translate('access_for') }} {{ racer.racername }}?</v-card-title>
      <v-card-text> {{ translate('can_be_reverted') }}  </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="revokeDialog = false">
            {{ translate('close') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="red" @click="revokeUser()">
            {{ translate('confirm') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog attach=".app-container" contained v-model="deleteDialog" width="auto">
    <v-card rounded="lg">
      <v-card-title>{{ translate('delete_user') }}  {{ racer.racername }}?</v-card-title>
      <v-card-text> {{ translate('cant_be_reverted') }}  </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="deleteDialog = false">
            {{ translate('close') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="red" @click="deleteUser()">
            {{ translate('confirm') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { MyRacer } from "@/store/types";
import { computed } from "vue";
import { ref } from "vue";
import { translate } from "@/helpers/translate";

const props = defineProps<{
  racer: MyRacer;
}>();
const globalStore = useGlobalStore();

const authDialog = ref(false);
const revokeDialog = ref(false);
const deleteDialog = ref(false);
const emits = defineEmits(['triggerReload'])
const revokedBool = computed(() => props.racer.revoked == 1 ? true : false)
const authority = ref(props.racer.auth)

const allAuths = computed(() => {
  const newAuths = globalStore.baseData.data.allAuthorities;
  const authList: string[] = []
  Object.entries(newAuths).map(([key, value]) => {
    authList.push(key)
  });
  return authList
});

const confirmAuth = () => {
    api.post('UiChangeAuth', JSON.stringify({racername: props.racer.racername, auth: authority.value, citizenId: props.racer.citizenid }))
    authDialog.value = false;
    setTimeout(() => {
      emits('triggerReload')
    }, 1000);
};
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
