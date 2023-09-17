function executeCommand() {
	raw_update="$1"
	cmd="$2"
	args="$3"

	known=$(compgen -A function | grep "${cmd#\/}BBCmd")

	if [ -z "$known" -o "$known" = " " ]; then
		echo "Idk what command is that"
	else
		res=$($known "$args" "$raw_update")
		echo "$res"
	fi

	return 0
}
