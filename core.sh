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
		new_id=$(echo "$updates" | egrep -oh 'update_id":\d*' | tr -d 'update_id":')
		new_id=$(echo "$new_id" | awk -v RS='' '{print $NF}')
		if [ ! -z "$new_id" ]; then
			last_id=$((new_id+1))
		fi

		handleMessages "$updates"
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
	chat_ids=($(getNumericField "$1" "id"))

	for i in "${!messages[@]}"; do
		chat_id=${chat_ids[$((2*i))]}
		msg="${messages[$i]}"
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
	echo "Got command: $msg"

	msg="$1"
	chat_id="$2"
	raw_update="$3"

	msg_wo_cmd=${msg#* }
	
	if [[ "$msg" == /send* ]]; then
		answer=$(sendCmd "$msg_wo_cmd")
		sendMessage "$answer" "$chat_id"
	else
		sendMessage "Idk what command is that" "$chat_id"
	fi
	return 0
}

# Just simple echo for now
function handleMessage() {
	msg="$1"
	chat_id="$2"
	raw_update="$3"

	sendMessage "$msg" "$chat_id"
	return 0
}

