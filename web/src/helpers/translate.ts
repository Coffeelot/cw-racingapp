import { useGlobalStore } from "@/store/global";

export const translate = (key: string, ...inputs: Array<string | number>) => {
    const globalStore = useGlobalStore();
    let tpl = globalStore.baseData.data?.translations?.[key] ?? key;

    if (inputs && inputs.length > 0) {
        for (const v of inputs) {
            tpl = tpl.replace('%INPUT%', String(v));
        }
    }

    return tpl;
}