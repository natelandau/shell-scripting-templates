_haveInternet_() {
  # DESC:   Tests to see if there is an active Internet connection
  # ARGS:   None
  # OUTS:   None
  # USAGE:  _haveInternet_ && [SOMETHING]
  # NOTE:   https://stackoverflow.com/questions/929368/

  if command -v fping &>/dev/null; then
    fping 1.1.1.1 &>/dev/null \
      && return 0 \
      || return 1
  elif ping -t 2 -c 1 1 1.1.1.1 &>/dev/null; then
    return 0
  elif command -v route &>/dev/null; then
    local GATEWAY="$(route -n get default | grep gateway)"
    ping -t 2 -c 1 "$(echo "${GATEWAY}" | cut -d ':' -f 2)" &>/dev/null \
      && return 0 \
      || return 1
  elif command -v ip &>/dev/null; then
    ping -t 2 -c 1 "$(ip r | grep default | cut -d ' ' -f 3)" &>/dev/null \
      && return 0 \
      || return 1
  else
    return 1
  fi
}

_httpStatus_() {
  # DESC:   Report the HTTP status of a specified URL
  # ARGS:   $1 (Required) - URL (will work fine without https:// prefix)
  #         $2 (Optional) - Seconds to wait until timeout (Default is 3)
  #         $3 (Optional) - either '--code'  or '--status' (default)
  #         $4 (optional) - CURL opts separated by spaces (Use -L to follow redirects)
  # OUTS:   Prints output to STDOUT
  # USAGE:  _httpStatus_ URL [timeout] [--code or --status] [curl opts]
  # NOTE:   https://gist.github.com/rsvp/1171304
  #
  #         Example:  $ _httpStatus_ bit.ly
  #                   301 Redirection: Moved Permanently
  #
  #         Example: $ _httpStatus_ www.google.com 100 --code
  local code
  local status

  local saveIFS=${IFS}
  IFS=$' \n\t'

  local url=${1:?_httpStatus_ needs an url}
  local timeout=${2:-'3'}
  local flag=${3:-'--status'}
  local arg4=${4:-''}
  local arg5=${5:-''}
  local arg6=${6:-''}
  local arg7=${7:-''}
  local curlops="${arg4} ${arg5} ${arg6} ${arg7}"

  #      __________ get the CODE which is numeric:
  code=$(echo "$(curl --write-out %{http_code} --silent --connect-timeout "${timeout}" \
    --no-keepalive "${curlops}" --output /dev/null "${url}")")

  #      __________ get the STATUS (from code) which is human interpretable:
  case $code in
    000) status="Not responding within ${timeout} seconds" ;;
    100) status="Informational: Continue" ;;
    101) status="Informational: Switching Protocols" ;;
    200) status="Successful: OK within ${timeout} seconds" ;;
    201) status="Successful: Created" ;;
    202) status="Successful: Accepted" ;;
    203) status="Successful: Non-Authoritative Information" ;;
    204) status="Successful: No Content" ;;
    205) status="Successful: Reset Content" ;;
    206) status="Successful: Partial Content" ;;
    300) status="Redirection: Multiple Choices" ;;
    301) status="Redirection: Moved Permanently" ;;
    302) status="Redirection: Found residing temporarily under different URI" ;;
    303) status="Redirection: See Other" ;;
    304) status="Redirection: Not Modified" ;;
    305) status="Redirection: Use Proxy" ;;
    306) status="Redirection: status not defined" ;;
    307) status="Redirection: Temporary Redirect" ;;
    400) status="Client Error: Bad Request" ;;
    401) status="Client Error: Unauthorized" ;;
    402) status="Client Error: Payment Required" ;;
    403) status="Client Error: Forbidden" ;;
    404) status="Client Error: Not Found" ;;
    405) status="Client Error: Method Not Allowed" ;;
    406) status="Client Error: Not Acceptable" ;;
    407) status="Client Error: Proxy Authentication Required" ;;
    408) status="Client Error: Request Timeout within ${timeout} seconds" ;;
    409) status="Client Error: Conflict" ;;
    410) status="Client Error: Gone" ;;
    411) status="Client Error: Length Required" ;;
    412) status="Client Error: Precondition Failed" ;;
    413) status="Client Error: Request Entity Too Large" ;;
    414) status="Client Error: Request-URI Too Long" ;;
    415) status="Client Error: Unsupported Media Type" ;;
    416) status="Client Error: Requested Range Not Satisfiable" ;;
    417) status="Client Error: Expectation Failed" ;;
    500) status="Server Error: Internal Server Error" ;;
    501) status="Server Error: Not Implemented" ;;
    502) status="Server Error: Bad Gateway" ;;
    503) status="Server Error: Service Unavailable" ;;
    504) status="Server Error: Gateway Timeout within ${timeout} seconds" ;;
    505) status="Server Error: HTTP Version Not Supported" ;;
    *) die "httpstatus: status not defined." ;;
  esac

  case ${flag} in
    --status) echo "${code} ${status}" ;;
    -s) echo "${code} ${status}" ;;
    --code) echo "${code}" ;;
    -c) echo "${code}" ;;
    *) echo " httpstatus: bad flag" && _safeExit_ ;;
  esac

  IFS="${saveIFS}"
}

_pushover_() {
  # DESC:   Sends a notification via Pushover
  # ARGS:   $1 (Required) - Title of notification
  #         $2 (Required) - Body of notification
  # OUTS:   None
  # USAGE:  _pushover_ "Title Goes Here" "Message Goes Here"
  # NOTE:   The variables for the two API Keys must have valid values
  #         Credit: http://ryonsherman.blogspot.com/2012/10/shell-script-to-send-pushover.html

  local PUSHOVERURL
  local API_KEY
  local USER_KEY
  local DEVICE
  local TITLE
  local MESSAGE

  PUSHOVERURL="https://api.pushover.net/1/messages.json"
  API_KEY="${PUSHOVER_API_KEY}"
  USER_KEY="${PUSHOVER_USER_KEY}"
  DEVICE=""
  TITLE="${1}"
  MESSAGE="${2}"
  curl \
    -F "token=${API_KEY}" \
    -F "user=${USER_KEY}" \
    -F "device=${DEVICE}" \
    -F "title=${TITLE}" \
    -F "message=${MESSAGE}" \
    "${PUSHOVERURL}" >/dev/null 2>&1
}
