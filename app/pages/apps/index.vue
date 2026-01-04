<script setup lang="ts">
const { data: apps } = await useAsyncData(() =>
  queryCollection('apps').order('date', 'DESC').all()
)
</script>

<template>
  <SectionHero
    title="Apps"
    subtitle="Personal web applications, playable demos, and tiny experiments."
    kicker="Experiments"
  />
  <ContentGrid :items="apps" type="app" />
</template>
