<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryForm" :inline="true" :model="queryParams" label-width="80px" size="small">
      <el-form-item label="文件名">
        <el-input
          v-model="queryParams.fileName"
          clearable
          placeholder="请输入文件名搜索"
          style="width: 240px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item>
        <el-button icon="el-icon-search" size="mini" type="primary" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="resourceList" @selection-change="handleSelectionChange">
      <el-table-column align="center" type="selection" width="55" />
      <el-table-column align="center" label="文件名" prop="objectName" :show-overflow-tooltip="true" min-width="200" />
      <el-table-column align="center" label="文件类型" prop="fileType" width="100">
        <template slot-scope="scope">
          <el-tag v-if="isImage(scope.row.fileType)" size="small" type="success">图片</el-tag>
          <el-tag v-else-if="isVideo(scope.row.fileType)" size="small" type="primary">视频</el-tag>
          <el-tag v-else-if="isDoc(scope.row.fileType)" size="small" type="warning">文档</el-tag>
          <el-tag v-else size="small" type="info">{{ scope.row.fileType.toUpperCase() }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column align="center" label="文件大小" prop="fileSize" width="100" />
      <el-table-column align="center" label="修改时间" prop="lastModified" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.lastModified) }}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" class-name="small-padding fixed-width" label="操作" width="260">
        <template slot-scope="scope">
          <div class="table-ops">
            <el-button
              v-hasPermi="['system:resource:list']"
              icon="el-icon-download"
              size="mini"
              type="text"
              @click="handleDownload(scope.row)"
            >下载</el-button>
            <el-button
              v-if="isImage(scope.row.fileType)"
              v-hasPermi="['system:resource:list']"
              icon="el-icon-view"
              size="mini"
              type="text"
              @click="handlePreview(scope.row)"
            >预览</el-button>
            <el-button
              v-hasPermi="['system:resource:remove']"
              icon="el-icon-delete"
              size="mini"
              type="text"
              @click="handleDelete(scope.row)"
            >删除</el-button>
          </div>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :limit.sync="queryParams.pageSize"
      :page.sync="queryParams.pageNum"
      :total="total"
      @pagination="getList"
    />

    <!-- 图片预览对话框 -->
    <el-dialog :visible.sync="previewOpen" title="图片预览" width="800px">
      <div style="text-align: center;">
        <el-image
          v-if="previewUrl"
          :src="previewUrl"
          fit="contain"
          style="max-width: 100%; max-height: 70vh;"
        />
        <span v-else>无法加载图片</span>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listMinioResource, downloadMinioFile, delMinioResource, getMinioPreviewUrl } from "@/api/minio/resource";

export default {
  name: "VideoResource",
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 资源表格数据
      resourceList: [],
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        fileName: undefined
      },
      // 预览对话框
      previewOpen: false,
      previewUrl: ''
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询MinIO资源列表 */
    getList() {
      this.loading = true;
      listMinioResource().then(response => {
        const allData = response.rows || [];
        // 前端搜索过滤
        let filteredData = allData;
        if (this.queryParams.fileName) {
          const keyword = this.queryParams.fileName.toLowerCase();
          filteredData = allData.filter(item =>
            item.objectName.toLowerCase().includes(keyword)
          );
        }
        this.total = filteredData.length;
        // 前端分页
        const start = (this.queryParams.pageNum - 1) * this.queryParams.pageSize;
        const end = start + this.queryParams.pageSize;
        this.resourceList = filteredData.slice(start, end);
        this.loading = false;
      }).catch(() => {
        this.loading = false;
      });
    },
    // 判断文件类型
    isImage(fileType) {
      return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp', 'ico'].includes(fileType);
    },
    isVideo(fileType) {
      return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv', 'webm'].includes(fileType);
    },
    isDoc(fileType) {
      return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].includes(fileType);
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.objectName);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    /** 下载按钮操作 */
    handleDownload(row) {
      this.$modal.confirm('是否确认下载文件 "' + row.objectName + '"？').then(() => {
        return downloadMinioFile(row.objectName);
      }).then((data) => {
        // 创建blob并下载
        const blob = new Blob([data]);
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = row.objectName;
        link.click();
        URL.revokeObjectURL(link.href);
        this.$modal.msgSuccess("下载成功");
      }).catch(() => {});
    },
    /** 预览按钮操作 */
    handlePreview(row) {
      this.previewUrl = row.previewUrl;
      this.previewOpen = true;
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      this.$modal.confirm('是否确认删除文件 "' + row.objectName + '"？').then(() => {
        return delMinioResource(row.objectName);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    }
  }
};
</script>
