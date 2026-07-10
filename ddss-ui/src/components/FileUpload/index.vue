<template>
  <div class="upload-file">
    <el-upload
      v-if="!disabled"
      ref="fileUpload"
      :action="uploadFileUrl"
      :before-upload="handleBeforeUpload"
      :data="data"
      :file-list="fileList"
      :headers="headers"
      :limit="limit"
      :on-error="handleUploadError"
      :on-exceed="handleExceed"
      :on-success="handleUploadSuccess"
      :show-file-list="false"
      class="upload-file-uploader"
      multiple
    >
      <!-- 涓婁紶鎸夐挳 -->
      <el-button size="mini" type="primary">閫夊彇鏂囦欢</el-button>
      <!-- 涓婁紶鎻愮ず -->
      <div v-if="showTip" slot="tip" class="el-upload__tip">
        璇蜂笂浼?
        <template v-if="fileSize"> 澶у皬涓嶈秴杩?<b style="color: #ff3b30">{{ fileSize }}MB</b></template>
        <template v-if="fileType"> 鏍煎紡涓?<b style="color: #ff3b30">{{ fileType.join("/") }}</b></template>
        鐨勬枃浠?
      </div>
    </el-upload>

    <!-- 鏂囦欢鍒楄〃 -->
    <transition-group ref="uploadFileList" class="upload-file-list el-upload-list el-upload-list--text"
                      name="el-fade-in-linear" tag="ul">
      <li v-for="(file, index) in fileList" :key="file.url" class="el-upload-list__item ele-upload-list__item-content">
        <el-link :href="`${baseUrl}${file.url}`" :underline="false" target="_blank">
          <span class="el-icon-document"> {{ getFileName(file.name) }} </span>
        </el-link>
        <div class="ele-upload-list__item-content-action">
          <el-link v-if="!disabled" :underline="false" type="danger" @click="handleDelete(index)">鍒犻櫎</el-link>
        </div>
      </li>
    </transition-group>
  </div>
</template>

<script>
import {getToken} from "@/utils/auth"
import Sortable from 'sortablejs'

export default {
  name: "FileUpload",
  props: {
    // 鍊?
    value: [String, Object, Array],
    // 涓婁紶鎺ュ彛鍦板潃
    action: {
      type: String,
      default: "/common/upload"
    },
    // 涓婁紶鎼哄甫鐨勫弬鏁?
    data: {
      type: Object
    },
    // 鏁伴噺闄愬埗
    limit: {
      type: Number,
      default: 5
    },
    // 澶у皬闄愬埗(MB)
    fileSize: {
      type: Number,
      default: 5
    },
    // 鏂囦欢绫诲瀷, 渚嬪['png', 'jpg', 'jpeg']
    fileType: {
      type: Array,
      default: () => ["doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "pdf"]
    },
    // 鏄惁鏄剧ず鎻愮ず
    isShowTip: {
      type: Boolean,
      default: true
    },
    // 绂佺敤缁勪欢锛堜粎鏌ョ湅鏂囦欢锛?
    disabled: {
      type: Boolean,
      default: false
    },
    // 鎷栧姩鎺掑簭
    drag: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      number: 0,
      uploadList: [],
      baseUrl: process.env.VUE_APP_BASE_API,
      uploadFileUrl: process.env.VUE_APP_BASE_API + this.action, // 涓婁紶鏂囦欢鏈嶅姟鍣ㄥ湴鍧€
      headers: {
        Authorization: "Bearer " + getToken(),
      },
      fileList: []
    }
  },
  mounted() {
    if (this.drag && !this.disabled) {
      this.$nextTick(() => {
        const element = this.$refs.uploadFileList?.$el || this.$refs.uploadFileList
        Sortable.create(element, {
          ghostClass: 'file-upload-darg',
          onEnd: (evt) => {
            const movedItem = this.fileList.splice(evt.oldIndex, 1)[0]
            this.fileList.splice(evt.newIndex, 0, movedItem)
            this.$emit("input", this.listToString(this.fileList))
          }
        })
      })
    }
  },
  watch: {
    value: {
      handler(val) {
        if (val) {
          let temp = 1
          // 棣栧厛灏嗗€艰浆涓烘暟缁?
          const list = Array.isArray(val) ? val : this.value.split(',')
          // 鐒跺悗灏嗘暟缁勮浆涓哄璞℃暟缁?
          this.fileList = list.map(item => {
            if (typeof item === "string") {
              item = {name: item, url: item}
            }
            item.uid = item.uid || new Date().getTime() + temp++
            return item
          })
        } else {
          this.fileList = []
          return []
        }
      },
      deep: true,
      immediate: true
    }
  },
  computed: {
    // 鏄惁鏄剧ず鎻愮ず
    showTip() {
      return this.isShowTip && (this.fileType || this.fileSize)
    },
  },
  methods: {
    // 涓婁紶鍓嶆牎妫€鏍煎紡鍜屽ぇ灏?
    handleBeforeUpload(file) {
      // 鏍℃鏂囦欢绫诲瀷
      if (this.fileType) {
        const fileName = file.name.split('.')
        const fileExt = fileName[fileName.length - 1]
        const isTypeOk = this.fileType.indexOf(fileExt) >= 0
        if (!isTypeOk) {
          this.$modal.msgError(`鏂囦欢鏍煎紡涓嶆纭紝璇蜂笂浼?{this.fileType.join("/")}鏍煎紡鏂囦欢!`)
          return false
        }
      }
      // 鏍℃鏂囦欢鍚嶆槸鍚﹀寘鍚壒娈婂瓧绗?
      if (file.name.includes(',')) {
        this.$modal.msgError('鏂囦欢鍚嶄笉姝ｇ‘锛屼笉鑳藉寘鍚嫳鏂囬€楀彿!')
        return false
      }
      // 鏍℃鏂囦欢澶у皬
      if (this.fileSize) {
        const isLt = file.size / 1024 / 1024 < this.fileSize
        if (!isLt) {
          this.$modal.msgError(`涓婁紶鏂囦欢澶у皬涓嶈兘瓒呰繃 ${this.fileSize} MB!`)
          return false
        }
      }
      this.$modal.loading("姝ｅ湪涓婁紶鏂囦欢锛岃绋嶅€?..")
      this.number++
      return true
    },
    // 鏂囦欢涓暟瓒呭嚭
    handleExceed() {
      this.$modal.msgError(`涓婁紶鏂囦欢鏁伴噺涓嶈兘瓒呰繃 ${this.limit} 涓?`)
    },
    // 涓婁紶澶辫触
    handleUploadError(err) {
      this.$modal.msgError("涓婁紶鏂囦欢澶辫触锛岃閲嶈瘯")
      this.$modal.closeLoading()
    },
    // 涓婁紶鎴愬姛鍥炶皟
    handleUploadSuccess(res, file) {
      if (res.code === 200) {
        this.uploadList.push({name: res.fileName, url: res.fileName})
        this.uploadedSuccessfully()
      } else {
        this.number--
        this.$modal.closeLoading()
        this.$modal.msgError(res.msg)
        this.$refs.fileUpload.handleRemove(file)
        this.uploadedSuccessfully()
      }
    },
    // 鍒犻櫎鏂囦欢
    handleDelete(index) {
      this.fileList.splice(index, 1)
      this.$emit("input", this.listToString(this.fileList))
    },
    // 涓婁紶缁撴潫澶勭悊
    uploadedSuccessfully() {
      if (this.number > 0 && this.uploadList.length === this.number) {
        this.fileList = this.fileList.concat(this.uploadList)
        this.uploadList = []
        this.number = 0
        this.$emit("input", this.listToString(this.fileList))
        this.$modal.closeLoading()
      }
    },
    // 鑾峰彇鏂囦欢鍚嶇О
    getFileName(name) {
      // 濡傛灉鏄痷rl閭ｄ箞鍙栨渶鍚庣殑鍚嶅瓧 濡傛灉涓嶆槸鐩存帴杩斿洖
      if (name.lastIndexOf("/") > -1) {
        return name.slice(name.lastIndexOf("/") + 1)
      } else {
        return name
      }
    },
    // 瀵硅薄杞垚鎸囧畾瀛楃涓插垎闅?
    listToString(list, separator) {
      let strs = ""
      separator = separator || ","
      for (let i in list) {
        strs += list[i].url + separator
      }
      return strs != '' ? strs.substr(0, strs.length - 1) : ''
    }
  }
}
</script>

<style lang="scss" scoped>
.file-upload-darg {
  opacity: 0.5;
  background: #c8ebfb;
}

.upload-file-uploader {
  margin-bottom: 5px;
}

.upload-file-list .el-upload-list__item {
  border: 1px solid #e4e7ed;
  line-height: 2;
  margin-bottom: 10px;
  position: relative;
}

.upload-file-list .ele-upload-list__item-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: inherit;
}

.ele-upload-list__item-content-action .el-link {
  margin-right: 10px;
}
</style>
