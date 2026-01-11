<script setup lang="ts">
import { computed, useAttrs } from 'vue'

defineOptions({ inheritAttrs: false })

const props = defineProps<{
  src: string
  alt?: string
}>()

const attrs = useAttrs()
const imgAttrs = computed(() => {
  const { loading, ...rest } = attrs
  return rest
})
const loadingAttr = computed(() => (attrs.loading as string | undefined) ?? 'lazy')
</script>

<template>
  <img
    :src="props.src"
    :alt="props.alt || ''"
    :loading="loadingAttr"
    class="content-img"
    v-bind="imgAttrs"
  />
</template>
