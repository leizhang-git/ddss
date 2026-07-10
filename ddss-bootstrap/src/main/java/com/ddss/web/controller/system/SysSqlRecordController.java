package com.ddss.web.controller.system;

import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.server.domain.po.SysSqlRecord;
import com.ddss.server.service.SysSqlRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

/**
 * SQL记录管理 Controller
 *
 * @author ddss
 */
@RestController
@RequestMapping("/system/sqlRecord")
public class SysSqlRecordController extends BaseController {

    @Autowired
    private SysSqlRecordService sqlRecordService;

    /**
     * 分页列表
     */
    @PreAuthorize("@ss.hasPermi('system:sql:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysSqlRecord record) {
        startPage();
        List<SysSqlRecord> list = sqlRecordService.selectList(record);
        return getDataTable(list);
    }

    /**
     * 详情
     */
    @PreAuthorize("@ss.hasPermi('system:sql:query')")
    @GetMapping("/{sqlId}")
    public AjaxResult getInfo(@PathVariable Long sqlId) {
        return success(sqlRecordService.selectById(sqlId));
    }

    /**
     * 新增
     */
    @PreAuthorize("@ss.hasPermi('system:sql:add')")
    @Log(title = "SQL管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysSqlRecord record) {
        record.setCreateBy(getUsername());
        record.setCreateTime(new Date());
        return toAjax(sqlRecordService.insert(record));
    }

    /**
     * 修改
     */
    @PreAuthorize("@ss.hasPermi('system:sql:edit')")
    @Log(title = "SQL管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysSqlRecord record) {
        record.setUpdateBy(getUsername());
        record.setUpdateTime(new Date());
        return toAjax(sqlRecordService.update(record));
    }

    /**
     * 删除
     */
    @PreAuthorize("@ss.hasPermi('system:sql:remove')")
    @Log(title = "SQL管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{sqlIds}")
    public AjaxResult remove(@PathVariable Long[] sqlIds) {
        return toAjax(sqlRecordService.deleteByIds(sqlIds));
    }
}
