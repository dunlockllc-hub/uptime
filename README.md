# uptime

An outside "is it up?" alarm for a handful of public websites.

- `.github/workflows/uptime.yml` checks every site in its list every 10 minutes, retries a failure once after 20 seconds, and fails the run if a site is still down. A failed run is GitHub's email to the repo owner.
- It also reads Driveway's `/api/health` and fails if `ok` or `backupFresh` is false (`scripts/check-health.sh`). The status code alone cannot see this, because that endpoint answers 200 when the database is down. `tests/check-health.test.sh` proves that every unhealthy answer fails, and it runs on every pull request.
- To prove the alarm can go red: Actions, Uptime, Run workflow, and put a bad address in `extra_url` (for example `https://does-not-exist.taskwell360.com/`). That run must fail and the email must arrive.
- The repo is public so Actions minutes are free. Never put a secret, a private hostname or an IP address in it.

## The 60-day limit

GitHub turns off scheduled workflows in a public repo after 60 days with no commits. `keepalive.yml` commits a date stamp on the 1st of every month to stop that. If the schedule is ever found switched off anyway: Actions, pick the workflow, Enable workflow.

## It is NOT a 10-minute alarm

GitHub runs scheduled workflows when it has spare capacity. It does not run them on the clock. Between 25 Oct 07:31 and 28 Oct 23:35 UTC (2026), the `*/10` schedule ran 21 times in about 88 hours, roughly once every 4 hours. Treat this repo as a backstop that keeps working when the server is gone, not as the pager. The real 1 to 5 minute monitor is Better Stack, with a keyword monitor on the same `/api/health` URL. Backups get a Healthchecks.io dead-man's switch that `backup.sh` pings.
