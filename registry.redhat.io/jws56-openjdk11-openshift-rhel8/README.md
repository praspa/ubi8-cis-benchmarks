# Tomcat 9 Image Build Notes

## Tomcat9 CIS Benchmark Build Time Exclusions

The following audits are skipped at image build time check gate.

* 6.1 - we don't force mutual tls for all apps
* 6.5 - ssl connector does not get setup until runtime with jws container, will always fail at buildtime audit
* 7.6 - by ocp design, we log to console not to file, then aggregate at logging stack
* 9.1 - security manager on developers to configure
* 9.3 - deploy on startup is part of s2i image design, wars get placed into deployment at build time
* 10.2 - don't use remote manager in container
* 10.11 - don't have requirement to force all apps tls, also could be doing edge routes too in ocp
* 10.19 - do not use manager in containerize environment

