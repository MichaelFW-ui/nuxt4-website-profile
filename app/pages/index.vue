<script setup lang="ts">
const {
  data: latestPosts,
  pending: latestPostsPending,
  refresh: refreshLatestPosts
} = await useAsyncData('latest-posts', () =>
  queryCollection('blog').order('date', 'DESC').limit(3).all()
)

const {
  data: recentPapers,
  pending: recentPapersPending,
  refresh: refreshRecentPapers
} = await useAsyncData('recent-papers', () =>
  queryCollection('papers').order('year', 'DESC').limit(3).all()
)

const {
  data: featuredApps,
  pending: featuredAppsPending,
  refresh: refreshFeaturedApps
} = await useAsyncData('featured-apps', () =>
  queryCollection('apps').order('date', 'DESC').limit(3).all()
)

const {
  data: homeDoc,
  pending: homeDocPending,
  refresh: refreshHomeDoc
} = await useAsyncData('home-doc', () =>
  queryCollection('pages').path('/').first()
)

onMounted(() => {
  void refreshLatestPosts()
  void refreshRecentPapers()
  void refreshFeaturedApps()
  void refreshHomeDoc()
})
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
  <section v-else-if="homeDocPending" class="section">
    <div class="container">
      <p class="loading-hint">Loading intro...</p>
    </div>
  </section>

  <SectionHero title="Latest writing" subtitle="Notes, experiments, and project write-ups." />
  <section v-if="latestPostsPending && !latestPosts?.length" class="section">
    <div class="container">
      <p class="loading-hint">Loading latest writing...</p>
    </div>
  </section>
  <ContentGrid v-else :items="latestPosts" type="blog" :columns="3" empty-title="No blog posts yet" />

  <SectionHero title="Research outputs" subtitle="Public releases and paper homepages." />
  <section v-if="recentPapersPending && !recentPapers?.length" class="section">
    <div class="container">
      <p class="loading-hint">Loading research outputs...</p>
    </div>
  </section>
  <ContentGrid v-else :items="recentPapers" type="paper" :columns="3" empty-title="No papers yet" />

  <SectionHero title="Personal apps" subtitle="Interactive demos and web experiments." />
  <section v-if="featuredAppsPending && !featuredApps?.length" class="section">
    <div class="container">
      <p class="loading-hint">Loading personal apps...</p>
    </div>
  </section>
  <ContentGrid v-else :items="featuredApps" type="app" :columns="3" empty-title="No apps yet" />
</template>
