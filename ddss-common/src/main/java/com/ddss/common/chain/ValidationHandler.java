package com.ddss.common.chain;

public interface ValidationHandler {
    ValidationResult handle(Object target);

    default ValidationResult handleNext(ValidationHandler next, Object target) {
        if (next == null) {
            return ValidationResult.success();
        }
        return next.handle(target);
    }
}
