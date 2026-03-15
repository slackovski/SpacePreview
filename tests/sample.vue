<template>
  <div class="container">
    <h1>{{ title }}</h1>
    <ul>
      <li v-for="item in items" :key="item.id">{{ item.name }}</li>
    </ul>
    <button @click="loadMore">加载更多</button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";

const title = ref("用户列表");
const items = ref<{ id: number; name: string }[]>([]);

async function loadMore() {
  const res = await fetch("/api/users");
  items.value = await res.json();
}

onMounted(loadMore);
</script>

<style scoped>
.container { max-width: 600px; margin: 0 auto; }
button { padding: 8px 16px; background: #007aff; color: #fff; border: none; border-radius: 6px; }
</style>
