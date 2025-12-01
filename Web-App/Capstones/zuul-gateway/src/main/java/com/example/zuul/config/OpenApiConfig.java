package com.example.zuul.config;

import io.swagger.v3.oas.models.ExternalDocumentation;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI gatewayOpenAPI() {
        return new OpenAPI()
                .addServersItem(new Server().url("/").description("Gateway Server"))
                .info(new Info()
                        .title("Personal Finance API Gateway")
                        .description("API Gateway for User Auth, Transactions, and Analytics services")
                        .version("v1")
                        .contact(new Contact().name("Dev Team").email("dev@example.com"))
                        .license(new License().name("Apache 2.0").url("https://www.apache.org/licenses/LICENSE-2.0"))
                )
                .externalDocs(new ExternalDocumentation()
                        .description("Project Docs")
                        .url("https://example.com/docs"));
    }
}
