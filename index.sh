#!/bin/bash

ignore=("thisstringisnevergoingtoappearlolbutwedontwanttofilterouteverythingwhichiswhatanemptyarraywoulddo")

usage() {
	if [ "$1" != "" ]; then
		echo "$1"
		echo "────────────────"
	fi

	cat <<EOF
Usage: $(basename $0) heroku-app-name [path/to/env.sh]

path/to/env.sh is optional. if it's provided, the file will be written
and made executable. if it's blank or '-', it's written to stdout.

Options:
	-i PATTERN	ignore any config var matching PATTERN. can be used multiple times
	-l VAR=val	add an entry setting VAR to val. use with -i to prevent duplicates
	-h		show this help
EOF

	exit $([ "$1" == "" ] ; echo $?)
}

while getopts ':i:l:h' opt; do
		case $opt in
				i) ignore+=("$OPTARG") ;;
				l) localv+=("$OPTARG") ;;
				h) usage ;;
				?) usage "Unknown option $OPTARG"
		esac
done

shift $((OPTIND -1))

function join { local IFS="$1"; shift; echo "$*"; }

readonly APP_NAME="$1"
OUT_FILE="$2"

if [ "$APP_NAME" == "" ]; then
	usage "App name missing"
fi

if [ "$OUT_FILE" == "" ] || [ "$OUT_FILE" == "-" ] ; then
	OUT_FILE="/dev/stdout"
fi

mkdir -p "$(dirname "$OUT_FILE")"

heroku config --app "$APP_NAME" |\
		# strip the heroku header
		tail +2 |\
		# remove ignored vars
		grep -vE "($(join '|' ${ignore[@]}))" |\
		# convert to bashy format
		sed 's/: *\(.*\)$/="\1"/' |\
		# add locally-set vars
		cat - <(echo ${localv[@])} | tr ' ' '\n') |\
		# remove empty lines
		grep -v '^$' |\
		# prepend export
		sed 's/^/export /' |\
		# write the file with a shebang
		cat <(echo '#!/bin/sh') - > "$OUT_FILE"

if [ "$OUT_FILE" != "/dev/stdout" ]; then
	chmod +x $OUT_FILE
fi
