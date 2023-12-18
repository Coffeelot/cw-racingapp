<template>
      <v-navigation-drawer
        :v-model="currentPage"
        expand-on-hover
        rail
      >
        <v-list density="compact" nav>
            <v-list-item prepend-icon="mdi-racing-helmet" title="Racing" value="racing" @click="openPage('racing')"></v-list-item>
            <v-list-item prepend-icon="mdi-trophy" title="Results" value="results" @click="openPage('results')"></v-list-item>
            <v-list-item v-if="globalStore.baseData.data.auth.create" prepend-icon="mdi-go-kart-track" title="My Tracks" value="mytracks" @click="openPage('mytracks')"></v-list-item>
            <v-list-item v-if="globalStore.baseData.data.auth.control" prepend-icon="mdi-account-multiple" title="Handle Racers" value="racers" @click="openPage('racers')"></v-list-item>
        </v-list>
        <template v-slot:append>
          <v-list-item prepend-icon="mdi-cog" title="Settings" value="settings" @click="openPage('settings')"></v-list-item>
        </template>
      </v-navigation-drawer>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { ref } from "vue";
const globalStore = useGlobalStore();
const currentPage = ref(globalStore.currentPage)

const openPage = (page: string) => {
  globalStore.$state.currentPage = page
}
const openSettings = () => {
  console.log('settings')
}
</script>

<style scoped lang="scss">

.sidebar {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  color: $text-color-inv;
  z-index: 200;
  position: absolute;
  height: 100%;
}

.sidebar-buttons {
  display: flex;
  flex-direction: column;
  color: $text-color-inv;
  z-index: 201;
}

.pagelink {
  background: none;
  color: $text-color-inv;
  font-weight: bold;
  float: left;
  border: none;
  outline: none;
  cursor: pointer;
  padding: 14px 16px;
  font-size: 17px;
  color: $text-color;
}

.pagelink:hover {
  background-color: $background-color-dark;
}

.settings-button {
  width: 100%;
  cursor: pointer;
  top: 598px;
  left: 479px;
  z-index: 201;
  color: white;
  display: flex;
  justify-content: center;
  padding-bottom: 12px;
}
.settings-button:hover {
  color: rgb(199, 199, 199);
}

</style>
