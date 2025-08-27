<template>
  <Card>
    <CardHeader>
      <CardTitle>
        {{ translate("ranked_vs_unranked") }}
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
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { translate } from '@/helpers/translate'
import { chartOptions } from '@/chartConfig'

const props = defineProps<{
  trackStats: TrackRaceStats[]
}>()

ChartJS.register(ArcElement, Tooltip, Legend)

// Calculate totals
const chartData = computed(() => {
  const totalRaces = props.trackStats.reduce((sum, t) => sum + t.totalRaces, 0)
  const rankedRaces = props.trackStats.reduce((sum, t) => sum + t.rankedCount, 0)
  const unrankedRaces = totalRaces - rankedRaces

  return {
    labels: [
      translate('ranked_races'),
      translate('unranked_races')
    ],
    datasets: [
      {
        label: translate('total'),
        data: [rankedRaces, unrankedRaces],
        backgroundColor: [
          '#2ca6b9', // ranked
          '#27272a'  // unranked
        ],
        borderColor: '#18181b',
        borderWidth: 2,
      }
    ]
  }
})
</script>