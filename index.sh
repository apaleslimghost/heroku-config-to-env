#!/bin/bash

readonly APP_NAME="$1"
readonly OUT_FILE="$2"

mkdir -p "$(dirname "$OUT_FILE")"

heroku config --app "$APP_NAME" |\
		tail +2 |\
		sed 's/: */=/;  s/^/export /' |\
		cat <(echo '#!/bin/sh') - > "$OUT_FILE"

chmod +x $OUT_FILE

