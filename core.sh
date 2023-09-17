#!/bin/bash

source json_helpers.sh
source commands.sh

URL="https://api.telegram.org/bot"

function startPolling() {
	token="$1"
	URL="$URL$token"
	last_id=-1
	while true; do
		updates=$(getUpdates "$last_id")
		new_id=$(getNumericField "$updates" "update_id")
		new_id=$(echo "$new_id" | awk -v RS='' '{print $NF}')
		if [ ! -z "$new_id" ]; then
			last_id=$((new_id+1))
			handleMessages "$updates"
		fi

		sleep 1
	done
}

function getUpdates() {
	if [ "$1" = '-1' ]; then
		curl -s "$URL/getUpdates"
	else
		curl -s "$URL/getUpdates?offset=$1"
	fi
}


function handleMessages() {
	IFS=$'\n'
	messages=($(getTextField "$1" "text"))
	echo "$messages"
	chat_ids=($(getNumericField "$1" "id"))

	for i in "${!messages[@]}"; do
		chat_id=${chat_ids[$((2*i))]}
		msg="${messages[$i]}"
		echo "Got message: $msg"
		if [[ "$msg" =~ \/[a-zA-Z]+ ]]; then
			handleCommand "$msg" "$chat_id" "$1"
		else
			handleMessage "$msg" "$chat_id" "$1"
		fi
	done
}

function sendMessage() {
	text="$1"
	chat_id="$2"

	body="{\"chat_id\":\"$chat_id\",\"text\":\"$text\"}"
	curl -s "$URL/sendMessage?chat_id=$chat_id" -H "Content-Type: application/json" -d "$body"
	return 0
}

function handleCommand() {
	echo "Got command: $1"

	msg="$1"
	chat_id="$2"
	raw_update="$3"

	args=${msg#* }
	cmd=$(echo "$msg" | awk '{print $1}')

	ans=$(executeCommand "$raw_update" "$cmd" "$args")
	sendMessage "$ans" "$chat_id"

	return 0
}

# Just simple echo for now
function handleMessage() {
	echo "Got message: $1"
	msg="$1"
	chat_id="$2"
	raw_update="$3"

	sendMessage "$msg" "$chat_id"
	return 0
}

