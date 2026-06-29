package com.ddss.common.annotation;

import java.lang.annotation.*;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Cacheable {

    String cacheName() default "";

    String key() default "";

    long ttl() default 3600;
}
