import os
import re
import json
import argparse
import sys
import subprocess

# Keep this file compatible with Python 3.6 (the python3 shipped in UBI8).

parser = argparse.ArgumentParser(description='Utility to audit and remediate applications, runtimes, and platforms.')
parser.add_argument('-i', action='store', dest='conf_file', help='The benchmark configuration file.')
parser.add_argument('-r', action='store_true', dest='do_remediate', help='Perform remediation (implies running the audit to decide what to remediate).')
parser.add_argument('-a', action='store_true', dest='do_audit', help='Perform audit.')
parser.add_argument('-x', action='store', dest='control_regexp', help='Regular expression of what controls to audit and remediate.')
parser.add_argument('-s', action='store', dest='control_ignore', help='Comma separated list of control ids to ignore.')
parser.add_argument('-t', action='store', dest='timeout', type=int, default=600, help='Per-command timeout in seconds (default: 600).')

results = parser.parse_args()
conf_file = results.conf_file
do_remediate = results.do_remediate
do_audit = results.do_audit
control_regexp = results.control_regexp or ""
cmd_timeout = results.timeout
ignore_list = [c.strip() for c in results.control_ignore.split(",") if c.strip()] if results.control_ignore else []

benchmark = {}

audit_report_passed = []
audit_report_failed = []
audit_report_na = []
audit_report_manual = []

remediate_report_passed = []
remediate_report_failed = []
remediate_report_none = []

# Some Status Constants
STATUS_PASS = "Pass"
STATUS_FAIL = "Fail"
STATUS_NA = "Not Applicable"

RESULT_TYPE_RC = "rc"
RESULT_TYPE_STDOUT = "stdout"

RESULT_NONZERO = "!0"

RC_TIMEOUT = 124


def validateInput():
    if not conf_file:
        print("error: please specify -i <benchmark file>. Good-bye!")
        sys.exit(2)

    if not os.path.isfile(conf_file):
        print("error: provided benchmark configuration file does not exist. Good-bye!")
        sys.exit(2)

    if not do_remediate and not do_audit:
        print("error: please specify -a (audit) and/or -r (remediate) arguments and try again. Good-bye!")
        sys.exit(2)


def loadBenchmark():
    global benchmark
    with open(conf_file, 'r') as f:
        benchmark = json.load(f)


def dumpBenchmark():
    print(json.dumps(benchmark, indent=4))


def runCmd(cmd):
    """Run a shell command. Returns (rc, stdout, stderr) with trailing whitespace stripped.

    stdin is /dev/null so a command that accidentally reads stdin cannot hang the run.
    """
    try:
        p = subprocess.run(cmd, shell=True, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE, encoding='utf8', errors='replace', timeout=cmd_timeout)
        return p.returncode, p.stdout.rstrip(' \t\n\r'), p.stderr.rstrip(' \t\n\r')
    except subprocess.TimeoutExpired:
        return RC_TIMEOUT, "", "command timed out after " + str(cmd_timeout) + "s"


def resultMatches(spec, rc, output):
    """Return True if a command result satisfies spec's result/result_type.

    rc:     result "!0" means any non-zero rc, otherwise rc must equal result.
    stdout: result "!0" means output must not equal "0", otherwise output must equal result.
    Returns None for an unknown result_type.
    """
    result_type = spec.get('result_type', RESULT_TYPE_RC)
    expected = str(spec.get('result', '0'))

    if result_type == RESULT_TYPE_RC:
        if expected == RESULT_NONZERO:
            return rc != 0
        return str(rc) == expected
    if result_type == RESULT_TYPE_STDOUT:
        if expected == RESULT_NONZERO:
            return output != "0"
        return output == expected
    return None


def printCmdResult(label, spec, rc, output, error):
    print(label + " RC: " + str(rc))
    print(label + " Output:<" + output + ">")
    if error:
        print(label + " Stderr:<" + error + ">")
    print(label + " expected " + str(spec.get('result_type')) + ":<" + str(spec.get('result')) + ">")


def isApplicable(checks, control_id):
    """All applicability checks must pass for the audit/remediation to apply."""
    for check in checks or []:
        print("Applicability Check CMD: " + check.get('cmd'))
        rc, output, error = runCmd(check.get('cmd'))
        printCmdResult("Applicability Check", check, rc, output, error)

        matched = resultMatches(check, rc, output)
        if matched is None:
            print("Error: Unknown applicability check result type: " + str(check.get('result_type')) + " for control id: " + control_id)
            return False
        if not matched:
            print("Warning: Applicability Check Failed for " + str(check.get('result_type')).upper() + ".")
            return False
    return True


def auditControl(control):
    """Run every applicable audit for a control. Returns STATUS_PASS, STATUS_FAIL or STATUS_NA."""
    control_id = control.get('id')
    audit_check_executed = False
    # Continue to run audit checks even if one fails
    audit_passed = True

    for audit_count, audit in enumerate(control.get('audits', []), start=1):

        # Go to the next audit, but don't fail the control audit check since it's not applicable
        if not isApplicable(audit.get('applicable_checks'), control_id):
            print("Audit Applicability Check Failed. Audit: " + str(audit_count) + " Control: " + control_id + " is not applicable to this environment.")
            continue

        audit_check_executed = True

        print("Audit cmd: " + audit.get('cmd'))
        rc, output, error = runCmd(audit.get('cmd'))
        printCmdResult("Audit Check", audit, rc, output, error)

        matched = resultMatches(audit, rc, output)
        if matched is None:
            print("Error: Unknown audit result type: " + str(audit.get('result_type')) + " for control id: " + control_id)
            audit_passed = False
        elif not matched:
            print("Warning: Audit Check Failed for " + str(audit.get('result_type')).upper() + ".")
            audit_passed = False

    if not audit_check_executed:
        return STATUS_NA
    return STATUS_PASS if audit_passed else STATUS_FAIL


def remediateControl(control):
    """Run applicable remediations, then re-audit.

    Returns True if the control passes its audit afterwards, False if it still fails,
    or None if no remediation is defined/applicable for this environment.
    """
    control_id = control.get('id')
    ran_any = False
    remediation_errors = False

    for remediation in control.get('remediations', []):
        if not isApplicable(remediation.get('applicable_checks'), control_id):
            print("Remediation not applicable, skipping: " + remediation.get('cmd'))
            continue

        ran_any = True
        print("Remediation cmd: " + remediation.get('cmd'))
        rc, output, error = runCmd(remediation.get('cmd'))
        printCmdResult("Remediation", remediation, rc, output, error)

        matched = resultMatches(remediation, rc, output)
        if not matched:
            print("Warning: Remediation Failed.")
            remediation_errors = True

    if not ran_any:
        return None

    print("Re-auditing control " + control_id + " after remediation ...")
    status = auditControl(control)
    if remediation_errors:
        print("Warning: one or more remediation commands for " + control_id + " failed.")
    return status != STATUS_FAIL


def executeBenchmark():
    print("===================================================================================")
    print("= Benchmark Type: " + benchmark.get('benchmark').get('type'))
    print("= Benchmark Source: " + benchmark.get('benchmark').get('upstream_source'))
    print("===================================================================================")

    if do_audit:
        print()
        print("INFO: System audit enabled.")
        print()

    if do_remediate:
        print()
        print("INFO: System remediate enabled.")
        print()

    for control in benchmark.get('benchmark').get('controls'):
        control_id = control.get('id')

        # Skip controls that don't match our pattern
        if control_regexp != "" and not re.match("^" + control_regexp, control_id):
            print("Skipping control: " + control_id)
            continue

        # Skip controls in ignore list
        if control_id in ignore_list:
            print("Skipping control: " + control_id + " in ignore list.")
            continue

        print()
        print("===================================================================================")
        print("= Control ID: " + control_id)
        print("= Control  Level: " + str(control.get('level')))
        print("= Description: " + control.get('description'))
        print("===================================================================================")
        print()

        # Controls that can only be verified by a person are reported, not scored.
        if control.get('manual'):
            print("Control: " + control_id + " - MANUAL REVIEW REQUIRED")
            audit_report_manual.append(control_id)
            continue

        # The audit result is needed to decide whether to remediate, so -r implies auditing.
        print("Performing Audit ...")
        status = auditControl(control)

        if status == STATUS_NA:
            print("Control: " + control_id + " - Audit Not Applicable")
            audit_report_na.append(control_id)
        elif status == STATUS_FAIL:
            print("Control: " + control_id + " - Audit FAIL")
            audit_report_failed.append(control_id)
        else:
            print("Control: " + control_id + " - Audit PASS")
            audit_report_passed.append(control_id)

        ## Remediate only failed controls, and only if the cmd line switch is on
        if do_remediate and status == STATUS_FAIL:
            print("Performing Remediation ...")
            fixed = remediateControl(control)

            if fixed is None:
                print("Control: " + control_id + " - NO AUTOMATED REMEDIATION AVAILABLE")
                remediate_report_none.append(control_id)
            elif fixed:
                print("Control: " + control_id + " - REMEDIATE SUCCESS (verified by re-audit)")
                remediate_report_passed.append(control_id)
            else:
                print("Control: " + control_id + " - REMEDIATE FAIL (still failing re-audit)")
                remediate_report_failed.append(control_id)


def printList(title, items):
    print(title + ": ", len(items))
    for control_id in items:
        print(control_id)
    print()


def createReport():
    print()
    print("===================================================================================")
    print("= Audit Report")
    print("===================================================================================")

    if ignore_list:
        printList("Controls Not Applicable - Known a priori", ignore_list)

    printList("Controls Not Applicable - Derived", audit_report_na)
    printList("Controls Requiring Manual Review", audit_report_manual)
    printList("Controls Passed", audit_report_passed)
    printList("Controls Failed", audit_report_failed)

    if do_remediate:
        print()
        print("===================================================================================")
        print("= Remediation Report")
        print("===================================================================================")

        printList("Controls Remediated Success", remediate_report_passed)
        printList("Controls Remediated Failed", remediate_report_failed)
        printList("Controls Without Automated Remediation", remediate_report_none)


def evalResults():
    # A control counts against the run if it failed its audit and was not fixed by remediation.
    still_failing = [c for c in audit_report_failed if c not in remediate_report_passed]
    if still_failing:
        sys.exit(254)


## Main ##
validateInput()
loadBenchmark()
# Commands reference ./scripts and ./conf relative to the benchmark file, so run from its directory.
os.chdir(os.path.dirname(os.path.abspath(conf_file)))
#dumpBenchmark()
executeBenchmark()
createReport()
evalResults()
