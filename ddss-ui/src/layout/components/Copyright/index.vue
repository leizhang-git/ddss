<template>
  <footer v-if="visible" class="copyright">
    <span>{{ content }}</span>
  </footer>
</template>

<script>
export default {
  computed: {
    visible() {
      return this.$store.state.settings.footerVisible
    },
    content() {
      return this.$store.state.settings.footerContent
    }
  }
}
</script>

<style scoped>
.copyright {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 36px;
  padding: 10px 20px;
  text-align: right;
  background-color: #f9fafb;
  color: #9ca3af;
  font-size: 12px;
  border-top: 1px solid #f3f4f6;
  z-index: 999;
  letter-spacing: 0.02em;
}
</style>