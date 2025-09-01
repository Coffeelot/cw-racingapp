<template>
  <Dialog v-model:open="open">
    <DialogTrigger as-child>
      <Button variant="ghost">
        <PlusIcon></PlusIcon>
        {{ translate("create_track") }}
      </Button>
    </DialogTrigger>
    {{ tab }}
    <DialogContent class="dark text-foreground z-3000 max-w-2xl">
      <DialogHeader>
        <DialogTitle>{{ translate("create_track") }}</DialogTitle>
      </DialogHeader>
      <Tabs v-model="tab" class="mb-4">
        <TabsList>
          <TabsTrigger value="editor">{{
            translate("create_with_editor")
          }}</TabsTrigger>
          <TabsTrigger value="share">{{
            translate("create_with_share")
          }}</TabsTrigger>
        </TabsList>
        <TabsContent value="editor">
          <h2>{{ translate("create_with_editor") }}</h2>
          <div class="flex flex-col gap-2 mb-2 mt-2">
            <Input
              density="compact"
              :placeholder="translate('track_name')"
              v-model="trackName"
            />
          </div>
        </TabsContent>
        <TabsContent value="share">
          <h2>{{ translate("create_with_share") }}</h2>
          <div class="flex flex-col gap-2 mb-2 mt-2">
            <Input
              density="compact"
              :placeholder="translate('track_name')"
              v-model="trackName"
            />
            <Input
              density="compact"
              placeholder="Paste Checkpoints Here"
              v-model="checkpoints"
            />
          </div>
        </TabsContent>
      </Tabs>
      <DialogFooter>
        <Button
          variant="default"
          type="submit"
          @click="openRaceEditor"
        >
          {{ translate("confirm") }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref } from "vue";
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import DialogFooter from "@/components/ui/dialog/DialogFooter.vue";
import { PlusIcon } from "lucide-vue-next";
import { translate } from "@/helpers/translate";

const open = ref(false);
const tab = ref("editor");
const trackName = ref("");
const checkpoints = ref("");

const openRaceEditor = async () => {
  const response = await api.post(
    "UiCreateTrack",
    JSON.stringify({ name: trackName.value, checkpoints: checkpoints.value === "" ? undefined : checkpoints.value })
  );
  if (response.data) closeApp();
};

</script>

<style scoped>
.card {
  margin-bottom: 1em;
}
</style>
