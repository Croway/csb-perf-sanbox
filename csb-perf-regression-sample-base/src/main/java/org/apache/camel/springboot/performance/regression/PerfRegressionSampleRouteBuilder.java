package org.apache.camel.springboot.performance.regression;

import org.apache.camel.builder.RouteBuilder;
import org.springframework.stereotype.Component;

@Component
public class PerfRegressionSampleRouteBuilder extends RouteBuilder {

	@Override
	public void configure() throws Exception {
		restConfiguration().component("servlet").host("localhost").port(8080);

		rest().get("hello").to("direct:hello");

		from("direct:hello")
				.setBody(constant("Hello from Camel Spring Boot performance regression sample"));
	}

}
