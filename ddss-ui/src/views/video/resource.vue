<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryForm" :inline="true" :model="queryParams" label-width="80px" size="small">
      <el-form-item label="资源名称" prop="resourceName">
        <el-input
          v-model="queryParams.resourceName"
          clearable
          placeholder="请输入资源名称"
          style="width: 220px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="请选择状态" style="width: 160px">
          <el-option label="正常" value="0" />
          <el-option label="停用" value="1" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button icon="el-icon-search" size="mini" type="primary" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          v-hasPermi="['video:resource:add']"
          icon="el-icon-plus"
          plain
          size="mini"
          type="primary"
          @click="handleAdd"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          v-hasPermi="['video:resource:edit']"
          :disabled="single"
          icon="el-icon-edit"
          plain
          size="mini"
          type="success"
          @click="handleUpdate"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          v-hasPermi="['video:resource:remove']"
          :disabled="multiple"
          icon="el-icon-delete"
          plain
          size="mini"
          type="danger"
          @click="handleDelete"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          v-hasPermi="['video:resource:download']"
          :disabled="multiple"
          icon="el-icon-download"
          plain
          size="mini"
          type="warning"
          @click="handleBatchDownload"
        >批量下载</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="resourceList" @selection-change="handleSelectionChange">
      <el-table-column align="center" type="selection" width="55" />
      <el-table-column align="center" label="资源ID" prop="resourceId" width="80" />
      <el-table-column align="center" label="资源名称" prop="resourceName" :show-overflow-tooltip="true" min-width="160" />
      <el-table-column align="center" label="文件类型" prop="fileType" width="100" />
      <el-table-column align="center" label="文件大小" prop="fileSize" width="120" />
      <el-table-column align="center" label="文件路径" prop="filePath" :show-overflow-tooltip="true" min-width="200" />
      <el-table-column align="center" label="状态" width="80">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status === '0'" type="success">正常</el-tag>
          <el-tag v-else type="danger">停用</el-tag>
        </template>
      </el-table-column>
      <el-table-column align="center" label="创建时间" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" class-name="small-padding fixed-width" label="操作" width="260">
        <template slot-scope="scope">
          <div class="table-ops">
            <el-button
              v-hasPermi="['video:resource:download']"
              icon="el-icon-download"
              size="mini"
              type="text"
              @click="handleDownload(scope.row)"
            >下载</el-button>
            <el-button
              v-hasPermi="['video:resource:edit']"
              icon="el-icon-edit"
              size="mini"
              type="text"
              @click="handleUpdate(scope.row)"
            >修改</el-button>
            <el-button
              v-hasPermi="['video:resource:remove']"
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

    <!-- 添加或修改资源对话框 -->
    <el-dialog :title="title" :visible.sync="open" append-to-body width="600px">
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="资源名称" prop="resourceName">
              <el-input v-model="form.resourceName" placeholder="请输入资源名称" maxlength="100" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio label="0">正常</el-radio>
                <el-radio label="1">停用</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="文件类型" prop="fileType">
              <el-input v-model="form.fileType" placeholder="如: image/png" maxlength="50" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="文件大小" prop="fileSize">
              <el-input v-model="form.fileSize" placeholder="如: 10MB" maxlength="50" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="文件路径" prop="filePath">
              <el-input v-model="form.filePath" placeholder="请输入文件路径" maxlength="500" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" placeholder="请输入备注信息" type="textarea" :rows="3" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import request from '@/utils/request'
import { listResource, getResource, delResource, addResource, updateResource } from "@/api/video/resource";

export default {
  name: "Resource",
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
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        resourceName: undefined,
        status: undefined
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        resourceName: [
          { required: true, message: "资源名称不能为空", trigger: "blur" }
        ]
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询资源列表 */
    getList() {
      this.loading = true;
      listResource(this.queryParams).then(response => {
        this.resourceList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        resourceId: undefined,
        resourceName: undefined,
        fileType: undefined,
        fileSize: undefined,
        filePath: undefined,
        status: "0",
        remark: undefined
      };
      this.resetForm("form");
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
      this.ids = selection.map(item => item.resourceId);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加资源";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const resourceId = row.resourceId || this.ids;
      getResource(resourceId).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改资源";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.resourceId != undefined) {
            updateResource(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addResource(this.form).then(response => {
              this.$modal.msgSuccess("新增成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const resourceIds = row.resourceId || this.ids;
      this.$modal.confirm('是否确认删除资源编号为"' + resourceIds + '"的数据项？').then(function() {
        return delResource(resourceIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 单个下载按钮操作 */
    handleDownload(row) {
      if (!row.filePath) {
        this.$modal.msgWarning("文件路径为空，无法下载");
        return;
      }
      this.loading = true;
      request({
        url: '/video/resource/download',
        method: 'get',
        params: { objectName: row.filePath },
        responseType: 'blob'
      }).then(async (data) => {
        if (data.size > 0) {
          const fileName = row.filePath.substring(row.filePath.lastIndexOf('/') + 1);
          const link = document.createElement('a');
          link.href = URL.createObjectURL(data);
          link.download = fileName;
          link.click();
          URL.revokeObjectURL(link.href);
          this.$modal.msgSuccess("下载成功");
        } else {
          const resText = await data.text();
          const rspObj = JSON.parse(resText);
          this.$modal.msgError(rspObj.msg || '下载失败');
        }
      }).catch(error => {
        this.$modal.msgError('下载失败：' + (error.msg || error.message || '未知错误'));
      }).finally(() => {
        this.loading = false;
      });
    },
    /** 批量下载按钮操作 */
    handleBatchDownload() {
      if (this.ids.length === 0) {
        this.$modal.msgWarning("请先选择要下载的资源");
        return;
      }
      // 获取选中资源的文件路径
      const selectedResources = this.resourceList.filter(item => this.ids.includes(item.resourceId));
      const filePaths = selectedResources.map(item => item.filePath).filter(path => path);
      
      if (filePaths.length === 0) {
        this.$modal.msgWarning("选中的资源没有有效的文件路径");
        return;
      }
      
      // 调用后端批量下载接口
      this.loading = true;
      request({
        url: '/video/resource/batchDownload',
        method: 'post',
        headers: { 'Content-Type': 'application/json' },
        data: filePaths,
        responseType: 'blob'
      }).then(async (data) => {
        if (data.size > 0) {
          const link = document.createElement('a');
          link.href = URL.createObjectURL(data);
          link.download = `resources_${new Date().getTime()}.zip`;
          link.click();
          URL.revokeObjectURL(link.href);
          this.$modal.msgSuccess("批量下载成功");
        } else {
          const resText = await data.text();
          const rspObj = JSON.parse(resText);
          this.$modal.msgError(rspObj.msg || '批量下载失败');
        }
      }).catch(error => {
        this.$modal.msgError('批量下载失败：' + (error.msg || error.message || '未知错误'));
      }).finally(() => {
        this.loading = false;
      });
    }
  }
};
</script>
