/**
 * main.ts
 */

// Components
import App from './App.vue'

// Composables
import { createApp } from 'vue'

// Plugins
import { createPinia } from 'pinia'

const pinia = createPinia()
const app = createApp(App)

app.use(pinia)

app.mount('#app')
