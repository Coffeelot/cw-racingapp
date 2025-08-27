<template>
  <Card class="big-card" rounded="xl">
    <CardHeader >
      <CardTitle class="title">
        {{ member.racername }}
        <DropdownMenu v-if="isFounder && !memberIsFounder" >
          <DropdownMenuTrigger as-child>
            <Button variant="ghost" class=" ml-2" ><EllipsisVertical /> </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent class="dark" align="end">
            <DropdownMenuItem @click="kickDialog = true">
              {{ translate('kick_member') }}
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </CardTitle>
    </CardHeader>
    <CardContent class="text">
      <Badge v-if="memberIsFounder" ><StarIcon/> {{ translate('founder') }}</Badge>
      <Badge variant="outline">{{ translate('citizen_id') }}: {{ member.citizenID }}</Badge>
    </CardContent>
  </Card>

  <!-- Kick Member Dialog -->
  <Dialog v-model:open="kickDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>
          {{ translate('kick_member') }} {{ member.racername }}?
        </DialogTitle>
      </DialogHeader>
      <div>{{ translate('cant_be_reverted') }}</div>
      <DialogFooter>
        <Button variant="ghost" @click="kickDialog = false">{{ translate('close') }}</Button>
        <Button variant="default" @click="kickMember">{{ translate('confirm') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { CrewMember } from "@/store/types";
import { translate } from "@/helpers/translate";
import {
  Card, CardHeader, CardContent,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from "@/components/ui/dropdown-menu";
import api from "@/api/axios";
import { EllipsisVertical, StarIcon } from "lucide-vue-next";

const props = defineProps<{
  member: CrewMember;
  memberIsFounder: boolean;
  isFounder: boolean;
}>();

const emits = defineEmits(['triggerReload']);

const kickDialog = ref(false);

const kickMember = async () => {
  await api.post("UiKickCrewMember", JSON.stringify({ citizenId: props.member.citizenID, memberName: props.member.racername }));
  kickDialog.value = false;
  emits('triggerReload');
};
</script>

<style scoped>
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
.big-card {
  flex: 1 1 45%;
  max-width: 49%;
  min-width: 20em;
  box-sizing: border-box;
}
</style>