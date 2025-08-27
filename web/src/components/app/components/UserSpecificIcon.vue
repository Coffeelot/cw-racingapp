<template>
  <StarIcon v-if="isAdmin"/>
  <UserIcon v-else></UserIcon>
</template>

<script setup lang="ts">
import { useGlobalStore } from '@/store/global';
import { StarIcon, UserIcon } from 'lucide-vue-next';
const globalstore = useGlobalStore()

const isAdmin = globalstore.baseData?.data?.auth?.controlAll

</script>

<style scoped >

</style>
