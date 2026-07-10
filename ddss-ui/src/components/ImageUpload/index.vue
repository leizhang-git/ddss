<template>
  <div class="component-upload-image">
    <el-upload
      ref="imageUpload"
      :action="uploadImgUrl"
      :before-upload="handleBeforeUpload"
      :class="{hide: this.fileList.length >= this.limit}"
      :data="data"
      :disabled="disabled"
      :file-list="fileList"
      :headers="headers"
      :limit="limit"
      :on-error="handleUploadError"
      :on-exceed="handleExceed"
      :on-preview="handlePictureCardPreview"
      :on-remove="handleDelete"
      :on-success="handleUploadSuccess"
      :show-file-list="true"
      list-type="picture-card"
      multiple
    >
      <i class="el-icon-plus"></i>
    </el-upload>

    <!-- 涓婁紶鎻愮ず -->
    <div v-if="showTip && !disabled" slot="tip" class="el-upload__tip">
      璇蜂笂浼?
      <template v-if="fileSize"> 澶у皬涓嶈秴杩?<b style="color: #ff3b30">{{ fileSize }}MB</b></template>
      <template v-if="fileType"> 鏍煎紡涓?<b style="color: #ff3b30">{{ fileType.join("/") }}</b></template>
      鐨勬枃浠?
    </div>

    <el-dialog
      :visible.sync="dialogVisible"
      append-to-body
      title="棰勮"
      width="800"
    >
      <img
        :src="dialogImageUrl"
        style="display: block; max-width: 100%; margin: 0 auto"
      />
    </el-dialog>
  </div>
</template>

<script>
import {getToken} from "@/utils/auth"
import {isExternal} from "@/utils/validate"
import Sortable from 'sortablejs'

export default {
  props: {
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
    // 鍥剧墖鏁伴噺闄愬埗
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
      default: () => ["png", "jpg", "jpeg"]
    },
    // 鏄惁鏄剧ず鎻愮ず
    isShowTip: {
      type: Boolean,
      default: true
    },
    // 绂佺敤缁勪欢锛堜粎鏌ョ湅鍥剧墖锛?
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
      dialogImageUrl: "",
      dialogVisible: false,
      hideUpload: false,
      baseUrl: process.env.VUE_APP_BASE_API,
      uploadImgUrl: process.env.VUE_APP_BASE_API + this.action, // 涓婁紶鐨勫浘鐗囨湇鍔″櫒鍦板潃
      headers: {
        Authorization: "Bearer " + getToken(),
      },
      fileList: []
    }
  },
  mounted() {
    if (this.drag && !this.disabled) {
      this.$nextTick(() => {
        const element = this.$refs.imageUpload?.$el?.querySelector('.el-upload-list')
        Sortable.create(element, {
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
          // 棣栧厛灏嗗€艰浆涓烘暟缁?
          const list = Array.isArray(val) ? val : this.value.split(',')
          // 鐒跺悗灏嗘暟缁勮浆涓哄璞℃暟缁?
          this.fileList = list.map(item => {
            if (typeof item === "string") {
              if (item.indexOf(this.baseUrl) === -1 && !isExternal(item)) {
                item = {name: this.baseUrl + item, url: this.baseUrl + item}
              } else {
                item = {name: item, url: item}
              }
            }
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
    // 涓婁紶鍓峫oading鍔犺浇
    handleBeforeUpload(file) {
      let isImg = false
      if (this.fileType.length) {
        let fileExtension = ""
        if (file.name.lastIndexOf(".") > -1) {
          fileExtension = file.name.slice(file.name.lastIndexOf(".") + 1)
        }
        isImg = this.fileType.some(type => {
          if (file.type.indexOf(type) > -1) return true
          if (fileExtension && fileExtension.indexOf(type) > -1) return true
          return false
        })
      } else {
        isImg = file.type.indexOf("image") > -1
      }

      if (!isImg) {
        this.$modal.msgError(`鏂囦欢鏍煎紡涓嶆纭紝璇蜂笂浼?{this.fileType.join("/")}鍥剧墖鏍煎紡鏂囦欢!`)
        return false
      }
      if (file.name.includes(',')) {
        this.$modal.msgError('鏂囦欢鍚嶄笉姝ｇ‘锛屼笉鑳藉寘鍚嫳鏂囬€楀彿!')
        return false
      }
      if (this.fileSize) {
        const isLt = file.size / 1024 / 1024 < this.fileSize
        if (!isLt) {
          this.$modal.msgError(`涓婁紶澶村儚鍥剧墖澶у皬涓嶈兘瓒呰繃 ${this.fileSize} MB!`)
          return false
        }
      }
      this.$modal.loading("姝ｅ湪涓婁紶鍥剧墖锛岃绋嶅€?..")
      this.number++
    },
    // 鏂囦欢涓暟瓒呭嚭
    handleExceed() {
      this.$modal.msgError(`涓婁紶鏂囦欢鏁伴噺涓嶈兘瓒呰繃 ${this.limit} 涓?`)
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
        this.$refs.imageUpload.handleRemove(file)
        this.uploadedSuccessfully()
      }
    },
    // 鍒犻櫎鍥剧墖
    handleDelete(file) {
      const findex = this.fileList.map(f => f.name).indexOf(file.name)
      if (findex > -1) {
        this.fileList.splice(findex, 1)
        this.$emit("input", this.listToString(this.fileList))
      }
    },
    // 涓婁紶澶辫触
    handleUploadError() {
      this.$modal.msgError("涓婁紶鍥剧墖澶辫触锛岃閲嶈瘯")
      this.$modal.closeLoading()
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
    // 棰勮
    handlePictureCardPreview(file) {
      this.dialogImageUrl = file.url
      this.dialogVisible = true
    },
    // 瀵硅薄杞垚鎸囧畾瀛楃涓插垎闅?
    listToString(list, separator) {
      let strs = ""
      separator = separator || ","
      for (let i in list) {
        if (list[i].url) {
          strs += list[i].url.replace(this.baseUrl, "") + separator
        }
      }
      return strs != '' ? strs.substr(0, strs.length - 1) : ''
    }
  }
}
</script>
<style lang="scss" scoped>
// .el-upload--picture-card 鎺у埗鍔犲彿閮ㄥ垎
::v-deep.hide .el-upload--picture-card {
  display: none;
}

::v-deep .el-upload-list--picture-card.is-disabled + .el-upload--picture-card {
  display: none !important;
}

// 鍘绘帀鍔ㄧ敾鏁堟灉
::v-deep .el-list-enter-active,
::v-deep .el-list-leave-active {
  transition: all 0s;
}

::v-deep .el-list-enter, .el-list-leave-active {
  opacity: 0;
  transform: translateY(0);
}
</style>

