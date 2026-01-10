<script setup lang="ts">
const { data: posts } = await useAsyncData(() =>
  queryCollection('blog').order('date', 'DESC').all()
)

const search = ref('')
const selectedTag = ref('all')

const tagList = computed(() => {
  const set = new Set<string>()
  for (const post of posts.value || []) {
    if (Array.isArray(post.tags)) {
      for (const tag of post.tags) {
        set.add(tag)
      }
    }
  }
  return ['all', ...Array.from(set).sort((a, b) => a.localeCompare(b))]
})

const filteredPosts = computed(() => {
  const list = posts.value || []
  const term = search.value.trim().toLowerCase()

  return list.filter((post) => {
    const tags = Array.isArray(post.tags) ? post.tags : []
    const matchesTag = selectedTag.value === 'all' || tags.includes(selectedTag.value)
    if (!matchesTag) return false
    if (!term) return true

    const haystack = [post.title, post.description, post.summary, ...tags]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    return haystack.includes(term)
  })
})
</script>

<template>
  <SectionHero
    title="Blog"
    subtitle="Field notes, technical essays, and reflections on research in progress."
    kicker="Writing"
  />
  <section class="section section-tight">
    <div class="container">
      <div class="card filter-card">
        <div class="filter-bar">
          <div class="search-shell">
            <UIcon name="i-heroicons-magnifying-glass" class="search-icon" />
            <UInput
              v-model="search"
              class="search-input"
              placeholder="Search posts by title, summary, or tag"
              size="lg"
              variant="none"
              autocomplete="off"
              :ui="{
                base: 'search-field'
              }"
            />
          </div>
          <div class="filter-controls">
            <UButton
              v-for="tag in tagList"
              :key="tag"
              :variant="selectedTag === tag ? 'solid' : 'outline'"
              size="xs"
              class="tag-chip"
              @click="selectedTag = tag"
            >
              {{ tag === 'all' ? 'All' : tag }}
            </UButton>
          </div>
          <p class="card-meta">Showing {{ filteredPosts?.length || 0 }} posts</p>
        </div>
      </div>
      <p class="page-hint">Tip: use search or tags to narrow the list.</p>
    </div>
  </section>
  <ContentGrid :items="filteredPosts" type="blog" />
</template>
