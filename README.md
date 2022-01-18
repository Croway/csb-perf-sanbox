## Openshift performance test

* Simple spring boot camel route that expose an http endpoint deployed on OCP, right now the project uses camel-http with servlet implementation, is it possible to use platform-http on spring-boot?
* Use Hyperfoil in order to generate load and collect request/response metrics
* * Collect report results from Hyperfoil, archive html pages report
* Use Istio as sidecar to gather runtime information
* Export jfr recording and archive it
* Export JMX metrics and archive it