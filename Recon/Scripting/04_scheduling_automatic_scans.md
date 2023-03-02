## Scheduling Automatic Scans

Let's improve our automation a bit more by building an alert system to ping us if anything interesting turns up!

For this...we can use the almighty cron job. All hail!

Ok but seriously, cron jobs are amazing. It'll allow us to schedule jobs to run periodically, searching for changes including new endpoints or new vulnerabilities that pop up. We can configure Cron's behaviour by using a file called a crontab. Unix keeps different copies of crontabs for each user. We can edit the current user's crontab by running:

```
crontab -e
```

All crontabs follow this syntax:

```
A B C D E command_to_be_executed
A: Minute (0 – 59)
B: Hour (0 – 23)
C: Day (1 – 31)
D: Month (1 – 12)
E: Weekday (0 – 7) (Sunday is 0 or 7, Monday is 1...)
```

Also, here's a [Cron expression generator](https://cron-ai.vercel.app/) to make life easy.

Anyway, each line specifies a command ot be run and the time at which it should run, using 5 sets of numbers. For example, let's run our `recon.sh` at 9:30PM every day:

```
30 21 * * * ./scan.sh
```

We can also batch-run the scripts within directories. The `run-parts` command tells Cron to runn all the scripts stored in a directory:

```
30 21 * * * run-parts /Users/blee/scripts/security
```

Something else to help us here is to use `git diff`. Let's say we were to want to compare scan results at different times, we can do something like this:

```
git diff SCAN_1 SCAN_2
```

The reason this is relevant is that this means we can write a script that'll notify us of new changes on a target every day:

```
#!/bin/bash
DOMAIN=$1
DIRECTORY=${DOMAIN}_recon
echo "Checking for new changes about the target: $DOMAIN.\n Found these new things."
git diff <SCAN AT TIME 1> <SCAN AT TIME 2>
```

And we can then schedule it:

```
30 21 * * * ./scan_diff.sh facebook.com
```

This is very useful to discover subdomain takeover vulnerabilities in particular. Oh, we can also check git diffs by simple using a cron job to push to a designated repo and view our commit history!
