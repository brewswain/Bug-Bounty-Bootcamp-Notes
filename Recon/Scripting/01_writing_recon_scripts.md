## Bash Scripting basics

By now, it's probably obvious that recon is extensive. So, let's make some scripts ot make our life way easier! We'll use bash scripts for this.

```
#!/bin/bash
nmap scanme.nmap.org
/PATH/TO/dirsearch.py -u scanme.nmap.org -e php
```

The first line declares which interpreter we want to use for this script.
In its current state, this script isn't very useful since it requires a hardcoded URL, so let's update it to let users provide inputs as arguments.

Bash represents arguments passed with `$1`, `$2` etc.
`$@` represents all arguments passed in.
`$#` represents the total number of arguments.

Let's update our script to allow users to specify their targets using one input argument:

```
#!/bin/bash
nmap $1
/PATH/TO/dirsearch.py -u $1 -e php
```

Obviously, we fix our pathing as necessary. We can also add our scripts to PATH, etc. It's pretty intuitive overall.

oh also, if we try to run the script you may encounter a permission denied message. We can bypass that by using `chmod`:

```
chmod +x recon.sh
```

`+x` adds executing rights to all users, so keep that in mind.

To use our script, we'll need to add the URL that we wish to scout for:

```
recon.sh scanme.nmap.org

Starting Nmap 7.60 ( https://nmap.org )
Nmap scan report for scanme.nmap.org (45.33.32.156)
Host is up (0.062s latency).
Other addresses for scanme.nmap.org (not scanned): 2600:3c01::f03c:91ff:fe18:bb2f
Not shown: 992 closed ports
PORT STATE SERVICE
22/tcp open ssh
25/tcp filtered smtp
80/tcp open http
135/tcp filtered msrpc
139/tcp filtered netbios-ssn
445/tcp filtered microsoft-ds
9929/tcp open nping-echo
31337/tcp open Elite
Nmap done: 1 IP address (1 host up) scanned in 2.16 seconds
Extensions: php | HTTP method: get | Threads: 10 | Wordlist size: 6023
Error Log: /Users/vickieli/tools/dirsearch/logs/errors.log
Target: scanme.nmap.org
[11:14:30] Starting:
[11:14:32] 403 - 295B - /.htaccessOLD2
[11:14:32] 403 - 294B - /.htaccessOLD
[11:14:33] 301 - 316B - /.svn -> http://scanme.nmap.org/.svn/
[11:14:33] 403 - 298B - /.svn/all-wcprops
[11:14:33] 403 - 294B - /.svn/entries
[11:14:33] 403 - 297B - /.svn/prop-base/
[11:14:33] 403 - 296B - /.svn/pristine/
[11:14:33] 403 - 315B - /.svn/text-base/index.php.svn-base
[11:14:33] 403 - 297B - /.svn/text-base/
[11:14:33] 403 - 293B - /.svn/props/
[11:14:33] 403 - 291B - /.svn/tmp/
[11:14:55] 301 - 318B - /images -> http://scanme.nmap.org/images/
[11:14:56] 200 - 7KB - /index
[11:14:56] 200 - 7KB - /index.html
Web Hacking Reconnaissance   83
[11:15:08] 403 - 296B - /server-status/
[11:15:08] 403 - 295B - /server-status
[11:15:08] 301 - 318B - /shared -> http://scanme.nmap.org/shared/
Task Completed
```

---

## Saving Tool Output to a File

It'll often be more convenient if our script outputs results into a separate file. Some useful operators for this are as follows:

-  `PROGRAM > FILENAME` Writes the program’s output into the file with that
   name. (It will clear any content from the file first. It will also create the
   file if the file does not already exist.)
-  `PROGRAM >> FILENAME` Appends the output of the program to the end of
   the file, without clearing the file’s original content.
-  `PROGRAM < FILENAME` Reads from the file and uses its content as the program input.
-  `PROGRAM1 | PROGRAM2` Uses the output of PROGRAM1 as the input to PROGRAM2.

Let's write the results of our 2 queries, Nmap and Dirsearch, into different files:

```
#!/bin/bash
echo "Creating directory $1_recon." 1
mkdir $1_recon 2
nmap $1 > $1_recon/nmap 3
echo "The results of nmap scan are stored in $1_recon/nmap."
dirsearch -u $1 -e php 4 --simple-report=$1_recon/dirsearch
echo "The results of dirsearch scan are stored in $1_recon/dirsearch."
```

note the line `--simple-report=$1_recon/dirsearch`. This is some variable assignment. Treat it like we're writing a .env, with no spaces around the `=` operator.

Now that we have variable assignment available to us, let's
