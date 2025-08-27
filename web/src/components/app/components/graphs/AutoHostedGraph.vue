<template>
  <Card>
    <CardHeader>
      <CardTitle>
        {{ translate("auto_vs_manual_hosted") }}
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

const chartData = computed(() => {
  const totalRaces = props.trackStats.reduce((sum, t) => sum + t.totalRaces, 0)
  const automatedRaces = props.trackStats.reduce((sum, t) => sum + t.automatedCount, 0)
  const manualRaces = totalRaces - automatedRaces

  return {
    labels: [
      translate('automated_races'),
      translate('manual_races')
    ],
    datasets: [
      {
        label: translate('total'),
        data: [automatedRaces, manualRaces],
        backgroundColor: [
          '#fe9a00', // automated
          '#2ca6b9'  // manual
        ],
        borderColor: '#18181b',
        borderWidth: 2,
      }
    ]
  }
})

</script>