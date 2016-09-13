# biosolicit

program to solicit bios emails from alumNY. You'll need a mailgun account and
keys/domain. logs to syslog or wherever `logger` goes.

## Usage

```
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
```

## Installation

```bash
mkdir /opt/biosolicit
git clone https://github.com/wyc/biosolicit /opt/biosolicit
echo 'Hello, world!' > /opt/biosolicit/message.txt
echo "email1@example.com\nemail2@example.com" > /opt/biosolicit/queue.txt
# run every tuesday at 9:00 am
(crontab -l; echo "00 09 * * TUE $(whoami) bash /opt/biosolicit/run.sh") | crontab -
```

## Example log entries
```
Sep 13 15:43:04 /opt/biosolicit/victim.sh[9115]: biosolicit, i choose you! awaken!!!
Sep 13 15:43:04 /opt/biosolicit/victim.sh[9119]: no victims in message file: /opt/biosolicit/message.txt
Sep 13 15:43:04 /opt/biosolicit/victim.sh[9120]: going to sleep...Zzz
Sep 13 15:43:31 /opt/biosolicit/victim.sh[10322]: biosolicit, i choose you! awaken!!!
Sep 13 15:43:31 /opt/biosolicit/victim.sh[10328]: chose victim: email@example.com
Sep 13 15:43:31 /opt/biosolicit/victim.sh[10330]: queuing email for email@example.com on mailgun
Sep 13 15:43:32 /opt/biosolicit/victim.sh[10337]: message messaged on mailgun!
Sep 13 15:43:32 /opt/biosolicit/victim.sh[10338]: checking delivery status of email to email@example.com
Sep 13 15:43:32 /opt/biosolicit/victim.sh[10385]: no emails detected...
Sep 13 15:43:37 /opt/biosolicit/victim.sh[10589]: no emails detected...
Sep 13 15:43:43 /opt/biosolicit/victim.sh[10992]: email delivered
Sep 13 15:43:43 /opt/biosolicit/victim.sh[10994]: entry email@example.com moved to delivered file: /opt/biosolicit/delivered.txt

```
