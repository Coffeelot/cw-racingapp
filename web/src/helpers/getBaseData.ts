import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";

export const getBaseData = async () => {
    if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
        console.log('MOCK DATA ACTIVE. SKIPPING BASE DATA FETCH')
        return
      }
    const store = useGlobalStore()
    store.isLoadingBaseData = true
    const res = await api.post("GetBaseData");
    if (res) {
        store.baseData = res
    }
    store.isLoadingBaseData = false
}