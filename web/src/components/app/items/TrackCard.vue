<template>
  <Card class="track-card">
    <CardHeader class="title">
      <CardTitle class="flex gap-2 items-center">
        <h2 >{{ track.RaceName }}</h2>
        <Badge v-if="track.Curated" icon="mdi-star"><StarIcon></StarIcon> {{ translate('curated') }}</Badge>
      </CardTitle>
      <DropdownMenu >
        <DropdownMenuTrigger as-child>
          <Button variant="ghost" class=" ml-2" ><EllipsisVertical /> </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent class="dark" align="end" >
          <DropdownMenuItem @click="showRace">{{ translate('show_track') }}</DropdownMenuItem>
          <DropdownMenuItem @click="copyToClipboard">{{ translate('copy_checkpoints') }}</DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem v-if="globalStore.baseData.data.auth.curateTracks" @click="curateDialog = true">
            {{ translate('curation') }}
          </DropdownMenuItem>
          <DropdownMenuItem @click="openRecordsModal">{{ translate('view_records') }}</DropdownMenuItem>
          <DropdownMenuItem @click="lbDialog = true">{{ translate('clear_lead') }}</DropdownMenuItem>
          <DropdownMenuItem v-if="!track.Curated" @click="editDialog = true">{{ translate('edit_track') }}</DropdownMenuItem>
          <DropdownMenuItem @click="openEditMetadata">{{ translate('edit_settings') }}</DropdownMenuItem>
          <DropdownMenuItem @click="openEditAccess">{{ translate('edit_access') }}</DropdownMenuItem>
          <DropdownMenuItem @click="deleteDialog = true" class="text-red-600">
            {{ translate('delete_track') }}
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </CardHeader>
    <CardContent class="text">
      <Badge variant="outline" class="allow-select">{{ translate('track_id') }}: {{ track.TrackId }}</Badge>
      <Badge variant="outline"><TrackIcon /> {{ translate('length') }}: {{ track.Distance }}m</Badge>
      <Badge variant="outline"><FlagTriangleLeft /> {{ translate('checkpoints') }}: {{ track.Checkpoints.length }}</Badge>
      <Badge variant="outline"> <CompassIcon /> {{ translate('created_by') }}: {{ track.CreatorName }}</Badge>
      <Badge variant="outline" v-if="track.Access?.race && track.Access.race.length > 0">
        <UsersIcon />
        {{ translate('shared_with') }}: {{ track.Access.race.length }} {{ translate('racers') }}
      </Badge>
    </CardContent>
  </Card>

  <!-- Curation Dialog -->
  <Dialog v-model:open="curateDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ translate('handle_curation_for') }}: {{ track.RaceName }}?</DialogTitle>
      </DialogHeader>
      <DialogFooter>
        <Button variant="ghost" @click="curateDialog = false">{{ translate('close') }}</Button>
        <Button variant="destructive" @click="setCuration(0)">{{ translate('set_uncurated') }}</Button>
        <Button variant="default" @click="setCuration(1)">{{ translate('set_curated') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>

  <!-- Clear Lead Dialog -->
  <Dialog v-model:open="lbDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ translate('clear_lead_for') }}: {{ track.RaceName }}?</DialogTitle>
      </DialogHeader>
      <div>{{ translate('cant_be_reverted') }}</div>
      <DialogFooter>
        <Button variant="ghost" @click="lbDialog = false">{{ translate('close') }}</Button>
        <Button variant="destructive" @click="clearLB">{{ translate('confirm') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>

  <!-- Edit Track Dialog -->
  <Dialog v-model:open="editDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ translate('open_track_editor_for') }}: {{ track.RaceName }}?</DialogTitle>
      </DialogHeader>
      <DialogFooter>
        <Button variant="ghost" @click="editDialog = false">{{ translate('close') }}</Button>
        <Button variant="default" @click="editTrack">{{ translate('confirm') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>

  <!-- Edit Access Dialog -->
  <Dialog v-model:open="accessDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ translate('editing_access_for') }}: {{ track.RaceName }}</DialogTitle>
      </DialogHeader>
      <div>
        <Input :placeholder="translate('access_list')" v-model="access.race" />
        <small>{{ translate('editing_access_info') }}</small>
      </div>
      <DialogFooter>
        <Button variant="ghost" @click="accessDialog = false">{{ translate('close') }}</Button>
        <Button variant="default" @click="editAccess">{{ translate('confirm') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>

  <!-- Edit Settings Dialog -->
  <Dialog v-model:open="settingsDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>
          {{ translate('edit_settings') }}: {{ track.RaceName }}
        </DialogTitle>
      </DialogHeader>
      <div>
        <Textarea
          class="text-area mb-3"
          :maxlength="200"
          :counter="200"
          :placeholder="translate('description')"
          :hint="translate('description_hint')"
          color="primary"
          v-model="settings.description"
        />
        <Select v-model="settings.raceType" class="mt-2">
          <SelectTrigger>
            <SelectValue :placeholder="translate('race_type')" />
          </SelectTrigger>
          <SelectContent class="dark">
            <SelectItem v-for="type in trackTypes" :key="type.value" :value="type.value">
              {{ type.label }}
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
      <DialogFooter>
        <Button variant="ghost" @click="settingsDialog = false">{{ translate('close') }}</Button>
        <Button variant="default" @click="confirmSettings">{{ translate('confirm') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>

  <!-- Delete Dialog -->
  <Dialog v-model:open="deleteDialog">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ translate('delete_track') }}: {{ track.RaceName }}?</DialogTitle>
      </DialogHeader>
      <div>{{ translate('cant_be_reverted') }}</div>
      <DialogFooter>
        <Button variant="ghost" @click="deleteDialog = false">{{ translate('close') }}</Button>
        <Button variant="destructive" @click="deleteTrack">{{ translate('confirm') }}</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>

  <!-- Records Dialog -->
  <Dialog v-model:open="editRecords">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ translate('view_records') }}: {{ track.RaceName }}?</DialogTitle>
        <DialogDescription>{{ translate('view_records_modal_desc') }}</DialogDescription>
      </DialogHeader>
      <Alert v-if="!loadingRecords" type="warning"><TriangleAlert/> <AlertTitle>{{ translate('changes_are_permanent') }}</AlertTitle></Alert>
      <Table v-if="!loadingRecords">
        <TableBody>
          <TableRow v-for="(record, i) in trackRecords" :key="i">
            <TableCell>{{ record.racerName }}</TableCell>
            <TableCell>{{ record.time }}</TableCell>
            <TableCell>{{ record.vehicleModel }}</TableCell>
            <TableCell>{{ record.carClass }}</TableCell>
            <TableCell>
              <Button variant="outline" color="red" size="sm" @click="openConfirmRecordModal(record)">
                {{ translate('remove_record') }}
              </Button>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
      <Skeleton v-else class="w-full" />
      <DialogFooter>
        <Button variant="ghost" @click="editRecords = false">{{ translate('close') }}</Button>
      </DialogFooter>
    </DialogContent>
    <!-- Confirm Record Removal Dialog -->
    <Dialog v-model:open="confirmRecordRemovalDialog">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{{ translate('confirm_record_removal') }}</DialogTitle>
        </DialogHeader>
        <div v-if="selectedRecord">
          <p>{{ translate('racer_name') }}: {{ selectedRecord.racerName }}</p>
          <p>{{ translate('best_lap') }}: {{ selectedRecord.time }}</p>
          <p>{{ translate('vehicle') }}: {{ selectedRecord.vehicleModel }}</p>
          <p>{{ translate('class') }}: {{ selectedRecord.carClass }}</p>
          <p>{{ translate('race_type') }}: {{ selectedRecord.raceType }}</p>
          <p>{{ translate('reversed') }}: {{ selectedRecord.reversed }}</p>
        </div>
        <DialogFooter>
          <Button variant="ghost" @click="resetRecordRemoval">{{ translate('close') }}</Button>
          <Button :loading="loadingRecordRemoval" variant="destructive" @click="handleRemoveRecord">{{ translate('confirm') }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </Dialog>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { RaceRecord, Track, TrackMetadata } from "@/store/types";
import { Ref, ref } from "vue";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import {
  Card, CardHeader, CardContent, 
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Alert, AlertTitle } from "@/components/ui/alert";
import { Textarea } from "@/components/ui/textarea";
import Skeleton from "@/components/ui/skeleton/Skeleton.vue";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import { CompassIcon, EllipsisVertical, FlagTriangleLeft, StarIcon, TriangleAlert, UsersIcon } from "lucide-vue-next";
import { mockRecords } from "@/mocking/testState";
import { Table, TableBody, TableCell } from "@/components/ui/table";
import TableRow from "@/components/ui/table/TableRow.vue";
import TrackIcon from "@/assets/icons/TrackIcon.vue";
import copy from 'copy-to-clipboard';
import { toast } from "vue-sonner";

const trackTypes = [
  { value: 'any', label: translate('any') },
  { value: 'circuit_only', label: translate('circuit_only') },
  { value: 'sprint_only', label: translate('sprint_only') },
];

const globalStore = useGlobalStore();

const props = defineProps<{
  track: Track;
}>();
const emit = defineEmits(['update']);

const curateDialog = ref(false);
const lbDialog = ref(false);
const editDialog = ref(false);
const accessDialog = ref(false);
const settingsDialog = ref(false);
const editRecords = ref(false);
const loadingRecords = ref(false);

const confirmRecordRemovalDialog = ref(false);
const selectedRecord: Ref<RaceRecord | undefined> = ref(undefined);
const loadingRecordRemoval = ref(false);

const openConfirmRecordModal = (record: RaceRecord) => {
  selectedRecord.value = record;
  if (selectedRecord.value) {
    confirmRecordRemovalDialog.value = true;
  }
};

const trackRecords: Ref<RaceRecord[] | undefined> = ref(undefined);

const fetchRecords = async () => {
  loadingRecords.value = true;
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    setTimeout(() => {
      trackRecords.value = mockRecords as unknown as RaceRecord[];
      loadingRecords.value = false;
    }, 1000);
    return
  }
  const result = await api.post('UiGetRaceRecordsForTrack', JSON.stringify({ trackId: props.track.TrackId }));
  trackRecords.value = result.data as RaceRecord[];
  loadingRecords.value = false;
};

const openRecordsModal = async () => {
  editRecords.value = true;
  fetchRecords();
};

const resetRecordRemoval = () => {
  selectedRecord.value = undefined;
  confirmRecordRemovalDialog.value = false;
};

const handleRemoveRecord = async () => {
  loadingRecordRemoval.value = true;
  if (selectedRecord.value) {
    const response = await api.post('UiRemoveRecord', JSON.stringify({ record: selectedRecord.value }));
    if (response) {
      fetchRecords();
      resetRecordRemoval();
      loadingRecordRemoval.value = false;
      confirmRecordRemovalDialog.value = false;
    }
  }
};

const settings: Ref<TrackMetadata> = ref({
  description: undefined,
  raceType: undefined,
});
const deleteDialog = ref(false);
const access: any = ref(undefined);

const copyToClipboard = async () => {
  const success = copy(JSON.stringify(props.track.Checkpoints));
  if (success) {
    toast.success(translate('checkpoints_copied'));
  } else {
    toast.error(translate('checkpoints_copy_failed'));
  }
};

const clearLB = () => {
  api.post('UiClearLeaderboard', JSON.stringify({ RaceName: props.track.RaceName, TrackId: props.track.TrackId }));
  lbDialog.value = false;
};
const editTrack = () => {
  api.post('UiEditTrack', JSON.stringify({ RaceName: props.track.RaceName, TrackId: props.track.TrackId }));
  editDialog.value = false;
  closeApp();
};
const openEditAccess = async () => {
    if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    setTimeout(() => {
      access.value = { race: ['Coffeegod', 'SomeFakeName']};
      accessDialog.value = true;
    }, 500);
    return
  }
  const response = await api.post('UiGetAccess', JSON.stringify({ RaceName: props.track.RaceName, TrackId: props.track.TrackId }));
  access.value = response.data;
  accessDialog.value = true;
};

const openEditMetadata = async () => {
  Object.keys(settings.value).forEach((key) => {
    settings.value[key as keyof TrackMetadata] = props.track.Metadata[key as keyof TrackMetadata] || undefined;
  });
  settingsDialog.value = true;
};

const editAccess = () => {
  api.post('UiEditAccess', JSON.stringify({ RaceName: props.track.RaceName, TrackId: props.track.TrackId, NewAccess: access.value }));
  accessDialog.value = false;
};

const confirmSettings = async () => {
  if (settings.value.raceType === 'any') settings.value.raceType = undefined;
  await api.post('UiConfirmSettings', JSON.stringify({ TrackId: props.track.TrackId, Metadata: settings.value }));
  settingsDialog.value = false;
  emit('update');
};

const deleteTrack = () => {
  api.post('UiDeleteTrack', JSON.stringify({ RaceName: props.track.RaceName, TrackId: props.track.TrackId }));
  deleteDialog.value = false;
  setTimeout(() => {
    emit('update');
  }, 1500);
};

const setCuration = async (curated: number) => {
  const response = await api.post('UiSetCurated', JSON.stringify({ curated, trackId: props.track.TrackId }));
  if (response.data) {
    // eslint-disable-next-line vue/no-mutating-props
    props.track.Curated = curated;
    curateDialog.value = false;
  }
};

const showRace = async () => {
  const res = await api.post("UiShowTrack", JSON.stringify(props.track.TrackId));
  if (res.data) closeApp();
};
</script>

<style scoped>
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
.track-card {
  flex: 1 1 45%;
  max-width: 49%;
  min-width: 20em;
  box-sizing: border-box;
}
.text-area {
  min-width: 30em;
}
</style>