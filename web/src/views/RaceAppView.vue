<template>
  <div class="ui-container">
    <div class="screen-container dark" v-if="globalStore.baseData.data">
      <!-- <TopBar /> -->
      <div ref="screen-root" id="screen-root" class="app-container dark bg-background text-foreground">
        <Toaster container="screen-root" position="top-center" />
        <SidebarProvider class="m-h-0 h-80">
          <AppSideBar />
          <SidebarInset>
            <main class="main-content">
              <div
                class="tabs-container"
                v-if="!hasProblem"
              >
                <DashboardPage v-if="globalStore.currentPage === 'dashboard'" />
                <RacingPage v-if="globalStore.currentPage === 'racing'" />
                <ResultsPage v-if="globalStore.currentPage === 'results'" />
                <MyTracksPage v-if="globalStore.currentPage === 'mytracks'" />
                <RacersPage v-if="globalStore.currentPage === 'racers'" />
                <CrewPage v-if="globalStore.currentPage === 'crew'" />
                <SettingsPage v-if="globalStore.currentPage === 'settings'" />
                <AdminMenu v-if="globalStore.currentPage === 'admin'" />
              </div>
              <div id="revoked-message-container" v-else>
                <div class="revoked-message-holder">
                  <Alert
                    :variant="hasProblem.color || 'destructive'"
                    class="mb-4"
                  >
                   <CircleAlertIcon></CircleAlertIcon>
                   <AlertTitle> {{ hasProblem.title }}</AlertTitle>
                   <AlertDescription>{{ hasProblem.text }}</AlertDescription>
                    
                  </Alert>
                  <UserCreation/>
                </div>
              </div>
            </main>
          </SidebarInset>
        </SidebarProvider>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "../store/global";
import RacingPage from "../components/app/pages/RacingPage.vue";
import ResultsPage from "../components/app/pages/ResultsPage.vue";
import MyTracksPage from "../components/app/pages/TracksPage.vue";
import RacersPage from "../components/app/pages/RacersPage.vue";
import SettingsPage from "../components/app/pages/SettingsPage.vue";
import CrewPage from "@/components/app/pages/CrewPage.vue";
import { closeApp } from "@/helpers/closeApp";
import { getBaseData } from "@/helpers/getBaseData";
import { translate } from "@/helpers/translate";
import UserCreation from "@/components/app/components/UserCreation.vue";
import AdminMenu from "@/components/app/pages/AdminMenu.vue";
import { computed } from "vue";
import { onMounted } from "vue";
import { Toaster } from "@/components/ui/sonner";
import { toast } from "vue-sonner";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import AppSideBar from "../components/app/AppSidebar.vue";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { CircleAlertIcon } from "lucide-vue-next";
import AlertTitle from "@/components/ui/alert/AlertTitle.vue";
import 'vue-sonner/style.css'
import DashboardPage from "@/components/app/pages/DashboardPage.vue";

const globalStore = useGlobalStore();

type ProblemColor = "default" | "destructive";


const hasProblem = computed(() => {

  if (
    !globalStore.baseData.data.currentRacerName &&
    globalStore.baseData.data.racerNames &&
    globalStore.baseData.data.racerNames.length === 0
  ) {
    return {
      title: translate("error_lacking_user"),
      text: translate("error_lacking_user_desc"),
      color: "default" as ProblemColor,
      icon: "$info",
      type: "no_user",
    };
  } else if (globalStore.baseData.data.currentRacerName) {
    const currentRacer = globalStore.baseData.data.racerNames?.find(
      (racer) => globalStore.baseData.data.currentRacerName === racer.racername
    );
    if (currentRacer) {
      if (currentRacer.revoked) {
        return {
          title: translate("error_revoked"),
          text: translate("error_revoked_desc"),
          type: "revoked",
          color: "destructive" as ProblemColor,
        };
      }
    } else {
      return {
        title: translate("error_permanently_removed"),
        text: translate("error_permanently_removed_desc"),
        type: "removed",
        color: "destructive" as ProblemColor,
      };
    }
  } else {
    return {
      title: translate("error_no_user"),
      text: translate("error_no_user_desc"),
      color: "default" as ProblemColor,
      icon: "$info",
      type: "no_user",
    };
  }
  return false;
});

document.onkeydown = function (evt) {
  if (evt?.key === "Escape") closeApp();
};

const toastTypeMap: Record<string, keyof typeof toast> = {
  revoked: "error",
  removed: "error",
  no_user: "info",
};

const handleMessageListener = (event: MessageEvent) => {
  const itemData: any = event?.data;
  if (itemData.type === "notify") {
    globalStore.$state.notification = itemData.data;
    const type = toastTypeMap[itemData.data.type] || "message";
    toast[type](itemData.data.title, {
      description: itemData.data.text,
      action: itemData.data.action
        ? {
            label: itemData.data.action.label,
            onClick: itemData.data.action.onClick,
          }
        : undefined,
    });
  }
};

onMounted(() => {
  getBaseData();
  window.addEventListener("message", handleMessageListener);
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    setTimeout(() => {
      handleMessageListener({
        data: {
          type: 'notify',
          duration: 10000000,
          data: {
            title: 'Welcome to the Racing App',
            text: 'This is a mock environment. Enjoy testing!',
            type: 'info',
            action: {
              label: 'Got it',
              onClick: () => console.log('Mock notification acknowledged')
            }
          }
        }
      } as MessageEvent);
    }, 500);
  }
});
</script>

<style scoped >
body {
  overflow: hidden;
}

h2 {
  margin-bottom: 0px;
}

.revoked-message-holder {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 2em 2em 2em 2em;
  color: white;
}

.screen-frame {
  position: absolute;
  pointer-events: none;
  z-index: 55;
}

.ui-container {
  height: 100vh;
  width: 100vw;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 40;
}

.screen-container {
  width: 80vw;
  height: 80vh;
  display: flex;
  flex-direction: column;
  min-height: 0;
  padding: 1em;
  border-radius: 1em;
  background: #131316;
  border: 1px solid #484848b3;
  font-family: "Gill Sans", "Gill Sans MT", Calibri, "Trebuchet MS", sans-serif;
}

.app-container {
  flex: 1 1 0%;
  display: flex;
  flex-direction: column;
  min-height: 0;
  min-width: 0;
  height: 100%; /* Fills .screen-container only */
  position: relative
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
</style>
