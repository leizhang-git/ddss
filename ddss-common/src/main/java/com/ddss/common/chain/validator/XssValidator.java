package com.ddss.common.chain.validator;

import com.ddss.common.chain.AbstractValidationHandler;
import com.ddss.common.chain.ValidationResult;

import java.lang.reflect.Field;

public class XssValidator extends AbstractValidationHandler {
    private final String fieldName;
    private final String errorMessage;

    public XssValidator(String fieldName, String errorMessage) {
        this.fieldName = fieldName;
        this.errorMessage = errorMessage;
    }

    @Override
    protected ValidationResult doValidate(Object target) {
        try {
            Field field = target.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            Object value = field.get(target);
            if (value instanceof String && com.ddss.common.xss.XssValidator.containsHtml((String) value)) {
                return ValidationResult.fail(errorMessage);
            }
        } catch (NoSuchFieldException | IllegalAccessException e) {
            return ValidationResult.fail("Validation error: " + e.getMessage());
        }
        return ValidationResult.success();
    }
}
