<template>
  <div class="playing-line" :class="{'playing': playing}">
    <span class="left"></span>
    <span class="line1"></span>
    <span class="line2"></span>
    <span class="line3"></span>
    <span class="right"></span>
  </div>
</template>

<script>
export default {
  name: 'PlayingLine',
  props: {
    playing: false,
  }
}
</script>

<style scoped lang="scss">
.playing-line {
  display: flex;
  height: 1px;
  align-items: center;

  > span {
    border-top: #2c3e50 1px solid;
    flex: auto;
  }

  .line1, .line2, .line3 {
    max-width: 8px;
    transform: translate3d(1, 1, 0);
    margin: 0;
    transition: max-width 0.6s ease, margin 0.6s ease;
  }

  &.playing {
    .line1, {
      max-width: 1px;
      margin: 0 0 0 6px;
      animation: 1.4s 0.5s  b infinite;
    }

    .line2, {
      max-width: 1px;
      margin: 0 4px;
      animation: 1.4s 0.75s  b infinite;
    }

    .line3 {
      max-width: 1px;
      margin: 0 6px 0 0;
      animation: 1.4s 1s  b infinite;
    }
  }
}


@keyframes b {
  0%, 100% {
    border-top-width: 1px;
  }

  50% {
    border-top-width: 11px;
  }
}
</style>
