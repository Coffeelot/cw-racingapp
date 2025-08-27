<template>
  <div class="top-racers" v-if="topRacerStats.topRacerWins.length > 0 || topRacerStats.topRacerWinLoss.length > 0">
    <h3>{{ translate('top_3_wins') }}</h3>
    <Table class="w-full">
      <TableHeader>
        <TableRow>
          <TableHead class="text-left"></TableHead>
          <TableHead class="text-left">{{ translate('wins') }}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        <TableRow v-for="(item, index) in sortTop3Wins(topRacerStats.topRacerWins)" :key="item.racerName">
          <TableCell>
            {{ index + 1 }}. {{ item.racerName }}
          </TableCell>
          <TableCell>{{ item.wins }}</TableCell>
        </TableRow>
      </TableBody>
    </Table>
    <Separator class="my-4" />
    <h3>{{ translate('top_3_wins_losses') }}</h3>
    <Table class="w-full">
      <TableHeader>
        <TableRow>
          <TableHead class="text-left"></TableHead>
          <TableHead class="text-left">{{ translate('win_loss_ratio') }}</TableHead>
          <TableHead class="text-left">{{ translate('wins') }}</TableHead>
          <TableHead class="text-left">{{ translate('races') }}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        <TableRow v-for="(item, index) in sortTop3WinLoss(topRacerStats.topRacerWinLoss)" :key="item.racerName">
          <TableCell>
            {{ index + 1 }}. {{ item.racerName }}
          </TableCell>
          <TableCell>{{ roundToTwoDecimals(item.winLoss) }}</TableCell>
          <TableCell>{{ item.wins }}</TableCell>
          <TableCell>{{ item.wins + item.losses }}</TableCell>
        </TableRow>
      </TableBody>
    </Table>
  </div>
</template>

<script setup lang="ts">
import { Separator } from '@/components/ui/separator';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { roundToTwoDecimals } from '@/helpers/roundToTwoDecimals';
import { translate } from '@/helpers/translate';
import { TopRacerStats } from '@/store/types';


const props = defineProps<{
  topRacerStats: TopRacerStats,
}>();

const sortTop3Wins = (top3Wins: { racerName: string; wins: number }[]) => {
  return [...top3Wins].sort((a, b) => b.wins - a.wins);
}

// Sorts by best win/loss ratio (descending)
const sortTop3WinLoss = (top3WinLoss: { racerName: string; wins: number; losses: number; winLoss: number }[]) => {
  return [...top3WinLoss].sort((a, b) => b.winLoss - a.winLoss);
}

</script>

<style scoped >

</style>
