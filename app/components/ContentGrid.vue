<script setup lang="ts">
const props = withDefaults(defineProps<{
  items?: Array<any> | null
  type: 'blog' | 'paper' | 'app'
  emptyTitle?: string
  emptyText?: string
  columns?: 2 | 3
}>(), {
  items: () => [],
  columns: 2
})

const formatDate = (value?: string) => {
  if (!value) return ''
  return new Date(value).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const blogPublished = (item: any) => formatDate(item?.date)
const blogUpdated = (item: any) => formatDate(item?.updated)

const metaLabel = (item: any) => {
  if (props.type === 'paper') return item.venue || item.year
  return item.status || item.stack
}

const gridClass = computed(() => (props.columns === 3 ? 'grid-3' : 'grid-2'))
</script>

<template>
  <section class="section">
    <div class="container">
      <div v-if="items?.length" class="grid" :class="gridClass">
        <article v-for="item in items" :key="item.path || item._path" class="card">
          <div class="card-meta">
            <template v-if="type === 'blog'">
              <span v-if="item.date">Published {{ blogPublished(item) }}</span>
              <span v-if="item.updated">Updated {{ blogUpdated(item) }}</span>
              <span v-if="item.readingTime">{{ item.readingTime }} min read</span>
            </template>
            <template v-else>
              <span v-if="metaLabel(item)">{{ metaLabel(item) }}</span>
              <span v-if="item.year" class="badge">{{ item.year }}</span>
              <span v-if="item.status" class="badge">{{ item.status }}</span>
            </template>
          </div>
          <div>
            <h3>{{ item.title }}</h3>
            <p>{{ item.description || item.summary }}</p>
          </div>
          <div class="card-meta" v-if="item.tags?.length">
            <span v-for="tag in item.tags" :key="tag" class="badge">{{ tag }}</span>
          </div>
          <div class="action-row">
            <UButton :to="item.path || item._path" color="primary" variant="solid">Open</UButton>
            <UButton v-if="item.links?.demo" :to="item.links.demo" target="_blank" variant="outline">
              Demo
            </UButton>
            <UButton v-if="item.links?.pdf" :to="item.links.pdf" target="_blank" variant="outline">
              PDF
            </UButton>
          </div>
        </article>
      </div>
      <div v-else class="card">
        <h3>{{ emptyTitle || 'No content yet' }}</h3>
        <p>{{ emptyText || 'Add markdown files under the matching content folder to populate this section.' }}</p>
      </div>
    </div>
  </section>
</template>
