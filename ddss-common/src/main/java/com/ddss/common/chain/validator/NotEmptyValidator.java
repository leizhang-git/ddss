package com.ddss.common.chain.validator;

import com.ddss.common.chain.AbstractValidationHandler;
import com.ddss.common.chain.ValidationResult;
import com.ddss.common.utils.StringUtils;

import java.lang.reflect.Field;

public class NotEmptyValidator extends AbstractValidationHandler {
    private final String fieldName;
    private final String errorMessage;

    public NotEmptyValidator(String fieldName, String errorMessage) {
        this.fieldName = fieldName;
        this.errorMessage = errorMessage;
    }

    @Override
    protected ValidationResult doValidate(Object target) {
        try {
            Field field = target.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            Object value = field.get(target);
            if (value == null || (value instanceof String && StringUtils.isEmpty((String) value))) {
                return ValidationResult.fail(errorMessage);
            }
        } catch (NoSuchFieldException | IllegalAccessException e) {
            return ValidationResult.fail("Validation error: " + e.getMessage());
        }
        return ValidationResult.success();
    }
}
