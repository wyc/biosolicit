#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
message="${DIR}/message.txt"
queue="${DIR}/queue.txt"
delivered="${DIR}/delivered.txt"
failed="${DIR}/failed.txt"

exec ${DIR}/victim.sh "$message" "$queue" "$delivered" "$failed"
