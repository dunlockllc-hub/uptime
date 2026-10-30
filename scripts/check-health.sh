#!/usr/bin/env bash
# check-health.sh <url> — fail unless a /api/health answer says ok:true AND backupFresh:true.
#
# The plain uptime check only sees the HTTP status, and Driveway's /api/health
# answers 200 even when the database is down or last night's backup is missing.
# So this reads the values. Retries once after 20 seconds, like the site check.
# HEALTH_FILE=<path> reads a saved answer instead of fetching (used by the tests).
#
# allOk (Driveway PR #57): true only when every dependency is fine (jobs on
# time, mailboxes syncing, no open high-severity incident). If the answer has
# the key it must be true. REQUIRE_ALLOK=1 also fails when the key is missing:
# set it in the workflow once #57 is deployed, so a release that drops the key
# cannot go quiet.
set -u
url=${1:?usage: check-health.sh <url>}

fetch() {
	if [ -n "${HEALTH_FILE:-}" ]; then cat "$HEALTH_FILE"; return; fi
	curl -fsS -m 20 --connect-timeout 10 "$url" 2>/dev/null || true
}

verdict() { # prints OK or the reason
	body=$1
	if [ -z "$body" ]; then echo "no answer"; return; fi
	if ! printf '%s' "$body" | jq -e 'type == "object"' >/dev/null 2>&1; then echo "not JSON"; return; fi
	printf '%s' "$body" | jq -r --arg req "${REQUIRE_ALLOK:-}" '
		if .ok != true then "ok is \(.ok) (db: \(.db // "?"))"
		elif .backupFresh != true then "backupFresh is \(.backupFresh) (backupState: \(.backupState // "?"))"
		elif has("allOk") and .allOk != true then "allOk is \(.allOk) (a job, a mailbox or an incident; see the token-gated detail)"
		elif ($req == "1") and (has("allOk") | not) then "allOk is missing and REQUIRE_ALLOK=1"
		else "OK" end'
}

v=$(verdict "$(fetch)")
if [ "$v" != OK ]; then
	[ -n "${HEALTH_FILE:-}" ] || sleep 20
	v2=$(verdict "$(fetch)")
	if [ "$v2" != OK ]; then
		echo "::error title=Health check failed::$url $v, then $v2 on retry"
		exit 1
	fi
	echo "OK    $url ($v, then OK on retry)"
	exit 0
fi
echo "OK    $url (ok, backupFresh)"
