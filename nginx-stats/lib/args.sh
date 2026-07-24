#!/usr/bin/env bash

LOG_FILE=""
SCORE_MODE=""

usage() {

cat <<EOF

Usage:

nginx-stats [options]

Options

--log FILE    Path to nginx access log
--score       Run abuse detection and scoring
--help        Show this help
--version     Show version

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

--score)

SCORE_MODE=1
shift
;;

*)

error "Unknown argument: $1"

;;

esac

done

}