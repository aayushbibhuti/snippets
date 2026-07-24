#!/usr/bin/env bash

LOG_FILE=""

usage() {

cat <<EOF

Usage:

nginx-stats [options]

Options

--log FILE
--help
--version

EOF

exit 0

}

parse_args() {

while [[ $# -gt 0 ]]
do

case "$1" in

--help|-h)

usage
;;

--version)

echo "$VERSION"
exit 0
;;

--log)

LOG_FILE="$2"
shift 2
;;

*)

error "Unknown argument: $1"

;;

esac

done

}