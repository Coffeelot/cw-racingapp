<template>
  <Card class="bounty-card rounded-xl border">
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        {{ bounty.trackName }}
        <Badge :variant="hasBeenCompleted ? 'default' : 'outline'" class="ml-2">
          {{ msToHMS(bounty.timeToBeat) }}
        </Badge>
      </CardTitle>
    </CardHeader>
    <CardContent class="text flex gap-2 flex-wrap">
      <Badge variant="outline">
        {{ translate('price') }}: {{ translate('currency_text') }}{{ bounty.price }}
      </Badge>
      <Badge variant="outline">
        {{ translate('class') }}: {{ bounty.maxClass }}
      </Badge>
      <Badge :variant="meetsRequiredRank ? 'outline' : 'destructive'">
        {{ translate('required_rank') }}: {{ bounty.rankRequired }}
      </Badge>
      <Badge variant="outline" v-if="bounty.reversed">
        {{ translate('reversed') }}
      </Badge>
      <Badge variant="outline" v-if="bounty.sprint">
        {{ translate('sprint') }}
      </Badge>
      <Badge variant="outline" v-else>
        {{ translate('circuit') }}
      </Badge>
    </CardContent>
    <CardFooter class="flex gap-2 justify-end">
      <div class="flex-1"></div>
      <Button variant="ghost"  @click="recordsDialog = true">
        {{ translate('records') }}
      </Button>
      <Button
        
        :disabled="!meetsRequiredRank || loading || globalStore.activeRace?.raceName"
        @click="quickHost"
      >
        {{ translate('quick_host') }}
      </Button>
    </CardFooter>
    <Dialog v-model:open="recordsDialog">
      <DialogPortal to="#screen-root">
        <DialogOverlay class="fixed inset-0 bg-black/10" />
        <DialogContent class="dark text-foreground z-3000">
          <DialogHeader>
            <DialogTitle>{{ bounty.trackName }}</DialogTitle>
          </DialogHeader>
          <DialogDescription>
            <div class="flex gap-2 flex-wrap mb-2">
              <Badge variant="outline">
                {{ translate('class') }}: {{ bounty.maxClass }}
              </Badge>
              <Badge variant="outline" v-if="bounty.reversed">
                {{ translate('reversed') }}
              </Badge>
              <Badge variant="outline" v-if="bounty.sprint">
                {{ translate('sprint') }}
              </Badge>
              <Badge variant="outline" v-else>
                {{ translate('circuit') }}
              </Badge>
              <Badge :variant="meetsRequiredRank ? 'outline' : 'destructive'">
                {{ translate('required_rank') }}: {{ bounty.rankRequired }}
              </Badge>
            </div>
            <div>
              <Table v-if="times && times.length > 0" class="min-w-full text-sm">
                <TableHeader>
                  <TableRow>
                    <TableHead class="text-left"> {{  translate('racer_name') }}</TableHead >
                    <TableHead class="text-left">{{ translate('time') }}</TableHead >
                    <TableHead class="text-left">{{ translate('vehicle') }}</TableHead >
                  </TableRow>
                </TableHeader>
                <TableBody>
                  <TableRow v-for="(item, index) in times" :key="index">
                    <TableCell>{{ index + 1 }}. {{ item.racerName }}</TableCell>
                    <TableCell>{{ msToHMS(item.time) }}</TableCell>
                    <TableCell>{{ item.vehicleModel }}</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
              <InfoText v-else :title="translate('no_data')" />
            </div>
          </DialogDescription>
          <DialogFooter>
            <Button  @click="recordsDialog = false">
              {{ translate('close') }}
            </Button>
          </DialogFooter>
        </DialogContent>
      </DialogPortal>
    </Dialog>
  </Card>
</template>

<script setup lang="ts">
import { msToHMS } from "@/helpers/msToHMS";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import { Bounty, RaceRecord } from "@/store/types";
import { computed, ref } from "vue";
import InfoText from "../components/InfoText.vue";
import api from "@/api/axios";
import {
  Card, CardHeader, CardTitle, CardContent, CardFooter,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter,
} from "@/components/ui/dialog";
import { Table, TableCell, TableBody, TableHead, TableRow, TableHeader } from "@/components/ui/table";
import { DialogPortal } from "reka-ui";
import DialogOverlay from "@/components/ui/dialog/DialogOverlay.vue";

const props = defineProps<{
  bounty: Bounty;
}>();

const loading = ref(false)
const recordsDialog = ref(false)
const globalStore = useGlobalStore()
const times = computed(() => {
  const claims = props.bounty.claimed as unknown as RaceRecord[]
  const timearray = Object.values(claims).sort((res1, res2) => res1.time < res2.time ? -1 : 1 )
  return timearray as RaceRecord[]
})

const hasBeenCompleted = computed(() => {
  return times.value.filter((time) => time.racerName === globalStore.baseData.data.currentRacerName).length > 0
})

const meetsRequiredRank = computed(() => {
  return props.bounty.rankRequired <= globalStore.baseData.data.currentRanking
})

const quickHost = async () => {
  loading.value = true
  await api.post("UiQuickSetupBounty", JSON.stringify(props.bounty));
  loading.value = false
}
</script>

<style scoped>
.text {
  display: flex;
  gap: 0.5em;
  flex-wrap: wrap;
}
.bounty-card {
  flex: 1 1 45%;
  max-width: 49%;
  min-width: 20em;
  box-sizing: border-box;
}
</style>
