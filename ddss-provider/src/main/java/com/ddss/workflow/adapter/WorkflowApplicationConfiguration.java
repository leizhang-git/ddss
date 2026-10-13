package com.ddss.workflow.adapter;

import com.ddss.application.workflow.DecideWorkflowTask;
import com.ddss.application.workflow.DeleteWorkflowDeployments;
import com.ddss.application.workflow.GetWorkflowDone;
import com.ddss.application.workflow.GetWorkflowTodo;
import com.ddss.application.workflow.WorkflowTaskQueryPort;
import com.ddss.application.workflow.LeaveApplicationPort;
import com.ddss.application.workflow.SubmitLeave;
import com.ddss.application.workflow.WorkflowApprovalPort;
import com.ddss.application.workflow.WorkflowProcessPort;
import com.ddss.application.workflow.LeaveWithdrawalPort;
import com.ddss.application.workflow.WithdrawLeaveApplications;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import org.flowable.engine.HistoryService;
import org.flowable.engine.RepositoryService;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.TaskService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class WorkflowApplicationConfiguration {
    @Bean
    public LeaveApplicationPort leaveApplicationPort(DdssLeaveMapper mapper) {
        return new LegacyLeaveAdapters.Persistence(mapper);
    }

    @Bean
    public WorkflowProcessPort workflowProcessPort(RuntimeService runtimeService) {
        return new LegacyLeaveAdapters.Process(runtimeService);
    }

    @Bean
    public SubmitLeave submitLeave(LeaveApplicationPort applications, WorkflowProcessPort processes) {
        return new SubmitLeave(applications, processes);
    }

    @Bean
    public WorkflowApprovalPort workflowApprovalPort(TaskService taskService, RuntimeService runtimeService,
                                                     DdssLeaveMapper mapper) {
        return new LegacyWorkflowApprovalAdapter(taskService, runtimeService, mapper);
    }

    @Bean
    public DecideWorkflowTask decideWorkflowTask(WorkflowApprovalPort approvals) {
        return new DecideWorkflowTask(approvals);
    }

    @Bean
    public LeaveWithdrawalPort leaveWithdrawalPort(DdssLeaveMapper mapper, RuntimeService runtimeService) {
        return new LegacyLeaveWithdrawalAdapter(mapper, runtimeService);
    }

    @Bean
    public WithdrawLeaveApplications withdrawLeaveApplications(LeaveWithdrawalPort withdrawals) {
        return new WithdrawLeaveApplications(withdrawals);
    }

    @Bean
    public DeleteWorkflowDeployments deleteWorkflowDeployments(RepositoryService repositoryService,
                                                               RuntimeService runtimeService) {
        return new DeleteWorkflowDeployments(
                new LegacyWorkflowDeploymentDeletionAdapter(repositoryService, runtimeService));
    }

    @Bean
    public WorkflowTaskQueryPort workflowTaskQueryPort(TaskService taskService, HistoryService historyService,
                                                       DdssLeaveMapper mapper) {
        return new LegacyWorkflowTaskQueryAdapter(taskService, historyService, mapper);
    }

    @Bean
    public GetWorkflowTodo getWorkflowTodo(WorkflowTaskQueryPort tasks) {
        return new GetWorkflowTodo(tasks);
    }

    @Bean
    public GetWorkflowDone getWorkflowDone(WorkflowTaskQueryPort tasks) {
        return new GetWorkflowDone(tasks);
    }
}
