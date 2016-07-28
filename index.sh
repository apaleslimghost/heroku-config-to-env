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

`export` is prepended to each line, unless -e is set or the path ends with .env

Options:
	-i PATTERN	ignore any config var matching PATTERN. can be used multiple times
	-l VAR=val	add an entry setting `VAR` to `val`. use with -i to prevent duplicates
	-e		don't prepend `export` to each line
	-h		show this help
EOF

	exit $([ "$1" == "" ] ; echo $?)
}

while getopts ':i:l:eh' opt; do
		case $opt in
				i) ignore+=("$OPTARG") ;;
				l) localv+=("$OPTARG") ;;
				e) noexport=1          ;;
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

# shouldn't export vars if it's a .env file
if [ "$OUT_FILE" == *.env ] || [ "$OUT_FILE" == ".env" ]; then
	noexport=1
fi

mkdir -p "$(dirname "$OUT_FILE")"

heroku config --shell --app "$APP_NAME" |\
		# strip the heroku header
		tail +2 |\
		# remove ignored vars
		grep -vE "($(join '|' ${ignore[@]}))" |\
		# add locally-set vars
		cat - <(echo ${localv[@]} | tr ' ' '\n') |\
		# remove empty lines
		grep -v '^$' |\
		# prepend export (unless noexport is set)
		([ "$noexport" == '1' ] && cat || sed 's/^/export /') |\
		# write the file with a shebang
		cat <(echo '#!/bin/sh') - > "$OUT_FILE"

if [ "$OUT_FILE" != "/dev/stdout" ]; then
	chmod +x $OUT_FILE
fi
