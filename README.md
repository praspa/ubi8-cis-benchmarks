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
            "cmd": "sed -i 's/package.access=.*/package.access=sun.,org.apache.catalina.,org.apache.coyote.,org.apache.jasper.,org.apache.tomcat./g' $JWS_HOME/conf/catalina.properties",
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
usage: run_benchmark.py [-h] [-i CONF_FILE] [-r] [-a] [-x CONTROL_REGEXP] [-s CONTROL_IGNORE] [-t TIMEOUT]

Utility to audit and remediate applications, runtimes, and platforms.

options:
  -h, --help         show this help message and exit
  -i CONF_FILE       The benchmark configuration file.
  -r                 Perform remediation (implies running the audit to decide what to remediate).
  -a                 Perform audit.
  -x CONTROL_REGEXP  Regular expression of what controls to audit and remediate.
  -s CONTROL_IGNORE  Comma separated list of control ids to ignore.
  -t TIMEOUT         Per-command timeout in seconds (default: 600).
```

Commands run from the directory containing the benchmark file, so relative paths such as
`./scripts/...` and `./conf/...` resolve regardless of where the driver is invoked from.
Commands get `/dev/null` as stdin and their stderr is captured into the log.

Example:

```
python run_benchmark.py -i ./benchmark/tomcat9/cis_tomcat9.json \
    -a -s "5.1,6.1,6.5,7.6,9.1,9.3,10.2,10.11,10.19" | tee /security/cis_results.log
```

* Each control often has one to many audit (-a) checks
   * Each audit has one to many applicability checks
      * All applicability checks must pass for the audit to be performed
      * If the remediation flag is set (-r), the remediations are executed after the control's audit fails
   * Each remediation may also have applicability checks; a remediation whose checks fail is skipped
      * Remediations run in order and each one's applicability is evaluated just before it runs,
        so later steps see the effect of earlier ones (e.g. `touch` a file, then `chmod` it)
   * After remediating, the control is re-audited; it only counts as remediated if the re-audit passes
   * Controls with no applicable remediation are reported under "Controls Without Automated Remediation"

* Controls marked `"manual": true` are not executed and are reported under "Controls Requiring Manual Review"
  rather than counted as passes.

* Exit code: 254 if any control failed its audit and was not fixed by remediation; 2 on invalid arguments.

* Permission checks use `./scripts/check_mode.sh <path> <max_mode>`, which passes when the file's mode is
  `<max_mode>` or more restrictive (matching the CIS wording).

* If a control is known to be not applicable to the environment, skip the control with comma separated list of control numbers
   * -s "1.1,1.2,..."

* For testing, to run a single or subset of controls use -x
   * For example, to run all of the checks under 1.1.x , use -x "1.1"
   * Or to run a specific check only,  -x "1.2.2.1"

## Build on OCP

```
# cd to base of of git repo

oc new-project pwr-ubi8-cis

cat ./registry.redhat.io/ubi8/Dockerfile | oc new-build --dockerfile=- --name=ubi8-cis

# wait for build to fail as dockerfile has references to files in local env that are missing from build context

oc start-build ubi8-cis --from-dir=.

Uploading directory "." as binary input for the build ...

Uploading finished
build.build.openshift.io/ubi8-cis-2 started

# verify build completes
oc get pods
NAME               READY   STATUS      RESTARTS   AGE
...
ubi8-cis-4-build   0/1     Completed   0          77s

# inspect the audit in pod logs
oc logs ubi8-cis-4-build | less


```

## Dockerfile artifacts for CIS secure container images

* https://catalog.redhat.com/software/containers/search
* https://catalog.redhat.com/software/containers/ubi8/5c647760bed8bd28d0e38f9f




