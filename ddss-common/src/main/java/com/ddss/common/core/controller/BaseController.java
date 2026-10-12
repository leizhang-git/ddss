package com.ddss.common.core.controller;

import com.ddss.common.constant.HttpStatus;
import com.ddss.common.core.code.GlobalErrorCode;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.domain.R;
import com.ddss.common.core.domain.model.LoginUser;
import com.ddss.common.core.page.PageDomain;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.core.page.TableSupport;
import com.ddss.common.utils.DateUtils;
import com.ddss.common.utils.PageUtils;
import com.ddss.common.utils.SecurityUtils;
import com.ddss.common.utils.StringUtils;
import com.ddss.common.utils.sql.SqlUtil;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;

import java.beans.PropertyEditorSupport;
import java.util.Date;
import java.util.List;
import java.util.function.Supplier;

/**
 * web层通用数据处理
 *
 * @author ruoyi
 */
public class BaseController {
    protected final Logger logger = LoggerFactory.getLogger(this.getClass());

    /**
     * 将前台传递过来的日期格式的字符串，自动转化为Date类型
     */
    @InitBinder
    public void initBinder(WebDataBinder binder) {
        // Date 类型转换
        binder.registerCustomEditor(Date.class, new PropertyEditorSupport() {
            @Override
            public void setAsText(String text) {
                setValue(DateUtils.parseDate(text));
            }
        });
    }

    /**
     * 设置请求分页数据
     *
     * @deprecated 分页查询请使用 {@link #pageQuery(Supplier)}，它会保证 ThreadLocal 被清理
     */
    @Deprecated
    protected void startPage() {
        PageUtils.startPage();
    }

    /**
     * 分页查询统一出口：一行完成 分页上下文 → 执行查询 → 提取 total → finally 清理 ThreadLocal
     * <p>
     * 用法：{@code return pageQuery(() -> financeService.selectFinanceList(finance)); }
     *
     * @param query 业务列表查询（内部已按 PageHelper 上下文分页）
     * @param <T>   行类型
     */
    protected <T> TableDataInfo pageQuery(Supplier<List<T>> query) {
        PageUtils.startPage();
        try {
            List<T> list = query.get();
            TableDataInfo rspData = new TableDataInfo();
            rspData.setCode(HttpStatus.SUCCESS);
            rspData.setMsg("查询成功");
            rspData.setRows(list);
            rspData.setTotal(new PageInfo(list).getTotal());
            return rspData;
        } finally {
            PageUtils.clearPage();
        }
    }

    /**
     * 设置请求排序数据
     */
    protected void startOrderBy() {
        PageDomain pageDomain = TableSupport.buildPageRequest();
        if (StringUtils.isNotEmpty(pageDomain.getOrderBy())) {
            String orderBy = SqlUtil.escapeOrderBySql(pageDomain.getOrderBy());
            PageHelper.orderBy(orderBy);
        }
    }

    /**
     * 清理分页的线程变量
     */
    protected void clearPage() {
        PageUtils.clearPage();
    }

    /**
     * 响应请求分页数据
     */
    @SuppressWarnings({"rawtypes", "unchecked"})
    protected TableDataInfo getDataTable(List<?> list) {
        TableDataInfo rspData = new TableDataInfo();
        rspData.setCode(HttpStatus.SUCCESS);
        rspData.setMsg("查询成功");
        rspData.setRows(list);
        rspData.setTotal(new PageInfo(list).getTotal());
        return rspData;
    }

    /**
     * 返回成功
     */
    public AjaxResult success() {
        return AjaxResult.success();
    }

    /**
     * 返回失败消息
     */
    public AjaxResult error() {
        return AjaxResult.error();
    }

    /**
     * 返回成功消息
     */
    public AjaxResult success(String message) {
        return AjaxResult.success(message);
    }

    /**
     * 返回成功消息
     */
    public AjaxResult success(Object data) {
        return AjaxResult.success(data);
    }

    /**
     * 返回失败消息
     */
    public AjaxResult error(String message) {
        return AjaxResult.error(message);
    }

    /**
     * 返回警告消息
     */
    public AjaxResult warn(String message) {
        return AjaxResult.warn(message);
    }

    /**
     * 响应返回结果
     *
     * @param rows 影响行数
     * @return 操作结果
     */
    protected AjaxResult toAjax(int rows) {
        return rows > 0 ? AjaxResult.success() : AjaxResult.error();
    }

    /**
     * R 契约版：按影响行数判定成败（新代码用）
     */
    protected <T> R<T> toResult(int rows) {
        return rows > 0 ? R.ok() : R.fail(GlobalErrorCode.SYSTEM_ERROR);
    }

    /**
     * 响应返回结果
     *
     * @param result 结果
     * @return 操作结果
     */
    protected AjaxResult toAjax(boolean result) {
        return result ? success() : error();
    }

    /**
     * 页面跳转
     */
    public String redirect(String url) {
        return StringUtils.format("redirect:{}", url);
    }

    /**
     * 获取用户缓存信息
     */
    public LoginUser getLoginUser() {
        return SecurityUtils.getLoginUser();
    }

    /**
     * 获取登录用户id
     */
    public Long getUserId() {
        return getLoginUser().getUserId();
    }

    /**
     * 获取登录部门id
     */
    public Long getDeptId() {
        return getLoginUser().getDeptId();
    }

    /**
     * 获取登录用户名
     */
    public String getUsername() {
        return getLoginUser().getUsername();
    }
}
