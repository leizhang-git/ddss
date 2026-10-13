package com.ddss.domain.workflow;

import java.time.LocalDate;
import java.util.Objects;

public final class LeaveApplication {
    private final String applicant;
    private final String applicantName;
    private final LeaveDays days;
    private final LocalDate startDate;
    private final String reason;
    private final String leader;
    private final String boss;
    private final LeaveStatus status;

    private LeaveApplication(String applicant, String applicantName, LeaveDays days, LocalDate startDate,
                             String reason, String leader, String boss, LeaveStatus status) {
        this.applicant = requireText(applicant, "Applicant is required");
        this.applicantName = requireText(applicantName, "Applicant name is required");
        this.days = Objects.requireNonNull(days, "Leave duration is required");
        this.startDate = Objects.requireNonNull(startDate, "Start date is required");
        this.reason = requireText(reason, "Leave reason is required");
        this.leader = requireText(leader, "First approver is required");
        this.boss = requireText(boss, "Second approver is required");
        this.status = Objects.requireNonNull(status, "Status is required");
    }

    public static LeaveApplication submit(String applicant, String applicantName, LeaveDays days, LocalDate startDate,
                                         String reason, String leader, String boss) {
        return new LeaveApplication(applicant, applicantName, days, startDate, reason, leader, boss,
                LeaveStatus.PENDING);
    }

    public LeaveApplication approve() {
        return transition(LeaveStatus.APPROVED);
    }

    public LeaveApplication reject() {
        return transition(LeaveStatus.REJECTED);
    }

    private LeaveApplication transition(LeaveStatus target) {
        if (status != LeaveStatus.PENDING) {
            throw new IllegalStateException("Only pending leave applications can be decided");
        }
        return new LeaveApplication(applicant, applicantName, days, startDate, reason, leader, boss, target);
    }

    private static String requireText(String value, String message) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(message);
        }
        return value.trim();
    }

    public String applicant() { return applicant; }
    public String applicantName() { return applicantName; }
    public LeaveDays days() { return days; }
    public LocalDate startDate() { return startDate; }
    public String reason() { return reason; }
    public String leader() { return leader; }
    public String boss() { return boss; }
    public LeaveStatus status() { return status; }
}
