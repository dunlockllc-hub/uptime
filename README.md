# uptime

An outside "is it up?" alarm for a handful of public websites.

- `.github/workflows/uptime.yml` checks every site in its list every 10 minutes, retries a failure once after 20 seconds, and fails the run if a site is still down. A failed run is GitHub's email to the repo owner.
- To prove the alarm can go red: Actions, Uptime, Run workflow, and put a bad address in `extra_url` (for example `https://does-not-exist.taskwell360.com/`). That run must fail and the email must arrive.
- The repo is public so Actions minutes are free. Never put a secret, a private hostname or an IP address in it.

## The 60-day limit

GitHub turns off scheduled workflows in a public repo after 60 days with no commits. `keepalive.yml` commits a date stamp on the 1st of every month to stop that. If the schedule is ever found switched off anyway: Actions, pick the workflow, Enable workflow.
