package com.ddss.framework.event;

import org.springframework.context.ApplicationEvent;

import javax.servlet.http.HttpServletRequest;

public class LoginEvent extends ApplicationEvent {

    private static final long serialVersionUID = 1L;

    private final String username;
    private final String status;
    private final String message;
    private final HttpServletRequest request;

    public LoginEvent(Object source, String username, String status, String message, HttpServletRequest request) {
        super(source);
        this.username = username;
        this.status = status;
        this.message = message;
        this.request = request;
    }

    public String getUsername() { return username; }
    public String getStatus() { return status; }
    public String getMessage() { return message; }
    public HttpServletRequest getRequest() { return request; }
}
