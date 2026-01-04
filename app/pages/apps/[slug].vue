<script setup lang="ts">
const route = useRoute()
const slug = computed(() => String(route.params.slug || ''))
const path = computed(() => `/apps/${slug.value}`)
const { data: doc } = await useAsyncData(
  () => queryCollection('apps').path(path.value).first(),
  { watch: [path] }
)
</script>

<template>
  <SectionHero v-if="doc" :title="doc.title" :subtitle="doc.summary || doc.description" kicker="App" />
  <section v-if="doc" class="section">
    <div class="container">
      <div class="grid grid-3">
        <div class="card">
          <h3>Status</h3>
          <p>{{ doc.status || 'Prototype' }}</p>
          <div class="card-meta">
            <span v-if="doc.stack" class="badge">{{ doc.stack }}</span>
          </div>
        </div>
        <div class="card">
          <h3>Links</h3>
          <div class="action-row">
            <UButton v-if="doc.links?.demo" :to="doc.links.demo" target="_blank" variant="solid">Launch</UButton>
            <UButton v-if="doc.links?.code" :to="doc.links.code" target="_blank" variant="outline">Source</UButton>
          </div>
        </div>
        <div class="card">
          <h3>Goal</h3>
          <p>{{ doc.goal || 'Describe what you wanted to explore with this app.' }}</p>
        </div>
      </div>
      <article class="prose">
        <ContentRenderer :value="doc" />
      </article>
    </div>
  </section>
  <SectionHero v-else title="App not found" subtitle="The requested app page could not be loaded." kicker="App" />
</template>
