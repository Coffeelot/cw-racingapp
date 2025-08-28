<template>
  <div id="CrewPage" class="page-container">
    <div class="subheader inline gap-2">
      <h3 class="header-text">{{ translate("my_crew") }}</h3>

      <CreateCrewDialog
        v-if="globalStore?.baseData?.data?.auth?.createCrew && !myCrew"
        @created="refreshCrew"
      />
      <InviteCrewDialog v-if="myCrew"></InviteCrewDialog>
      <CrewInvitesPopover :invites="myInvites" @refreshCrew="refreshCrew">
      </CrewInvitesPopover>
    </div>

    <div v-if="myCrew" class="pagecontent">
      <InfoHeader :title="myCrew.crewName">
        <Badge variant="outline"
            >{{ translate("rank") }}: {{ myCrew.rank }}</Badge
          >
          <Badge variant="outline"
            >{{ translate("races") }}: {{ myCrew.races }}</Badge
          >
          <Badge variant="outline"
            >{{ translate("wins") }}: {{ myCrew.wins }}</Badge
          >
          <template #actions>
            <DropdownMenu  >
              <DropdownMenuTrigger as-child class="dark">
                <Button variant="ghost" class="ml-2"
                  ><EllipsisVertical />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent class="dark" align="end" >
                <DropdownMenuItem
                  v-if="isFounder"
                  @click="disbandDialog = true"
                >
                  {{ translate("disband_crew") }}
                </DropdownMenuItem>
                <DropdownMenuItem
                  v-if="!isFounder"
                  @click="leaveCrewDialog = true"
                >
                  {{ translate("leave_current_crew") }}
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </template>
      </InfoHeader>

      <div class="subheader inline mt-1">
        <h3 class="header-text">{{ translate("  ") }}</h3>
      </div>
      <div
        class="item-flex-container"
        v-if="myCrew?.members && myCrew?.members?.length > 0"
      >
        <MyCrewMemberCard
          v-for="member in myCrew.members"
          :isFounder="isFounder"
          :memberIsFounder="member.racername === myCrew.founderName"
          @triggerReload="refreshCrew"
          :member="member"
          :key="member.citizenID"
        />
      </div>
      <InfoText v-else :title="translate('no_members_in_crew')" />
    </div>
    <InfoText v-else :title="translate('not_in_crew')" />
    </div>

  <!-- Disband Dialog -->
  <Dialog v-model:open="disbandDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle
          >{{ translate("disband_crew") }}:
          {{ globalStore.baseData.data.currentCrewName }}?</DialogTitle
        >
      </DialogHeader>
      <DialogDescription>
        <div>{{ translate("cant_be_reverted") }}</div>
      </DialogDescription>
      <DialogFooter>
        <Button
          block
          variant="destructive"
          @click="disbandCrew"
          :loading="loading"
        >
          {{ translate("confirm") }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
  <Dialog v-model:open="leaveCrewDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle
          >{{ translate("leaveCrewDialog") }}:
          {{ globalStore.baseData.data.currentCrewName }}?</DialogTitle
        >
      </DialogHeader>
      <DialogDescription>
        <div>{{ translate("cant_be_reverted") }}</div>
      </DialogDescription>
      <DialogFooter>
        <Button
          block
          variant="destructive"
          @click="leaveCrew"
          :loading="loading"
        >
          {{ translate("confirm") }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { Ref, ref, computed, onMounted } from "vue";
import { Crew } from "@/store/types";
import MyCrewMemberCard from "../items/CrewMemberCard.vue";
import InfoText from "../components/InfoText.vue";
import { getBaseData } from "@/helpers/getBaseData";
import { translate } from "@/helpers/translate";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import CreateCrewDialog from "../components/dialogs/CreateCrewDialog.vue";
import CrewInvitesPopover from "../components/dialogs/CrewInvitesPopover.vue";
import { mockCrewData } from "@/mocking/testState";
import InviteCrewDialog from "../components/dialogs/InviteCrewPopover.vue";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { EllipsisVertical } from "lucide-vue-next";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import InfoHeader from "../components/InfoHeader.vue";

const globalStore = useGlobalStore();
const myCrew: Ref<Crew | undefined> = ref(globalStore.myCrew);
const myInvites: Ref<any | undefined> = ref(undefined);
const loading = ref(false);
const isFounder = computed(
  () =>
    myCrew?.value?.founderName === globalStore.baseData.data.currentRacerName
);
const disbandDialog = ref(false);
const leaveCrewDialog = ref(false);

const refreshCrew = () => {
  getMyCrew();
  getBaseData();
};

const getMyCrew = async () => {
  if (import.meta.env.VITE_USE_MOCK_DATA === "true") {
    myCrew.value = mockCrewData.crew;
    myInvites.value = mockCrewData.invites;
    return;
  }
  const response = await api.post("UiGetCrewData");
  if (response.data) {
    globalStore.myCrew = response.data.crew;
    myCrew.value = response.data.crew;
    myInvites.value = response.data.invites;
  }
};

const leaveCrew = async () => {
  loading.value = true;
  api.post(
    "UiLeaveCrew",
    JSON.stringify({ crewName: globalStore.baseData.data.currentCrewName })
  );
  setTimeout(() => {
    refreshCrew();
    loading.value = false;
  }, 1000);
};

const disbandCrew = async () => {
  loading.value = true;
  api.post(
    "UiDisbandCrew",
    JSON.stringify({ crewName: globalStore.baseData.data.currentCrewName })
  );
  setTimeout(() => {
    refreshCrew();
    loading.value = false;
  }, 1000);
};

onMounted(() => {
  getMyCrew();
});
</script>

<style scoped>
.header-text {
  flex-grow: 1;
}
.text-field {
  flex-grow: 1;
}
.myRacers-items-container {
  margin-top: 1em;
  display: flex;
  flex-direction: column;
  gap: 0.5em;
}
.text {
  display: flex;
  gap: 0.5em;
  flex-wrap: wrap;
}
.invitations {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 1em;
}
.card {
  flex-grow: 1;
  height: fit-content;
}
.invite-popover {
  display: inline-block;
}
.invite-badge {
  color: red;
  font-weight: bold;
  margin-left: 0.5em;
}
.crew-stats-card {
  margin-bottom: 1.5em;
}
.manage-crew-section {
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
}
.title {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
