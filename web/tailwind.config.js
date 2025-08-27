export default {
  content: ["./index.html", "./src/**/*.{vue,js,ts}"],
  theme: { extend: {
      colors: {
        primary: '#2563eb', // or your desired color
        secondary: '#64748b',
        'primary-foreground': '#fff',
        'secondary-foreground': '#fff',
      },
  } },
  plugins: [],
  safelist: [
    'bg-primary',
    'bg-secondary',
    'text-primary-foreground',
    'text-secondary-foreground',
  ],
}