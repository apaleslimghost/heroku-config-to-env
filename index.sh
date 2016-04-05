#!/bin/bash

ignore=("thisstringisnevergoingtoappearlolbutwedontwanttofilterouteverythingwhichiswhatanemptyarraywoulddo")

while getopts ':i:' opt; do
		case $opt in
				i) ignore+=("$OPTARG")
		esac
done

shift $((OPTIND -1))

function join { local IFS="$1"; shift; echo "$*"; }

readonly APP_NAME="$1"
readonly OUT_FILE="$2"

mkdir -p "$(dirname "$OUT_FILE")"

heroku config --app "$APP_NAME" |\
		tail +2 |\
		sed 's/: */=/;  s/^/export /' |\
		grep -vE "($(join '|' ${ignore[@]}))" |\
		cat <(echo '#!/bin/sh') - > "$OUT_FILE"

chmod +x $OUT_FILE

