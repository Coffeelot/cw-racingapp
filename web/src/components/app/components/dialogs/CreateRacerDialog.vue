<template>
  <Dialog v-model:open="open">
    <DialogTrigger as-child>
      <Button variant="ghost">
        <PlusIcon />
        {{ translate("create_racer") }}
      </Button>
    </DialogTrigger>
    <DialogContent class="dark text-foreground max-w-2xl">
      <DialogHeader>
        <DialogTitle>{{ translate("create_racer") }}</DialogTitle>
      </DialogHeader>
      <div class="flex flex-col gap-2 mb-2 mt-2">
        <Input
          density="compact"
          :placeholder="translate('racer_name')"
          v-model="racerName"
        />
        <Input
          density="compact"
          :placeholder="translate('racer_id')"
          v-model="racerId"
        />
        <Select
          v-if="creationTypes && creationTypes.length > 0"
          v-model="selectedAuth"
          class="mt-2 dark"
        >
          <SelectTrigger>
            <SelectValue :placeholder="translate('auth')" />
          </SelectTrigger>
          <SelectContent class="dark">
            <SelectItem
              v-for="auth in Object.values(creationTypes)"
              :key="auth.value || auth"
              :value="auth"
            >
              {{ auth.label || auth }}
            </SelectItem>
          </SelectContent>
        </Select>
        <InfoText v-else :title="translate('not_auth')" />
      </div>
      <DialogFooter>
        <Button
          variant="default"
          type="submit"
          @click="createUser"
          :loading="loading"
          :disabled="shouldDisableButton"
        >
          {{ translate("confirm") }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, Ref } from "vue";
import { translate } from "@/helpers/translate";
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import DialogFooter from "@/components/ui/dialog/DialogFooter.vue";
import { PlusIcon } from "lucide-vue-next";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { availableUsersMock } from "@/mocking/testState";
import InfoText from "../InfoText.vue";

const open = ref(false);
const racerName = ref("");
const racerId = ref("");
const selectedAuth = ref(undefined);
const creationTypes: Ref<any[] | undefined> = ref([]);
const loading = ref(false);

const shouldDisableButton = computed(() => {
  if (loading.value) return true;
  if (!racerName.value) return true;
  if (!selectedAuth.value) return true;
  return false;
});

const fetchCreationTypes = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    creationTypes.value = availableUsersMock;
    return
  }
  const typeResults = await api.post('UiGetPermissionedUserTypes');
  if (typeResults.data) {
    creationTypes.value = typeResults.data;
  }
};

const createUser = async () => {
  loading.value = true;
  const response = await api.post(
    "UiCreateUser",
    JSON.stringify({
      racerName: racerName.value,
      racerId: racerId.value,
      selectedAuth: selectedAuth.value,
    })
  );
  setTimeout(() => {
    loading.value = false;
    if (response.data) {
      racerName.value = '';
      racerId.value = '';
      open.value = false;
      closeApp();
    }
  }, 1000);
};

onMounted(() => {
  fetchCreationTypes();
});
</script>
<style scoped>
.card {
  margin-bottom: 1em;
}
</style>