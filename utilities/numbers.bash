
_fromSeconds_() {
  # DESC:   Convert seconds to HH:MM:SS
  # ARGS:   $1 (Required) - Time in seconds
  # OUTS:   Print HH:MM:SS to STDOUT
  # USAGE:  _convertSecs_ "SECONDS"
  #     To compute the time it takes a script to run:
  #       STARTTIME=$(date +"%s")
  #       ENDTIME=$(date +"%s")
  #       TOTALTIME=$(($ENDTIME-$STARTTIME)) # human readable time
  #       _convertSecs_ "$TOTALTIME"

  ((h = ${1} / 3600))
  ((m = (${1} % 3600) / 60))
  ((s = ${1} % 60))
  printf "%02d:%02d:%02d\n" $h $m $s
}

_toSeconds_() {
  # DESC:   Converts HH:MM:SS to seconds
  # ARGS:   $1 (Required) - Time in HH:MM:SS
  # OUTS:   Print seconds to STDOUT
  # USAGE:  _toSeconds_ "01:00:00"
  # NOTE:   Acceptable Input Formats
  #           24 12 09
  #           12,12,09
  #           12;12;09
  #           12:12:09
  #           12-12-09
  #           12H12M09S
  #           12h12m09s

  local saveIFS

  if [[ "$1" =~ [0-9]{1,2}(:|,|-|_|,| |[hHmMsS])[0-9]{1,2}(:|,|-|_|,| |[hHmMsS])[0-9]{1,2} ]]; then
    saveIFS="$IFS"
    IFS=":,;-_, HhMmSs" read -r h m s <<< "$1"
    IFS="$saveIFS"
  else
    h="$1"
    m="$2"
    s="$3"
  fi

  echo $(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
}

_countdown_() {
  # DESC:   Sleep for a specified amount of time
  # ARGS:   $1 (Optional) - Total seconds to sleep for(Default is 10)
  #         $2 (Optional) - Increment to count down
  #         $3 (Optional) - Message to print at each increment (default is ...)
  # OUTS:   None
  # USAGE:  _countdown_ 10 1 "Waiting for cache to invalidate"

  local i ii t
  local n=${1:-10}
  local stime=${2:-1}
  local message="${3:-...}"
  ((t = n + 1))

  for ((i = 1; i <= n; i++)); do
    ((ii = t - i))
    if declare -f "info" &>/dev/null 2>&1; then
      info "${message} ${ii}"
    else
      echo "${message} ${ii}"
    fi
    sleep $stime
  done
}
