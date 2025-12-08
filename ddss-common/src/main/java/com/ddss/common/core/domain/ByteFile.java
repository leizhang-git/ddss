package com.ddss.common.core.domain;

import lombok.Data;

/**
 * @Auth zhanglei
 * @Date 2023/2/18 22:57
 */
@Data
public class ByteFile {

    private byte[] byteFile;

    private String fileName;

    public ByteFile(byte[] byteFile, String fileName) {
        this.byteFile = byteFile;
        this.fileName = fileName;
    }
}
