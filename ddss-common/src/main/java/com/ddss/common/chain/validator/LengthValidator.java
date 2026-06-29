package com.ddss.common.chain.validator;

import com.ddss.common.chain.AbstractValidationHandler;
import com.ddss.common.chain.ValidationResult;

import java.lang.reflect.Field;

public class LengthValidator extends AbstractValidationHandler {
    private final String fieldName;
    private final int min;
    private final int max;
    private final String errorMessage;

    public LengthValidator(String fieldName, int min, int max, String errorMessage) {
        this.fieldName = fieldName;
        this.min = min;
        this.max = max;
        this.errorMessage = errorMessage;
    }

    @Override
    protected ValidationResult doValidate(Object target) {
        try {
            Field field = target.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            Object value = field.get(target);
            if (value instanceof String) {
                int length = ((String) value).length();
                if (length < min || length > max) {
                    return ValidationResult.fail(errorMessage);
                }
            }
        } catch (NoSuchFieldException | IllegalAccessException e) {
            return ValidationResult.fail("Validation error: " + e.getMessage());
        }
        return ValidationResult.success();
    }
}
