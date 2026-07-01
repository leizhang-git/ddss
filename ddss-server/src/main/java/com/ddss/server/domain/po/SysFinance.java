package com.ddss.server.domain.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 财务管理实体
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName(value = "sys_finance")
public class SysFinance {

    @TableId(value = "finance_id", type = IdType.AUTO)
    private Long financeId;

    /** 欠款方名称 */
    @TableField(value = "creditor_name")
    private String creditorName;

    /** 借款总额 */
    @TableField(value = "loan_amount")
    private BigDecimal loanAmount;

    /** 借款日期 */
    @TableField(value = "loan_date")
    private LocalDate loanDate;

    /** 还款开始日期 */
    @TableField(value = "repayment_start_date")
    private LocalDate repaymentStartDate;

    /** 还款结束日期 */
    @TableField(value = "repayment_end_date")
    private LocalDate repaymentEndDate;

    /** 借款期限(月) */
    @TableField(value = "loan_term")
    private Integer loanTerm;

    /** 每月还款日(几号) */
    @TableField(value = "repayment_day")
    private Integer repaymentDay;

    /** 月还款额 */
    @TableField(value = "monthly_payment")
    private BigDecimal monthlyPayment;

    /** 利率(%) */
    @TableField(value = "interest_rate")
    private BigDecimal interestRate;

    /** 利息总额 */
    @TableField(value = "interest_amount")
    private BigDecimal interestAmount;

    /** 提前结清金额 */
    @TableField(value = "early_settlement_amount")
    private BigDecimal earlySettlementAmount;

    /** 剩余未还金额 */
    @TableField(value = "remaining_amount")
    private BigDecimal remainingAmount;

    /** 已还金额 */
    @TableField(value = "paid_amount")
    private BigDecimal paidAmount;

    /** 状态：0-还款中 1-已结清 2-逾期 */
    @TableField(value = "status")
    private String status;

    /** 备注 */
    @TableField(value = "remark")
    private String remark;

    /** 已还月份（逗号分隔，如 "7月,8月"） */
    @TableField(value = "paid_months")
    private String paidMonths;

    @TableField(value = "create_by")
    private String createBy;

    @TableField(value = "create_time")
    private LocalDateTime createTime;

    @TableField(value = "update_by")
    private String updateBy;

    @TableField(value = "update_time")
    private LocalDateTime updateTime;
}
