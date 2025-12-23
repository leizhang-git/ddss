package com.ddss.server.util;

import java.io.*;
import java.util.List;

// ==================== 严格区分不同包的同名类 ====================
// 1. PDF相关类（com.lowagie.text）：全部写全类名，避免和POI混淆
import com.lowagie.text.*;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

// 2. Word相关类（org.apache.poi.xwpf.usermodel）：单独导入，明确用途
import org.apache.poi.hwpf.HWPFDocument;
import org.apache.poi.hwpf.extractor.WordExtractor;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.apache.poi.xwpf.usermodel.XWPFPicture;
import org.apache.poi.xwpf.usermodel.XWPFPictureData;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.util.Units;
/**
 * @Auther: zhanglei
 * @Date: 2025/12/23 - 12 - 23 - 17:12
 */
public class PdfUtil {

    // PDF页面配置
    private static final Rectangle PDF_PAGE_SIZE = PageSize.A4;
    private static final float PDF_MARGIN = 50;
    // 宋体字体路径（必须放simsun.ttf）
    private static final String FONT_PATH = "src/main/resources/fonts/simfang.ttf";
    // 明确指定：PDF的Font类型（避免和其他Font混淆）
    private static com.lowagie.text.Font PDF_DEFAULT_FONT;

    static {
        // 初始化字体（解决中文乱码）
        try {
            // 优先从资源目录加载字体（兼容JAR包运行）
            InputStream fontIs = PdfUtil.class.getClassLoader().getResourceAsStream("fonts/simsun.ttf");
            if (fontIs != null) {
                BaseFont baseFont = BaseFont.createFont(FONT_PATH, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
                PDF_DEFAULT_FONT = new com.lowagie.text.Font(baseFont, 12);
                fontIs.close();
            } else {
                // 兜底：使用OpenPDF内置中文字体
                BaseFont baseFont = BaseFont.createFont("STSong-Light", "UniGB-UCS2-H", BaseFont.NOT_EMBEDDED);
                PDF_DEFAULT_FONT = new com.lowagie.text.Font(baseFont, 12);
                System.err.println("未找到simsun.ttf，使用内置中文字体（可能部分样式异常）");
            }
        } catch (Exception e) {
            PDF_DEFAULT_FONT = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 12);
            System.err.println("字体初始化失败，中文可能乱码：" + e.getMessage());
        }
    }

    // 测试主方法（直接运行）
    public static void main(String[] args) {
        try {
            // 替换为你的测试文件路径
            String inputPath = "D:\\test\\test.wps";
            String outputPath = "D:\\test\\test.pdf";
            PdfUtil.convertWordToPdf(inputPath, outputPath);
            System.out.println("转换成功！");
        } catch (Exception e) {
            System.err.println("转换失败：" + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 统一转换入口：支持 .wps / .doc / .docx
     * @param wordPath 源文件路径（.wps/.doc/.docx）
     * @param pdfPath  输出PDF路径
     */
    public static void convertWordToPdf(String wordPath, String pdfPath) throws Exception {
        File wordFile = new File(wordPath);
        if (!wordFile.exists()) {
            throw new FileNotFoundException("源文件不存在：" + wordPath);
        }

        // 1. 获取文件后缀
        String suffix = getFileSuffix(wordPath).toLowerCase();
        // 2. 根据后缀/格式适配解析逻辑
        if (suffix.equals("wps")) {
            convertWpsToPdf(wordFile, new File(pdfPath));
        } else if (suffix.equals("doc")) {
            convertDocToPdf(wordFile, new File(pdfPath));
        } else if (suffix.equals("docx")) {
            convertDocxToPdf(wordFile, new File(pdfPath));
        } else {
            throw new IllegalArgumentException("仅支持 .wps / .doc / .docx 格式");
        }
    }

    /**
     * 处理 .wps 格式：自动判断新旧版WPS
     */
    private static void convertWpsToPdf(File wpsFile, File pdfFile) throws Exception {
        try (FileInputStream fis = new FileInputStream(wpsFile)) {
            // 判断是否为XML格式（新版WPS，兼容docx）
            boolean isXmlFormat = isXmlBasedFile(fis);
            if (isXmlFormat) {
                // 新版WPS：按docx逻辑解析
                fis.getChannel().position(0); // 重置流指针
                convertDocxToPdf(wpsFile, pdfFile);
            } else {
                // 旧版WPS：按doc逻辑提取文本
                fis.getChannel().position(0); // 重置流指针
                convertDocToPdf(wpsFile, pdfFile);
            }
        } catch (Exception e) {
            throw new Exception("WPS文件解析失败（建议转存为.docx后重试）：" + e.getMessage());
        }
    }

    /**
     * 处理 .doc 格式（旧版Word/旧版WPS）：仅提取文本
     */
    private static void convertDocToPdf(File docFile, File pdfFile) throws Exception {
        try (FileInputStream fis = new FileInputStream(docFile);
             POIFSFileSystem fs = new POIFSFileSystem(fis);
             HWPFDocument doc = new HWPFDocument(fs);
             FileOutputStream fos = new FileOutputStream(pdfFile)) {

            // 提取文本
            WordExtractor extractor = new WordExtractor(doc);
            String[] paragraphs = extractor.getParagraphText();

            // 生成PDF
            Document pdfDoc = new Document(PDF_PAGE_SIZE, PDF_MARGIN, PDF_MARGIN, PDF_MARGIN, PDF_MARGIN);
            PdfWriter.getInstance(pdfDoc, fos);
            pdfDoc.open();

            for (String paraText : paragraphs) {
                if (paraText == null || paraText.trim().isEmpty()) {
                    continue;
                }
                // 清理无效字符
                String cleanText = paraText.replaceAll("\\u0000", "").trim();
                com.lowagie.text.Paragraph pdfPara = new com.lowagie.text.Paragraph(cleanText, PDF_DEFAULT_FONT);
                pdfPara.setSpacingAfter(5);
                pdfDoc.add(pdfPara);
            }

            pdfDoc.close();
            extractor.close();
        }
    }

    /**
     * 处理 .docx / 新版WPS 格式：支持文本+表格+图片
     */
    private static void convertDocxToPdf(File docxFile, File pdfFile) throws Exception {
        try (FileInputStream fis = new FileInputStream(docxFile);
             XWPFDocument doc = new XWPFDocument(fis);
             FileOutputStream fos = new FileOutputStream(pdfFile)) {

            Document pdfDoc = new Document(PDF_PAGE_SIZE, PDF_MARGIN, PDF_MARGIN, PDF_MARGIN, PDF_MARGIN);
            PdfWriter.getInstance(pdfDoc, fos);
            pdfDoc.open();

            // 处理段落
            List<XWPFParagraph> wordParagraphs = doc.getParagraphs();
            for (XWPFParagraph wordPara : wordParagraphs) {
                if (wordPara.isEmpty()) {
                    continue;
                }
                com.lowagie.text.Paragraph pdfPara = parseWordParagraphToPdfPara(wordPara);
                if (!pdfPara.isEmpty()) {
                    pdfDoc.add(pdfPara);
                }
            }

            // 处理表格
            List<XWPFTable> wordTables = doc.getTables();
            for (XWPFTable wordTable : wordTables) {
                PdfPTable pdfTable = parseWordTableToPdfTable(wordTable);
                pdfDoc.add(pdfTable);
            }

            pdfDoc.close();
        }
    }

    // ==================== 工具方法 ====================
    /**
     * 判断文件是否为XML格式（新版WPS/.docx）
     */
    private static boolean isXmlBasedFile(InputStream is) throws IOException {
        byte[] header = new byte[8];
        int read = is.read(header);
        if (read < 8) {
            return false;
        }
        // OOXML格式（docx/新版WPS）的文件头特征：PK开头（ZIP压缩）
        return header[0] == 0x50 && header[1] == 0x4B && (header[2] == 0x03 || header[2] == 0x05 || header[2] == 0x07);
    }

    /**
     * 获取文件后缀
     */
    private static String getFileSuffix(String filePath) {
        int lastDotIndex = filePath.lastIndexOf(".");
        if (lastDotIndex == -1) {
            return "";
        }
        return filePath.substring(lastDotIndex + 1);
    }

    /**
     * 解析段落为PDF格式
     */
    private static com.lowagie.text.Paragraph parseWordParagraphToPdfPara(XWPFParagraph wordPara) throws Exception {
        com.lowagie.text.Paragraph pdfPara = new com.lowagie.text.Paragraph();
        pdfPara.setFont(PDF_DEFAULT_FONT);
        pdfPara.setSpacingAfter(5);

        for (XWPFRun wordRun : wordPara.getRuns()) {
            // 文本
            String text = wordRun.getText(0);
            if (text != null && !text.trim().isEmpty()) {
                pdfPara.add(new Chunk(text.trim(), PDF_DEFAULT_FONT));
            }
            // 图片
            for (XWPFPicture wordPic : wordRun.getEmbeddedPictures()) {
                XWPFPictureData picData = wordPic.getPictureData();
                Image pdfImage = Image.getInstance(picData.getData());
                float maxWidth = PDF_PAGE_SIZE.getWidth() - 2 * PDF_MARGIN;
                if (pdfImage.getWidth() > maxWidth) {
                    pdfImage.scaleToFit(maxWidth, pdfImage.getHeight() * (maxWidth / pdfImage.getWidth()));
                }
                pdfPara.add(pdfImage);
            }
        }
        return pdfPara;
    }

    /**
     * 解析表格为PDF格式
     */
    private static PdfPTable parseWordTableToPdfTable(XWPFTable wordTable) {
        int colCount = wordTable.getRow(0).getTableCells().size();
        PdfPTable pdfTable = new PdfPTable(colCount);
        pdfTable.setWidthPercentage(100);
        pdfTable.setSpacingBefore(10);

        for (XWPFTableRow wordRow : wordTable.getRows()) {
            for (XWPFTableCell wordCell : wordRow.getTableCells()) {
                PdfPCell pdfCell = new PdfPCell();
                pdfCell.setPadding(5);

                com.lowagie.text.Paragraph cellPara = new com.lowagie.text.Paragraph();
                cellPara.setFont(PDF_DEFAULT_FONT);
                for (XWPFParagraph p : wordCell.getParagraphs()) {
                    for (XWPFRun r : p.getRuns()) {
                        String text = r.getText(0);
                        if (text != null) {
                            cellPara.add(new Chunk(text.trim(), PDF_DEFAULT_FONT));
                        }
                    }
                }
                pdfCell.addElement(cellPara);
                pdfTable.addCell(pdfCell);
            }
        }
        return pdfTable;
    }


}
