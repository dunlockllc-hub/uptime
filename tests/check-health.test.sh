#!/usr/bin/env bash
# Runs check-health.sh against saved answers. Every unhealthy shape must fail.
set -u
cd "$(dirname "$0")/.."
pass=0; fail=0
expect() { # expect <fixture> <0|1>
	HEALTH_FILE="tests/fixtures/$1" bash scripts/check-health.sh https://example.invalid/api/health >/dev/null 2>&1
	rc=$?
	if [ "$rc" = "$2" ]; then echo "PASS  $1 -> $rc"; pass=$((pass+1)); else echo "FAIL  $1 -> $rc, wanted $2"; fail=$((fail+1)); fi
}
expect healthy.json 0
expect db-down.json 1
expect backup-stale.json 1
expect backup-missing.json 1
expect not-json.json 1
expect empty.json 1
echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
