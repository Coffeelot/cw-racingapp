<template>
  <Dialog :key="track.TrackId" v-model:open="open" class="max-w-2xl">
    <DialogTrigger as-child>
      <Button variant="ghost">
        {{ translate('setup_race') }}
      </Button>
    </DialogTrigger>
    <DialogContent class="dark max-w-2xl">
      <DialogHeader>
        <DialogTitle>
          {{ translate('selected_track') }} {{ track.RaceName }}
        </DialogTitle>
      </DialogHeader>
      <DialogDescription>
        <form :id="'setup-'+track.TrackId">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
            <!-- Laps -->
            <FormField v-slot="{ componentField }" name="laps">
              <FormItem>
                <FormLabel>{{ translate('laps') }}</FormLabel>
                <FormControl>
                  <Select  v-bind="componentField" >
                    <SelectTrigger class="w-full">
                      <SelectValue :placeholder="translate('laps')" />
                    </SelectTrigger>
                    <SelectContent class="dark">
                      <SelectItem v-for="lap in lapsFiltered" :key="lap.value" :value="lap.value || 'sprint'">
                        {{ lap.text }}
                      </SelectItem>
                    </SelectContent>
                  </Select>
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
            <!-- Buy In -->
            <FormField v-slot="{ componentField }" name="buyIn">
              <FormItem>
                <FormLabel>{{ translate('buy_in') }}</FormLabel>
                <FormControl>
                  <Select v-bind="componentField" class="input">
                    <SelectTrigger  class="w-full">
                      <SelectValue :placeholder="translate('buy_in')" />
                    </SelectTrigger>
                    <SelectContent class="dark" >
                      <SelectItem v-for="buyIn in globalStore.baseData.data.buyIns" :key="buyIn.value" :value="buyIn.value">
                        {{ buyIn.value }}
                      </SelectItem>
                    </SelectContent>
                  </Select>
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
            <!-- Ghosting -->
            <FormField v-if="globalStore.baseData.data.ghostingEnabled" v-slot="{ componentField }" name="ghosting">
              <FormItem>
                <FormLabel>{{ translate('ghosting') }}</FormLabel>
                <FormControl>
                  <Select v-bind="componentField" class="input">
                    <SelectTrigger  class="w-full">
                      <SelectValue :placeholder="translate('ghosting')" />
                    </SelectTrigger>
                    <SelectContent class="dark" >
                      <SelectItem v-for="ghost in globalStore.baseData.data.ghostingTimes" :key="ghost.value" :value="ghost.value">
                        {{ ghost.text || ghost.value }}
                      </SelectItem>
                    </SelectContent>
                  </Select>
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
            <!-- Max Class -->
            <FormField v-slot="{ componentField }" name="maxClass">
              <FormItem>
                <FormLabel>{{ translate('max_class') }}</FormLabel>
                <FormControl>
                  <Select v-bind="componentField" class="input">
                    <SelectTrigger  class="w-full">
                      <SelectValue :placeholder="translate('max_class')" />
                    </SelectTrigger>
                    <SelectContent class="dark" >
                      <SelectItem v-for="cls in globalStore.baseData.data.classes" :key="cls.value" :value="cls.value || 'NONE'">
                        {{ cls.text }}
                      </SelectItem>
                    </SelectContent>
                  </Select>
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
            <!-- Host Silent -->
            <FormField  type="checkbox" v-slot="{ componentField }" name="silent">
              <FormItem>
                <FormLabel>{{ translate('host_silent') }}</FormLabel>
                <FormControl>
                  <Switch v-bind="componentField" />
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
            <!-- Reversed -->
            <FormField  type="checkbox" v-if="globalStore.baseData.data.auth.startReversed" v-slot="{ componentField }" name="reversed">
              <FormItem>
                <FormLabel>{{ translate('reversed') }}</FormLabel>
                <FormControl>
                  <Switch v-bind="componentField" />
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
            <!-- First Person -->
            <FormField  type="checkbox" v-slot="{ componentField }" name="firstPerson">
              <FormItem>
                <FormLabel>{{ translate('first_person') }}</FormLabel>
                <FormControl>
                  <Switch v-bind="componentField" />
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
            <!-- Participation Money -->
            <FormField
              v-if="globalStore?.baseData?.data?.auth?.setupParticipation"
              v-slot="{ componentField }"
              name="participationMoney"
            >
              <FormItem>
                <FormLabel>{{ translate('participation_amount') }}</FormLabel>
                <FormControl>
                  <Input
                    type="number"
                    v-bind="componentField"
                    prepend-icon="mdi-help-circle-outline"
                    :prepend-tooltip="translate('participation_info')"
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
            <!-- Participation Currency -->
            <FormField
              v-if="globalStore?.baseData?.data?.auth?.setupParticipation"
              v-slot="{ componentField }"
              name="participationCurrency"
            >
              <FormItem>
                <FormLabel>{{ translate('currency') }}</FormLabel>
                <FormControl>
                  <Select v-bind="componentField" class="input">
                    <SelectTrigger  class="w-full">
                      <SelectValue :placeholder="translate('currency')" />
                    </SelectTrigger>
                    <SelectContent class="dark" >
                      <SelectItem v-for="cur in globalStore.baseData.data.participationCurrencyOptions" :key="cur.value" :value="cur.value">
                        {{ cur.text || cur.value }}
                      </SelectItem>
                    </SelectContent>
                  </Select>
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
            <!-- Ranked -->
            <FormField
              type="checkbox"
              v-if="globalStore?.baseData?.data?.auth?.startRanked"
              v-slot="{ componentField }"
              name="ranked"
            >
              <FormItem>
                <FormLabel>{{ translate('ranked') }}</FormLabel>
                <FormControl>
                  <Switch :disabled="setupData.laps === -1" v-bind="componentField" />
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
          </div>
          <DialogFooter>
            <Button :disabled="globalStore.activeRace?.raceName" type="submit" form="dialogForm" @click="handleConfirm">
              {{ translate('confirm') }}
            </Button>
          </DialogFooter>
        </form>
      </DialogDescription>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { Track } from "@/store/types";
import { translate } from "@/helpers/translate";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import Switch from "@/components/ui/switch/Switch.vue";
import Input from "@/components/ui/input/Input.vue";
import {
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from "@/components/ui/form";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useForm } from "vee-validate";

const props = defineProps<{
  track: Track;
}>();

const emits = defineEmits(["goBack"]);
const globalStore = useGlobalStore();
const open = ref(false);

const lapsFiltered = computed(() =>
  globalStore.baseData.data.laps.filter((lapType) => {
    if (lapType.value === -1) {
      // For elimination
      return globalStore.baseData.data.auth.startElimination;
    }
    if (props.track.Metadata?.raceType) {
      if (props.track.Metadata.raceType === 'sprint' && lapType.value > 0) return false
      if (props.track.Metadata.raceType === 'circuit_only' && lapType.value === 0) return false
    }
    return true;
  })
);

const trackHasDefinedType = props.track.Metadata?.raceType === 'circuit_only' || props.track.Metadata?.raceType === 'sprint'
const defaultLapValue = trackHasDefinedType ? (
  props.track.Metadata?.raceType === 'circuit_only' ? globalStore.baseData.data.laps[2].value :'sprint' ):
  'sprint'

const setupData = ref({
  laps: defaultLapValue,
  buyIn: globalStore.baseData.data.buyIns[0].value,
  ghosting: globalStore.baseData.data.ghostingTimes[0].value,
  maxClass: globalStore.baseData.data.classes[0].value == '' ? 'NONE' : globalStore.baseData.data.classes[0].value,
  ranked: false,
  reversed: false,
  firstPerson: false,
  participationMoney: 0,
  participationCurrency: globalStore.baseData.data.participationCurrencyOptions[0].value,
  silent: false,
});

const form = useForm({
  initialValues: setupData.value,
})

const handleConfirm = async () => {
  if (form.values.participationMoney < 0)
    form.values.participationMoney = 0;
  if (form.values.laps === -1) form.values.ranked = false;
  
  let maxClass;
  if (form.values.maxClass === 'NONE') {
    maxClass = '';
  } else {
    maxClass = form.values.maxClass
  }
  let laps;
  if (form.values.laps === 'sprint') {
    laps = 0;
  } else {
    laps = form.values.laps
  }

  let data = {
    trackId: props.track.TrackId,
    laps: laps,
    buyIn: form.values.buyIn,
    maxClass: maxClass,
    ghostingOn: form.values.ghosting !== -1,
    ghostingTime: form.values.ghosting,
    ranked: form.values.ranked,
    participationMoney: form.values.participationMoney,
    participationCurrency: form.values.participationCurrency,
    reversed: form.values.reversed,
    firstPerson: form.values.firstPerson,
    silent: form.values.silent,
  };

  const res = await api.post("UiSetupRace", JSON.stringify(data));
  if (res.data) {
    globalStore.$state.currentTab.racing = "current";
    closeApp();
    emits("goBack");
  }
};
</script>