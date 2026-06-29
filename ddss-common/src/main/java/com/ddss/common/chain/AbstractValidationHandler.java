package com.ddss.common.chain;

public abstract class AbstractValidationHandler implements ValidationHandler {
    protected ValidationHandler next;

    public ValidationHandler setNext(ValidationHandler next) {
        this.next = next;
        return next;
    }

    protected abstract ValidationResult doValidate(Object target);

    @Override
    public ValidationResult handle(Object target) {
        ValidationResult result = doValidate(target);
        if (!result.isValid()) {
            return result;
        }
        if (next != null) {
            return next.handle(target);
        }
        return ValidationResult.success();
    }
}
