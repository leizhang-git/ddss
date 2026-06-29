package com.ddss.common.composite;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

public class TreeBuilder {

    public static <T extends TreeNode<T>> List<T> buildTree(List<T> allNodes) {
        return buildTree(allNodes, 0L);
    }

    public static <T extends TreeNode<T>> List<T> buildTree(List<T> allNodes, Long rootParentId) {
        if (allNodes == null || allNodes.isEmpty()) {
            return Collections.emptyList();
        }
        Map<Long, List<T>> parentIdMap = allNodes.stream()
                .filter(n -> n.getParentId() != null)
                .collect(Collectors.groupingBy(TreeNode::getParentId));
        List<T> roots = parentIdMap.getOrDefault(rootParentId, new ArrayList<>());
        for (T root : roots) {
            buildChildren(root, parentIdMap);
        }
        roots.sort(Comparator.comparing(TreeNode::getOrderNum, Comparator.nullsLast(Comparator.naturalOrder())));
        return roots;
    }

    private static <T extends TreeNode<T>> void buildChildren(T parent, Map<Long, List<T>> parentIdMap) {
        List<T> children = parentIdMap.getOrDefault(parent.getId(), new ArrayList<>());
        children.sort(Comparator.comparing(TreeNode::getOrderNum, Comparator.nullsLast(Comparator.naturalOrder())));
        for (T child : children) {
            buildChildren(child, parentIdMap);
        }
        parent.setChildren(children);
    }

    public static <T extends TreeNode<T>> List<T> findChildren(List<T> allNodes, Long parentId) {
        if (allNodes == null || allNodes.isEmpty()) {
            return Collections.emptyList();
        }
        return allNodes.stream()
                .filter(n -> Objects.equals(n.getParentId(), parentId))
                .sorted(Comparator.comparing(TreeNode::getOrderNum, Comparator.nullsLast(Comparator.naturalOrder())))
                .collect(Collectors.toList());
    }

    public static <T extends TreeNode<T>> List<T> getDescendants(List<T> allNodes, Long nodeId) {
        if (allNodes == null || allNodes.isEmpty()) {
            return Collections.emptyList();
        }
        Map<Long, List<T>> parentIdMap = allNodes.stream()
                .filter(n -> n.getParentId() != null)
                .collect(Collectors.groupingBy(TreeNode::getParentId));
        List<T> descendants = new ArrayList<>();
        collectDescendants(nodeId, parentIdMap, descendants);
        return descendants;
    }

    private static <T extends TreeNode<T>> void collectDescendants(Long nodeId, Map<Long, List<T>> parentIdMap, List<T> result) {
        List<T> children = parentIdMap.getOrDefault(nodeId, new ArrayList<>());
        for (T child : children) {
            result.add(child);
            collectDescendants(child.getId(), parentIdMap, result);
        }
    }

    public static <T extends TreeNode<T>> List<T> getAncestors(List<T> allNodes, Long nodeId) {
        if (allNodes == null || allNodes.isEmpty()) {
            return Collections.emptyList();
        }
        Map<Long, T> nodeMap = allNodes.stream()
                .filter(n -> n.getId() != null)
                .collect(Collectors.toMap(TreeNode::getId, n -> n, (a, b) -> a));
        List<T> ancestors = new ArrayList<>();
        Long currentId = nodeId;
        while (currentId != null) {
            T node = nodeMap.get(currentId);
            if (node == null) {
                break;
            }
            Long parentId = node.getParentId();
            if (parentId != null && parentId != 0L) {
                T parent = nodeMap.get(parentId);
                if (parent != null) {
                    ancestors.add(parent);
                    currentId = parentId;
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        return ancestors;
    }
}
