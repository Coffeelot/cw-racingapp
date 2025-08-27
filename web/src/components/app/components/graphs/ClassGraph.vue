<template>
  <Card>
    <CardHeader>
      <CardTitle>
        {{ translate("most_used_classes") }}
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
import { useGlobalStore } from '@/store/global'
import { chartOptions } from '@/chartConfig'

const props = defineProps<{
  trackStats: TrackRaceStats[]
}>()

ChartJS.register(ArcElement, Tooltip, Legend)

const globalStore = useGlobalStore()

const classLabels = computed(() => {
  return globalStore.baseData?.data?.classes?.map(c => c.value) ?? ['D', 'C', 'B', 'A', 'S', 'X']
})

const classDisplayNames = computed(() => {
  return globalStore.baseData?.data?.classes?.map(c => c.text) ?? classLabels.value
})

const classCounts = computed(() => {
  const counts: Record<string, number> = {}
  const topClass = classLabels.value[classLabels.value.length - 1]
  classLabels.value.forEach(cls => { counts[cls] = 0 })
  props.trackStats.forEach(stat => {
    let cls = stat.mostUsedMaxClass
    if (!cls || !classLabels.value.includes(cls)) {
      cls = topClass
    }
    counts[cls] = (counts[cls] ?? 0) + 1
  })
  return classLabels.value.map(cls => counts[cls])
})

const chartData = computed(() => ({
  labels: classDisplayNames.value,
  datasets: [
    {
      label: translate('track_count'),
      data: classCounts.value,
      backgroundColor: [
        '#2ca6b9', '#4e5bff', '#fe9a00', '#ad46ff', '#ff2056', '#b3b3c9'
      ],
      borderColor: '#18181b',
      borderWidth: 2,
    }
  ]
}))

</script>