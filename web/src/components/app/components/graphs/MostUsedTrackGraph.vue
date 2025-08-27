<template>
  <Card>
    <CardHeader>
      <CardTitle>
        {{ translate("most_used_tracks") }}
      </CardTitle>
    </CardHeader>
    <CardContent>
      <Doughnut :data="chartData" :options="chartOptions" />
    </CardContent>

  </Card>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { TrackRaceStats } from '@/store/types'
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'
import { Doughnut } from 'vue-chartjs'
import { chartOptions } from '@/chartConfig';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { translate } from '@/helpers/translate';

const props = defineProps<{
  trackStats: TrackRaceStats[]
}>()

ChartJS.register(ArcElement, Tooltip, Legend)

// Compute top 5 tracks by totalRaces
const chartData = computed(() => {
  // Sort and take top 5
  const topTracks = [...props.trackStats]
    .sort((a, b) => b.totalRaces - a.totalRaces)
    .slice(0, 5)

  return {
    labels: topTracks.map(t => t.trackName),
    datasets: [
      {
        label: 'Total Races',
        data: topTracks.map(t => t.totalRaces),
        backgroundColor: [
          '#2ca6b9', '#4e5bff', '#fe9a00', '#ad46ff', '#ff2056'
        ],
        borderColor: '#18181b',
        borderWidth: 2,
      }
    ]
  }
})

</script>