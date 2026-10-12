package com.ddss.framework.aspectj;

import com.ddss.common.annotation.Cacheable;
import com.ddss.common.core.redis.RedisCache;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.DefaultParameterNameDiscoverer;
import org.springframework.core.ParameterNameDiscoverer;
import org.springframework.expression.EvaluationContext;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.expression.spel.support.StandardEvaluationContext;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;

@Aspect
@Component
public class CacheAspect {

    private static final Logger log = LoggerFactory.getLogger(CacheAspect.class);

    @Autowired
    private RedisCache redisCache;

    private final ExpressionParser parser = new SpelExpressionParser();
    private final ParameterNameDiscoverer discoverer = new DefaultParameterNameDiscoverer();

    @Around("@annotation(cacheable)")
    public Object around(ProceedingJoinPoint point, Cacheable cacheable) throws Throwable {
        String cacheName = cacheable.cacheName();
        String keyExpression = cacheable.key();
        long ttl = cacheable.ttl();

        String cacheKey = cacheName + ":" + resolveKey(point, keyExpression);

        return redisCache.getOrSet(cacheKey, () -> {
            try {
                return point.proceed();
            } catch (Throwable e) {
                throw new RuntimeException(e);
            }
        }, ttl);
    }

    private String resolveKey(ProceedingJoinPoint point, String expression) {
        if (expression == null || expression.isEmpty()) {
            return generateDefaultKey(point);
        }

        try {
            MethodSignature signature = (MethodSignature) point.getSignature();
            Method method = signature.getMethod();
            String[] parameterNames = discoverer.getParameterNames(method);
            Object[] args = point.getArgs();

            EvaluationContext context = new StandardEvaluationContext();
            if (parameterNames != null) {
                for (int i = 0; i < parameterNames.length; i++) {
                    context.setVariable(parameterNames[i], args[i]);
                }
            }

            Object value = parser.parseExpression(expression).getValue(context);
            return value != null ? value.toString() : generateDefaultKey(point);
        } catch (Exception e) {
            log.warn("Failed to resolve SpEL expression '{}', using default key", expression, e);
            return generateDefaultKey(point);
        }
    }

    private String generateDefaultKey(ProceedingJoinPoint point) {
        MethodSignature signature = (MethodSignature) point.getSignature();
        StringBuilder key = new StringBuilder(signature.getMethod().getName());
        Object[] args = point.getArgs();
        if (args != null) {
            for (Object arg : args) {
                key.append(":").append(arg != null ? arg.toString() : "null");
            }
        }
        return key.toString();
    }
}
