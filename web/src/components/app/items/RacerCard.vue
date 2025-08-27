<template>
  <Card class="racer-card" rounded="xl">
    <CardHeader class="title">
      <span>{{ racer.racername }}</span>
      <DropdownMenu >
        <DropdownMenuTrigger as-child>
          <Button variant="ghost" class="ml-2"><EllipsisVertical /> </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent class="dark" align="end" >
          <DropdownMenuItem v-if="globalStore.baseData.data.auth.controlAll" @click="authDialog = true">
            {{ translate('auth') }}
          </DropdownMenuItem>
          <DropdownMenuItem @click="revokeDialog = true">
            {{ revokedBool ? translate('activate') : translate('revoke') }}
          </DropdownMenuItem>
          <DropdownMenuItem v-if="globalStore.baseData.data.auth.controlAll" @click="deleteDialog = true">
            {{ translate('delete_user') }}
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </CardHeader>
  
    <CardContent class="text">
      <Badge variant="outline" class="allow-select">{{ translate('citizen_id') }} : {{ racer.citizenid }}</Badge>
      <Badge variant="outline">{{ translate('tracks') }} : {{ racer.tracks }}</Badge>
      <Badge variant="outline">{{ translate('races') }} : {{ racer.races }}</Badge>
      <Badge variant="outline">{{ translate('wins') }} : {{ racer.wins }}</Badge>
      <Badge variant="outline">{{ translate('auth') }} : {{ racer.auth }}</Badge>
      <Badge variant="outline">{{ translate('created_by') }} : {{ racer.createdby ? racer.createdby : translate('unknown') }}</Badge>
    </CardContent>
  </Card>

  <!-- Auth Dialog -->
  <Dialog v-model:open="authDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ translate('change_auth') }}?</DialogTitle>
      </DialogHeader>
      <div>
        <Select v-model="authority" >
          <SelectTrigger>
            <SelectValue :placeholder="translate('auth')" />
          </SelectTrigger>
          <SelectContent class="dark" >
            <SelectItem v-for="auth in allAuths" :key="auth" :value="auth">
              {{ auth }}
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
      <DialogFooter>
        <Button variant="default" @click="confirmAuth">{{ translate('confirm') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>

  <!-- Revoke Dialog -->
  <Dialog v-model:open="revokeDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>
          {{ revokedBool ? translate('activate') : translate('revoke') }} {{ translate('access_for') }} {{ racer.racername }}?
        </DialogTitle>
        <DialogDescription>
          <div>{{ translate('can_be_reverted') }}</div>
        </DialogDescription>
      </DialogHeader>
      
      <DialogFooter>
        <Button variant="destructive" @click="revokeUser">{{ translate('confirm') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>

  <!-- Delete Dialog -->
  <Dialog v-model:open="deleteDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ translate('delete_user') }} {{ racer.racername }}?</DialogTitle>
      </DialogHeader>
      <DialogDescription>
        <div>{{ translate('delete_user_desc') }}</div>
      </DialogDescription>
      <DialogFooter>
        <Button variant="destructive" @click="deleteUser">{{ translate('confirm') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { MyRacer } from "@/store/types";
import { computed } from "vue";
import { ref } from "vue";
import { translate } from "@/helpers/translate";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogTitle } from "@/components/ui/dialog";
import DialogHeader from "@/components/ui/dialog/DialogHeader.vue";
import { Select, SelectTrigger, SelectValue } from "@/components/ui/select";
import SelectContent from "@/components/ui/select/SelectContent.vue";
import SelectItem from "@/components/ui/select/SelectItem.vue";
import { EllipsisVertical } from "lucide-vue-next";

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

<style scoped >
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
.racer-card {
  flex: 1 1 45%;
  max-width: 49%;
  min-width: 20em;
  box-sizing: border-box;
}
</style>
