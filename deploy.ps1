# ============================================================
# DDSS 一键部署脚本
# 用法: .\deploy.ps1              # 部署后端+前端
#       .\deploy.ps1 -Backend     # 只部署后端
#       .\deploy.ps1 -Frontend    # 只部署前端
#       .\deploy.ps1 -SkipBuild   # 跳过编译，直接上传
# ============================================================

param(
    [switch]$Backend,
    [switch]$Frontend,
    [switch]$SkipBuild
)

# ==================== 配置区（改成你自己的） ====================
$VM_HOST    = "192.168.xxx.xxx"      # 虚拟机 IP
$VM_USER    = "root"                  # SSH 用户名
$VM_PORT    = 22                      # SSH 端口
$VM_KEY     = "$env:USERPROFILE\.ssh\id_rsa"  # SSH 私钥路径（配置免密登录后就用这个）

# 虚拟机上的路径
$VM_JAR_DIR   = "/opt/ddss"                         # JAR 包存放目录
$VM_START_CMD = "cd $VM_JAR_DIR && ./start.sh restart"  # 重启命令
$VM_NGINX_DIR = "/usr/share/nginx/html"             # Nginx 静态文件目录
$VM_NGINX_RELOAD = "nginx -s reload"                # Nginx 重载命令

# 本机路径（一般不用改）
$PROJECT_ROOT = $PSScriptRoot
$JAR_NAME     = "ddss-bootstrap.jar"
$LOCAL_JAR    = "$PROJECT_ROOT\ddss-bootstrap\target\$JAR_NAME"
$UI_DIR       = "$PROJECT_ROOT\ddss-ui"
$DIST_DIR     = "$UI_DIR\dist"
# =============================================================

$ErrorActionPreference = "Stop"
$deployAll = (-not $Backend -and -not $Frontend)

function Write-Step { Write-Host "`n>> $args" -ForegroundColor Cyan }
function Write-OK   { Write-Host "   OK" -ForegroundColor Green }
function Write-Warn { Write-Host "   WARN: $args" -ForegroundColor Yellow }
function Write-Err  { Write-Host "   ERROR: $args" -ForegroundColor Red }

# SSH 命令封装
function Invoke-SSH($cmd) {
    if (Test-Path $VM_KEY) {
        ssh -i $VM_KEY -p $VM_PORT -o StrictHostKeyChecking=no ${VM_USER}@${VM_HOST} $cmd
    } else {
        ssh -p $VM_PORT -o StrictHostKeyChecking=no ${VM_USER}@${VM_HOST} $cmd
    }
}

# SCP 上传封装
function Invoke-SCP($localPath, $remotePath) {
    if (Test-Path $VM_KEY) {
        scp -i $VM_KEY -P $VM_PORT -o StrictHostKeyChecking=no $localPath ${VM_USER}@${VM_HOST}:${remotePath}
    } else {
        scp -P $VM_PORT -o StrictHostKeyChecking=no $localPath ${VM_USER}@${VM_HOST}:${remotePath}
    }
}

# ==================== 后端部署 ====================
function Deploy-Backend {
    if (-not $SkipBuild) {
        Write-Step "编译后端..."
        mvn clean package -pl ddss-bootstrap -am -DskipTests
        if ($LASTEXITCODE -ne 0) { Write-Err "编译失败"; exit 1 }
        Write-OK
    }

    if (-not (Test-Path $LOCAL_JAR)) {
        Write-Err "找不到 JAR: $LOCAL_JAR"; exit 1
    }

    Write-Step "上传 JAR 到 ${VM_HOST}..."
    Invoke-SCP $LOCAL_JAR "${VM_JAR_DIR}/"
    Write-OK

    Write-Step "重启后端服务..."
    Invoke-SSH $VM_START_CMD
    Write-OK

    Write-Host "后端部署完成!" -ForegroundColor Green
}

# ==================== 前端部署 ====================
function Deploy-Frontend {
    if (-not $SkipBuild) {
        Write-Step "编译前端..."
        Push-Location $UI_DIR
        npm run build:prod
        if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Err "前端编译失败"; exit 1 }
        Pop-Location
        Write-OK
    }

    if (-not (Test-Path $DIST_DIR)) {
        Write-Err "找不到 dist: $DIST_DIR"; exit 1
    }

    Write-Step "上传前端文件到 ${VM_HOST}..."
    # 先清远程目录（保留上级目录结构）
    Invoke-SSH "rm -rf ${VM_NGINX_DIR}/*"
    # 上传 dist 内容
    Get-ChildItem -Path "$DIST_DIR\*" | ForEach-Object {
        Invoke-SCP $_.FullName "${VM_NGINX_DIR}/"
    }
    Write-OK

    Write-Step "重载 Nginx..."
    Invoke-SSH $VM_NGINX_RELOAD
    Write-OK

    Write-Host "前端部署完成!" -ForegroundColor Green
}

# ==================== 主流程 ====================
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DDSS 一键部署" -ForegroundColor Cyan
Write-Host "  目标: ${VM_USER}@${VM_HOST}:${VM_PORT}" -ForegroundColor DarkGray
Write-Host "============================================" -ForegroundColor Cyan

# 检查连通性
Write-Step "检查 VM 连通性..."
$pingResult = Invoke-SSH "echo ok" 2>&1
if ($pingResult -match "ok") {
    Write-OK
} else {
    Write-Err "无法连接虚拟机，请检查 IP / SSH 配置"
    Write-Host "  提示: 先配好免密登录，执行: ssh-copy-id ${VM_USER}@${VM_HOST}" -ForegroundColor Yellow
    exit 1
}

if ($deployAll) {
    Deploy-Backend
    Deploy-Frontend
} else {
    if ($Backend)  { Deploy-Backend }
    if ($Frontend) { Deploy-Frontend }
}

Write-Host "`n全部部署完成!" -ForegroundColor Green
