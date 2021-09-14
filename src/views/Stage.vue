<template>
  <div>
    <div class="state-box">
      <div v-for="(item,index) in stage.state"
           class="state-item"
           :class="{'playing': currStateIndex===index}"
      >
        {{ item.title }}

        <span>
          {{ item.music_file }} / {{ item.volume }} %
        </span>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: 'Stage',
  props: {
    msg: String,
  },
  data() {
    return {
      stage: {
        state: []
      },
      currStateIndex: 0,
    }
  },
  methods: {
    movePrev() {
      if (this.currStateIndex <= 0) {
        return
      }

      this.playState(this.currStateIndex - 1)
    },
    moveNext() {
      if (this.currStateIndex >= this.stage.state.length - 1) {
        return
      }
      this.playState(this.currStateIndex + 1)

    },
    playState(index) {
      let nowState = this.stage.state[this.currStateIndex]


          this.currStateIndex = index

    }
  },
  async mounted() {
    let stage = await fetch('demo-stage.json')
    stage = await stage.json()
    this.stage = stage

    // 监听 key 事件

    document.onkeydown = (e) => {
      let key = e.code;
      console.log('xxx', e.code)
      if (key === 'ArrowRight') {
        this.moveNext()
      } else if (key === 'ArrowLeft') {
        this.movePrev()
      }
    }
  }
}
</script>


<style lang="scss"
       scoped>
.state-box {
  display: flex;

  .state-item {
    width: 150px;
    box-shadow: 0 15px 35px rgba(50, 50, 93, .07), 0 5px 15px rgba(0, 0, 0, .07);
    background: #fff;
    padding: 15px;

    &.playing {
      background: #adee78;
    }
  }
}
</style>
