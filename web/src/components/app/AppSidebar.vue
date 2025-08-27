<template>
  <Sidebar class="relative m-h-0 h-full" collapsible="icon">
    <SidebarContent >
      <SidebarHeader >
        <SidebarUser v-if="isOpen" ></SidebarUser>
        <SidebarTrigger v-if="!isOpen"></SidebarTrigger>
      </SidebarHeader>
      <SidebarGroup v-if="!noUser">
        <SidebarGroupLabel>
          {{ translate('navigation_title') }}
        </SidebarGroupLabel>
        <SidebarGroupContent>
          <SidebarMenu>
            <SidebarMenuItem v-for="item in items" :key="item.name">
              <SidebarMenuButton
                :isActive="globalStore.currentPage === item.name"
                asChild
                v-if="item.visible"
                >
                <a @click="openPage(item.name)">
                  <component :is="item.icon" />
                  <span>{{ item.title }}</span>
                </a>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarGroupContent>
      </SidebarGroup>
    </SidebarContent>
    <SidebarFooter >
      <SidebarMenuButton
         asChild
         :isActive="globalStore.currentPage === 'settings'"
         >
         <a @click="openPage('settings')">
           <CogIcon />
           <span>{{ translate('settings') }}</span>

         </a>
       </SidebarMenuButton>
    </SidebarFooter>
  </Sidebar>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
const globalStore = useGlobalStore();
import { translate } from "@/helpers/translate";
import { Sidebar, SidebarTrigger, SidebarContent, SidebarFooter, SidebarGroup, SidebarGroupContent, SidebarMenu, SidebarHeader, SidebarGroupLabel } from "../ui/sidebar";
import SidebarMenuItem from "../ui/sidebar/SidebarMenuItem.vue";
import SidebarMenuButton from "../ui/sidebar/SidebarMenuButton.vue";
import { CogIcon, HomeIcon, Route, ShieldUser, Trophy, User, UserCog } from "lucide-vue-next";
import { computed, ref } from "vue";
import HelmetIcon from "@/assets/icons/HelmetIcon.vue";
import { useSidebar } from "@/components/ui/sidebar";
import SidebarUser from "./SidebarUser.vue";
const sidebarContext = useSidebar();

sidebarContext.setOpen(false);

const isOpen = ref(sidebarContext.open)

const allItems = [
  { name: 'dashboard', icon: HomeIcon, title: translate('dashboard_page'), visible: globalStore.baseData.data.dashboardSettings?.enabled },
  { name: 'racing', icon: HelmetIcon, title: translate('racing'), visible: true },
  { name: 'results', icon: Trophy, title: translate('results'), visible: true },
  { name: 'crew', icon: User, title: translate('crew'), visible: true },
  { name: 'mytracks', icon: Route, title: translate('my_tracks'), visible: globalStore.baseData.data?.auth?.create },
  { name: 'racers', icon: UserCog, title: translate('racers'), visible: globalStore.baseData.data?.auth?.control },
  { name: 'admin', icon: ShieldUser, title: translate('admin'), visible: globalStore.baseData.data?.auth?.adminMenu },
];

const items = computed(() => allItems.filter(item => item.visible))

const noUser = computed(() => !globalStore.baseData.data.currentRacerName &&
    globalStore.baseData.data.racerNames &&
    globalStore.baseData.data.racerNames.length === 0);

const openPage = (page: string) => {
  globalStore.currentPage = page;
};
</script>

<style scoped >
</style>
