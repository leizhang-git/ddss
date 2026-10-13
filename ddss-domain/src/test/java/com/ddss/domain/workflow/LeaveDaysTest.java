package com.ddss.domain.workflow;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class LeaveDaysTest {
    @Test
    void acceptsHalfDayValuesAndNormalizesScale() {
        assertEquals(new BigDecimal("1.5"), LeaveDays.of(new BigDecimal("1.50")).value());
    }

    @Test
    void rejectsDurationsOutsideTheDomain() {
        assertThrows(IllegalArgumentException.class, () -> LeaveDays.of(new BigDecimal("0.25")));
        assertThrows(IllegalArgumentException.class, () -> LeaveDays.of(new BigDecimal("30.5")));
        assertThrows(IllegalArgumentException.class, () -> LeaveDays.of(new BigDecimal("1.25")));
    }
}
