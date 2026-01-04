<script setup lang="ts">
const route = useRoute()
const slug = computed(() => String(route.params.slug || ''))
const path = computed(() => `/papers/${slug.value}`)
const { data: doc } = await useAsyncData(
  () => queryCollection('papers').path(path.value).first(),
  { watch: [path] }
)
</script>

<template>
  <SectionHero v-if="doc" :title="doc.title" :subtitle="doc.summary || doc.description" kicker="Paper Homepage" />
  <section v-if="doc" class="section">
    <div class="container">
      <div class="grid grid-3">
        <div class="card">
          <h3>Metadata</h3>
          <div class="card-meta">
            <span v-if="doc.venue">{{ doc.venue }}</span>
            <span v-if="doc.year" class="badge">{{ doc.year }}</span>
            <span v-if="doc.status" class="badge">{{ doc.status }}</span>
          </div>
          <p v-if="doc.authors">{{ doc.authors }}</p>
        </div>
        <div class="card">
          <h3>Links</h3>
          <div class="action-row">
            <UButton v-if="doc.links?.pdf" :to="doc.links.pdf" target="_blank" variant="solid">PDF</UButton>
            <UButton v-if="doc.links?.arxiv" :to="doc.links.arxiv" target="_blank" variant="outline">arXiv</UButton>
            <UButton v-if="doc.links?.code" :to="doc.links.code" target="_blank" variant="outline">Code</UButton>
            <UButton v-if="doc.links?.data" :to="doc.links.data" target="_blank" variant="outline">Dataset</UButton>
          </div>
        </div>
        <div class="card">
          <h3>Highlights</h3>
          <p>{{ doc.highlights || 'Summarize the contribution, methods, and findings.' }}</p>
        </div>
      </div>
      <article class="prose">
        <ContentRenderer :value="doc" />
      </article>
    </div>
  </section>
  <SectionHero v-else title="Paper not found" subtitle="The requested paper page could not be loaded." kicker="Paper Homepage" />
</template>
