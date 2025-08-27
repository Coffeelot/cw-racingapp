<template>
  <SidebarMenu>
    <SidebarMenuItem>
      <SidebarMenuButton
        size="lg"
        class="data-[state=open]:bg-sidebar-accent data-[state=open]:text-sidebar-accent-foreground h-fit"
        @click="sidebarContext.setOpen(false)"
      >
        <SidebarTrigger />
        <div class="grid flex-1 text-left text-sm leading-tight gap-1">
          <span class="truncate font-semibold">
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger class="flex items-center gap-2">
                  {{ globalStore.baseData?.data?.currentRacerName }}
                  <span v-if="globalStore.baseData?.data?.currentCrewName">
                    [{{ globalStore.baseData.data.currentCrewName }}]
                  </span>
                </TooltipTrigger>
                <TooltipContent side="bottom">
                  {{ globalStore.baseData?.data?.currentRacerName }}
                  <span v-if="globalStore.baseData?.data?.currentCrewName">
                    [{{ globalStore.baseData.data.currentCrewName }}]
                  </span>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </span>
          <span class="flex items-center gap-1">
            <Badge v-if="globalStore.baseData?.data?.currentRacerAuth" variant="outline">
              <UserSpecificIcon />
              {{ translate("auth_type_" + globalStore.baseData?.data?.currentRacerAuth) }}
            </Badge>
            <Badge
              v-if="globalStore.baseData?.data?.currentVehicle?.model && globalStore.baseData?.data?.currentVehicle?.class"
              variant="outline"
            >
              <CarIcon />
              {{ globalStore.baseData?.data?.currentVehicle?.model }}
              [{{ globalStore.baseData?.data?.currentVehicle?.class }}]
            </Badge>
          </span>
        </div>
      </SidebarMenuButton>
    </SidebarMenuItem>

    <CryptoDialog
      v-if="
        globalStore.baseData.data.currentRacerName &&
        !!globalStore.baseData?.data?.isUsingRacingCrypto
      "
    ></CryptoDialog>
  </SidebarMenu>
</template>

<script setup lang="ts">
import { ref } from "vue";
import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarTrigger,
  useSidebar,
} from "../ui/sidebar";
import { useGlobalStore } from "@/store/global";
import { translate } from "@/helpers/translate";
import CryptoDialog from "./components/dialogs/CryptoDialog.vue";
import { Badge } from "../ui/badge";
import { CarIcon } from "lucide-vue-next";
import UserSpecificIcon from "./components/UserSpecificIcon.vue";
import { TooltipContent, TooltipProvider, TooltipTrigger } from "../ui/tooltip";
import Tooltip from "../ui/tooltip/Tooltip.vue";

const sidebarContext = useSidebar();


const globalStore = useGlobalStore();
</script>
