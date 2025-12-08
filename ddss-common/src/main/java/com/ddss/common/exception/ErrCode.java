package com.ddss.common.exception;

/**
 * @Auth zhanglei
 * @Date 2023/2/18 21:10
 */
public enum ErrCode {

    /**
     * zookeeper创建节点失败
     */
    SYS_ZOOK_CREATE_ERROR("SYS-00001", "sys.zook.create.error"),

    /**
     * zookeeper设置节点数据失败
     */
    SYS_ZOOK_SET_NODE_ERROR("SYS-00002", "sys.zook.set.node.error"),

    /**
     * 公共接口报错
     */
    SYS_COMMON_INTERFACE_ERROR("SYS-00003", "sys.common.interface.error"),

    /**
     * 刪除节点失败
     */
    SYS_ZOOK_DELETE_ERROR("SYS-00004", "sys.zook.delete.error"),

    /**
     * key为null
     */
    SYS_JWT_NULL_ERROR("SYS-00005", "sys.jwt.null.error"),

    /**
     * jwtToken超时,请重新获取
     */
    SYS_JWT_KEY_TIMEOUT_ERROR("SYS-00006", "sys.jwt.key.timeout.error"),

    /**
     * 密码错误
     */
    SYS_PASSWORD_ERROR("SYS-00007", "sys.password.error"),

    /**
     * 数据同步失败
     */
    SYS_SYNC_ERROR("sys-00008", "sys.sync.error"),

    /**
     * 没有权限访问
     */
    SYS_NOT_AUTH_ERROR("sys-00009", "sys.not.auth.error");

    /**
     * 异常编码
     */
    private final String errCode;

    /**
     * 异常注释
     */
    private final String errDesc;

    ErrCode(String errCode, String errDesc) {
        this.errCode = errCode;
        this.errDesc = errDesc;
    }

    public String getErrCode() {
        return this.errCode;
    }

    public String getErrDesc() {
        return this.errDesc;
    }

}
