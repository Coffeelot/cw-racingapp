/**
 * plugins/vuetify.ts
 *
 * Framework documentation: https://vuetifyjs.com`
 */

// Styles
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

// Composables
import { createVuetify } from 'vuetify'

export default createVuetify({
  theme: {
    themes: {
      dark: {
        colors: {
          primary: '#e36a00',
          secondary: '#5CBBF6',
          surface: '#0e0e0e'
        },
      },
    },
  },
})
