package com.ddss.workflow.service.impl;

import com.ddss.application.workflow.LeaveApplicationPort;
import com.ddss.application.workflow.LeaveWithdrawalPort;
import com.ddss.application.workflow.LeaveWithdrawalSnapshot;
import com.ddss.application.workflow.DeleteWorkflowDeployments;
import com.ddss.application.workflow.GetWorkflowDone;
import com.ddss.application.workflow.GetWorkflowTodo;
import com.ddss.application.workflow.WorkflowTaskPage;
import com.ddss.application.workflow.WorkflowTaskQueryPort;
import com.ddss.application.workflow.WorkflowTaskRow;
import com.ddss.application.workflow.WorkflowDeploymentDeletionPort;
import com.ddss.application.workflow.WorkflowDeploymentSnapshot;
import com.ddss.application.workflow.DeploymentDeletionResult;
import com.ddss.application.workflow.SubmitLeave;
import com.ddss.application.workflow.WithdrawLeaveApplications;
import com.ddss.application.workflow.WorkflowProcessPort;
import com.ddss.common.exception.ServiceException;
import com.ddss.domain.workflow.LeaveApplication;
import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import com.ddss.workflow.vo.WorkflowPage;
import com.ddss.workflow.vo.WorkflowTaskVO;
import org.flowable.engine.RepositoryService;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class WorkflowServiceContractTest {

    @Test
    void rejectsInvalidLeaveDaysBeforePersisting() {
        WorkflowLeaveServiceImpl service = new WorkflowLeaveServiceImpl();
        DdssLeaveMapper leaveMapper = mock(DdssLeaveMapper.class);
        ReflectionTestUtils.setField(service, "leaveMapper", leaveMapper);

        DdssLeave leave = new DdssLeave();
        leave.setLeaveDays(new BigDecimal("1.25"));

        assertThrows(ServiceException.class, () -> service.startLeave(leave, "applicant"));
        verify(leaveMapper, never()).insert(any(DdssLeave.class));
    }

    @Test
    void submitsHalfDayLeaveThroughApplicationPorts() {
        WorkflowLeaveServiceImpl service = new WorkflowLeaveServiceImpl();
        DdssLeaveMapper leaveMapper = mock(DdssLeaveMapper.class);
        ReflectionTestUtils.setField(service, "leaveMapper", leaveMapper);

        StringBuilder calls = new StringBuilder();
        LeaveApplicationPort applications = new LeaveApplicationPort() {
            @Override
            public long insert(LeaveApplication application) {
                calls.append("insert:").append(application.days()).append(';');
                return 42L;
            }

            @Override
            public void updateStatus(long leaveId, String processInstanceId) {
                calls.append("update:").append(leaveId).append(':').append(processInstanceId).append(';');
            }

            @Override
            public void delete(long leaveId) {
                calls.append("delete:").append(leaveId).append(';');
            }
        };
        WorkflowProcessPort processes = new WorkflowProcessPort() {
            @Override
            public String startLeave(String businessKey, LeaveApplication application) {
                calls.append("start:").append(businessKey).append(':').append(application.days()).append(';');
                return "process-42";
            }

            @Override
            public void cancel(String processInstanceId, String reason) { }

            @Override
            public boolean isRunning(String processInstanceId) { return false; }
        };
        ReflectionTestUtils.setField(service, "submitLeave", new SubmitLeave(applications, processes));

        DdssLeave leave = validLeave(new BigDecimal("0.5"));
        service.startLeave(leave, "applicant");

        assertEquals("insert:0.5;start:42:0.5;update:42:process-42;", calls.toString());
        assertEquals(42L, leave.getLeaveId());
        assertEquals("process-42", leave.getProcessInstanceId());
        verify(leaveMapper, never()).insert(any(DdssLeave.class));
    }

    @Test
    void preflightsAllLeaveOwnersBeforeTerminatingAnyProcess() {
        WorkflowLeaveServiceImpl service = new WorkflowLeaveServiceImpl();
        List<String> calls = new ArrayList<>();
        ReflectionTestUtils.setField(service, "withdrawLeaveApplications",
                new WithdrawLeaveApplications(new LeaveWithdrawalPort() {
                    @Override
                    public Optional<LeaveWithdrawalSnapshot> find(long leaveId) {
                        calls.add("find:" + leaveId);
                        String applicant = leaveId == 1L ? "applicant" : "someone-else";
                        return Optional.of(new LeaveWithdrawalSnapshot(
                                leaveId, applicant, "process-" + leaveId));
                    }

                    @Override
                    public void cancelProcess(String processInstanceId, String reason) {
                        calls.add("cancel:" + processInstanceId);
                    }

                    @Override
                    public boolean isProcessRunning(String processInstanceId) {
                        calls.add("running:" + processInstanceId);
                        return true;
                    }

                    @Override
                    public void delete(long leaveId) {
                        calls.add("delete:" + leaveId);
                    }
                }));

        assertThrows(ServiceException.class,
                () -> service.deleteLeaveByIds(new Long[]{1L, 2L}, "applicant"));

        assertEquals(List.of("find:1", "find:2"), calls);
    }

    @Test
    void validatesEveryDeploymentBeforeDeletingAny() {
        WorkflowDefinitionServiceImpl service = new WorkflowDefinitionServiceImpl();
        List<String> calls = new ArrayList<>();
        ReflectionTestUtils.setField(service, "deleteWorkflowDeployments",
                new DeleteWorkflowDeployments(new WorkflowDeploymentDeletionPort() {
                    @Override
                    public Optional<WorkflowDeploymentSnapshot> find(String deploymentId) {
                        calls.add("find:" + deploymentId);
                        return Optional.of(new WorkflowDeploymentSnapshot(deploymentId,
                                List.of("definition-" + deploymentId)));
                    }

                    @Override
                    public boolean hasRunningInstances(String processDefinitionId) {
                        calls.add("running:" + processDefinitionId);
                        return processDefinitionId.endsWith("deployment-2");
                    }

                    @Override
                    public void deleteCascade(String deploymentId) {
                        calls.add("delete:" + deploymentId);
                    }
                }));

        ServiceException failure = assertThrows(ServiceException.class,
                () -> service.deleteDefinition("deployment-1,deployment-2"));

        assertEquals("流程定义存在运行中的实例，无法删除", failure.getMessage());
        assertEquals(List.of("find:deployment-1", "running:definition-deployment-1",
                "find:deployment-2", "running:definition-deployment-2"), calls);
    }

    @Test
    void mapsApplicationTaskPagesToTheExistingWorkflowPageContract() {
        WorkflowTaskServiceImpl service = new WorkflowTaskServiceImpl();
        WorkflowTaskRow todoRow = new WorkflowTaskRow("task-todo", "Manager", "process-1",
                Instant.parse("2026-10-13T01:00:00Z"), 42L, "alice", "Alice", new BigDecimal("0.5"),
                LocalDate.of(2026, 10, 13), "Personal", "manager", "director", null, null, null);
        WorkflowTaskRow doneRow = new WorkflowTaskRow("task-done", "Director", "process-2",
                Instant.parse("2026-10-13T02:00:00Z"), null, null, null, null, null, null, null, null,
                false, "Rejected", Instant.parse("2026-10-13T03:00:00Z"));
        List<String> calls = new ArrayList<>();
        WorkflowTaskQueryPort queries = new WorkflowTaskQueryPort() {
            @Override
            public WorkflowTaskPage findTodo(String actor, int pageNum, int pageSize) {
                calls.add("todo:" + actor + ':' + pageNum + ':' + pageSize);
                return new WorkflowTaskPage(9, List.of(todoRow));
            }

            @Override
            public WorkflowTaskPage findDone(String actor, int pageNum, int pageSize) {
                calls.add("done:" + actor + ':' + pageNum + ':' + pageSize);
                return new WorkflowTaskPage(4, List.of(doneRow));
            }
        };
        ReflectionTestUtils.setField(service, "getWorkflowTodo", new GetWorkflowTodo(queries));
        ReflectionTestUtils.setField(service, "getWorkflowDone", new GetWorkflowDone(queries));

        WorkflowPage<WorkflowTaskVO> todo = service.selectTodoList("alice", 2, 10);
        WorkflowPage<WorkflowTaskVO> done = service.selectDoneList("bob", 1, 15);

        assertEquals(List.of("todo:alice:2:10", "done:bob:1:15"), calls);
        assertEquals(9L, todo.getTotal());
        assertEquals("task-todo", todo.getRows().get(0).getTaskId());
        assertEquals(42L, todo.getRows().get(0).getLeaveId());
        assertEquals(new BigDecimal("0.5"), todo.getRows().get(0).getLeaveDays());
        assertEquals(Date.from(todoRow.taskCreateTime()), todo.getRows().get(0).getTaskCreateTime());
        assertEquals(4L, done.getTotal());
        assertEquals("task-done", done.getRows().get(0).getTaskId());
        assertEquals(Boolean.FALSE, done.getRows().get(0).getApproved());
        assertEquals("Rejected", done.getRows().get(0).getComment());
        assertEquals(Date.from(doneRow.finishTime()), done.getRows().get(0).getFinishTime());
    }

    @Test
    void preservesResourceReadFailureCause() {
        WorkflowDefinitionServiceImpl service = new WorkflowDefinitionServiceImpl();
        RepositoryService repositoryService = mock(RepositoryService.class);
        ReflectionTestUtils.setField(service, "repositoryService", repositoryService);
        IOException cause = new IOException("read failed");
        InputStream stream = new InputStream() {
            @Override
            public int read() throws IOException {
                throw cause;
            }
        };
        when(repositoryService.getResourceAsStream("deployment-1", "process.bpmn")).thenReturn(stream);

        ServiceException exception = assertThrows(ServiceException.class,
                () -> service.getDefinitionXml("deployment-1", "process.bpmn"));

        assertSame(cause, exception.getCause());
    }

    private DdssLeave validLeave(BigDecimal days) {
        DdssLeave leave = new DdssLeave();
        leave.setApplyUserName("Applicant");
        leave.setLeaveDays(days);
        leave.setStartDate(LocalDate.of(2026, 10, 13));
        leave.setReason("Personal reasons");
        leave.setLeader("manager");
        leave.setBoss("director");
        return leave;
    }
}
