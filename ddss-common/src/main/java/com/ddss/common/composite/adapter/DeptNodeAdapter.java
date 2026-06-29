package com.ddss.common.composite.adapter;

import com.ddss.common.composite.TreeNode;
import com.ddss.common.core.domain.entity.SysDept;

import java.util.ArrayList;
import java.util.List;

public class DeptNodeAdapter implements TreeNode<DeptNodeAdapter> {
    private final SysDept dept;
    private List<DeptNodeAdapter> children = new ArrayList<>();

    public DeptNodeAdapter(SysDept dept) {
        this.dept = dept;
    }

    @Override
    public Long getId() {
        return dept.getDeptId();
    }

    @Override
    public Long getParentId() {
        return dept.getParentId();
    }

    @Override
    public List<DeptNodeAdapter> getChildren() {
        return children;
    }

    @Override
    public void setChildren(List<DeptNodeAdapter> children) {
        this.children = children;
    }

    @Override
    public Integer getOrderNum() {
        return dept.getOrderNum();
    }

    public SysDept getDept() {
        return dept;
    }
}
