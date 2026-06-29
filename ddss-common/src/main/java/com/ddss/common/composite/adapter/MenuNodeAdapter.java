package com.ddss.common.composite.adapter;

import com.ddss.common.composite.TreeNode;
import com.ddss.common.core.domain.entity.SysMenu;

import java.util.ArrayList;
import java.util.List;

public class MenuNodeAdapter implements TreeNode<MenuNodeAdapter> {
    private final SysMenu menu;
    private List<MenuNodeAdapter> children = new ArrayList<>();

    public MenuNodeAdapter(SysMenu menu) {
        this.menu = menu;
    }

    @Override
    public Long getId() {
        return menu.getMenuId();
    }

    @Override
    public Long getParentId() {
        return menu.getParentId();
    }

    @Override
    public List<MenuNodeAdapter> getChildren() {
        return children;
    }

    @Override
    public void setChildren(List<MenuNodeAdapter> children) {
        this.children = children;
    }

    @Override
    public Integer getOrderNum() {
        return menu.getOrderNum();
    }

    public SysMenu getMenu() {
        return menu;
    }
}
