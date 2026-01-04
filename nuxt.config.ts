export default defineNuxtConfig({
  srcDir: 'app/',
  compatibilityDate: '2026-01-04',
  modules: ['@nuxt/ui', '@nuxt/content'],
  css: ['~/assets/css/main.css'],
  app: {
    head: {
      title: 'Nuxt Research Hub',
      meta: [
        { name: 'description', content: 'Personal research hub for blog, papers, resume, and apps.' }
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Fraunces:wght@400;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap'
        }
      ]
    }
  },
  content: {
    documentDriven: false
  }
})
