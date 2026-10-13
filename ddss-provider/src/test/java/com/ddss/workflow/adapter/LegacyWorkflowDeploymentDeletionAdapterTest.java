package com.ddss.workflow.adapter;

import org.flowable.engine.RepositoryService;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.repository.Deployment;
import org.flowable.engine.repository.DeploymentQuery;
import org.flowable.engine.repository.ProcessDefinition;
import org.flowable.engine.repository.ProcessDefinitionQuery;
import org.flowable.engine.runtime.ProcessInstanceQuery;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class LegacyWorkflowDeploymentDeletionAdapterTest {
    @Test
    void mapsDeploymentAndItsProcessDefinitionIds() {
        RepositoryService repositoryService = mock(RepositoryService.class);
        DeploymentQuery deploymentQuery = mock(DeploymentQuery.class);
        ProcessDefinitionQuery definitionQuery = mock(ProcessDefinitionQuery.class);
        ProcessDefinition definition = mock(ProcessDefinition.class);
        when(repositoryService.createDeploymentQuery()).thenReturn(deploymentQuery);
        when(deploymentQuery.deploymentId("deployment-1")).thenReturn(deploymentQuery);
        when(deploymentQuery.singleResult()).thenReturn(mock(Deployment.class));
        when(repositoryService.createProcessDefinitionQuery()).thenReturn(definitionQuery);
        when(definitionQuery.deploymentId("deployment-1")).thenReturn(definitionQuery);
        when(definitionQuery.list()).thenReturn(List.of(definition));
        when(definition.getId()).thenReturn("definition-1");
        LegacyWorkflowDeploymentDeletionAdapter adapter = new LegacyWorkflowDeploymentDeletionAdapter(
                repositoryService, mock(RuntimeService.class));

        var snapshot = adapter.find("deployment-1");

        assertTrue(snapshot.isPresent());
        assertEquals("deployment-1", snapshot.get().deploymentId());
        assertEquals(List.of("definition-1"), snapshot.get().processDefinitionIds());
    }

    @Test
    void returnsEmptyForMissingDeploymentWithoutQueryingDefinitions() {
        RepositoryService repositoryService = mock(RepositoryService.class);
        DeploymentQuery deploymentQuery = mock(DeploymentQuery.class);
        when(repositoryService.createDeploymentQuery()).thenReturn(deploymentQuery);
        when(deploymentQuery.deploymentId("missing")).thenReturn(deploymentQuery);
        when(deploymentQuery.singleResult()).thenReturn(null);
        LegacyWorkflowDeploymentDeletionAdapter adapter = new LegacyWorkflowDeploymentDeletionAdapter(
                repositoryService, mock(RuntimeService.class));

        assertTrue(adapter.find("missing").isEmpty());
        verify(repositoryService, org.mockito.Mockito.never()).createProcessDefinitionQuery();
    }

    @Test
    void checksRuntimeInstancesAndDeletesDeploymentWithHistoryCascade() {
        RepositoryService repositoryService = mock(RepositoryService.class);
        RuntimeService runtimeService = mock(RuntimeService.class);
        ProcessInstanceQuery processInstanceQuery = mock(ProcessInstanceQuery.class);
        when(runtimeService.createProcessInstanceQuery()).thenReturn(processInstanceQuery);
        when(processInstanceQuery.processDefinitionId("definition-1")).thenReturn(processInstanceQuery);
        when(processInstanceQuery.count()).thenReturn(0L);
        LegacyWorkflowDeploymentDeletionAdapter adapter = new LegacyWorkflowDeploymentDeletionAdapter(
                repositoryService, runtimeService);

        assertFalse(adapter.hasRunningInstances("definition-1"));
        adapter.deleteCascade("deployment-1");

        verify(repositoryService).deleteDeployment("deployment-1", true);
    }
}
