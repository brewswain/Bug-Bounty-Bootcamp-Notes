## Building Interactive Programs

Let's work on user inputs during execution.

Let's say we want our program to enter an interactive mode once we use a specific flag, `-i`. In this mode, we'll want it to ask us to input a domain to scan. We can use `read` for this!

```
echo "Please enter a domain!"
read $DOMAIN
```

This'll store the input inside of $DOMAIN. Let's drop it in a while loop so that a user can input multiple domains:

```
while [ $INPUT != "quit" ];do
 echo "Please enter a domain!"
 read INPUT
 if [ $INPUT != "quit" ];then
 scan_domain $INPUT
 report_domain $INPUT
 fi
done
```

Oh also, we'll need to let our script invoke multiple options, including the new `-i` flag:

```
while getopts "m:i" OPTION; do
    case $OPTION in
        m)
            MODE=$OPTARG
        ;;
        i)
            INTERACTIVE=true
        ;;
        *)echo "error" >&2
            exit 1
    esac
done
```
