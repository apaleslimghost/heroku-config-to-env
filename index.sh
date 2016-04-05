#!/bin/bash

ignore=("thisstringisnevergoingtoappearlolbutwedontwanttofilterouteverythingwhichiswhatanemptyarraywoulddo")

while getopts ':i:l:' opt; do
		case $opt in
				i) ignore+=("$OPTARG") ;;
				l) localv+=("$OPTARG")
		esac
done

shift $((OPTIND -1))

function join { local IFS="$1"; shift; echo "$*"; }

readonly APP_NAME="$1"
readonly OUT_FILE="$2"

mkdir -p "$(dirname "$OUT_FILE")"

heroku config --app "$APP_NAME" |\
		tail +2 |\
		grep -vE "($(join '|' ${ignore[@]}))" |\
		sed 's/: */=/' |\
		cat - <(echo ${localv[@] | tr ' ' '\n'}) |\
		sed 's/^/export /' |\
		cat <(echo '#!/bin/sh') - > "$OUT_FILE"

chmod +x $OUT_FILE

