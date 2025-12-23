package com.ddss.server.util;

import com.aspose.words.Document;
import com.aspose.words.SaveFormat;

import java.io.File;

/**
 * @Auther: zhanglei
 * @Date: 2025/12/23 - 12 - 23 - 17:54
 */
public class PdfUtil2 {

    /**
     * 核心转换方法：支持 .doc/.docx/.wps 转 PDF
     * @param inputPath 源文件路径（.doc/.docx/.wps）
     * @param outputPath PDF输出路径
     */
    public static void convertToPdf(String inputPath, String outputPath) throws Exception {
        // 1. 校验文件
        File inputFile = new File(inputPath);
        if (!inputFile.exists()) {
            throw new IllegalArgumentException("源文件不存在：" + inputPath);
        }

        // 2. 加载文档（自动识别格式，无需区分.doc/.docx/.wps）
        Document doc = new Document(inputPath);

        // 3. 转换为PDF（一行代码，完整保留所有格式）
        doc.save(outputPath, SaveFormat.PDF);

        System.out.println("转换成功：" + outputPath);
    }

    // 测试主方法
    public static void main(String[] args) {
        try {
            // 替换为你的文件路径（.doc/.docx/.wps 均可）
            String inputPath = "D:\\test\\test.wps";
            String outputPath = "D:\\test\\test.pdf";
            PdfUtil2.convertToPdf(inputPath, outputPath);
        } catch (Exception e) {
            System.err.println("转换失败：" + e.getMessage());
            e.printStackTrace();
        }
    }
}
