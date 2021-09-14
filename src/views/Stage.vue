<template>
  <div>
    <div class="status">
      <span v-if="playStatus==='play'"> 正在播放 </span>
      <span v-else> 暂停中 </span>
    </div>

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

function MoveIt(base) {
  let t
  return {
    base,
    setBase(base) {
      this.base = base
      return this
    },
    to(to, duration, callback) {
      if (t) {
        clearTimeout(t)
      }

      let from = base

      let step = Math.abs(to - from) / 5 + 1
      let x = to > from ? 1 : -1
      let stepTime = duration / step

      let index = 1
      let update = () => {
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
        base = want
        callback(want)

        index += 1
        if (index >= step) {
          return
        }
        t = setTimeout(update, stepTime)
      }

      t = setTimeout(update, stepTime)
    }
  }
}

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
      playStatus: 'pause',
      currStateIndex: -1,
      audioDom: null,
      moveIt: MoveIt(0),
    }
  },
  methods: {
    movePrev() {
      if (this.currStateIndex <= 0) {
        return
      }

      this.playState(this.currStateIndex - 1)
    },
    pause(p) {
      if (this.currStateIndex < 0) {
        this.playState(0)
        return
      }
      if (p !== undefined) {
        if (p) {
          this.audioDom.play()
          this.playStatus = 'play'
        } else {
          this.audioDom.pause()
          this.playStatus = 'pause'
        }

        return;
      }

      if (this.audioDom.paused) {
        this.audioDom.play()
        this.playStatus = 'play'
      } else {
        this.audioDom.pause()
        this.playStatus = 'pause'
      }

    },
    moveNext() {
      if (this.currStateIndex >= this.stage.state.length - 1) {
        return
      }
      this.playState(this.currStateIndex + 1)
    },
    async playState(index) {
      let nowState = this.stage.state[this.currStateIndex] || {}
      let wantState = this.stage.state[index]
      this.currStateIndex = index
      console.log('nowState', nowState, wantState)

      this.audioDom.loop = wantState.loop

      // 调整音量
      if (nowState.music_file === wantState.music_file) {
        if (nowState.volume === wantState.volume) {
          return
        }

        this.moveIt.to(wantState.volume, 800, (p) => {
              console.log('to', p)
              this.audioDom.volume = p / 100
            }
        )
      } else {
        // 是否在播放，如果在播放则先减为 0
        if (nowState.music_file) {
          this.moveIt.to(0, 400, (p) => {
                console.log('to', p)
                this.audioDom.volume = p / 100
              }
          )

          await new Promise(resolve => {
            setTimeout(resolve, 400)
          })
        }

        this.audioDom.volume = 0
        this.audioDom.src = wantState.music_file

        this.audioDom.play()
        this.moveIt.to(wantState.volume, 400, (p) => {
              console.log('to', p)
              this.audioDom.volume = p / 100
            }
        )
      }
    }
  },
  async mounted() {
    this.audioDom = new Audio("");

    let stage = await fetch('demo-stage.json')
    stage = await stage.json()
    this.stage = stage

    // this.playState(0)

    // 监听 key 事件

    document.onkeydown = (e) => {
      let key = e.code;
      console.log('keydown', e.code)
      if (key === 'ArrowRight') {
        this.moveNext()
      } else if (key === 'ArrowLeft') {
        this.movePrev()
      } else if (key === 'Space') {
        this.pause()
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
