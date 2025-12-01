package com.example.zuul.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class LoggingFilter implements GlobalFilter, Ordered {

    private static final Logger log = LoggerFactory.getLogger(LoggingFilter.class);

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        
        log.info("Request Method: {}, URL: {}", request.getMethod(), request.getURI());
        
        // Add custom header
        ServerHttpRequest modifiedRequest = request.mutate()
                .header("X-Gateway-Timestamp", String.valueOf(System.currentTimeMillis()))
                .build();
        
        return chain.filter(exchange.mutate().request(modifiedRequest).build())
                .then(Mono.fromRunnable(() -> {
                    log.info("Response Status: {}", exchange.getResponse().getStatusCode());
                }));
    }

    @Override
    public int getOrder() {
        return -1;
    }
}
