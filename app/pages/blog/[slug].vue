<script setup lang="ts">
const route = useRoute()
const slug = computed(() => String(route.params.slug || ''))
const path = computed(() => `/blog/${slug.value}`)
const { data: doc } = await useAsyncData(
  () => queryCollection('blog').path(path.value).first(),
  { watch: [path] }
)
const formatDate = (value?: string) => {
  if (!value) return ''
  return new Date(value).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>

<template>
  <SectionHero v-if="doc" :title="doc.title" :subtitle="doc.description" kicker="Blog" />
  <section v-if="doc" class="section">
    <div class="container">
      <article class="prose">
        <div class="card-meta">
          <span v-if="doc.date">{{ formatDate(doc.date) }}</span>
          <span v-if="doc.readingTime">{{ doc.readingTime }} min read</span>
        </div>
        <ContentRenderer :value="doc" />
      </article>
    </div>
  </section>
  <SectionHero v-else title="Post not found" subtitle="The requested article could not be loaded." kicker="Blog" />
</template>
