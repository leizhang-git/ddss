package com.ddss.domain.finance;

public enum FinanceStatus {
    REPAYING("0", "还款中"),
    SETTLED("1", "已结清"),
    OVERDUE("2", "逾期"),
    UNKNOWN("", "");

    private final String code;
    private final String label;

    FinanceStatus(String code, String label) {
        this.code = code;
        this.label = label;
    }

    public static FinanceStatus fromLegacyCode(String code) {
        for (FinanceStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        return UNKNOWN;
    }

    public String label() {
        return label;
    }
}
