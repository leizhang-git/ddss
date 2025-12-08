package com.ddss.common.utils;

import java.util.ArrayList;
import java.util.List;

/**
 * SQL工具类
 * @Auth zhanglei
 * @Date 2023/2/18 22:49
 */
public class SQLUtil {

    /**
     * pg转mysql
     * @param pgSQL sql
     * @param manipulation insert
     * @return sql
     */
    public static List<String> pgToMySQL(List<String> pgSQL, String manipulation) {
        List<String> result = new ArrayList<>();
        if("INSERT".equalsIgnoreCase(manipulation)) {
            for (String s : pgSQL) {
                String[] values = s.split("VALUES");
                String replace = values[0].replace("\"public\".", "")
                        .replace("\"", "");
                String s2 = replace + "VALUES" + values[1];
                result.add(s2);
            }
            return result;
        }
        return result;
    }

    /**
     * update语句转换
     * @param manipulation update
     * @param tableName 表名
     * @param fields 旧字段名称
     * @param newFields 新字段名称
     * @param newValue 新数据
     * @param oldValue 旧数据（基准）
     * @param oldValue1
     * @return
     */
    public static List<String> updateSQLTransition(String manipulation, String tableName, List<String> fields, List<String> newFields, List<String> newValue, List<String> oldValue, List<String> oldValue1) {
        List<String> list = new ArrayList<>();
        if("UPDATE".equalsIgnoreCase(manipulation)) {
            for (int i = 0; i < oldValue.size(); i++) {
                if(fields.size() == 1) {
                    String str = manipulation + " " + tableName + " set " + "\"" + newFields.get(0) + "\"" + " = " + "'" + newValue.get(i) + "'" + " where " + fields.get(0) + " = " + "'" + oldValue.get(i) + "'" + ";";
                    list.add(str);
                }else if (fields.size() == 2) {
                    String str = manipulation + " " + tableName + " set " + "\"" + newFields.get(0) + "\"" + " = " + "'" + newValue.get(i) + "'" + " where " + fields.get(0) + " = " + "'" + oldValue.get(i) + "'" + " and " + fields.get(1) + " = " + oldValue1.get(i) + ";";
                }
            }
            list.forEach(System.out::println);
            return list;
        }else {
            return new ArrayList<>();
        }
    }

}
