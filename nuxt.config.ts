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
    css: ['~/assets/css/main.css', 'katex/dist/katex.min.css'],
    app: localAppConfig ?? appConfig,
    content: {
      documentDriven: false,
      build: {
        markdown: {
          remarkPlugins: {
            'remark-math': {}
          },
          rehypePlugins: {
            'rehype-katex': {}
          }
        }
      }
    },
    routeRules: {
      '/': { prerender: true },
      '/blog/**': {
        swr: 300,
        headers: {
          'cache-control': 'public, max-age=0, s-maxage=300, stale-while-revalidate=600'
        }
      },
      '/papers/**': {
        swr: 600,
        headers: {
          'cache-control': 'public, max-age=0, s-maxage=600, stale-while-revalidate=1200'
        }
      },
      '/apps/**': {
        swr: 600,
        headers: {
          'cache-control': 'public, max-age=0, s-maxage=600, stale-while-revalidate=1200'
        }
      },
      '/resume': {
        swr: 86400,
        headers: {
          'cache-control': 'public, max-age=0, s-maxage=86400, stale-while-revalidate=172800'
        }
      },
      '/research': {
        swr: 86400,
        headers: {
          'cache-control': 'public, max-age=0, s-maxage=86400, stale-while-revalidate=172800'
        }
      },
      '/application/**': {
        headers: {
          // 对浏览器与CDN都不缓存（并避免CF误缓存）
          'cache-control': 'private, no-store, no-cache, max-age=0, must-revalidate'
        }
      }
    },
    ...(localNuxtConfig ?? {})
  }
})
