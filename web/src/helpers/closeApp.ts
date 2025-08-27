import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";

export const closeApp = () => {
    const store = useGlobalStore()
    store.appIsOpen = false 
    api.post("UiCloseUi");
}