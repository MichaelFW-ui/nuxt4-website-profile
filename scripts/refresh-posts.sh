#!/usr/bin/env bash
set -euo pipefail

node --input-type=module - "$@" <<'NODE'
import { existsSync, readFileSync, writeFileSync, readdirSync } from 'node:fs'
import { join, extname } from 'node:path'

const mode = process.argv[2] ?? 'refresh'
const args = process.argv.slice(3)

const postsDir = process.env.POSTS_DIR || join(process.cwd(), 'content', 'blog')
const today = new Date().toISOString().slice(0, 10)
const wpm = Number(process.env.WORDS_PER_MINUTE || '200')

const isFrontmatterStart = (line) => line.trim() === '---'

const splitFrontmatter = (text) => {
  const lines = text.split('\n')
  if (!lines.length || !isFrontmatterStart(lines[0])) {
    return { frontmatterLines: [], body: text, hasFrontmatter: false }
  }
  const endIndex = lines.slice(1).findIndex((line) => isFrontmatterStart(line))
  if (endIndex === -1) {
    return { frontmatterLines: [], body: text, hasFrontmatter: false }
  }
  const fmLines = lines.slice(1, endIndex + 1)
  const body = lines.slice(endIndex + 2).join('\n')
  return { frontmatterLines: fmLines, body, hasFrontmatter: true }
}

const countWords = (text) => {
  const latin = text.match(/[A-Za-z0-9]+/g) ?? []
  const cjk = text.match(/[\u4E00-\u9FFF]/g) ?? []
  return latin.length + cjk.length
}

const normalizeLine = (key, value) => {
  if (typeof value === 'number') {
    return `${key}: ${value}`
  }
  return `${key}: "${value}"`
}

const updateFrontmatter = (lines, readingTimeValue) => {
  let hasDate = false
  let hasUpdated = false
  let hasReadingTime = false

  const updatedLines = lines.map((line) => {
    const trimmed = line.trim()
    if (trimmed.startsWith('date:')) {
      hasDate = true
      return line
    }
    if (trimmed.startsWith('updated:')) {
      hasUpdated = true
      return normalizeLine('updated', today)
    }
    if (trimmed.startsWith('readingTime:')) {
      hasReadingTime = true
      return normalizeLine('readingTime', readingTimeValue)
    }
    return line
  })

  if (!hasDate) {
    updatedLines.push(normalizeLine('date', today))
  }
  if (!hasUpdated) {
    updatedLines.push(normalizeLine('updated', today))
  }
  if (!hasReadingTime) {
    updatedLines.push(normalizeLine('readingTime', readingTimeValue))
  }

  return updatedLines
}

const refreshFile = (filePath) => {
  const raw = readFileSync(filePath, 'utf8')
  const { frontmatterLines, body, hasFrontmatter } = splitFrontmatter(raw)
  const words = countWords(body)
  const readingTimeValue = Math.max(1, Math.ceil(words / wpm))
  const newFrontmatter = updateFrontmatter(frontmatterLines, readingTimeValue)

  const output = [
    '---',
    ...newFrontmatter,
    '---',
    body.replace(/^\n/, '')
  ].join('\n')

  writeFileSync(filePath, output)
}

const slugify = (input) => {
  const slug = input
    .toLowerCase()
    .replace(/['"]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
  if (slug) {
    return slug
  }
  const stamp = new Date().toISOString().replace(/[-:TZ.]/g, '').slice(0, 14)
  return `post-${stamp}`
}

const createPost = (title) => {
  if (!existsSync(postsDir)) {
    throw new Error(`Missing posts directory: ${postsDir}`)
  }
  const baseSlug = slugify(title)
  let slug = baseSlug
  let index = 2
  while (existsSync(join(postsDir, `${slug}.md`))) {
    slug = `${baseSlug}-${index}`
    index += 1
  }
  const filePath = join(postsDir, `${slug}.md`)
  const content = [
    '---',
    normalizeLine('title', title),
    'description: ""',
    normalizeLine('date', today),
    normalizeLine('updated', today),
    'tags: []',
    normalizeLine('readingTime', 1),
    '---',
    '',
    ''
  ].join('\n')
  writeFileSync(filePath, content)
  return filePath
}

const isMarkdown = (fileName) => extname(fileName).toLowerCase() === '.md'

const refreshAll = () => {
  if (!existsSync(postsDir)) {
    throw new Error(`Missing posts directory: ${postsDir}`)
  }
  const files = readdirSync(postsDir)
    .filter(isMarkdown)
    .map((file) => join(postsDir, file))

  if (!files.length) {
    return
  }

  for (const file of files) {
    refreshFile(file)
  }
}

try {
  if (mode === 'new') {
    const title = args.join(' ').trim()
    if (!title) {
      console.error('Usage: refresh-posts.sh new "Post Title"')
      process.exit(1)
    }
    const filePath = createPost(title)
    refreshFile(filePath)
    console.log(`Created ${filePath}`)
  } else {
    refreshAll()
  }
} catch (error) {
  console.error(error?.message ?? String(error))
  process.exit(1)
}
NODE
