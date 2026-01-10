import { existsSync } from 'node:fs'
import { resolve } from 'node:path'
import { pathToFileURL } from 'node:url'

import appConfig from './nuxt.app.config'

const loadOptionalConfig = async (path: string) => {
  const absolutePath = resolve(path)
  if (!existsSync(absolutePath)) {
    return null
  }
  const mod = await import(pathToFileURL(absolutePath).href)
  return mod.default ?? mod
}

export default defineNuxtConfig(async () => {
  const localNuxtConfig = await loadOptionalConfig('nuxt.config.local.ts')
  const localAppConfig = await loadOptionalConfig('nuxt.app.config.local.ts')

  return {
    srcDir: 'app/',
    compatibilityDate: '2026-01-04',
    modules: ['@nuxt/ui', '@nuxt/content'],
    css: ['~/assets/css/main.css'],
    app: localAppConfig ?? appConfig,
    content: {
      documentDriven: false
    },
    ...(localNuxtConfig ?? {})
  }
})
