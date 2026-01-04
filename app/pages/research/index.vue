<script setup lang="ts">
const { data: doc } = await useAsyncData(() =>
  queryCollection('pages').path('/research').first()
)
</script>

<template>
  <SectionHero v-if="doc" :title="doc.title" :subtitle="doc.description" kicker="Research" />
  <section v-if="doc" class="section">
    <div class="container">
      <div class="prose">
        <ContentRenderer :value="doc" />
      </div>
    </div>
  </section>
  <SectionHero v-else title="Research page missing" subtitle="Add content/research/index.md to populate this page." kicker="Research" />
</template>
