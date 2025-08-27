import { useGlobalStore } from "@/store/global";

export const translate = (key: string) => {
    const globalStore = useGlobalStore();
    return globalStore.baseData.data?.translations?.[key] || key;
}