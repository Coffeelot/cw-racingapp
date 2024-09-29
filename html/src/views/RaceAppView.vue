<template>
  <div class="ui-container">
    <div class="screen-container" v-if="globalStore.baseData.data">
      <TopBar></TopBar>
      <div class="app-container">
        <v-snackbar
        v-model="snackbar"
        attach=".app-container"
        transition="slide-y-transition"
        location="top"
        contained
        multi-line
        vertical
        :timeout="snackTimeout"
        :color="globalStore.notification?.type"
        >
          <h3 >{{ globalStore.notification?.title }}</h3>
          <p class="text-subtitle-1 pt-2" v-if=" globalStore.notification?.text">{{ globalStore.notification.text }}</p>
          <template v-slot:actions>
          <v-btn
            variant="text"
            @click="snackbar = false"
          >
              {{ translate('close') }}
            </v-btn>
          </template>
        </v-snackbar>
        <v-layout>
          <SideBar></SideBar>
          <div
            class="tabs-container"
            v-if="globalStore.currentPage === 'settings' || !hasProblem"
          >
            <RacingPage
              v-if="globalStore.currentPage === 'racing'"
            ></RacingPage>
            <ResultsPage
              v-if="globalStore.currentPage === 'results'"
            ></ResultsPage>
            <MyTracksPage
              v-if="globalStore.currentPage === 'mytracks'"
            ></MyTracksPage>
            <RacersPage
              v-if="globalStore.currentPage === 'racers'"
            ></RacersPage>
            <CrewPage
              v-if="globalStore.currentPage === 'crew'"
            ></CrewPage>
            <SettingsPage
              v-if="globalStore.currentPage === 'settings'"
            ></SettingsPage>
          </div>
          <div id="revoked-message-container" v-else>
            <div class="revoked-message-holder">
              <v-alert
                :title="hasProblem.title"
                :text="hasProblem.text"
                :color="hasProblem.color ? hasProblem.color : 'error'"
                :icon="hasProblem.icon ? hasProblem.icon : '$error'"
              >
              </v-alert>
              <UserCreation v-if="globalStore.baseData.data.anyoneCanCreate && globalStore.baseData.data.racerNames.length === 0"></UserCreation>
            </div>
          </div>
        </v-layout>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from "vue";
import { useGlobalStore } from "../store/global";
import TopBar from "../components/app/TopBar.vue";
import SideBar from "../components/app/SideBar.vue";
import RacingPage from "../components/app/pages/RacingPage.vue";
import ResultsPage from "../components/app/pages/ResultsPage.vue";
import MyTracksPage from "../components/app/pages/MyTracksPage.vue";
import RacersPage from "../components/app/pages/RacersPage.vue";
import SettingsPage from "../components/app/pages/SettingsPage.vue";
import CrewPage from "@/components/app/pages/CrewPage.vue";
import { closeApp } from "@/helpers/closeApp";
import { getBaseData } from "@/helpers/getBaseData";
import { computed } from "vue";
import { translate } from "@/helpers/translate";
import UserCreation from "@/components/app/components/UserCreation.vue";

const globalStore = useGlobalStore();

const snackbar = ref(false)
const snackTimeout = ref(3000)

const hasProblem = computed(() => {
  if (
    !globalStore.baseData.data.currentRacerName &&
    globalStore.baseData.data.racerNames &&
    globalStore.baseData.data.racerNames.length === 0
  ) {
    return {
      title: translate('error_lacking_user'),
      text: translate('error_lacking_user_desc'),
      color: "info",
      icon: "$info",
      type: 'no_user'
    };
  } else if (globalStore.baseData.data.currentRacerName) {
    const currentRacer = globalStore.baseData.data.racerNames?.find(
      (racer) => globalStore.baseData.data.currentRacerName === racer.racername
    );
    if (currentRacer) {
      if (currentRacer.revoked) {
        return {
          title: translate('error_revoked'),
          text: translate('error_revoked_desc'),
          type: 'revoked'
        };
      }
    } else {
      return {
        title: translate('error_permanently_removed'),
        text: translate('error_permanently_removed_desc'),
        type: 'removed'
      };
    }
  } else {
    return {
      title: translate('error_no_user'),
      text: translate('error_no_user_desc'),
      color: "info",
      icon: "$info",
      type: 'no_user'
    };
  }
  return false;
});
document.onkeydown = function (evt) {
  if (evt?.key === "Escape") closeApp();
};

const handleMessageListener = (event: MessageEvent) => {
  const itemData: any = event?.data;
  if (itemData.type === 'notify') {
    globalStore.$state.notification = itemData.data
    snackbar.value = true
  }
  
};

onMounted(() => {
  getBaseData();
  window.addEventListener("message", handleMessageListener);

});
</script>

<style scoped lang="scss">
body {
  overflow: hidden;
}

h2 {
  margin-bottom: 0px;
}

.ui-container {
  z-index: 2000;
  width: 100%;
  position: absolute;
  bottom: 1em;
  display: flex;
  justify-content: center;
  z-index: 2000;
}

#revoked-message-container {
  width: 100%;
  margin-left: 56px;
}

.revoked-message-holder {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  margin: 2em 2em 2em 2em;
  color: white;
}

.screen-frame {
  position: absolute;
  pointer-events: none;
  z-index: 10001;
}

.screen-container {
  width: 70vw;
  height: 90vh;
  margin-top: 72px;
  font-family: "Gill Sans", "Gill Sans MT", Calibri, "Trebuchet MS", sans-serif;
  border: 1.2em solid #131316;
  background: #131316;
  border-radius: 1em;
}

.app-container {
  background: $background;
  overflow-y: hidden;
  overflow-x: hidden;
  position: relative;
  display: flex;
  height: calc(100% - 2.6em)
}

.tabs-container {
  width: 100%;
  margin-left: 56px;
}

/* SCROLLBAR */
/* width */
::-webkit-scrollbar {
  width: 10px;
}

/* Track */
::-webkit-scrollbar-track {
  background: #f1f1f1;
}

/* Handle */
::-webkit-scrollbar-thumb {
  background: #888;
}

/* Handle on hover */
::-webkit-scrollbar-thumb:hover {
  background: #555;
}

@keyframes rotation {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

#track-items-loader {
  display: none;
}

.confirmation-box {
  position: absolute;
  bottom: -100px;
  width: 747px;
  right: 0;
  color: $text-color;
  display: flex;
  justify-content: center;
}

.confirmation-card {
  color: $text-color;
  background-color: $background-color-topbar;
  border-radius: $border-radius;
  width: 400px;
  padding: 15px;
  display: flex;
  flex-direction: column;
  gap: 5px;
  height: fit-content;
}

.confirmation-card-body {
  display: flex;
  justify-content: flex-end;
  height: fit-content;
}

.confirmation-footer {
  width: 100%;
}

/* TOOLTIP */
*[data-tooltip] {
  position: relative;
}

*[data-tooltip]::after {
  content: attr(data-tooltip);

  position: absolute;
  top: -20px;
  right: -40px;
  width: 150px;

  pointer-events: none;
  opacity: 0;
  -webkit-transition: opacity 0.15s ease-in-out;
  -moz-transition: opacity 0.15s ease-in-out;
  -ms-transition: opacity 0.15s ease-in-out;
  -o-transition: opacity 0.15s ease-in-out;
  transition: opacity 0.15s ease-in-out;

  display: block;
  font-size: 12px;
  line-height: 16px;
  background: $background-color-topbar;
  padding: 4px 4px;
  border: $border;
  border-radius: $border-radius;
}

*[data-tooltip]:hover::after {
  opacity: 1;
}

/* CHECKBOX */
/* Customize the label (the container) */
.checkbox-container {
  display: block;
  position: relative;
  padding-left: 35px;
  margin-bottom: 12px;
  cursor: pointer;
  font-size: 22px;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}

/* Hide the browser's default checkbox */
.checkbox-container input {
  position: absolute;
  opacity: 0;
  cursor: pointer;
  height: 0;
  width: 0;
}

/* Create a custom checkbox */
.checkmark {
  position: absolute;
  top: 0;
  left: 0;
  height: 20px;
  width: 20px;
  background-color: $text-color-disabled;
  border-radius: 4px;
}

/* On mouse-over, add a grey background color */
.checkbox-container:hover input ~ .checkmark {
  background-color: $text-color-disabled;
}

/* When the checkbox is checked, add a blue background */
.checkbox-container input:checked ~ .checkmark {
  background-color: $primary-color;
}

/* Create the checkmark/indicator (hidden when not checked) */
.checkmark:after {
  content: "";
  position: absolute;
  display: none;
}

/* Show the checkmark when checked */
.checkbox-container input:checked ~ .checkmark:after {
  display: block;
}

/* Style the checkmark/indicator */
.checkbox-container .checkmark:after {
  left: 6px;
  top: 2px;
  width: 5px;
  height: 10px;
  border: solid white;
  border-width: 0 3px 3px 0;
  -webkit-transform: rotate(45deg);
  -ms-transform: rotate(45deg);
  transform: rotate(45deg);
}
</style>
