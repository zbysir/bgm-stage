<template>
  <div class="stage-page">
    <div class="status">
      <span v-if="playStatus==='play'"> 正在播放 </span>
      <span v-else> 暂停中 </span>
    </div>

    <div class="tips">
      [←] 播放上一个阶段，[→] 播放下一个阶段，[空格] 播放、暂停。
    </div>

    <div class="state-box">
      <div
          v-for="(item,index) in stage.state"
          class="state-item"
          @click="onItemClick(index)"
          :class="{'playing': currStateIndex===index}"
      >
        <div class="title">
          {{ item.title }}
          <small>
            {{ item.volume }} %
          </small>
        </div>

        <div
            v-if="item.description"
            class="desc">
          {{ item.description }}
        </div>

        <div
            v-if="item.music_file"
            class="name">
          {{ getFileName(item.music_file) }}
        </div>
      </div>
    </div>

    <div class="btns">
      <button @click="onEditClick"> Edit</button>
      <button v-if="showSaveBtn"
              @click="onEditorSave"> Save
      </button>
    </div>

    <div v-if="showEditor">
      <textarea
          class="editor-input"
          v-model="stageText"
          @input="onEditorChange"
          @keydown.stop
      />
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

function AudioX(file, volume) {
  let moveIt = MoveIt(volume)
  let audioDom = new Audio(file)
  audioDom.volume = volume

  return {
    play() {
      audioDom.play()
    },
    pause() {
      audioDom.pause()
    },
    getPaused() {
      return audioDom.paused
    },
    setVolume(v, cb) {
      moveIt.to(v, 800, (p) => {
        audioDom.volume = p / 100
        if (p === v) {
          cb && cb()
        }
      })
    },
    stop() {
      this.setVolume(0, () => {
        audioDom.pause()
      })
    },
    setLoop(loop) {
      audioDom.loop = loop
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
      showEditor: false,
      showSaveBtn: false,
      stageText: "",
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
    play() {
      if (this.currStateIndex < 0) {
        this.playState(0)
        return
      }

      this.audioDom.play()
      this.playStatus = 'play'
    },
    pause() {
      this.audioDom.pause()
      this.playStatus = 'pause'
    },
    async playState(index) {
      let nowState = this.stage.state[this.currStateIndex] || {}
      let wantState = this.stage.state[index]
      this.currStateIndex = index

      // 调整音量
      if (nowState.music_file === wantState.music_file) {
        if (nowState.volume === wantState.volume) {
          return
        }
        this.audioDom.setVolume(wantState.volume)
      } else {
        // 是否在播放，如果在播放则先减为 0
        if (nowState.music_file) {
          this.audioDom.stop()

          if (wantState.music_file) {
            this.audioDom = AudioX(wantState.music_file, 0)
            this.audioDom.play()
            this.audioDom.setVolume(wantState.volume)
          }
        } else {
          // 如果没有播放，则直接从音量 0 开始播放
          if (wantState.music_file) {
            this.audioDom = AudioX(wantState.music_file, 0)
            this.audioDom.play()
            this.audioDom.setVolume(wantState.volume)
          }
        }
      }

      this.play()
      this.audioDom.setLoop(wantState.loop)
    },
    onEditorChange() {
      this.showSaveBtn = true
    },
    onEditClick() {
      this.stageText = JSON.stringify(this.stage, null, 4)

      this.showEditor = !this.showEditor

      this.showSaveBtn = false
    },
    onEditorSave() {
      try {
        this.stage = JSON.parse(this.stageText)
        console.log('stage', this.stage)
      } catch (e) {
        alert(e.toString())
      }
    },
    onItemClick(index){
      // 点击播放
      if (index!==this.currStateIndex){
        this.playState(index)
        return
      }

      // 播放与暂停
      if (this.audioDom.getPaused()) {
        this.play()
      } else {
        this.pause()
      }
    },
    getFileName(url) {
      let l = url.lastIndexOf('/')
      if (l === -1) {
        return url
      }
      return url.substr(l + 1)
    }
  },
  async mounted() {
    let stage = await fetch('demo-stage.json')
    stage = await stage.json()
    this.stage = stage


    // 监听 key 事件
    document.onkeydown = (e) => {
      e.preventDefault()

      let key = e.code;
      console.log('keydown', e.code)
      if (key === 'ArrowRight') {
        this.moveNext()
      } else if (key === 'ArrowLeft') {
        this.movePrev()
      } else if (key === 'Space') {
        if (!this.audioDom) {
          this.play()
          return
        }

        if (this.audioDom.getPaused()) {
          this.play()
        } else {
          this.pause()
        }
      }
    }
  },
  beforeDestroy() {
    if (this.audioDom){
      this.audioDom.stop()
      delete this.audioDom
    }
  }
}
</script>

<style lang="scss"
       scoped>

.stage-page {
  padding: 30px 10px 10px 10px;
}

.status {
  font-size: 18px;
  margin-bottom: 15px;
}

.tips {
  font-size: 12px;
  margin-bottom: 15px;
}

.state-box {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;

  .state-item {
    width: 150px;
    box-shadow: 0 15px 35px rgba(50, 50, 93, .07), 0 5px 15px rgba(0, 0, 0, .07);
    background: #fff;
    padding: 15px;
    margin: 10px;
    transition: all 600ms;

    &.playing {
      background: #adee78;
    }

    .title {
      font-size: 18px;
      margin-bottom: 5px;
    }

    .desc {
      font-size: 14px;
      margin-bottom: 5px;
    }

    .name {
      font-size: 12px;
      margin-top: 10px;
      padding-top: 10px;

      border-top: #2c3e50 1px solid;
    }
  }
}

.editor-input {
  width: 100%;
  max-width: 700px;
  min-height: 500px;
}

.btns {
  margin-bottom: 10px;
  margin-top: 15px;
}
</style>
