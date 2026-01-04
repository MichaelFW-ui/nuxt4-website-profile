<script setup lang="ts">
const nav = [
  { label: 'Home', to: '/' },
  { label: 'Blog', to: '/blog' },
  { label: 'Research', to: '/research' },
  { label: 'Papers', to: '/papers' },
  { label: 'Resume', to: '/resume' },
  { label: 'Apps', to: '/apps' }
]
</script>

<template>
  <header class="navbar">
    <div class="container navbar-inner">
      <NuxtLink to="/" class="nav-chip">Nuxt Research Hub</NuxtLink>
      <nav class="nav-links">
        <NuxtLink v-for="item in nav" :key="item.to" :to="item.to" class="nav-chip">
          {{ item.label }}
        </NuxtLink>
      </nav>
    </div>
  </header>
</template>
