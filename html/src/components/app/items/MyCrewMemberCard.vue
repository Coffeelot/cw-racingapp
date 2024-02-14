<template>
  <v-card class="big-card">
    <v-card-title class="title">{{ member.racername }} {{ memberIsFounder && '⭐' }}</v-card-title>
    <v-card-text class="text">
      <v-chip>CitizenID: {{ member.citizenID }} </v-chip>
    </v-card-text>
  </v-card>
  <!-- <v-dialog contained v-model="deleteDialog" width="auto">
    <v-card>
      <v-card-title>Kick user {{ racer.racername }}?</v-card-title>
      <v-card-text> This <b>can not</b> be reverted. </v-card-text>
      <v-card-actions>
        <v-btn @click="deleteDialog = false">
            Close Dialog
        </v-btn>
        <v-btn color="red" @click="deleteUser()">
            Confirm
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog> -->
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { CrewMember } from "@/store/types";
import { computed, ref } from "vue";

const props = defineProps<{
  member: CrewMember;
  memberIsFounder: boolean;
  isFounder: boolean;
}>();
const globalStore = useGlobalStore();

const deleteDialog = ref(false);
const emits = defineEmits(['triggerReload'])

// const deleteUser = async () => {
//     api.post('UiRemoveRacer',  JSON.stringify({racername: props.racer.racername}))
//     deleteDialog.value = false;
//     setTimeout(() => {
//       emits('triggerReload')
//     }, 1000);
// };

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
