package com.ddss.common.chain;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class ValidationChain {
    private final List<ValidationHandler> handlers = new ArrayList<>();

    public ValidationChain addHandler(ValidationHandler handler) {
        handlers.add(handler);
        return this;
    }

    public ValidationResult execute(Object target) {
        for (ValidationHandler handler : handlers) {
            ValidationResult result = handler.handle(target);
            if (!result.isValid()) {
                return result;
            }
        }
        return ValidationResult.success();
    }

    public static ValidationChain of(ValidationHandler... handlers) {
        ValidationChain chain = new ValidationChain();
        chain.handlers.addAll(Arrays.asList(handlers));
        return chain;
    }
}
