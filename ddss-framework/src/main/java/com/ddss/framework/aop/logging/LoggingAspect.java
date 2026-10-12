package com.ddss.framework.aop.logging;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;

import java.util.Arrays;

/**
 * Service/Repository/RestController 三层方法进出与异常切面
 *
 * <p>移植自 iuap-data-common 的 LoggingAspect（作者 lzx），切点按 ddss 分层调整：
 * consumer 契约层引用 com.ddss.**.service 接口，provider 实现层在 com.ddss.**.service.impl、
 * com.ddss.**.mapper、com.ddss.**.web.rest。
 *
 * <p>默认只在 dev profile 下生效（见 LoggingAspectConfiguration），
 * 业务操作日志请用 @Log 注解的 LogAspect，本切面只负责开发期诊断。
 *
 * @author ddss（移植）
 */
@Aspect
public class LoggingAspect {

    private final Logger log = LoggerFactory.getLogger(this.getClass());

    private final Environment env;

    public LoggingAspect(Environment env) {
        this.env = env;
    }

    /**
     * 契约点：匹配所有 @Repository / @Service / @RestController 注解的 Spring Bean
     */
    @Pointcut("within(@org.springframework.stereotype.Repository *)" +
        " || within(@org.springframework.stereotype.Service *)" +
        " || within(@org.springframework.web.bind.annotation.RestController *)")
    public void springBeanPointcut() {
        // Method is empty as this is just a Pointcut, the implementations are in the advices.
    }

    /**
     * 应用点：匹配 ddss 的 mapper / service(含 impl) / web.rest 包下所有类
     */
    @Pointcut("within(com.ddss..*.mapper..*)" +
        " || within(com.ddss..*.service..*)" +
        " || within(com.ddss..*.web.rest..*)")
    public void applicationPackagePointcut() {
        // Method is empty as this is just a Pointcut, the implementations are in the advices.
    }

    /**
     * 异常 advice：dev 打印完整参数与原因链，非 dev 只打印概要（避免敏感参数外泄）
     *
     * @param joinPoint join point for advice
     * @param e         捕获的异常
     */
    @AfterThrowing(pointcut = "applicationPackagePointcut() && springBeanPointcut()", throwing = "e")
    public void logAfterThrowing(JoinPoint joinPoint, Throwable e) {
        if (env.acceptsProfiles("dev")) {
            log.error("Exception in {}.{}() with cause = '{}' and argument[s] = {} and exception = '{}'",
                joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName(),
                e.getCause() != null ? e.getCause() : "NULL",
                Arrays.toString(joinPoint.getArgs()),
                e.getMessage(), e);
        } else {
            log.error("Exception in {}.{}() with cause = {} and argument[s] = {}",
                joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName(),
                e.getCause() != null ? e.getCause() : "NULL",
                Arrays.toString(joinPoint.getArgs()));
        }
    }

    /**
     * 环绕 advice：debug 级别输出方法进出与返回值
     *
     * @param joinPoint join point for advice
     * @return 结果
     * @throws Throwable 抛出业务异常
     */
    @Around("applicationPackagePointcut() && springBeanPointcut()")
    public Object logAround(ProceedingJoinPoint joinPoint) throws Throwable {
        if (log.isDebugEnabled()) {
            log.debug("Enter: {}.{}() with argument[s] = {}",
                joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName(),
                Arrays.toString(joinPoint.getArgs()));
        }
        try {
            Object result = joinPoint.proceed();
            if (log.isDebugEnabled()) {
                log.debug("Exit: {}.{}() with result = {}",
                    joinPoint.getSignature().getDeclaringTypeName(),
                    joinPoint.getSignature().getName(),
                    result);
            }
            return result;
        } catch (IllegalArgumentException e) {
            log.error("Illegal argument: {} in {}.{}()",
                Arrays.toString(joinPoint.getArgs()),
                joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName());
            throw e;
        }
    }
}
