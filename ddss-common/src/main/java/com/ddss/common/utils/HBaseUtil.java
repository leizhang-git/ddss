package com.ddss.common.utils;//package com.recommend.provider.util;
//
//import cn.hutool.core.collection.CollUtil;
//import cn.hutool.core.util.StrUtil;
//import com.google.common.collect.Lists;
//import com.recommend.consumer.domain.dto.HBaseResult;
//import org.apache.hadoop.hbase.*;
//import org.apache.hadoop.hbase.client.*;
//import org.apache.hadoop.hbase.util.Bytes;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//import org.springframework.context.annotation.Bean;
//import org.springframework.stereotype.Component;
//
//import javax.annotation.Resource;
//import java.io.IOException;
//import java.util.ArrayList;
//import java.util.Collections;
//import java.util.List;
//
///**
// * @Describe
// * @Author zhanglei
// * @Date 2023/7/28 17:22
// */
//@Component
//public class HBaseUtil {
//
//    private static final Logger log = LoggerFactory.getLogger(HBaseUtil.class);
//
//    @Resource
//    private Connection connection;
//
//    private Admin admin;
//
//    @Bean
//    public void initial() throws IOException {
//        admin = connection.getAdmin();
//    }
//
//
//    /**
//     * 创建命名空间
//     * @param nameSpace 名称
//     * @throws IOException
//     */
//    public void createNameSpace(String nameSpace) throws IOException {
//        admin.createNamespace(NamespaceDescriptor.create(nameSpace).build());
//    }
//
//    /**
//     * 判断表是否存在
//     * @param tableName
//     * @return true or false
//     * @throws IOException
//     */
//    public Boolean tableExists(String tableName) throws IOException {
//        if(StrUtil.isBlank(tableName)) {
//            throw new IllegalArgumentException("tableName is empty.");
//        }
//        TableName name = TableName.valueOf(tableName);
//        return admin.tableExists(name);
//    }
//
//    /**
//     * 判断表是否存在(带namespace)
//     * @param namespace
//     * @param tableName
//     * @return true or false
//     * @throws IOException
//     */
//    public Boolean tableExists(String namespace, String tableName) throws IOException {
//        if(StrUtil.isBlank(tableName)) {
//            throw new IllegalArgumentException("tableName is empty.");
//        }
//        if(StrUtil.isBlank(namespace)) {
//            return tableExists(tableName);
//        }
//        TableName name = TableName.valueOf(namespace, tableName);
//        return admin.tableExists(name);
//    }
//
//    /**
//     * 创建表
//     * @param tableName name
//     * @param columnDesc 列族
//     * @throws IOException
//     */
//    public void createTable(String tableName, List<String> columnDesc) throws IOException {
//        if(tableExists(tableName)) {
//            return;
//        }
//        TableName name = TableName.valueOf(tableName);
//        HTableDescriptor tableDescriptor = new HTableDescriptor(name);
//        if(CollUtil.isNotEmpty(columnDesc)) {
//            columnDesc.forEach(c -> tableDescriptor.addFamily(new HColumnDescriptor(c)));
//        }
//        admin.createTable(tableDescriptor);
//    }
//
//
//    /**
//     * 获取所有表名
//     * @throws IOException
//     */
//    public List<String> listTableName() throws IOException {
//        List<String> result = Lists.newArrayList();
//        HTableDescriptor[] tableDescriptor = admin.listTables();
//        for (HTableDescriptor hTableDescriptor : tableDescriptor) {
//            result.add(hTableDescriptor.getNameAsString());
//        }
//        return result;
//    }
//
//    /**
//     * 查看所有表信息(namespace:name)
//     * @throws IOException
//     */
//    public List<String> listTable() throws IOException {
//        List<String> result = Lists.newArrayList();
//        TableName[] tableNames = admin.listTableNames();
//        for (TableName table : tableNames) {
//            result.add(table.getNameAsString());
//        }
//        return result;
//    }
//
//
//    /**
//     * 获取所有命名空间
//     * @throws IOException
//     */
//    public List<String> listNameSpace() throws IOException {
//        List<String> result = Lists.newArrayList();
//        NamespaceDescriptor[] namespaceDescriptors = admin.listNamespaceDescriptors();
//        for (NamespaceDescriptor namespaceDescriptor : namespaceDescriptors) {
//            result.add(namespaceDescriptor.getName());
//        }
//        return result;
//    }
//
//    /**
//     * 删除命名空间
//     * @param nameSpace 命名空间
//     * @throws IOException
//     */
//    public void deleteNameSpace(String nameSpace) throws IOException {
//        //获取该名称空间下所有的表
//        TableName[] names = admin.listTableNamesByNamespace(nameSpace);
//        for (TableName name : names) {
//            //禁用表
//            admin.disableTable(name);
//            //删除表
//            admin.deleteTable(name);
//        }
//        //删除名称空间
//        admin.deleteNamespace(nameSpace);
//    }
//
//
//    /**
//     * 插入一条数据（指定行，列，列族）
//     * @param tableName 表名
//     * @param rowKey 唯一标识
//     * @param family 列族名
//     * @param qualifier 列标识
//     * @param value 数据
//     */
//    public void putData(String tableName, String rowKey, String family, String qualifier, String value) {
//        try (Table table = connection.getTable(TableName.valueOf(tableName))) {
//            Put put = new Put(Bytes.toBytes(rowKey));
//            put.addColumn(Bytes.toBytes(family), Bytes.toBytes(qualifier), Bytes.toBytes(value));
//            table.put(put);
//        } catch (Exception e) {
//            log.error("putData error.", e);
//        }
//    }
//
//
//    /**
//     * 删除表
//     * @param tableName name
//     * @throws IOException
//     */
//    public void truncateTable(String tableName) throws IOException {
//        if(!tableExists(tableName)) {
//            return;
//        }
//        TableName name = TableName.valueOf(tableName);
//        admin.disableTable(name);
//        admin.deleteTable(name);
//    }
//
//
//    /**
//     * 删除指定列数据
//     * @param tableName
//     * @param rowKey
//     * @param family
//     * @param column
//     */
//    public void deleteData(String tableName, String rowKey, String family, String column) {
//        // 获取表
//        try (Table table = connection.getTable(TableName.valueOf(tableName))) {
//            // 创建delete对象,指定删除行
//            Delete delete = new Delete(rowKey.getBytes());
//            // 指定删除列数据
//            delete.addColumn(family.getBytes(), column.getBytes());
//            // 删除数据
//            table.delete(delete);
//        } catch (IOException e) {
//            log.error("deleteFamily error.", e);
//            e.printStackTrace();
//        }
//    }
//
//    /**
//     * 删除指定列族
//     * @param tableName
//     * @param rowKey
//     * @param family
//     */
//    public void deleteFamily(String tableName,String rowKey,String family) {
//        // 获取表
//        try (Table table = connection.getTable(TableName.valueOf(tableName))) {
//            // 创建delete对象,指定删除行
//            Delete delete = new Delete(rowKey.getBytes());
//            // 指定删除列族
//            delete.addFamily(family.getBytes());
//            // 删除数据
//            table.delete(delete);
//        } catch (IOException e) {
//            log.error("deleteFamily error.", e);
//            e.printStackTrace();
//        }
//    }
//
//    /**
//     * 删除指定行
//     * @param tableName
//     * @param rowKey
//     */
//    public void deleteRow(String tableName,String rowKey) {
//        // 获取表
//        try (Table table = connection.getTable(TableName.valueOf(tableName))) {
//            // 创建delete对象,指定删除行
//            Delete delete = new Delete(rowKey.getBytes());
//            // 删除数据
//            table.delete(delete);
//        } catch (IOException e) {
//            log.error("deleteRow error.", e);
//            e.printStackTrace();
//        }
//    }
//
//    /**
//     * 批量插入数据
//     * @param tableName 表名
//     * @param puts puts
//     */
//    public void putRows(String tableName, List<Put> puts) {
//        try (Table table = connection.getTable(TableName.valueOf(tableName))) {
//            table.put(puts);
//        } catch (IOException e) {
//            log.error("putRows error.", e);
//            e.printStackTrace();
//        }
//    }
//
//    /**
//     * 扫描指定rowKey范围数据
//     * @param tableName 表名
//     * @param startRowKey startkey
//     * @param endRowKey endkey
//     * @return
//     * @throws IOException
//     */
//    public List<Result> scanData(String tableName, String startRowKey, String endRowKey) throws IOException {
//        List<Result> resultList = Lists.newArrayList();
//        // 获取表
//        try (Table table = connection.getTable(TableName.valueOf(tableName))) {
//            // 获取扫描对象
//            Scan scan = new Scan();
//            // 从startRowKey开始扫描,到endRowKey结束,含头不含尾
//            scan.setStartRow(startRowKey.getBytes());
//            scan.setStopRow(endRowKey.getBytes());
//            ResultScanner scanner = table.getScanner(scan);
//            for (Result result : scanner) {
//                resultList.add(result);
//            }
//        }
//        return resultList;
//    }
//
//    /**
//     * 获取单行或多行数据
//     * @param tableName 表名
//     * @param rowKey rowKey
//     * @return result
//     * @throws IOException
//     */
//    public List<Result> getRowData(String tableName, String ...rowKey) throws IOException {
//        List<Result> resultList = Lists.newArrayList();
//        // 获取表
//        try (Table table = connection.getTable(TableName.valueOf(tableName))) {
//            // 创建集合存储行数据
//            List<Get> list = new ArrayList<>();
//            for (String s : rowKey) {
//                Get get = new Get(s.getBytes());
//                list.add(get);
//            }
//            Result[] results = table.get(list);
//            // 展示行数据
//            Collections.addAll(resultList, results);
//        }
//        return resultList;
//    }
//
//    /**
//     * 获取单元格数据
//     * @param result
//     * @return
//     */
//    public List<HBaseResult> getCallData(Result result) {
//        List<HBaseResult> hBaseResultList = Lists.newArrayList();
//        while(result.advance()){
//            HBaseResult hBaseResult = new HBaseResult();
//            Cell cell = result.current();
//            String row = new String(CellUtil.cloneRow(cell));
//            String family = new String(CellUtil.cloneFamily(cell));
//            String qualifier = new String(CellUtil.cloneQualifier(cell));
//            String value = new String(CellUtil.cloneValue(cell));
//            hBaseResult.setRow(row);
//            hBaseResult.setFamily(family);
//            hBaseResult.setQualifier(qualifier);
//            hBaseResult.setValue(value);
//            hBaseResultList.add(hBaseResult);
//        }
//        return hBaseResultList;
//    }
//}
