<script setup lang="ts">
defineProps<{
  title: string
  subtitle?: string
  kicker?: string
}>()
</script>

<template>
  <section class="hero">
    <div class="container">
      <p v-if="kicker" class="kicker">{{ kicker }}</p>
      <h1 class="hero-title">{{ title }}</h1>
      <p v-if="subtitle" class="hero-subtitle">{{ subtitle }}</p>
      <slot />
    </div>
  </section>
</template>
