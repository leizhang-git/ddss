package com.ddss.application.finance;

import com.ddss.domain.finance.FinanceLoan;

import java.util.List;

public interface FinanceExportPort {
    List<FinanceLoan> findAllForExport();
}
