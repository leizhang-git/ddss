# 用户认证系统改进 设计文档

## 架构概览

### 整体架构
采用前后端分离的微服务架构，认证服务独立部署：

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   前端应用     │    │   认证服务     │    │   业务服务     │
│                │    │                │    │                │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Vue.js    │ │    │ │  Spring     │ │    │ │  Spring     │ │
│ │   Router    │ │    │ │  Boot       │ │    │ │  Boot       │ │
│ └─────────────┘ │    │ │  Security   │ │    │ │  Services   │ │
│                │    │ └─────────────┘ │    │ └─────────────┘ │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Element   │ │    │ │  JWT        │ │    │ │   APIs      │ │
│ │   UI        │ │    │ │  Handler    │ │    │ │             │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                │    │ ┌─────────────┐ │    │                │
│ ┌─────────────┐ │    │ │  Redis      │ │    │                │
│ │   Axios     │ │    │ │  Cache      │ │    │                │
│ └─────────────┘ │    │ └─────────────┘ │    │                │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   数据库       │
                    │                │
                    │ ┌─────────────┐ │
                    │ │   MySQL     │ │
                    │ │  Users      │ │
                    │ │  Sessions   │ │
                    │ │  Logs       │ │
                    │ └─────────────┘ │
                    │                │
                    │ ┌─────────────┐ │
                    │ │   Redis     │ │
                    │ │   Tokens    │ │
                    │ └─────────────┘ │
                    └─────────────────┘
```

### 关键组件
1. **认证服务**：处理所有认证相关逻辑
2. **前端应用**：用户界面和认证流程
3. **业务服务**：调用认证服务进行权限验证
4. **数据库集群**：用户数据和会话管理
5. **缓存层**：JWT 令牌缓存

## 技术选型

### 后端技术
- **框架**：Spring Boot 2.5.15
- **安全框架**：Spring Security 5.7
- **JWT 库**：jjwt 0.11.5
- **数据库**：MySQL 8.0
- **缓存**：Redis 6.0
- **邮件**：Spring Mail
- **日志**：Logback + ELK Stack

### 前端技术
- **框架**：Vue 2.6.14
- **UI 库**：Element UI 2.15.7
- **HTTP 客户端**：Axios 0.21.1
- **状态管理**：Vuex 3.6.2
- **路由**：Vue Router 3.5.1
- **构建工具**：Vue CLI 4.5

### 部署技术
- **容器化**：Docker + Docker Compose
- **容器编排**：Kubernetes (生产)
- **API 网关**：Nginx + Spring Cloud Gateway
- **监控**：Prometheus + Grafana

## 数据库设计

### 用户表 (sys_user)
```sql
CREATE TABLE sys_user (
  user_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
  username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
  password VARCHAR(100) NOT NULL COMMENT '密码(BCrypt加密)',
  email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
  phone VARCHAR(20) COMMENT '手机号',
  avatar VARCHAR(255) COMMENT '头像URL',
  real_name VARCHAR(50) COMMENT '真实姓名',
  status TINYINT DEFAULT 1 COMMENT '状态(0-禁用,1-启用)',
  login_fail_count INT DEFAULT 0 COMMENT '登录失败次数',
  last_login_time DATETIME COMMENT '最后登录时间',
  last_login_ip VARCHAR(50) COMMENT '最后登录IP',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  create_by BIGINT COMMENT '创建人',
  update_by BIGINT COMMENT '更新人',
  remark VARCHAR(500) COMMENT '备注'
) COMMENT '用户信息表';
```

### 登录日志表 (sys_login_log)
```sql
CREATE TABLE sys_login_log (
  log_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
  username VARCHAR(50) NOT NULL COMMENT '用户名',
  login_type TINYINT NOT NULL COMMENT '登录类型(0-账号密码,1-验证码)',
  ip VARCHAR(50) NOT NULL COMMENT '登录IP',
  location VARCHAR(100) COMMENT '登录地点',
  browser VARCHAR(100) COMMENT '浏览器类型',
  os VARCHAR(100) COMMENT '操作系统',
  status TINYINT NOT NULL COMMENT '状态(0-失败,1-成功)',
  msg VARCHAR(500) COMMENT '消息',
  login_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间'
) COMMENT '系统登录日志表';
```

### 令牌表 (sys_token)
```sql
CREATE TABLE sys_token (
  token_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '令牌ID',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  token VARCHAR(500) NOT NULL UNIQUE COMMENT '令牌值',
  device_type VARCHAR(20) NOT NULL COMMENT '设备类型(PC,MOBILE)',
  device_info VARCHAR(500) COMMENT '设备信息',
  expire_time DATETIME NOT NULL COMMENT '过期时间',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY idx_user_device (user_id, device_type)
) COMMENT '系统登录令牌表';
```

## API 设计

### 认证相关 API

#### 1. 用户登录
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "123456",
  "rememberMe": false
}

Response:
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 7200,
    "user": {
      "userId": 1,
      "username": "admin",
      "email": "admin@example.com",
      "realName": "管理员",
      "avatar": null,
      "permissions": ["admin"]
    }
  }
}
```

#### 2. 令牌刷新
```
POST /api/auth/refresh
Authorization: Bearer <token>

Response:
{
  "code": 200,
  "message": "刷新成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 7200
  }
}
```

#### 3. 用户登出
```
POST /api/auth/logout
Authorization: Bearer <token>

Response:
{
  "code": 200,
  "message": "登出成功"
}
```

#### 4. 密码重置请求
```
POST /api/auth/reset-password/request
Content-Type: application/json

{
  "email": "user@example.com"
}

Response:
{
  "code": 200,
  "message": "重置邮件已发送"
}
```

#### 5. 密码重置确认
```
POST /api/auth/reset-password/confirm
Content-Type: application/json

{
  "token": "reset-token-123",
  "newPassword": "new-password-123",
  "confirmPassword": "new-password-123"
}

Response:
{
  "code": 200,
  "message": "密码重置成功"
}
```

### 权限验证拦截器

```java
@Component
public class JwtAuthenticationInterceptor implements HandlerInterceptor {
    
    @Autowired
    private JwtTokenUtils jwtTokenUtils;
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                           HttpServletResponse response, 
                           Object handler) throws Exception {
        
        // 1. 检查是否是公共接口
        if (handler instanceof HandlerMethod) {
            HandlerMethod handlerMethod = (HandlerMethod) handler;
            if (handlerMethod.hasMethodAnnotation(Public.class)) {
                return true;
            }
        }
        
        // 2. 获取令牌
        String token = request.getHeader("Authorization");
        if (token == null || !token.startsWith("Bearer ")) {
            throw new AuthenticationException("未登录或token已经过期");
        }
        
        token = token.substring(7);
        
        // 3. 验证令牌
        try {
            if (jwtTokenUtils.validateToken(token)) {
                // 4. 设置用户信息到SecurityContext
                UsernamePasswordAuthenticationToken authentication = 
                    jwtTokenUtils.getAuthentication(token);
                SecurityContextHolder.getContext().setAuthentication(authentication);
                return true;
            }
        } catch (JwtException e) {
            throw new AuthenticationException("token验证失败");
        }
        
        return false;
    }
    
    @Override
    public void afterCompletion(HttpServletRequest request, 
                              HttpServletResponse response, 
                              Object handler, 
                              Exception ex) {
        SecurityContextHolder.clearContext();
    }
}
```

## 安全设计

### 密码安全
1. **密码加密**：使用 BCrypt 哈希算法
2. **密码复杂度**：至少 8 位，包含大小写、数字和特殊字符
3. **密码历史**：保存最近 5 次密码，防止重复使用

```java
@Service
public class PasswordEncoderImpl implements PasswordEncoder {
    
    @Override
    public String encode(CharSequence rawPassword) {
        return BCrypt.hashpw(rawPassword.toString(), BCrypt.gensalt());
    }
    
    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        return BCrypt.checkpw(rawPassword.toString(), encodedPassword);
    }
}
```

### JWT 安全
1. **签名算法**：HS256（对称加密）
2. **密钥管理**：通过环境变量配置
3. **过期时间**：Access Token 2 小时，Refresh Token 7 天
4. **令牌刷新**：使用 Refresh Token 获取新的 Access Token

### 登录安全
1. **失败限制**：连续失败 5 次，锁定 30 分钟
2. **IP 黑名单**：记录异常登录 IP
3. **双因素认证**：可选的短信验证码

```java
@Service
public class LoginServiceImpl implements LoginService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private LoginLogRepository loginLogRepository;
    
    private static final int MAX_LOGIN_FAIL_COUNT = 5;
    private static final long LOCK_TIME = 30 * 60 * 1000; // 30分钟
    
    public LoginResult login(String username, String password, String ip) {
        User user = userRepository.findByUsername(username);
        
        // 检查用户是否存在
        if (user == null) {
            logLogin(username, ip, false, "用户不存在");
            throw new AuthenticationException("用户名或密码错误");
        }
        
        // 检查用户是否被锁定
        if (user.getStatus() == 0) {
            logLogin(username, ip, false, "用户已被禁用");
            throw new AuthenticationException("用户已被禁用");
        }
        
        // 检查登录失败次数
        if (user.getLoginFailCount() >= MAX_LOGIN_FAIL_COUNT) {
            if (System.currentTimeMillis() - user.getLastFailTime() < LOCK_TIME) {
                logLogin(username, ip, false, "登录失败次数过多，请稍后再试");
                throw new AuthenticationException("登录失败次数过多，请稍后再试");
            } else {
                // 重置失败次数
                user.setLoginFailCount(0);
                userRepository.save(user);
            }
        }
        
        // 验证密码
        if (!passwordEncoder.matches(password, user.getPassword())) {
            user.setLoginFailCount(user.getLoginFailCount() + 1);
            user.setLastFailTime(System.currentTimeMillis());
            userRepository.save(user);
            
            logLogin(username, ip, false, "密码错误");
            throw new AuthenticationException("用户名或密码错误");
        }
        
        // 登录成功
        user.setLoginFailCount(0);
        user.setLastLoginTime(new Date());
        user.setLastLoginIp(ip);
        userRepository.save(user);
        
        logLogin(username, ip, true, "登录成功");
        
        return createLoginResult(user);
    }
}
```

## 性能考虑

### 缓存策略
1. **JWT 令牌缓存**：Redis 缓存活跃令牌，快速验证
2. **用户信息缓存**：Redis 缓存用户基本信息，减少数据库查询
3. **权限缓存**：Redis 缓存用户权限，每次请求验证一次

```java
@Service
public class CacheServiceImpl {
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    private static final String TOKEN_PREFIX = "auth:token:";
    private static final String USER_PREFIX = "user:";
    private static final String PERMISSION_PREFIX = "permission:";
    
    public void cacheToken(String token, Long userId, long expireTime) {
        redisTemplate.opsForValue().set(
            TOKEN_PREFIX + token, 
            userId, 
            Duration.ofSeconds(expireTime)
        );
    }
    
    public Long getUserIdFromToken(String token) {
        Object userId = redisTemplate.opsForValue().get(TOKEN_PREFIX + token);
        return userId != null ? Long.valueOf(userId.toString()) : null;
    }
    
    public void cacheUserInfo(User user) {
        redisTemplate.opsForValue().set(
            USER_PREFIX + user.getUserId(),
            user,
            Duration.ofHours(1)
        );
    }
}
```

### 数据库优化
1. **索引设计**：
   - 用户表：username、email 索引
   - 登录日志表：username、login_time 索引
   - 令牌表：user_id、device_type 复合索引

2. **查询优化**：
   - 使用缓存减少数据库查询
   - 分页处理大量数据
   - 避免全表扫描

## 监控和日志

### 监控指标
1. **业务指标**：
   - 登录成功/失败次数
   - 令牌刷新次数
   - 密码重置次数

2. **技术指标**：
   - API 响应时间
   - 错误率
   - 系统资源使用率

### 日志规范
1. **结构化日志**：使用 JSON 格式
2. **日志级别**：DEBUG、INFO、WARN、ERROR
3. **敏感信息**：不记录密码等敏感信息

```java
@Component
public class LoginLogAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(LoginLogAspect.class);
    
    @Autowired
    private LoginLogRepository loginLogRepository;
    
    @AfterReturning(pointcut = "execution(* com.example.service.LoginService.login(..))", 
                   returning = "result")
    public void logLoginSuccess(JoinPoint joinPoint, LoginResult result) {
        String username = (String) joinPoint.getArgs()[0];
        String ip = request.getRemoteAddr();
        
        LoginLog log = new LoginLog();
        log.setUsername(username);
        log.setLoginType(0);
        log.setIp(ip);
        log.setStatus(1);
        log.setMsg("登录成功");
        log.setLoginTime(new Date());
        
        loginLogRepository.save(log);
        
        logger.info("用户登录成功: username={}, ip={}", username, ip);
    }
}
```

## 部署要求

### 环境要求
- **JDK**：8+
- **MySQL**：8.0+
- **Redis**：5.0+
- **Node.js**：14+（前端）
- **Nginx**：1.18+

### 配置文件
application.yml：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ddss?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:password}
    driver-class-name: com.mysql.cj.jdbc.Driver
  redis:
    host: ${REDIS_HOST:localhost}
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PASSWORD:}
    database: 0
  mail:
    host: ${MAIL_HOST:smtp.gmail.com}
    port: 587
    username: ${MAIL_USERNAME:}
    password: ${MAIL_PASSWORD:}
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
            required: true

jwt:
  secret: ${JWT_SECRET:mySecretKey}
  expiration: 7200 # 2小时
  refresh-expiration: 604800 # 7天
```

### Docker 部署
docker-compose.yml：
```yaml
version: '3.8'
services:
  auth-service:
    build: ./auth-service
    ports:
      - "8081:8080"
    environment:
      - DB_HOST=mysql
      - DB_PORT=3306
      - REDIS_HOST=redis
    depends_on:
      - mysql
      - redis
    
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: ddss
    volumes:
      - mysql-data:/var/lib/mysql
  
  redis:
    image: redis:6.0
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

volumes:
  mysql-data:
  redis-data:
```

## 测试策略

### 单元测试
1. **认证服务测试**：登录、登出、令牌验证
2. **密码编码测试**：加密、验证算法
3. **JWT 工具测试**：生成、验证、刷新令牌

### 集成测试
1. **API 接口测试**：所有认证相关接口
2. **数据库测试**：数据持久化操作
3. **缓存测试**：Redis 缓存功能

### 安全测试
1. **渗透测试**：SQL 注入、XSS 攻击
2. **令牌安全**：令牌泄露、重放攻击
3. **密码安全**：暴力破解测试

## 迁移计划

### 数据迁移
1. **用户数据迁移**：从旧系统导入用户信息
2. **密码迁移**：重新加密现有密码
3. **权限数据迁移**：保持现有权限结构

### 灰度发布
1. **阶段 1**：只读模式，不处理认证请求
2. **阶段 2**：处理部分用户的认证请求
3. **阶段 3**：全面切换到新认证系统

### 回滚方案
1. **快速回滚**：切换到旧认证系统
2. **数据恢复**：从备份恢复用户数据
3. **故障转移**：使用备用认证服务