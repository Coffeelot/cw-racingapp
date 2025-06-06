<template>
  <v-card border class="big-card" rounded="xl">
    <v-card-title class="title">
      <span class="d-inline-flex ga-1 align-xl-center ">{{ track.RaceName }}</span>
      <div>
        <v-btn rounded="xl" variant="text" @click='showRace()'>{{ translate('show_track') }} </v-btn>
        <v-btn rounded="xl" small variant="text" @click="copyToClipboard()"
          >{{ translate('copy_checkpoints') }} </v-btn
        >
        
      </div>
    </v-card-title>
    <v-card-text class="text">
      <v-chip v-if="track.Curated" color="green" prepend-icon="mdi-star">{{translate('curated')}}</v-chip>
      <v-chip color="primary" class="allow-select">{{ translate('track_id') }}: {{ track.TrackId }} </v-chip>
      <v-chip color="primary">{{ translate('length') }}: {{ track.Distance }}m </v-chip>
      <v-chip color="primary">{{ translate('checkpoints') }}: {{ track.Checkpoints.length }}</v-chip>
      <v-chip color="primary">{{ translate('created_by') }}: {{ track.CreatorName }}</v-chip>
      <v-chip color="primary" v-if="track.Access?.race && track.Access.race.length > 0">{{ translate('shared_with') }}: {{ track.Access.race.length }} {{ translate('racers') }} </v-chip>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn rounded="xl" v-if="globalStore.baseData.data.auth.curateTracks" @click="curateDialog = true">{{ translate('curation') }} </v-btn>
      <v-btn rounded="xl" @click="editRecords = true">{{ translate('view_records') }} </v-btn>
      <v-btn rounded="xl" @click="lbDialog = true">{{ translate('clear_lead') }} </v-btn>
      <v-btn rounded="xl" v-if="!track.Curated" @click="editDialog = true"
        >{{ translate('edit_track') }} </v-btn
      >
      <v-btn rounded="xl" @click="openEditMetadata()">{{ translate('edit_settings') }} </v-btn>
      <v-btn rounded="xl" @click="openEditAccess()">{{ translate('edit_access') }} </v-btn>
      <v-btn rounded="xl" @click="deleteDialog = true">{{ translate('delete_track') }} </v-btn>
    </v-card-actions>
  </v-card>
  <v-dialog attach=".app-container" contained v-model="curateDialog" width="auto">
    <v-card  rounded="lg">
      <v-card-title>{{ translate('handle_curation_for') }}  {{ track.RaceName }}?</v-card-title>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="lbDialog = false">
            {{ translate('close') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="red" @click="setCuration(0)">
            {{ translate('set_uncurated') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="success" @click="setCuration(1)">
            {{ translate('set_curated') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog attach=".app-container" contained v-model="lbDialog" width="auto">
    <v-card  rounded="lg">
      <v-card-title>{{ translate('clear_lead_for') }}  {{ track.RaceName }}?</v-card-title>
      <v-card-text> {{ translate('cant_be_reverted') }}  </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="lbDialog = false">
            {{ translate('close') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="red" @click="clearLB()">
            {{ translate('confirm') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog attach=".app-container" contained v-model="editDialog" width="auto">
    <v-card rounded="xl">
      <v-card-title>{{ translate('open_track_editor_for') }}  {{ track.RaceName }}?</v-card-title>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="editDialog = false">
            {{ translate('close') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="success"  @click="editTrack()">
            {{ translate('confirm') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog attach=".app-container" contained v-model="accessDialog" width="auto">
    <v-card rounded="xl">
        <v-card-title>{{ translate('editing_access_for') }} {{ track.RaceName }}</v-card-title>
        <v-card-text> 
            <v-text-field :label="translate('access_list')" v-model="access.race" :hint="translate('editing_access_info')"></v-text-field>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="accessDialog = false">
            {{ translate('close') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="success" @click="editAccess()">
          {{ translate('confirm') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog attach=".app-container" contained v-model="settingsDialog" width="auto">
    <v-card  rounded="lg">
      <v-card-title>{{ translate('edit_settings') }} <v-chip>{{ track.RaceName }}</v-chip></v-card-title>
      <v-card-text>
        <v-textarea
          class="text-area"
          :maxlength="200"
          :counter="200"
          :label="translate('description')"
          :hint="translate('description_hint')"
          color="primary"
          density="compact"  
          v-model="settings.description">
        </v-textarea>
        <v-select 
          :label="translate('race_type')"
          :items="trackTypes"
          item-value="value"
          item-title="label"
          color="primary"
          density="compact"  
          v-model="settings.raceType"
          hideDetails
        ></v-select>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="settingsDialog = false">
            {{ translate('close') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="success" @click="confirmSettings()">
            {{ translate('confirm') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog attach=".app-container" contained v-model="deleteDialog" width="auto">
    <v-card  rounded="lg">
      <v-card-title>{{ translate('delete_track') }} {{ track.RaceName }}?</v-card-title>
      <v-card-text> {{ translate('cant_be_reverted') }}  </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="deleteDialog = false">
            {{ translate('close') }} 
        </v-btn>
        <v-btn rounded="xl" variant="flat" color="red" @click="deleteTrack()">
            {{ translate('confirm') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
  <v-dialog attach=".app-container" contained v-model="editRecords" width="auto">
    <v-card  rounded="lg">
      <v-card-title>{{ translate('view_records') }} {{ track.RaceName }}?</v-card-title>
      <v-card-subtitle> {{ translate('view_records_modal_desc') }} </v-card-subtitle>
      
      <v-card-text>
        <v-alert type="warning" >  {{ translate('changes_are_permanent') }}</v-alert>
        <v-list>
          <v-list-item 
            v-for="(record, i) in track.Records" 
            :key="i" 
            :title="record.Holder + ' | ' + msToHMS(record.Time)" 
            :subtitle="record.Vehicle + ' | ' + record.Class"
          >
          <template v-slot:append>
            <v-btn variant="text" color="red" :text="translate('remove_record')" @click="openConfirmRecordModal(record)"></v-btn>
          </template>
          </v-list-item>
        </v-list>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn rounded="xl" @click="editRecords = false">
            {{ translate('close') }} 
        </v-btn>
      </v-card-actions>
    </v-card>
    <v-dialog  attach=".app-container" contained width="auto" v-model="confirmRecordRemovalDialog">
      <v-card rounded="lg" :title="translate('confirm_record_removal')">
        <v-card-text v-if="selectedRecord">
          <p> {{ translate('racer_name') }}: {{ selectedRecord.Holder }} </p>
          <p> {{ translate('best_lap') }}: {{ selectedRecord.Time }} </p>
          <p> {{ translate('vehicle') }}: {{ selectedRecord.Vehicle }} </p>
          <p> {{ translate('class') }}: {{ selectedRecord.Class }} </p>
          <p> {{ translate('race_type') }}: {{ selectedRecord.RaceType }} </p>
          <p> {{ translate('reversed') }}: {{ selectedRecord.Reversed }} </p>
        </v-card-text>
        <v-card-actions>
          <v-btn  variant="text" :text="translate('close')" @click="resetRecordRemoval"></v-btn>
          <v-btn :loading="loadingRecordRemoval" variant="text" color="red" @click="handleRemoveRecord" :text="translate('confirm')"></v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-dialog>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { Track, TrackMetadata, TrackRecord } from "@/store/types";
import { Ref, ref } from "vue";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import { msToHMS } from "@/helpers/msToHMS";

const trackTypes = [
  { value: 'any', label: translate('any') },
  { value: 'circuit_only', label: translate('circuit_only') },
  { value: 'sprint_only', label: translate('sprint_only') },
]

const globalStore = useGlobalStore();

const props = defineProps<{
  track: Track;
}>();
const emit = defineEmits(['update'])

const curateDialog = ref(false);
const lbDialog = ref(false);
const editDialog = ref(false);
const accessDialog = ref(false);
const settingsDialog = ref(false);
const editRecords = ref(false);

const confirmRecordRemovalDialog = ref(false);
const selectedRecord: Ref<TrackRecord | undefined> = ref(undefined)
const loadingRecordRemoval = ref(false)

const openConfirmRecordModal = (record: TrackRecord) => {
  selectedRecord.value = record
  confirmRecordRemovalDialog.value = true
}

const resetRecordRemoval = () => {
  selectedRecord.value = undefined
  confirmRecordRemovalDialog.value = false

}
const handleRemoveRecord = async () => {
  loadingRecordRemoval.value = true  
  if (selectedRecord.value) {
    const response = await api.post('UiRemoveRecord',  JSON.stringify({ trackId: props.track.TrackId, record: selectedRecord.value }))
    if (response) {
      emit('update')      
      resetRecordRemoval()
      loadingRecordRemoval.value = false
    }
  }
  
  
}

const settings: Ref<TrackMetadata> = ref({
  description: undefined,
  raceType: undefined,
});
const deleteDialog = ref(false);
const access: any = ref(undefined)

const copyToClipboard = () => {
  const el = document.createElement("textarea");
  el.value = JSON.stringify(props.track.Checkpoints);
  document.body.appendChild(el);
  el.select();
  document.execCommand("copy");
  document.body.removeChild(el);
};

const clearLB = () => {
    api.post('UiClearLeaderboard', JSON.stringify({ RaceName: props.track.RaceName, TrackId: props.track.TrackId }))
    lbDialog.value = false;
};
const editTrack = () => {
    api.post('UiEditTrack', JSON.stringify({ RaceName: props.track.RaceName, TrackId: props.track.TrackId }))
    editDialog.value = false;
    closeApp()
};
const openEditAccess = async () => {
    const response = await api.post('UiGetAccess',  JSON.stringify({ RaceName: props.track.RaceName, TrackId: props.track.TrackId }))
    access.value = response.data
    accessDialog.value = true;
};

const openEditMetadata = async () => {
    Object.keys(settings.value).forEach((key) => {
      settings.value[key as keyof TrackMetadata] = props.track.Metadata[key as keyof TrackMetadata] || undefined
    })
    settingsDialog.value = true;
};

const editAccess = () => {
    api.post('UiEditAccess', JSON.stringify({RaceName: props.track.RaceName, TrackId: props.track.TrackId, NewAccess: access.value}))
    accessDialog.value = false;
}

const confirmSettings = async () => {
    if (settings.value.raceType === 'any') settings.value.raceType = undefined
    await api.post('UiConfirmSettings', JSON.stringify({ TrackId: props.track.TrackId, Metadata: settings.value }))
    settingsDialog.value = false;
    emit('update')
};

const deleteTrack = () => {
    api.post('UiDeleteTrack', JSON.stringify({ RaceName: props.track.RaceName, TrackId: props.track.TrackId }))
    deleteDialog.value = false;
    setTimeout(() => {
      emit('update')      
    }, 1500);
};

const setCuration = async (curated: number) => {
    const response = await api.post('UiSetCurated', JSON.stringify({ curated, trackId: props.track.TrackId }))
    if (response.data) {
      // eslint-disable-next-line vue/no-mutating-props
      props.track.Curated = curated;
      curateDialog.value = false;
    }
};

const showRace = async () => {
    const res = await api.post("UiShowTrack", JSON.stringify(props.track.TrackId));
    if (res.data) closeApp()
}


</script>

<style scoped lang="scss">
.text {
    display: flex;
    gap: 0.5em;
    flex-wrap: wrap;
}
.title {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.available-card {
  flex-grow: 1;
}
.text-area {
  min-width: 30em;
}
</style>
