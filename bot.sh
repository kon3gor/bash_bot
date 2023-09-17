#!/bin/bash

function sendBBCmd() {
	echo "$1"
}

function runBBCmd() {
	res=$(python -c "$1")
	echo "$res"
}

source core.sh
source env.sh

startPolling "$TOKEN"

