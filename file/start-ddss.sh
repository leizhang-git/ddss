#!/bin/bash
# SpringBoot 应用启动脚本（Java8 + 修复进程检测误判）
# 适配：ddss-bootstrap.jar | 8088端口 | /data/app/ | /data/applogs/app/

# ======================== 核心配置项（无需修改）========================
APP_NAME="ddss-bootstrap.jar"
APP_DIR="/data/app/"
APP_PATH="${APP_DIR}${APP_NAME}"
APP_PORT=8088
DEBUG_PORT=5005
JVM_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+HeapDumpOnOutOfMemoryError"
LOGBACK_LOG_FILE="/data/applogs/app/ddss-app.log"
# ======================== 配置项结束 =========================

# Java8兼容的远程调试参数
DEBUG_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:${DEBUG_PORT}"

# 修复：更健壮的进程检测逻辑（双维度验证）
is_running() {
    # 方式1：通过端口查PID（兼容不同netstat格式）
    pid=$(ss -tlnp 2>/dev/null | grep ":${APP_PORT}" | awk -F',' '{print $2}' | awk -F'=' '{print $2}' | head -n1)
    if [ -z "${pid}" ]; then
        # 方式2：通过进程名查PID（兜底）
        pid=$(ps -ef 2>/dev/null | grep "${APP_NAME}" | grep -v grep | awk '{print $2}' | head -n1)
    fi
    
    # 最终验证：PID存在且是有效进程
    if [ -n "${pid}" ] && ps -p ${pid} >/dev/null 2>&1; then
        return 0
    else
        pid=""
        return 1
    fi
}

# 检查Jar包是否存在
check_app_exists() {
    if [ ! -f "${APP_PATH}" ]; then
        echo "错误：Jar包不存在！路径：${APP_PATH}"
        exit 1
    fi
}

# 确保日志目录存在
ensure_log_dir() {
    LOG_DIR=$(dirname ${LOGBACK_LOG_FILE})
    if [ ! -d "${LOG_DIR}" ]; then
        echo "日志目录 ${LOG_DIR} 不存在，正在创建..."
        mkdir -p ${LOG_DIR}
        chmod 755 ${LOG_DIR}
    fi
}

# 启动程序
start() {
    check_app_exists
    ensure_log_dir
    
    if is_running; then
        echo "================================"
        echo "应用 ${APP_NAME} 已在运行中"
        echo "PID: ${pid}"
        echo "远程调试端口: ${DEBUG_PORT}"
        echo "================================"
        return
    fi

    echo "================================"
    echo "正在启动 ${APP_NAME} (Java8环境)..."
    echo "部署路径: ${APP_PATH}"
    echo "应用端口: ${APP_PORT}"
    echo "远程调试已开启，调试端口: ${DEBUG_PORT}"
    echo "日志文件路径: ${LOGBACK_LOG_FILE}"
    echo "================================"
    
    cd ${APP_DIR}
    nohup java ${JVM_OPTS} ${DEBUG_OPTS} -jar ${APP_PATH} >> ${LOGBACK_LOG_FILE} 2>&1 &
    # ✅ 延长等待时间，适配应用启动较慢的场景
    sleep 8

    if is_running; then
        echo "应用启动成功，PID: ${pid}"
    else
        echo "⚠️  脚本检测启动状态异常，但请手动验证："
        echo "   1. 执行 netstat -anp | grep 8088 查看端口是否监听"
        echo "   2. 执行 ps -ef | grep ${APP_NAME} 查看进程是否存在"
        echo "   3. 查看日志：${LOGBACK_LOG_FILE}"
    fi
}

stop() {
    if ! is_running; then
        echo "================================"
        echo "应用 ${APP_NAME} 未运行"
        echo "================================"
        return
    fi

    echo "================================"
    echo "正在停止 ${APP_NAME} (PID: ${pid})..."
    kill -15 ${pid} >/dev/null 2>&1
    sleep 5

    if is_running; then
        echo "优雅停止失败，强制杀死进程..."
        kill -9 ${pid} >/dev/null 2>&1
        sleep 2
    fi
    echo "应用已停止"
    echo "================================"
}

restart() {
    echo "================================"
    echo "正在重启 ${APP_NAME} ..."
    echo "================================"
    stop
    start
}

status() {
    echo "================================"
    echo "应用基本信息："
    echo "Jar包名称: ${APP_NAME}"
    echo "部署路径: ${APP_PATH}"
    echo "应用端口: ${APP_PORT}"
    echo "调试端口: ${DEBUG_PORT}"
    echo "日志文件: ${LOGBACK_LOG_FILE}"
    echo "--------------------------------"
    if is_running; then
        echo "运行状态: 运行中"
        echo "PID: ${pid}"
        # 补充端口监听状态
        if netstat -anp 2>/dev/null | grep ":${APP_PORT}" | grep LISTEN >/dev/null; then
            echo "端口状态: 8088 已监听"
        fi
    else
        echo "运行状态: 已停止"
    fi
    echo "================================"
}

logs() {
    if [ -f "${LOGBACK_LOG_FILE}" ]; then
        echo "实时查看日志（按Ctrl+C退出）：${LOGBACK_LOG_FILE}"
        tail -f ${LOGBACK_LOG_FILE}
    else
        echo "日志文件 ${LOGBACK_LOG_FILE} 不存在！"
    fi
}

usage() {
    echo "使用说明: $0 {start|stop|restart|status|logs}"
    echo "  start   - 启动应用（开启远程调试）"
    echo "  stop    - 停止应用"
    echo "  restart - 重启应用"
    echo "  status  - 查看应用状态"
    echo "  logs    - 实时查看logback日志"
    exit 1
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    *)
        usage
        ;;
esac
