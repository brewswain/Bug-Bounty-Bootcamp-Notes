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
echo "Creating directory $1_recon."
mkdir $1_recon
nmap $1 > $1_recon/nmap
echo "The results of nmap scan are stored in $1_recon/nmap."
dirsearch -u $1 -e php --simple-report=$1_recon/dirsearch
echo "The results of dirsearch scan are stored in $1_recon/dirsearch."
```

note the line `--simple-report=$1_recon/dirsearch`. This tells dirsearch where to generate a report.

Also, we can assign variables by using the format of `VARIABLE_NAME=foobar`. Treat it like we're writing a .env, with no spaces around the `=` operator.
Now that we have variable assignment available to us, let's freshen up this script a bit:

```
#!/bin/bash

DOMAIN=$1
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

DIRSEARCH_DIRECTORY=$DOMAIN/dirsearch
OUTPUT_FILE=${DOMAIN}_${DATE}.txt

echo "Creating directory $DOMAIN."
mkdir -p $DOMAIN
echo "Creating subdirectory $DIRSEARCH_DIRECTORY."
mkdir -p $DIRSEARCH_DIRECTORY
touch $DIRSEARCH_DIRECTORY/$OUTPUT_FILE
echo "Creating Dirsearch Output file: $OUTPUT_FILE"
nmap $DOMAIN > $DOMAIN/nmap
echo "The results of nmap scan are stored in $DIRECTORY/nmap."
dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
```

---

## Adding Options to Choose the Tools to Run

Let's assume that we don't want to run a complete suite of tools every single time. Conditionals!

```
if [ condition 1 ]
then
   # Do thing
elif [ condition 2]
then
   # Do other thing
else
   # Default thing to run
fi
```

Let's say that we want to specify the scan `MODE`:

```
./recon.sh scanme.nmap.org MODE
```

we can do something like this:

```
#!/bin/bash

DOMAIN=$1
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

DIRSEARCH_DIRECTORY=$DOMAIN/dirsearch
OUTPUT_FILE=${DOMAIN}_${DATE}.txt

echo "Creating directory $DOMAIN."
mkdir -p $DOMAIN
echo "Creating subdirectory $DIRSEARCH_DIRECTORY."
mkdir -p $DIRSEARCH_DIRECTORY
touch $DIRSEARCH_DIRECTORY/$OUTPUT_FILE
echo "Creating Dirsearch Output file: $OUTPUT_FILE"

if [ $2 == "nmap-only" ]
then
    nmap $DOMAIN > $DOMAIN/nmap
    echo "The results of nmap scan are stored in $DIRECTORY/nmap."
elif [ $2 == "dirsearch-only" ]
then
    dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
    echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
else
    nmap $DOMAIN > $DOMAIN/nmap
    echo "The results of nmap scan are stored in $DIRECTORY/nmap."
    dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
    echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
fi
```

Nice! We can now add some flags to our script to decide if we want to exclusively only use one specific utility or not. However,
we can neaten this up a lil bit by using Case Statement (It's literally just a switch statement lol):

```
case $TEST_VARIABLE in
   case1)
      Do the thing
      ;;
   case2)
      Do the other thing
      ;;
   *)
      Default case here
      ;;
esac
```

Let's implement the statements now!

```
#!/bin/bash

DOMAIN=$1
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

DIRSEARCH_DIRECTORY=$DOMAIN/dirsearch
CRT_DIRECTORY=$DOMAIN/crt
OUTPUT_FILE=${DOMAIN}_${DATE}.txt

echo "Creating directory $DOMAIN."
mkdir -p $DOMAIN
echo "Creating subdirectory $DIRSEARCH_DIRECTORY."
mkdir -p $DIRSEARCH_DIRECTORY
touch $DIRSEARCH_DIRECTORY/$OUTPUT_FILE
echo "Creating Dirsearch Output file: $OUTPUT_FILE"

case $2 in
   nmap-only)
      nmap $DOMAIN > $DOMAIN/nmap
      echo "The results of nmap scan are stored in $DIRECTORY/nmap."
      ;;
   dirsearch-only)
      dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
      echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
      ;;
   crt-only)
      ;;
   *)
      nmap $DOMAIN > $DOMAIN/nmap
      echo "The results of nmap scan are stored in $DIRECTORY/nmap."
      dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
      echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
      curl "https://crt.sh/?q=$DOMAIN&output=json" -o $CRT_DIRECTORY
      echo "The results of cert parsing is stored in $CRT_DIRECTORY.
      ;;
esac
```

Definitely neater! However, we can still do better. Let's work functions into the mix:

```
#!/bin/bash
DOMAIN=$1
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

DIRSEARCH_DIRECTORY=$DOMAIN/dirsearch
CRT_DIRECTORY=$DOMAIN/crt
OUTPUT_FILE=${DOMAIN}_${DATE}.txt

echo "Creating directory $DOMAIN."
mkdir -p $DOMAIN
echo "Creating subdirectory $DIRSEARCH_DIRECTORY."
mkdir -p $DIRSEARCH_DIRECTORY
touch $DIRSEARCH_DIRECTORY/$OUTPUT_FILE
echo "Creating Dirsearch Output file: $OUTPUT_FILE"

nmap_scan()
{
    nmap $DOMAIN > $DOMAIN/nmap
    echo "The results of nmap scan are stored in $DIRECTORY/nmap."
}
dirsearch_scan()
{

    dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
    echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
}
crt_scan()
{
    curl "https://crt.sh/?q=$DOMAIN&output=json" -o $CRT_DIRECTORY
    echo "The results of cert parsing is stored in $CRT_DIRECTORY."
}

case $2 in
    nmap-only)
        nmap_scan
    ;;
    dirsearch-only)
        dirsearch_scan
    ;;
    crt-only)
        crt_scan
    ;;
    *)
        nmap_scan
        dirsearch_scan
        crt_scan
    ;;
esac
```

Nice. We removed a bunch of repetition, and even have our logic clumped together, which helps with debugging.

An interesting thing with bash is that all bash variables are global except for input params. Lexical scope's crying in the club rn. Basically that means
that using stuff like `$1` _inside_ of a function refers to the first argument that said function was called with. Other than that, everything's available globally.

An example of what I mean with the function:

```
nmap_scan()
{
 nmap $1 > $DIRECTORY/nmap
 echo "The results of nmap scan are stored in $DIRECTORY/nmap."
}
nmap_scan
```

In the above, `$1` refers to the first argument that `nmap_scan()` is called with, not the argument that our `recon.sh` script itself was called with.
Very important but simple distinction.

---

## Parsing the Results

Ok, so we have our script up and running. Let's continue improving it! Instead of us manually opening each file, let's add some `grep` functionality:

```
grep password file.txt
```

The above tells grep to look for "password" inside of a file called `file.txt`, then print the matching results out. To make it fit in with our script, let's say we want to see if our target has port 80 open:

```
grep 80 TARGET_DIRECTORY/nmap

80/tcp open http
```

Grep is also able to use regex (GREP === Global Regular Expression Print btw):

```
grep -E "^\S+\s+\S+\s+\S+$" DIRECTORY/nmap > DIRECTORY/nmap_cleaned
```

I'm not gonna add regex terms here, they're annoying. But they ARE pretty powerful so keep em in mind.

The above is pretty interesting since it acts like a filter--`\s`
matches any whitespace, and `\S` matches any non-whitespace. Therefore,`\s+` would match any whitespace one or more characters long, and `\S+` would
match any non-whitespace one or more characters long. This regex pattern
specifies that we should extract lines that contain three strings separated by
two whitespaces.

Basically, we should get this output:

```
PORT STATE SERVICE
22/tcp open ssh
25/tcp filtered smtp
80/tcp open http
135/tcp filtered msrpc
139/tcp filtered netbios-ssn
445/tcp filtered microsoft-ds
9929/tcp open nping-echo
31337/tcp open Elite
```

Let's add some optional spaces around our search string:

```
"^\s*\S+\s+\S+\s+\S+\s*$"
```

---

## Building a Master Report

Let's make a master report from all 3 output files! First of all, `crt.sh` gives us a JSON, so we need to parse it. there's a utility called `jq` that'll do it for us:

```
jq -r ".[] | .name_value" $DOMAIN/crt
```

-  `-r` tells `jq` to write to the output to standard format rather than as JSON string.
-  `.[]` iterates through the array within the JSON
-  `.name_value` extracts the `name_value` field of each item

Let's combine all output files into a master report now:

```
#!/bin/bash
DOMAIN=$1
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

DIRSEARCH_DIRECTORY=$DOMAIN/dirsearch
CRT_DIRECTORY=$DOMAIN/crt
OUTPUT_FILE=${DOMAIN}_${DATE}.txt

echo "Creating directory $DOMAIN."
mkdir -p $DOMAIN
echo "Creating subdirectory $DIRSEARCH_DIRECTORY."
mkdir -p $DIRSEARCH_DIRECTORY
touch $DIRSEARCH_DIRECTORY/$OUTPUT_FILE
echo "Creating Dirsearch Output file: $OUTPUT_FILE"

nmap_scan()
{
    nmap $DOMAIN > $DOMAIN/nmap
    echo "The results of nmap scan are stored in $DIRECTORY/nmap."
}
dirsearch_scan()
{

    dirsearch -u $DOMAIN -e php --output=/home/kali/Desktop/Scripts/Recon/$DIRSEARCH_DIRECTORY/${OUTPUT_FILE} --format=plain
    echo "The results of dirsearch scan are stored in $DIRSEARCH_DIRECTORY."
}
crt_scan()
{
    curl "https://crt.sh/?q=$DOMAIN&output=json" -o $CRT_DIRECTORY
    echo "The results of cert parsing is stored in $CRT_DIRECTORY."
}

case $2 in
    nmap-only)
        nmap_scan
    ;;
    dirsearch-only)
        dirsearch_scan
    ;;
    crt-only)
        crt_scan
    ;;
    *)
        nmap_scan
        dirsearch_scan
        crt_scan
    ;;
esac

echo "Generating Recon report from output file(s)."
echo "This scan was created on $DATE > $DIRECTORY/report
echo "Results for Nmap:" >> $DIRECTORY/report
grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report
echo "Results for Dirsearch:" >> $DIRECTORY/report
cat $DIRECTORY/dirsearch >> $DIRECTORY/report
echo "Results for crt.sh:" >> $DIRECTORY/report
jq -r ".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report
```
