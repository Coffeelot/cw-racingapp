<template>
    <Popover v-if="invites" class="invite-popover" >
        <PopoverTrigger as-child>
          <Button variant="outline" class="ml-2">
            {{ translate('invites') }}
            <Badge v-if="invites" class="invite-badge rounded-xl">!</Badge>
          </Button>
        </PopoverTrigger>
        <PopoverContent align="end" class="dark w-96">
          <div class="grid gap-4" v-if="invites">
            <div class="mb-2 font-bold">{{ translate('invite_from_crew') }}: {{ invites.crewName }}</div>
            <div class="flex gap-2">
              <Button variant="destructive" @click="denyCrew" :loading="loading">{{ translate('deny') }}</Button>
              <Button variant="default" @click="joinCrew" :loading="loading">{{ translate('accept') }}</Button>
            </div>
          </div>
          <div v-else class="grid gap-4">

          </div>
        </PopoverContent>
      </Popover>
</template>
<script setup lang="ts">
import api from '@/api/axios';
import Badge from '@/components/ui/badge/Badge.vue';
import { Button } from '@/components/ui/button';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { translate } from '@/helpers/translate';
import { ref } from 'vue';

const props = defineProps<{
  invites: any;
}>();

const emit = defineEmits<{
  (e: 'refreshCrew'): void;
}>();

const loading = ref(false);
const joinCrew = async () => {
  loading.value = true;
  api.post(
    "UiAcceptInvite",
    JSON.stringify({ crewName: props.invites.crewName })
  );
  setTimeout(() => {
    emit('refreshCrew')
    loading.value = false;
  }, 1000);
};

const denyCrew = async () => {
  loading.value = true;
  api.post("UiDenyInvite", JSON.stringify({}));
  setTimeout(() => {
    emit('refreshCrew')
    loading.value = false;
  }, 1000);
};

</script>
<style scoped>
</style>