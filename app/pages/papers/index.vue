<script setup lang="ts">
const { data: papers } = await useAsyncData(() =>
  queryCollection('papers').order('year', 'DESC').all()
)
</script>

<template>
  <SectionHero
    title="Papers"
    subtitle="Public releases with companion homepages, links, and datasets."
    kicker="Publications"
  />
  <ContentGrid :items="papers" type="paper" />
</template>
