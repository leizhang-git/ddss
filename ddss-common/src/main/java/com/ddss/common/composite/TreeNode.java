package com.ddss.common.composite;

import java.util.List;

public interface TreeNode<T> {
    Long getId();

    Long getParentId();

    List<T> getChildren();

    void setChildren(List<T> children);

    Integer getOrderNum();
}
