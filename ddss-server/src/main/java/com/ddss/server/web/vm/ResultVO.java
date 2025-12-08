package com.ddss.server.web.vm;


import com.ddss.server.domain.enums.ResultStatusEnum;
import lombok.Data;

/**
 * 接口返回结果
 * @Author zhanglei
 * @Date 2021/3/4 19:15
 */
@Data
public class ResultVO<T> {

    /**
     * 0 失败 1 成功
     */
    private Integer status;

    /**
     * 错误原因
     */
    private String msg;

    /**
     * 返回数据
     */
    private T data;

    public ResultVO(Integer status, String msg, T data) {
        this.status = status;
        this.msg = msg;
        this.data = data;
    }

    public ResultVO(Integer status, String msg) {
        this.status = status;
        this.msg = msg;
    }

    public static <T> ResultVO<T> getSuccess(String msg, T data) {
        return new ResultVO<>(ResultStatusEnum.SUCCESS.getStatus(), msg, data);
    }

    public static <T> ResultVO<T> getSuccess(T data) {
        return new ResultVO<>(ResultStatusEnum.SUCCESS.getStatus(), "SUCCESS", data);
    }

    public static <T> ResultVO<T> getFailed(String msg, T data) {
        return new ResultVO<>(ResultStatusEnum.FAILURE.getStatus(), msg, data);
    }

    public static <T> ResultVO<T> getFailed(String msg) {
        return new ResultVO<>(ResultStatusEnum.FAILURE.getStatus(), msg);
    }

    public static <T> ResultVO<T> getNoAuthorization() {
        return new ResultVO<>(ResultStatusEnum.NO_AUTH.getStatus(), "用户没有权限");
    }
}
