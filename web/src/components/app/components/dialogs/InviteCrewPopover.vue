<template>
  <Popover v-model:open="open">
    <PopoverTrigger as-child>
      <Button variant="ghost">
        <PlusIcon />
        {{ translate("invite_member") }}
      </Button>
    </PopoverTrigger>
    <PopoverContent class="dark text-foreground w-96">
      <Tabs v-model="tab" class="mb-4 h-fit">
        <TabsList>
          <TabsTrigger value="closest">{{ translate("invite_closest") }}</TabsTrigger>
          <TabsTrigger value="manual">{{ translate("invite") }}</TabsTrigger>
        </TabsList>
        <TabsContent value="closest">
          <div class="flex flex-col gap-2 mb-2 mt-2 h-fit">
            <Button
              block
              variant="default"
              type="button"
              @click="inviteMemberClosest"
              :loading="loading"
            >
              {{ translate("confirm") }}
            </Button>
          </div>
        </TabsContent>
        <TabsContent value="manual">
          <div class="flex flex-col gap-2 mb-2 mt-2">
            <Input
              density="compact"
              placeholder="CitizenID"
              v-model="inviteText"
            />
            <Button
              block
              variant="default"
              type="button"
              @click="inviteMember"
              :loading="loading"
              :disabled="!inviteText"
            >
              {{ translate("confirm") }}
            </Button>
          </div>
        </TabsContent>
      </Tabs>
    </PopoverContent>
  </Popover>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { translate } from "@/helpers/translate";
import api from "@/api/axios";
import {
  Popover,
  PopoverTrigger,
  PopoverContent,
} from "@/components/ui/popover";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { PlusIcon } from "lucide-vue-next";

const open = ref(false);
const tab = ref("closest");
const inviteText = ref("");
const loading = ref(false);

const inviteMember = async () => {
  loading.value = true;
  const response = await api.post(
    "UiSendInvite",
    JSON.stringify({ citizenId: inviteText.value })
  );
  setTimeout(() => {
    loading.value = false;
    if (response.data) inviteText.value = "";
    open.value = false;
  }, 1000);
};

const inviteMemberClosest = async () => {
  loading.value = true;
  const response = await api.post("UiSendInviteClosest", JSON.stringify({}));
  setTimeout(() => {
    loading.value = false;
    open.value = false;
  }, 1000);
};
</script>

<style scoped>
.card {
  margin-bottom: 1em;
}
</style>