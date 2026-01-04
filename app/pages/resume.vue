<script setup lang="ts">
const { data: doc } = await useAsyncData(() =>
  queryCollection('pages').path('/resume').first()
)
</script>

<template>
  <SectionHero v-if="doc" :title="doc.title" :subtitle="doc.description" kicker="Resume" />
  <section v-if="doc" class="section">
    <div class="container">
      <div class="prose">
        <ContentRenderer :value="doc" />
      </div>
    </div>
  </section>
  <SectionHero v-else title="Resume missing" subtitle="Add content/resume.md to render this page." kicker="Resume" />
</template>
