<template>
  <Dialog v-model:open="open">
    <DialogTrigger as-child>
      <Button variant="ghost">
        <PlusIcon />
        {{ translate("create_crew") }}
      </Button>
    </DialogTrigger>
    <DialogContent class="dark text-foreground max-w-2xl">
      <DialogHeader>
        <DialogTitle>{{ translate("create_crew") }}</DialogTitle>
      </DialogHeader>
      <div class="flex flex-col gap-2 mb-2 mt-2">
        <Input
          density="compact"
          :placeholder="translate('crew_name')"
          v-model="crewName"
        />
      </div>
      <DialogFooter>
        <Button
          variant="default"
          type="submit"
          @click="createCrew"
          :loading="loading"
          :disabled="!crewName || loading"
        >
          {{ translate("confirm") }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref } from "vue";
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

const open = ref(false);
const crewName = ref("");
const loading = ref(false);

const emit = defineEmits(["created"]);

const createCrew = async () => {
  if (!crewName.value) return;
  loading.value = true;
  const response = await api.post(
    "UiCreateCrew",
    JSON.stringify({ crewName: crewName.value })
  );
  setTimeout(() => {
    loading.value = false;
    if (response.data) {
      crewName.value = "";
      open.value = false;
      emit("created");
      closeApp();
    }
  }, 1000);
};
</script>

<style scoped>
.card {
  margin-bottom: 1em;
}
</style>