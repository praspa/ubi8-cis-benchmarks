# UBI8 CIS Benchmarks Audit and Remediation

Tooling to audit and remediate ubi8 based images at image build time.

Examples on auditing the image at runtime.

Auditing takes into account that the image may be running at privileged/nonprivileged modes.

## CIS Benchmark Control Checklists

```
$ ls -al ./benchmark/

drwx------. 1 praspant praspant    54 Apr 19 19:26 .
drwx------. 1 praspant praspant   122 Apr 20 08:38 ..
-rw-rw-r--. 1 praspant praspant 12500 Apr 19 19:26 run_benchmark.py
drwx------. 1 praspant praspant    32 Apr 19 19:26 tomcat9
drwx------. 1 praspant praspant    50 Apr 19 19:26 ubi8
```

## Sample Control Check (Audit/Remediation) 

```
...
      {
        "id": "8.1",
        "level": "1",
        "description": "Restrict runtime access to sensitive packages (Automated)",
        "audits": [
          {
            "applicable_checks": [
              {
                "cmd": "ls -l $JWS_HOME/conf/catalina.properties",
                "result": "0",
                "result_type": "rc"
              }
            ],
            "cmd": "grep 'package.access=sun.,org.apache.catalina.,org.apache.coyote.,org.apache.jasper.,org.apache.tomcat.' $JWS_HOME/conf/catalina.properties",
            "result": "0",
            "result_type": "rc"
          }
        ],
        "remediations": [
          {
            "applicable_checks": [],
            "cmd": "sed -i 's/package.access=.*/package.access=sun.,org.apache.catalina.,org.apache.coyote.,org.apache.jasper.,org.apache.tomcat./g $JWS_HOME/conf/catalina.properties",
            "result": "0",
            "result_type": "rc"
          }
        ]
      },
...
```

## Benchmark Driver Script and Usage

Driver Script (run_benchmark.py) Location:

```
$ ls -al ./benchmark/

drwx------. 1 praspant praspant    54 Apr 19 19:26 .
drwx------. 1 praspant praspant   122 Apr 20 08:38 ..
-rw-rw-r--. 1 praspant praspant 12500 Apr 19 19:26 run_benchmark.py
drwx------. 1 praspant praspant    32 Apr 19 19:26 tomcat9
drwx------. 1 praspant praspant    50 Apr 19 19:26 ubi8
```

Driver script usage:

```
usage: run_benchmark.py [-h] [-i CONF_FILE] [-r] [-a] [-x CONTROL_REGEXP] [-s CONTROL_IGNORE]

Utility to audit and remediate applications, runtimes, and platforms.

options:
  -h, --help         show this help message and exit
  -i CONF_FILE       The benchmark configuration file.
  -r                 Perform remediation.
  -a                 Perform audit.
  -x CONTROL_REGEXP  Regular expression of what controls to audit and remediate.
  -s CONTROL_IGNORE  Comma separated list of control ids to ignore.
```

Example:

```
python run_benchmark.py -i ./benchmark/tomcat9/cis_tomcat9.json \
    -a -s "5.1,6.1,6.5,7.6,9.1,9.3,10.2,10.11,10.19" | tee /security/cis_results.log
```

* Each control often has one to many audit (-a) checks
   * Each audit has one to many applicability checks
      * All applicability checks must pass for the audit to be performed
      * If the remediation flag is set (-r), the remediations are executed after the matching audit check fails

* If a control is known to be not applicable to the environment, skip the control with comma separated list of control numbers
   * -s "1.1,1.2,..."

* For testing, to run a single or subset of controls use -x
   * For example, to run all of the checks under 1.1.x , use -x "1.1"
   * Or to run a specific check only,  -x "1.2.2.1"

## Dockerfile artifacts for CIS secure container images

* https://catalog.redhat.com/software/containers/search
* https://catalog.redhat.com/software/containers/ubi8/5c647760bed8bd28d0e38f9f




