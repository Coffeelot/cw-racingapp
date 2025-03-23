<template>
  <v-card border rounded="xl" class="big-card">
    <v-card-title class="title">{{ member.racername }} {{ memberIsFounder ? '⭐' :'' }}</v-card-title>
    <v-card-text class="text">
      <v-chip color="primary">{{ translate('citizen_id') }}: {{ member.citizenID }} </v-chip>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { CrewMember } from "@/store/types";
import { translate } from "@/helpers/translate";

const props = defineProps<{
  member: CrewMember;
  memberIsFounder: boolean;
  isFounder: boolean;
}>();

const emits = defineEmits(['triggerReload'])


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
