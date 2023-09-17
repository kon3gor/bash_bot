#!/bin/bash

function getTextField() {
	json="$1"
	field="$2"
	map=$(echo "$json" | egrep -oh "$field\":\"(\/|\w|[[:space:]])*\"")
	result=$(echo "$map" | awk -F ":" '{print $2}' | tr -d '"')
	echo "$result"
}

function getNumericField() {
	json="$1"
	field="$2"
	map=$(echo "$json" | egrep -oh "\"$field\":[0-9]+")
	result=$(echo "$map" | awk -F ":" '{print $2}' | tr -d '"')
	echo "$result"
}
