package com.ddss.framework.event;

import org.springframework.context.ApplicationEvent;

public class LoginEvent extends ApplicationEvent {

    private static final long serialVersionUID = 1L;

    private final String username;
    private final String status;
    private final String message;
    private final String ipAddress;
    private final String userAgent;

    public LoginEvent(Object source, String username, String status, String message,
                      String ipAddress, String userAgent) {
        super(source);
        this.username = username;
        this.status = status;
        this.message = message;
        this.ipAddress = ipAddress;
        this.userAgent = userAgent;
    }

    public String getUsername() { return username; }
    public String getStatus() { return status; }
    public String getMessage() { return message; }
    public String getIpAddress() { return ipAddress; }
    public String getUserAgent() { return userAgent; }
}
