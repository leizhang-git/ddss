package com.ddss.common.utils;

import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import com.ddss.common.core.domain.ByteFile;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * @Auth zhanglei
 * @Date 2023/2/18 22:56
 */
public class FileUtil {

    /**
     * 将list按行写入到txt文件中
     * @param strings
     * @param path
     * @throws Exception
     */
    public static void writeFileContext(List<String>  strings, String path) throws Exception {
        File file = new File(path);
        //如果没有文件就创建
        if (!file.isFile()) {
            file.createNewFile();
        }
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(path))) {
            for (String l : strings) {
                writer.write(l + "\r\n");
            }
        }
    }

    /**
     * 读取文件内容至List中
     * @param filePath
     * @param list
     * @throws IOException
     */
    public static void getFileContent(String filePath, List<String> list) throws IOException {
        if(ObjectUtil.isEmpty(filePath)) {
            return;
        }
        try (BufferedReader br = new BufferedReader(new InputStreamReader(Files.newInputStream(Paths.get(filePath)), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                if(StrUtil.isNotEmpty(line)) {
                    list.add(line);
                }
            }
        }
    }

    /**
     * 文件转Byte[]
     * @param file
     * @param fileName
     * @return
     * @throws IOException
     */
    public static ByteFile uploadFile(MultipartFile file, String fileName) throws IOException {
        try (InputStream inputStream = file.getInputStream();
             ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()) {
            int i;
            byte[] bytes = new byte[1024];
            //转字节数组流
            while ((i = inputStream.read(bytes)) != -1) {
                byteArrayOutputStream.write(bytes, 0, i);
            }
            //放入字节数组
            byte[] fileByte = byteArrayOutputStream.toByteArray();
            return new ByteFile(fileByte, fileName);
        }
    }

    /**
     * 文件转List
     * @param fileName
     * @return
     * @throws IOException
     */
    public List<String> fileToList(String fileName) throws IOException {
        List<String> result = new ArrayList<>();
        try (BufferedReader bufferedReader = new BufferedReader(new FileReader(fileName))) {
            String str;
            while (null != (str = bufferedReader.readLine())) {
                result.add(str);
            }
        }
        return result;
    }

    public static byte[] inputToByte(InputStream inputStream) throws IOException {
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int num = inputStream.read(buffer);
            while (num != -1) {
                baos.write(buffer, 0, num);
                num = inputStream.read(buffer);
            }
            baos.flush();
            return baos.toByteArray();
        } finally {
            if (inputStream != null) {
                inputStream.close();
            }
        }
    }

    /**
     * 创建目录
     * @param destDirName
     * @return
     */
    public static Boolean createDir(String destDirName) {
        File dir = new File(destDirName);
        //判断有没有父路径，就是判断文件整个路径是否存在
        File parentFile = dir.getParentFile();
        if (parentFile != null && !parentFile.exists()) {
            //不存在就全部创建
            return parentFile.mkdirs();
        }
        return false;
    }
}
