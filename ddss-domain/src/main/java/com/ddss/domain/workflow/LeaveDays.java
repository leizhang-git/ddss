package com.ddss.domain.workflow;

import java.math.BigDecimal;
import java.util.Objects;

/** A leave duration expressed in half-day increments. */
public final class LeaveDays {
    private static final BigDecimal MINIMUM = new BigDecimal("0.5");
    private static final BigDecimal MAXIMUM = new BigDecimal("30.0");
    private static final BigDecimal HALF_DAY = new BigDecimal("0.5");

    private final BigDecimal value;

    private LeaveDays(BigDecimal value) {
        this.value = value;
    }

    public static LeaveDays of(BigDecimal value) {
        Objects.requireNonNull(value, "leave days are required");
        if (value.compareTo(MINIMUM) < 0 || value.compareTo(MAXIMUM) > 0) {
            throw new IllegalArgumentException("Leave duration must be between 0.5 and 30 days");
        }
        if (value.remainder(HALF_DAY).compareTo(BigDecimal.ZERO) != 0) {
            throw new IllegalArgumentException("Leave duration must use half-day increments");
        }
        return new LeaveDays(value.stripTrailingZeros());
    }

    public BigDecimal value() {
        return value;
    }

    @Override
    public boolean equals(Object other) {
        if (this == other) {
            return true;
        }
        if (!(other instanceof LeaveDays)) {
            return false;
        }
        LeaveDays that = (LeaveDays) other;
        return value.compareTo(that.value) == 0;
    }

    @Override
    public int hashCode() {
        return value.stripTrailingZeros().hashCode();
    }

    @Override
    public String toString() {
        return value.toPlainString();
    }
}
