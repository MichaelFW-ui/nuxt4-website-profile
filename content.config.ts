import { defineContentConfig, defineCollection, z } from '@nuxt/content'

const pageSchema = z.object({
  title: z.string(),
  description: z.string().optional()
})

export default defineContentConfig({
  collections: {
    pages: defineCollection({
      type: 'page',
      source: [
        { include: 'index.md' },
        { include: 'resume.md' },
        { include: 'research/**' }
      ],
      schema: pageSchema
    }),
    blog: defineCollection({
      type: 'page',
      source: 'blog/*.md',
      schema: pageSchema.extend({
        date: z.string().optional(),
        tags: z.array(z.string()).optional(),
        readingTime: z.number().optional()
      })
    }),
    papers: defineCollection({
      type: 'page',
      source: 'papers/*.md',
      schema: pageSchema.extend({
        summary: z.string().optional(),
        year: z.number().optional(),
        venue: z.string().optional(),
        status: z.string().optional(),
        authors: z.string().optional(),
        highlights: z.string().optional(),
        links: z
          .object({
            pdf: z.string().optional(),
            arxiv: z.string().optional(),
            code: z.string().optional(),
            data: z.string().optional()
          })
          .optional()
      })
    }),
    apps: defineCollection({
      type: 'page',
      source: 'apps/*.md',
      schema: pageSchema.extend({
        summary: z.string().optional(),
        date: z.string().optional(),
        status: z.string().optional(),
        stack: z.string().optional(),
        goal: z.string().optional(),
        links: z
          .object({
            demo: z.string().optional(),
            code: z.string().optional()
          })
          .optional()
      })
    })
  }
})
