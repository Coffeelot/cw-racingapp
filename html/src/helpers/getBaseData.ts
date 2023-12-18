import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";

export const getBaseData = async () => {
    const store = useGlobalStore()
    const res = await api.post("GetBaseData");
    store.baseData = res
}