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
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger as-child>
                <div class="flex items-center gap-2 truncate font-semibold">
                  {{ globalStore.baseData?.data?.currentRacerName }}
                  <span v-if="globalStore.baseData?.data?.currentCrewName">
                    [{{ globalStore.baseData.data.currentCrewName }}]
                  </span>
                </div>
              </TooltipTrigger>
              <TooltipContent class="dark" side="bottom">
                <div class="flex items-center gap-2">
                  {{ globalStore.baseData?.data?.currentRacerName }}
                  <span v-if="globalStore.baseData?.data?.currentCrewName">
                    [{{ globalStore.baseData.data.currentCrewName }}]
                  </span>
                </div>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
          <div class="flex items-center gap-1">
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
          </div>
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
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "../ui/tooltip";

const sidebarContext = useSidebar();


const globalStore = useGlobalStore();
</script>
