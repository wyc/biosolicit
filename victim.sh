#!/bin/bash

CHECK_DELIVERY_TIMEOUT=300

usage=$(cat <<HERE
usage: $(basename "$0") <message.txt> <queue.txt> <delivered.txt> <failed.txt>

program to solicit bios emails from alumNY

    message.txt     path to plaintext message file to send as body

    queue.txt       filepath to emails to randomly select from, one per line.
                    will be modified as emails are consumed.

    delivered.txt   filepath that the program appends emails to after
                    successful sending, one per line.

    failed.txt      filepath that the program appends emails to after failed
                    sending, one per line.

required env vars:

    export MAILGUN_API_KEY=key-deadbeefcoffeecoffeedeadbeefcoff
    Mailgun API key found in the account control panel

    export MAILGUN_DOMAIN=sandbox6a7433f93d694422bc4d9b66c193d048.mailgun.org
    A domain setup with Mailgun to send from

HERE
)

[ "$#" -ne "4" ] && echo "$usage" >&2 && exit -1

function mailgun_delivered() {
    logger -t "$0" "checking delivery status of email to ${1}"
    waited=0
    while [ "$waited" -lt "$CHECK_DELIVERY_TIMEOUT" ]; do
        resp="$(curl -s --user "api:${MAILGUN_API_KEY}" -G \
              https://api.mailgun.net/v3/events \
              --data-urlencode tags="$2" \
              --data-urlencode begin="$(date --date '-2 hour')" \
              --data-urlencode ascending=yes \
              --data-urlencode limit=25 \
              --data-urlencode pretty=yes \
              --data-urlencode recipient="$1")"

        if grep '"event": "delivered"' <(echo "$resp") 1>/dev/null; then
            logger -t "$0" "email delivered"
            return 0
        elif grep '"event": "failed"' <(echo "$resp") 1>/dev/null; then
            logger -t "$0" "email failed to send"
            return -1
        elif grep '"event": "accepted"' <(echo "$resp") 1>/dev/null; then
            logger -t "$0" "email sending..."
        else
            logger -t "$0" "no emails detected..."
        fi
        sleep 5;
        waited=$((waited + 5))
    done
    logger -t "$0" "email delivery status detection timed out"
    return -2
}

function mailgun_send() {
    epoch="$(date +%s)"
    logger -t "$0" "queuing email for ${1} on mailgun"
    resp="$(curl -i -s --user "api:${MAILGUN_API_KEY}" \
        "https://api.mailgun.net/v3/${MAILGUN_DOMAIN}/messages" \
        -F from="hackNY Biographies <biographies@${MAILGUN_DOMAIN}>" \
        -F to="$1" \
        -F subject="You've been tapped for an AlumNY Bio" \
        -F text="$(cat "$2")" \
        -F o:tag="$epoch")"
    if ! grep 'id' <(echo $resp) >/dev/null; then
        logger -t "$0" "queuing failed: $(grep 'message' <(echo $resp))"
        return -1
    fi
    logger -t "$0" "message queued on mailgun!"
    mailgun_delivered "$1" "$epoch"
}

message=$1
queue=$2
delivered=$3
failed=$4

logger -t "$0" 'biosolicit, i choose you! awaken!!!'
victim=$(sort -R "$queue" | head -n 1)
if [ -z "${victim}" ]; then
    logger -t "$0" "no victims in queue file: ${queue}"
    logger -t "$0" "going to sleep...Zzz"
    exit 0
fi

logger -t "$0" "chose victim: ${victim}"
if mailgun_send $victim $message; then
    echo "$victim" >> $delivered
    logger -t "$0" "entry ${victim} moved to delivered file: ${delivered}"
else
    echo "$victim" >> $failed
    logger -t "$0" "entry ${victim} moved to failed file: ${failed}"
fi
sed -i "/${victim}/d" "$queue"
