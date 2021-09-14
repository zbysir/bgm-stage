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
      currStateIndex: -1,
      audioDom: null,
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
    // todo 取消掉上一次 transform
    transform(aStage, bStage, duration) {
      return new Promise(resolve => {
        let from = aStage.volume
        let to = bStage.volume

        let step = Math.abs(to - from) / 5 + 1
        let x = to > from ? 1 : -1
        let stepTime = duration / step

        console.log('step', step, stepTime)

        let index = 1

        let upVolume = () => {
          let want = from + (index) * 5 * x
          if (x === 1) {
            if (want >= to) {
              want = to
            }

          } else {
            if (want <= to) {
              want = to
            }

          }
          this.audioDom.volume = want / 100
          console.log('up', want)
          index += 1
          if (index >= step) {
            resolve()
            return
          }
          setTimeout(upVolume, stepTime)
        }

        setTimeout(upVolume, stepTime)
      })
    },
    async playState(index) {
      let nowState = this.stage.state[this.currStateIndex] || {}
      let wantState = this.stage.state[index]
      this.currStateIndex = index
      console.log('nowState', nowState, wantState)

      if (nowState.music_file === wantState.music_file) {
        if (nowState.volume === wantState.volume) {
          return
        }

        // 调整音量
        // this.audioDom.volume = wantState.volume / 100

        await this.transform(nowState, wantState, 800)
        console.log("down")
      } else {
        this.audioDom.src = wantState.music_file
        this.audioDom.play()
        this.audioDom.volume = wantState.volume / 100
      }


    }
  },
  async mounted() {
    this.audioDom = new Audio("");

    let stage = await fetch('demo-stage.json')
    stage = await stage.json()
    this.stage = stage

    this.playState(0)

    // 监听 key 事件

    document.onkeydown = (e) => {
      let key = e.code;
      console.log('keydown', e.code)
      if (key === 'ArrowRight') {
        this.moveNext()
      } else if (key === 'ArrowLeft') {
        this.movePrev()
      }
    }
  },
  beforeDestroy() {
    if (this.audioDom){
      this.audioDom.currentTime = 0
      this.audioDom.pause()
      delete this.audioDom
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
