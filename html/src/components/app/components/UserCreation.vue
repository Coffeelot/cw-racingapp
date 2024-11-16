<template>
  <v-card class="w-100 mt-3">
    <v-card-title>{{ translate("create_racer") }} </v-card-title>
    <v-card-text>
      <v-text-field
        color="primary"
        density="compact"
        :placeholder="translate('racer_name')"
        v-model="create.racerName"
      />
      <v-alert icon="$info" color="info" v-if="globalStore.baseData.data.isFirstUser">
        {{ translate('is_first_user') }}
      </v-alert>
    </v-card-text>
    <v-card-actions>
      <v-btn
        block
        color="success"
        variant="flat"
        type="submit"
        @click="createUser()"
        :loading="loading"
        :disabled="shouldDisableButton"
      >
        {{ translate("confirm") }}
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { computed, onMounted, Ref } from "vue";
import { ref } from "vue";
import { translate } from "@/helpers/translate";

const globalStore = useGlobalStore();

const create = ref({
  racerName: "",
});
const loading = ref(false);
const creationType: Ref<any | undefined> = ref(undefined);

const shouldDisableButton = computed(() => {
  if (loading.value) return true;
  if (create.value.racerName === "") return true;

  return false;
});

const createUser = async () => {
  loading.value = true;
  const response = await api.post(
    "UiCreateUser",
    JSON.stringify({
      racerName: create.value.racerName,
      racerId: undefined,
      selectedAuth: creationType.value,
    })
  );
  setTimeout(() => {
    loading.value = false;
    if (response.data) create.value.racerName = "";
  }, 1000);
};

const getMyPermissionedTypes = async () => {
  const typeResults = await api.post('UiGetPermissionedUserTypeFirstUser')
  if (typeResults.data) {
    creationType.value = typeResults.data
  }
}

onMounted(() => {
  getMyPermissionedTypes()
});
</script>

<style scoped lang="scss"></style>
