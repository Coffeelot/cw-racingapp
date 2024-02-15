<template>
  <div id="CrewPage" class="pagecontent">
    <v-tabs v-model="tab">
      <v-tab value="myCrew">My Crew</v-tab>
      <v-tab value="create">Manage</v-tab>
      <v-tab value="invites">Invites</v-tab>
    </v-tabs>

    <v-window v-model="tab">
      <v-window-item value="myCrew" class="tabcontent">
        <v-card v-if="myCrew">
          <v-card-title>Crew stats</v-card-title>
          <v-card-text class="text">
            <v-chip>Ranking: {{ myCrew.rank }} </v-chip>
            <v-chip>Races: {{ myCrew.races }} </v-chip>
            <v-chip>Wins: {{ myCrew.wins }} </v-chip>
          </v-card-text>
        </v-card>
        <div class="subheader inline mt-1">
          <h3 class="header-text">My Crew</h3>
        </div>
        <div
          class="myRacers-items-container"
          v-if="myCrew && myCrew?.members?.length > 0"
        >
          <MyCrewMemberCard
            :isFounder="isFounder"
            :memberIsFounder="member.racername === myCrew.founderName"
            @triggerReload="getMyCrew()"
            v-for="member in myCrew.members"
            :member="member"
          ></MyCrewMemberCard>
        </div>
        <InfoText v-else-if="!myCrew" title="You are not in a crew"></InfoText>
        <InfoText v-else title="No members in this crew yet"></InfoText>
      </v-window-item>
      <v-window-item value="create" class="tabcontent">
        <div class="subheader inline">
          <h3 class="header-text">Create a new Crew</h3>
        </div>
        <div class="myRacers-items-container">
          <v-card>
            <v-card-title>Create a new crew</v-card-title>
            <v-card-text>
              <v-text-field
                density="compact"
                placeholder="Crew Name"
                v-model="creationCrewName"
              />
            </v-card-text>
            <v-card-actions>
              <v-btn
                block
                color="success"
                variant="elevated"
                type="submit"
                @click="createCrew()"
                :loading="loading"
              >
                Confirm
              </v-btn>
            </v-card-actions>
          </v-card>
          <v-card v-if="globalStore.baseData.data.currentCrewName && !isFounder">
            <v-card-title>Leave current crew: {{ globalStore.baseData.data.currentCrewName }}</v-card-title>
            <v-card-actions>
              <v-btn
                block
                color="error"
                variant="elevated"
                type="submit"
                @click="leaveCrew()"
                :loading="loading"
              >
                Leave
              </v-btn>
            </v-card-actions>
          </v-card>
          <v-card v-if="globalStore.baseData.data.currentCrewName && isFounder">
            <v-card-title>Disband current crew: {{ globalStore.baseData.data.currentCrewName }}</v-card-title>
            <v-card-actions>
              <v-btn
                block
                color="error"
                variant="elevated"
                type="submit"
                @click="disbandCrew()"
                :loading="loading"
              >
                Disband
              </v-btn>
            </v-card-actions>
          </v-card>
        </div>
      </v-window-item>
      <v-window-item value="invites" class="tabcontent">
        <div class="subheader inline">
          <h3 class="header-text">Invites</h3>
        </div>
        <div class="myRacers-items-container">
          <v-card v-if="myInvites">
            <v-card-title>Invite from crew: {{ myInvites.crewName }}</v-card-title>
            <v-card-actions>
              <v-btn
                variant="tonal"
                type="submit"
                @click="denyCrew()"
                :loading="loading"
              >
                Deny
              </v-btn>
              <v-btn
                color="success"
                variant="elevated"
                type="submit"
                @click="joinCrew()"
                :loading="loading"
              >
                Accept
              </v-btn>
            </v-card-actions>
          </v-card>
          <InfoText v-else title="No invites pending"></InfoText>
          <v-divider v-if="isFounder"></v-divider>
          <div class="invitations">
            <v-card class="card" v-if="isFounder">
              <v-card-title>Invite</v-card-title>
              <v-card-text>
                <v-text-field
                  density="compact"
                  placeholder="CitizenID"
                  v-model="inviteText"
                />
              </v-card-text>
              <v-card-actions>
                <v-btn
                  block
                  color="success"
                  variant="elevated"
                  type="submit"
                  @click="inviteMember()"
                  :loading="loading"
                >
                  Send Invite
                </v-btn>
              </v-card-actions>
            </v-card>
            <v-card class="card" v-if="isFounder">
              <v-card-title>Invite closest person</v-card-title>
              <v-card-actions>
                <v-btn
                  block
                  color="success"
                  variant="elevated"
                  type="submit"
                  @click="inviteMemberClosest()"
                  :loading="loading"
                >
                  Send Invite
                </v-btn>
              </v-card-actions>
            </v-card>
          </div>
        </div>
      </v-window-item>
    </v-window>
  </div>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { Ref } from "vue";
import { onMounted } from "vue";
import { ref } from "vue";
import { Crew } from "@/store/types";
import MyCrewMemberCard from "../items/MyCrewMemberCard.vue";
import InfoText from "../components/InfoText.vue";
import { getBaseData } from "@/helpers/getBaseData";
import { computed } from "vue";
const globalStore = useGlobalStore();
const tab = ref(globalStore.currentTab);
const myCrew: Ref<Crew | undefined> = ref(globalStore.myCrew);
const myInvites: Ref<any | undefined> = ref(undefined);
const loading = ref(false)

const isFounder = computed(()=> myCrew?.value?.founderName === globalStore.baseData.data.currentRacerName)
const creationCrewName = ref("");
const inviteText = ref("");

const getMyCrew = async () => {
  const response = await api.post("UiGetCrewData");
  if (response.data) {
    globalStore.myCrew = response.data.crew
    myCrew.value = response.data.crew;
    myInvites.value = response.data.invites;
  }
};

const createCrew = async () => {
  loading.value = true
   await api.post(
    "UiCreateCrew",
    JSON.stringify({ crewName: creationCrewName.value })
  );
  setTimeout(() => {
    getBaseData()
    getMyCrew();
    loading.value = false
  }, 1000);

};

const leaveCrew = async () => {
  loading.value = true
  api.post("UiLeaveCrew", JSON.stringify({ crewName: globalStore.baseData.data.currentCrewName}));
  setTimeout(() => {
    getBaseData()
    getMyCrew();
    loading.value = false
  }, 1000);
};

const disbandCrew = async () => {
  loading.value = true
  api.post("UiDisbandCrew", JSON.stringify({ crewName: globalStore.baseData.data.currentCrewName}));
  setTimeout(() => {
    getBaseData()
    getMyCrew();
    loading.value = false
  }, 1000);
};

const joinCrew = async () => {
  loading.value = true
  api.post("UiAcceptInvite", JSON.stringify({ crewName: myInvites.value.crewName}));
  setTimeout(() => {
    getBaseData()
    getMyCrew();
    loading.value = false
  }, 1000);
};

const denyCrew = async () => {
  loading.value = true
  api.post("UiDenyInvite", JSON.stringify({}));
  setTimeout(() => {
    getBaseData()
    getMyCrew();
    loading.value = false
  }, 1000);
};

const inviteMember = async () => {
  loading.value = true
  const response = await api.post("UiSendInvite", JSON.stringify({ citizenId: inviteText.value}));
  setTimeout(() => {
    getBaseData()
    getMyCrew();
    loading.value = false
    if (response.data) inviteText.value = ''
  }, 1000);
};
const inviteMemberClosest = async () => {
  loading.value = true
  const response = await api.post("UiSendInviteClosest", JSON.stringify({}));
  setTimeout(() => {
    getBaseData()
    getMyCrew();
    loading.value = false
  }, 1000);
};

onMounted(() => {
  getMyCrew();
});
</script>

<style scoped lang="scss">
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
  gap: 1em
}
.card {
  flex-grow: 1;
  height: fit-content;
}
</style>
