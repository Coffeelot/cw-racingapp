<template>
  <Card class="w-full mt-3">
    <CardHeader>
      <CardTitle>{{ translate("create_racer") }}</CardTitle>
    </CardHeader>
    <CardContent>
      <Input
        :placeholder="translate('racer_name')"
        v-model="create.racerName"
        class="mb-2"
      />
      <Alert v-if="globalStore.baseData.data.isFirstUser" variant="default" class="mb-2">
        {{ translate('is_first_user') }}
      </Alert>
    </CardContent>
    <CardFooter>
      <Button
        class="w-full"
        variant="default"
        type="submit"
        @click="createUser"
        :loading="loading"
        :disabled="shouldDisableButton"
      >
        {{ translate("confirm") }}
      </Button>
    </CardFooter>
  </Card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { computed, onMounted, ref } from "vue";
import { translate } from "@/helpers/translate";
import {
  Card,
  CardHeader,
  CardTitle,
  CardContent,
  CardFooter,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import Input from "@/components/ui/input/Input.vue";
import { Alert } from "@/components/ui/alert";

const globalStore = useGlobalStore();

const create = ref({
  racerName: "",
});
const loading = ref(false);
const creationType = ref<any | undefined>(undefined);

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
  const typeResults = await api.post('UiGetPermissionedUserTypeFirstUser');
  if (typeResults.data) {
    creationType.value = typeResults.data;
  }
};

onMounted(() => {
  getMyPermissionedTypes();
});
</script>

<style scoped></style>