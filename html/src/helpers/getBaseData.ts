import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";

export const getBaseData = async () => {
    const store = useGlobalStore()
    store.isLoadingBaseData = true
    const res = await api.post("GetBaseData");
    store.baseData = res
    store.isLoadingBaseData = false
}