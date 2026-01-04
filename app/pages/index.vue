<script setup lang="ts">
const { data: latestPosts } = await useAsyncData(() =>
  queryCollection('blog').order('date', 'DESC').limit(3).all()
)

const { data: recentPapers } = await useAsyncData(() =>
  queryCollection('papers').order('year', 'DESC').limit(3).all()
)

const { data: featuredApps } = await useAsyncData(() =>
  queryCollection('apps').order('date', 'DESC').limit(3).all()
)

const { data: homeDoc } = await useAsyncData(() =>
  queryCollection('pages').path('/').first()
)
</script>

<template>
  <SectionHero
    :title="homeDoc?.title || 'Your Name'"
    :subtitle="homeDoc?.description || 'A research-forward hub for writing, publications, and web experiments.'"
    kicker="Research Hub"
  >
    <div class="action-row">
      <UButton to="/blog" color="primary">Read the blog</UButton>
      <UButton to="/papers" variant="outline">Browse papers</UButton>
    </div>
  </SectionHero>

  <section v-if="homeDoc" class="section">
    <div class="container">
      <div class="prose">
        <ContentRenderer :value="homeDoc" />
      </div>
    </div>
  </section>

  <SectionHero title="Latest writing" subtitle="Notes, experiments, and project write-ups." />
  <ContentGrid :items="latestPosts" type="blog" empty-title="No blog posts yet" />

  <SectionHero title="Research outputs" subtitle="Public releases and paper homepages." />
  <ContentGrid :items="recentPapers" type="paper" empty-title="No papers yet" />

  <SectionHero title="Personal apps" subtitle="Interactive demos and web experiments." />
  <ContentGrid :items="featuredApps" type="app" empty-title="No apps yet" />
</template>
