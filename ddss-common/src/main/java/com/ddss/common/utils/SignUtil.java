package com.ddss.common.utils;

import org.apache.commons.codec.binary.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

/**
 * @Auth zhanglei
 * @Date 2023/3/4 21:54
 */
public class SignUtil {

    private static int NCC_SIGN_TIMEOUT_SECOND = 3600;
    private static Logger log = LoggerFactory.getLogger(SignUtil.class);

    public static String buildSign(String uri, Map<String, String> params, String secret) {
        try {
            Mac hmacSha256 = Mac.getInstance("HmacSHA256");
            byte[] keyBytes = secret.getBytes("UTF-8");
            hmacSha256.init(new SecretKeySpec(keyBytes, 0, keyBytes.length, "HmacSHA256"));
            String sign = new String(Base64.encodeBase64(hmacSha256.doFinal(buildSrcStr(uri, params).getBytes("UTF-8"))), "UTF-8");
            sign = sign.replace("+", ".").replace("/", "_");
            return sign;
        } catch (Exception var6) {
            throw new RuntimeException(var6);
        }
    }

    public static String buildSrcStr(String uri, Map<String, String> params) {
        StringBuilder sb = new StringBuilder();
        Map<String, String> sortMap = new TreeMap();
        if (null != params) {
            Iterator var4 = params.entrySet().iterator();

            while(var4.hasNext()) {
                Map.Entry<String, String> query = (Map.Entry)var4.next();
                if (!StringUtils.isBlank((String)query.getKey()) && !"sign".equals(query.getKey())) {
                    sortMap.put(query.getKey(), query.getValue());
                }
            }
        }

        StringBuilder sbParam = new StringBuilder();
        Iterator var8 = sortMap.entrySet().iterator();

        while(var8.hasNext()) {
            Map.Entry<String, String> item = (Map.Entry)var8.next();
            if (!StringUtils.isBlank((String)item.getKey())) {
                if (0 < sbParam.length()) {
                    sbParam.append("&");
                }

                sbParam.append((String)item.getKey());
                if (!StringUtils.isBlank((String)item.getValue())) {
                    sbParam.append("=").append((String)item.getValue());
                }
            }
        }

        sb.append(getURLEncoderString(uri) + "&" + getURLEncoderString(sbParam.toString()));
        return sb.toString();
    }

    public static String getURLEncoderString(String str) {
        String result = "";
        if (null == str) {
            return "";
        } else {
            try {
                result = URLEncoder.encode(str, "UTF-8");
                return result;
            } catch (UnsupportedEncodingException var3) {
                throw new RuntimeException(var3);
            }
        }
    }
}
