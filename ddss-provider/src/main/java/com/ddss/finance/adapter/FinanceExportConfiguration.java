package com.ddss.finance.adapter;

import com.ddss.application.finance.FinanceExportPort;
import com.ddss.application.finance.PrepareFinanceExport;
import com.ddss.domain.finance.FinanceScheduleCalculator;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Clock;

@Configuration
public class FinanceExportConfiguration {
    @Bean
    public FinanceExportPort financeExportPort(com.ddss.finance.service.SysFinanceService financeService) {
        return new LegacyFinanceExportAdapter(financeService);
    }

    @Bean
    public FinanceScheduleCalculator financeScheduleCalculator() {
        return new FinanceScheduleCalculator(Clock.systemDefaultZone());
    }

    @Bean
    public PrepareFinanceExport prepareFinanceExport(FinanceExportPort finance,
                                                      FinanceScheduleCalculator calculator) {
        return new PrepareFinanceExport(finance, calculator);
    }
}
