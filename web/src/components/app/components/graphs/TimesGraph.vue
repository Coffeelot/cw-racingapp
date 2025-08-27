<template>
  <Card class="w-full">
    <CardHeader>
      <CardTitle>
        {{ translate("best_vs_avg_times") }}
      </CardTitle>
    </CardHeader>
    <CardContent>
      <Bar :key="isOpenKey" :data="chartData" :options="chartOptions" />
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { TrackRaceStats } from '@/store/types'
import { Chart as ChartJS, BarElement, CategoryScale, LinearScale, Tooltip, Legend } from 'chart.js'
import { Bar } from 'vue-chartjs'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { translate } from '@/helpers/translate'
import { chartOptions } from '@/chartConfig'
import { useSidebar } from '@/components/ui/sidebar'

const props = defineProps<{
  trackStats: TrackRaceStats[]
}>()

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend)

function getRandomTracks(tracks: TrackRaceStats[], count = 5): TrackRaceStats[] {
  const shuffled = [...tracks].sort(() => Math.random() - 0.5)
  return shuffled.slice(0, Math.min(count, tracks.length))
}

const chartData = computed(() => {
  const randomTracks = getRandomTracks(props.trackStats, 5)
  const labels = randomTracks.map(t => t.trackName)
  const avgTimes = randomTracks.map(t => t.avgTime)
  const bestTimes = randomTracks.map(t => t.bestTime)

  return {
    labels,
    datasets: [
      {
        label: translate('avg_time'),
        data: avgTimes,
        backgroundColor: 'rgba(1, 188, 217, 0.7)',
        borderColor: '#2ca6b9',
        borderWidth: 1,
      },
      {
        label: translate('best_time'),
        data: bestTimes,
        backgroundColor: 'rgba(254, 154, 0, 0.7)',
        borderColor: '#fe9a00',
        borderWidth: 1,
      }
    ]
  }
})

const sidebarContext = useSidebar()
const isOpen = ref(sidebarContext.open)
const isOpenKey = ref(0)

watch(isOpen, () => {
  setTimeout(() => {
    isOpenKey.value++
  }, 500) 
})

</script>