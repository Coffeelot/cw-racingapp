<template>
  <v-container class="d-flex fill-height">
    <v-row justify="center" align="center">
      <v-card elevation="2" width="500px" maxWidth="500px" class="px-5 py-5">
        <v-card-title
          >Example Card
          <span
            ><v-icon color="primary" size="2rem">mdi-police-badge</v-icon></span
          ></v-card-title
        >
        <v-card-subtitle>Welcome to the example card</v-card-subtitle>
        <div v-if="playerID">
          <div>PlayerID: {{ playerID }}</div>
        </div>
        <v-alert type="error" dark shaped v-if="error">{{ error }}</v-alert>
        <v-text-field
          outlined
          label="Your name goes here"
          v-model="userName"
        ></v-text-field>
        <v-textarea
          outlined
          label="Your message goes here"
          v-model="message"
        ></v-textarea>
        <v-select
          outlined
          :items="colorOptions"
          label="Type of message"
          v-model="typeOfMessage"
        ></v-select>
        <v-layout v-if="typeOfMessage" class="previewLayout">
          <div>Color preview:</div>
          <v-avatar :color="typeOfMessage"></v-avatar>
        </v-layout>
        <v-card-actions>
          <v-btn variant="elevated" class="ml-auto" color="primary" @click="sendData"
            >Send data</v-btn
          >
          <v-btn variant="elevated" elevated color="error" @click="exitMenu">X</v-btn>
        </v-card-actions>
      </v-card>
    </v-row>
  </v-container>
</template>

<script lang="ts">
import { Ref, ref } from "vue";
import api from "@/api/axios";
import { useGlobalStore } from "../store/global";

export default {
  name: "BasicCardView",
  setup() {

    const globalStore = useGlobalStore();

    const colorOptions: Ref<string[]> = ref([
      "success",
      "error",
      "warning",
      "primary",
    ]);
    const typeOfMessage: Ref<string> = ref("");
    const error: Ref<string> = ref("");
    const userName: Ref<string> = ref("");
    const message: Ref<string> = ref("");
    const playerID: string = ''

    const sendError = (text: string) => {
      error.value = text;
      setTimeout(() => {
        error.value = "";
      }, 3000);
    };

    const sendData = async (): Promise<void> => {
      if (userName.value.length < 3) {
        return sendError("Your name should be longer than 2 characters.");
      }
      if (message.value.length < 4) {
        return sendError("Your message should be longer than 3 characters.");
      }
      if (!typeOfMessage.value) {
        return sendError("You must specify the type of message.");
      }

      try {
        await api.post("receiveData", {
          userName: userName.value,
          message: message.value,
          typeOfMessage: typeOfMessage.value,
        });
      } catch (error: any) {
        await api.post("error", error);
      }
    };

    const exitMenu = async () => {
      try {
        await api.post("exitMenu");
      } catch (error: any) {
        await api.post("error", error.message);
      }
    };

    return {
      colorOptions,
      typeOfMessage,
      error,
      userName,
      message,
      playerID,
      sendData,
      exitMenu,
    };
  },
};
</script>

<style scoped>
.previewLayout {
  display: flex;
  align-items: center;
  gap: 1rem;
}
</style>
