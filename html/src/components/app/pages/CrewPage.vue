<template>
  <div id="CrewPage" class="pagecontent">
    <v-tabs color="primary" v-model="tab">
      <v-tab @click="getMyCrew()" value="myCrew">{{ translate("my_crew") }} </v-tab>
      <v-tab @click="getMyCrew()" value="create">{{ translate("manage") }} </v-tab>
      <v-tab @click="getMyCrew()" value="invites">{{ translate("invites") }} </v-tab>
    </v-tabs>

    <v-window v-model="tab" class="page-container">
      <v-window-item value="myCrew" class="tabcontent">
        <v-card v-if="myCrew">
          <v-card-title>{{ translate("crew_stats") }} </v-card-title>
          <v-card-text class="text">
            <v-chip color="primary">{{ translate("rank") }}: {{ myCrew.rank }} </v-chip>
            <v-chip color="primary">{{ translate("races") }}: {{ myCrew.races }} </v-chip>
            <v-chip color="primary">{{ translate("wins") }}: {{ myCrew.wins }} </v-chip>
          </v-card-text>
        </v-card>
        <div class="subheader inline mt-1">
          <h3 class="header-text">{{ translate("my_crew") }} {{ myCrew?.crewName }}</h3>
        </div>
        <div
          class="myRacers-items-container"
          v-if="myCrew && myCrew?.members?.length > 0"
        >
          <MyCrewMemberCard
            v-for="member in myCrew.members"
            :isFounder="isFounder"
            :memberIsFounder="member.racername === myCrew.founderName"
            @triggerReload="getMyCrew()"
            :member="member"
            :key="member.citizenID"
          ></MyCrewMemberCard>
        </div>
        <InfoText
          v-else-if="!myCrew"
          :title="translate('not_in_crew')"
        ></InfoText>
        <InfoText v-else :title="translate('no_members_in_crew')"></InfoText>
      </v-window-item>
      <v-window-item value="create" class="tabcontent">
        <div class="subheader inline">
          <h3 class="header-text">{{ translate("manage") }}</h3>
        </div>
        <div class="w-100 invitations">
          <v-card class="card" v-if="globalStore?.baseData?.data?.auth?.createCrew && !isFounder">
            <v-card-title>{{ translate("create_crew") }} </v-card-title>
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
                {{ translate("confirm") }}
              </v-btn>
            </v-card-actions>
          </v-card>
          <v-card
            class="card"
            v-if="globalStore.baseData.data.currentCrewName && !isFounder"
          >
            <v-card-title
              >{{ translate('leave_current_crew') }} :
              {{ globalStore.baseData.data.currentCrewName }}</v-card-title
            >
            <v-card-actions>
              <v-btn
                block
                color="error"
                variant="elevated"
                type="submit"
                @click="leaveCrew()"
                :loading="loading"
              >
                {{ translate('leave') }} 
              </v-btn>
            </v-card-actions>
          </v-card>
          <v-card class="card" v-if="globalStore.baseData.data.currentCrewName && isFounder">
            <v-card-title
              >{{ translate('disband_crew') }} :
              {{ globalStore.baseData.data.currentCrewName }}</v-card-title
            >
            <v-card-actions>
              <v-btn
                block
                color="error"
                variant="elevated"
                type="submit"
                @click="disbandCrew()"
                :loading="loading"
              >
                {{ translate('confirm') }} 
              </v-btn>
            </v-card-actions>
          </v-card>
        </div>
      </v-window-item>
      <v-window-item value="invites" class="tabcontent">
        <div class="subheader inline">
          <h3 class="header-text">{{ translate('invites') }} </h3>
        </div>
        <div class="myRacers-items-container">
          <v-card v-if="myInvites">
            <v-card-title
              >{{ translate('invite_from_crew') }}: {{ myInvites.crewName }}</v-card-title
            >
            <v-card-actions>
              <v-btn
                variant="tonal"
                type="submit"
                @click="denyCrew()"
                :loading="loading"
              >
                {{ translate('deny') }} 
              </v-btn>
              <v-btn
                color="success"
                variant="elevated"
                type="submit"
                @click="joinCrew()"
                :loading="loading"
              >
                {{ translate('accept') }} 
              </v-btn>
            </v-card-actions>
          </v-card>
          <InfoText v-else :title="translate('no_invites')"></InfoText>
          <v-divider v-if="isFounder"></v-divider>
          <div class="invitations">
            <v-card class="card" v-if="isFounder">
              <v-card-title>{{ translate('invite') }} </v-card-title>
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
                  {{ translate('confirm') }} 
                </v-btn>
              </v-card-actions>
            </v-card>
            <v-card class="card" v-if="isFounder">
              <v-card-title>{{ translate('invite_closest') }} </v-card-title>
              <v-card-actions>
                <v-btn
                  block
                  color="success"
                  variant="elevated"
                  type="submit"
                  @click="inviteMemberClosest()"
                  :loading="loading"
                >
                {{ translate('confirm') }} 
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
const loading = ref(false);
import { translate } from "@/helpers/translate";
const isFounder = computed(
  () =>
    myCrew?.value?.founderName === globalStore.baseData.data.currentRacerName
);
const creationCrewName = ref("");
const inviteText = ref("");

const getMyCrew = async () => {
  const response = await api.post("UiGetCrewData");
  if (response.data) {
    globalStore.myCrew = response.data.crew;
    myCrew.value = response.data.crew;
    myInvites.value = response.data.invites;
  }
};

const createCrew = async () => {
  loading.value = true;
  await api.post(
    "UiCreateCrew",
    JSON.stringify({ crewName: creationCrewName.value })
  );
  setTimeout(() => {
    getBaseData();
    getMyCrew();
    loading.value = false;
  }, 1000);
};

const leaveCrew = async () => {
  loading.value = true;
  api.post(
    "UiLeaveCrew",
    JSON.stringify({ crewName: globalStore.baseData.data.currentCrewName })
  );
  setTimeout(() => {
    getBaseData();
    getMyCrew();
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
    getBaseData();
    getMyCrew();
    loading.value = false;
  }, 1000);
};

const joinCrew = async () => {
  loading.value = true;
  api.post(
    "UiAcceptInvite",
    JSON.stringify({ crewName: myInvites.value.crewName })
  );
  setTimeout(() => {
    getBaseData();
    getMyCrew();
    loading.value = false;
  }, 1000);
};

const denyCrew = async () => {
  loading.value = true;
  api.post("UiDenyInvite", JSON.stringify({}));
  setTimeout(() => {
    getBaseData();
    getMyCrew();
    loading.value = false;
  }, 1000);
};

const inviteMember = async () => {
  loading.value = true;
  const response = await api.post(
    "UiSendInvite",
    JSON.stringify({ citizenId: inviteText.value })
  );
  setTimeout(() => {
    getBaseData();
    getMyCrew();
    loading.value = false;
    if (response.data) inviteText.value = "";
  }, 1000);
};
const inviteMemberClosest = async () => {
  loading.value = true;
  const response = await api.post("UiSendInviteClosest", JSON.stringify({}));
  setTimeout(() => {
    getBaseData();
    getMyCrew();
    loading.value = false;
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
  gap: 1em;
}
.card {
  flex-grow: 1;
  height: fit-content;
}
</style>
