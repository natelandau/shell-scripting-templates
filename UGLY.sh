#! /dev/null/bash

function sortT ()
{
    declare tc_tab
    printf -v tc_tab '\t'
    sort -t"${tc_tab}" "${@}"
}

function columntT_cut_tw ()
{
    columntT | cut_tw
}

function cut_tw ()
{
    cut -b1-${COLUMNS}
}

function columntT ()
{
    declare tc_tab tc_sep
    printf -v tc_tab '\t'
    printf -v tc_sep "${1:-.}"
    [[ -z "${1}" ]] || shift
    sed \
            -e "s/^${tc_tab}/${tc_sep}${tc_tab}/" \
            -e "s/${tc_tab}\$/${tc_tab}${tc_sep}/" \
            -e :LOOP \
            -e "s/${tc_tab}${tc_tab}/${tc_tab}${tc_sep}${tc_tab}/;tLOOP" \
            -e :END |
        column -ts"${tc_tab}" "${@}"
}

function ls_ ()
{
    ls -d .??*
}

function cvs ()
{

    #
    ## Proxy CVS through, well, a proxy. ;P
    #
    # CVS server ports are often blocked by firewall rules.
    #

    proxychains4 -q cvs "${@}"

}

function find_apps ()
{ sudo find /Applications/. ~/Applications/. /System/. -type d -name "*.app" | while read DIR; do while :; do DIR="$( echo "${DIR}" | sed "s=^OK:==;s=^\([^${TAB}]*\)/\([^/${TAB}]*\)\.app[^${TAB}]*=OK:\1${TAB}\2=" )"; echo "${DIR}" | grep -q ^OK: || break; done; echo "${DIR}"; done; }

function findhome () 
{ 
    declare {rgxd,rgxf,args,cmd}=;
    args=();
    cd ~ || return 1;
    for I in ${@:+"${@}"};
    do
        printf -v J %q "${I}";
        args[${#args[@]}]="${J}";
    done;
    rgxd=('^(\./(Applications|Library|Maildirs)|.*/\.(git|hg|cvs|svn|bzr))$');
    cmd='find -E . \( -type d -a \( -false '"$( printf " -o -regex '%s' " "${rgxd[@]}" )"' \) -a -prune \) -o \( '"${args[*]:--print}"' \)';
    eval "${cmd}"
}

function findsrc ()
{
    declare {ENTS,ENT,CMD}=;
    ENTS=();
    CMD=();
    while [ "${#}" -gt 0 ]; do
        [[ "${1}" != [-\(\!]* ]] || break;
        ENTS[${#ENTS[@]}]="${1}";
        shift;
    done;
    for ENT in find ${ENTS[@]:+"${ENTS[@]}"} \( -type d -a \( -name .git -o -name .hg -o -name .cvs \) -a -prune -a -exec true \; \) -o "${@:--print}";
    do
        printf -v ENT %q "${ENT}";
        CMD[${#CMD[@]}]="${ENT}";
    done;
    #echo "${CMD[@]}" 1>&2
    eval "${CMD[@]}"
}

function security_dump_keychain_login ()
{

    declare CMD_{DECLARE,HEADERS}=
    CMD_DECLARE='declare {ENT,PAR,VAL,TMP,STG,UNKNOWN,KEYC,CLSS,NAME,ACCT,CRTR,CDAT,MDAT,SVCE,SRVR,PTCL,PORT,DESC,DATA,ACCS{,_CNT,_ENT,_VAL{,_AUTH,_NOPW,_DESC,_APPS}}}=; ACCS=(); ACCS_ENT=-1; ACCS_VAL_APPS=() UNKNOWN=()'
    CMD_HEADERS='printf %s KEYC; printf "\t%s" {CDAT,MDAT,CLSS,NAME,ACCT,CRTR,SVCE/SRVR,DATA,DESC,ACCS}; printf "\n"'

    RGX_IND='^( *)(.*)'

    eval "${CMD_DECLARE}"
    eval "${CMD_HEADERS}"

    declare tc_tilde
    printf -v tc_tilde '~'

    while read -r ENT
    do

        ENT="${ENT#:}"
        ENT="${ENT%:}"
        [[ "${ENT}" =~ ${RGX_IND} ]]
        IND="${#BASH_REMATCH[1]}"
        ENT="${BASH_REMATCH[2]}"

        #printf "\n# %s # %s # %s #\n" "${STG}" "${IND}" "${ENT}"; #continue

        [ "${ACCS_ENT}" -lt 0 ] || ACCS[${ACCS_ENT}]="${ACCS_VAL_NOPW}:${ACCS_VAL_AUTH}:${ACCS_VAL_DESC}:${ACCS_VAL_APPS[*]}"

        [ "${IND}" -gt 0 ] || {

            RGX='^keychain:[[:blank:]]*"(.*)"'
            [[ "${ENT}" =~ ${RGX} ]] && {
                [ -z "${NAME}" ] || {
                    printf "%s" "${KEYC/#${HOME}/${tc_tilde}}"
                    printf "\t%s" "${CDAT:-.}" "${MDAT:-.}" "${CLSS:-.}" "${NAME:-.}" "${ACCT:-.}" "${CRTR:-.}" "${SVCE:-${SRVR:+${SRVR}:${PORT:-.}:${PTCL:-.}}}" "${DATA:-.}" "${DESC:-.}"
                    printf "\t%s" ${ACCS[*]:+"${ACCS[@]//${TAB}/:}"}
                    printf "\n"
                    #[ "${#UNKNOWN[@]}" -eq 0 ] || printf "? %s\n" "${UNKNOWN[@]}"
                }
                eval "${CMD_DECLARE}"
                KEYC="${BASH_REMATCH[1]}"
                STG=CLSS
                continue
            }

            RGX='^class:[[:blank:]]*(.*)[[:blank:]]*'
            [[ "${ENT}" =~ ${RGX} ]] && {
                CLSS="${BASH_REMATCH[1]%\"}"
                CLSS="${CLSS#\"}"
                continue
            }

            RGX='^attributes:'
            [[ "${ENT}" =~ ${RGX} ]] && {
                STG=ATTS
                continue
            }

            RGX='^data:'
            [[ "${ENT}" =~ ${RGX} ]] && {
                STG=DATA
                continue
            }

            RGX='^access:[[:blank:]]+([0-9]+)[[:blank:]]+entr'
            [[ "${ENT}" =~ ${RGX} ]] && {
                ACCS_CNT="${BASH_REMATCH[1]}"
                STG=ACCS
                continue
            }

        }

    case "${STG}" in
        ( DATA ) {
            RGX='^([^"]*)[[:blank:]]*(\"(.*)\")? *$'
            [[ "${ENT}" =~ ${RGX} ]] && {
                DATA="${DATA:+${DATA}${NLN}}${BASH_REMATCH[3]:-${BASH_REMATCH[1]}}"
                continue
            }
        };;
        ( ATTS ) {
                        RGX='^("([^"]*)"|(0x[0-9A-F]+))[ ]*(<[^<>]*>)=([^" ]*)[[:blank:]]*(\"(.*)\")?[ ]*$'
            [[ "${ENT}" =~ ${RGX} ]] && {
                PAR="${BASH_REMATCH[2]:-${BASH_REMATCH[3]}}"
                                TYP="${BASH_REMATCH[4]}"
                VAL="${BASH_REMATCH[7]:-${BASH_REMATCH[5]}}"
                [ "${VAL}" == "<NULL>" ] && VAL=
                case "${PAR}" in
                    ( acct )	ACCT="${VAL}";;
                    ( crtr )	CRTR="${VAL}";;
                    ( cdat )	CDAT="${VAL%Z*}";;
                    ( mdat )	MDAT="${VAL%Z*}";;
                    ( svce )	SVCE="${VAL}";;
                    ( srvr )	SRVR="${VAL}";;
                    ( ptcl )	PTCL="${VAL}";;
                    ( port )	PORT="${VAL}";;
                    ( desc )	DESC="${VAL}";;
                    ( labl )	NAME="${NAME:-${VAL}}";;
                    ( 0x00000001 )	NAME="${NAME:-${VAL}}";;
                    ( 0x00000007 )	NAME="${NAME:-${VAL}}";;
                    #( 0x* )		eval ATT_${PAR}="\${VAL}";;
                    ( * )
                    {
                        [ -z "${VAL}" ] || UNKNOWN=(${UNKNOWN[*]:+"${UNKNOWN[@]}"} "${PAR}=${VAL}")
                    }
                    ;;
                esac
                continue
            }
        };;
        ( ACCS* ) {
            RGX='^entry[[:blank:]]+([0-9]+)'
            [[ "${ENT}" =~ ${RGX} ]] && {
                ACCS_ENT="${BASH_REMATCH[1]}"
                ACCS_VAL_NOPW="?"
                ACCS_VAL_APPS=()
                                ACCS_VAL_AUTH=
                                STG="ACCS"
                continue
            }
            RGX='^authorizations[[:blank:]]+\(([0-9]+)\):[[:blank:]]*(.*)'
            [[ "${ENT}" =~ ${RGX} ]] && {
                ACCS_VAL_AUTH="${BASH_REMATCH[2]// /,}"
                continue
            }
            RGX='^don.t-require-password'
            [[ "${ENT}" =~ ${RGX} ]] && {
                ACCS_VAL_NOPW="*"
                continue
            }
            RGX='^description:[[:blank:]]*(.*)'
            [[ "${ENT}" =~ ${RGX} ]] && {
                ACCS_VAL_DESC="${BASH_REMATCH[1]/<NULL>/}"
                continue
            }
            RGX='^applications[[:blank:]]+\(([0-9]+)\):[[:blank:]]*(.*)'
            [[ "${ENT}" =~ ${RGX} ]] && {
                STG="ACCS_APPS"
                continue
            }
            RGX='^applications:[[:blank:]]*<null>'
            [[ "${ENT}" =~ ${RGX} ]] && {
                STG="ACCS"
                continue
            }
            RGX='^([0-9]+):[[:blank:]]*(.*)'
            [[ "${ENT}" =~ ${RGX} ]] && {
                ACCS_VAL_APPS=( ${ACCS_VAL_APPS[*]:+"${ACCS_VAL_APPS[@]}"} "${BASH_REMATCH[2]}" )
                continue
            }
        };;
    esac

    done < <( { security dump-keychain -ad $( security login-keychain | cut -d"\"" -f2 ) 2>&1 | sed "s/.*/:&:/"; echo ':keychain: "<NULL>":'; } )

    eval "${CMD_HEADERS}"

}

function ssh_socks () 
{ 
    declare {hst,prt}=;
    hst="${1}";
    prt="${2}";
    ssh_via_wifi \
            ${hst} \
            -oControlPath=none \
            -p 443 \
            -D localhost:${prt} \
            -vaxnN \
            2>&1 |
        tee -a "${TMPDIR:-/tmp}/ssh_socks_${hst}_${prt}.log" |
        awk \
            '
            /([Ff]orward|[Cc]hannel|[Ll]ocal)/{
                sub(/^debug1: /,"");
                gsub(/ on /,"/");
                if(/^channel  *[0-9]*:/){
                    CHN=$2;
                    sub(/^channel  *[0-9]*:/,"");
                    printf("C%3s: %s",CHN,$0)
                }else{
                    print($0)
                }
            }
            '
}

function ssh_via_wifi () 
{ 
    ssh -b $( ifconfig en1 | sed -n "s/^[[:blank:]]*inet \([0-9\.]*\).*/\1/p" ) ${@:+"${@}"}
}

function weechat_log_view ()
{
    weechat_logs_view 1 ${@:+"${@}"}
}

function weechat_logs_view () 
{ 
    declare {AGE,RGX{,_NEG,_DTS},CMD_SED,ASESSION}=
    ASESSION="$$_$( date "+%Y%m%d%H%M%S" )_${RANDOM}"
    RGX_DTS="[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]"
    CMD_SED=(
    sed
    -e "'s=^\([^:]*\.weechatlog\):\(.*\)=&${TC_TAB}\1='"
    -e "'s=^\([^:]*\)/server\.\([^/:]*\)/=\1/\2/%/='"
    -e "'s=^\(\./core/[^/]*\)/\(.*\)=\1/%/\2='"
    -e "'s=^[^:]*/\([^/]*\)/\([^/]*\)/\([^/]*\)/[^/:]*\.weechatlog:\([0-9]*\):\(${RGX_DTS}\)\(${TC_TAB}\)\([^${TC_TAB}]*\)${TC_TAB}=\1\6\2\6\3\6\4\6\5\6\7\6___MSG___${ASESSION}___='"
    -e :FIX_NIL
    -e "'s=${TC_TAB}${TC_TAB}\(.*___MSG___${ASESSION}___\)=${TC_TAB}%${TC_TAB}\1=;tFIX_NIL'"
    -e "'s=${TC_TAB}___MSG___${ASESSION}___=${TC_TAB}='"
    )
    AGE="${1:-1}"
    shift
    RGX="${1:-${RGX_DTS}}"
    RGX_NEG="${2:-${ASESSION}}"
    cd ~/.weechat/logs/. || return
    weechat_logs "${AGE}" "${RGX}" |
    sed "s/.*${TC_TAB}//" |
    sort -u |
    tr "\n" "\0" |
    xargs -0 egrep -Hn "" |
    eval "${CMD_SED[@]}" |
    sed "s/${TC_TAB}[^${TC_TAB}]*\$//" |
    sort -t"${TC_TAB}" -k 5,5 -k 1,1 -k 2,2 -k 3,3 -k 4,4g |
    cut -f1-3,5- |
    { [ -t 1 ] && { column -ts"${TC_TAB}" | less -isR -p "${RGX}"; } || cat -; }
}

function weechat_msgs ()
{
    weechat_logs "${1}" "^irc.*....-..-.. ..:..:..${TC_TAB}[^ℹ<>]*${TC_TAB}.*${2}" "${3}"
}

function weechat_fifo ()
{
    declare {fnc,cfgd,out,tgt,cmd,tmp}=
    fnc="${FUNCNAME[0]:-}"
    tgt="${1:-}"
    cfgd="${WEECHAT_HOME:-${HOME}/.weechat}"
    out="$( find "${cfgd}" -maxdepth 1 -name "weechat_fifo_*" -type p -print 2>/dev/null )"
    [ -n "${out:-}" ] || {
        printf "${fnc}: %s\n" "No Weechat FIFO found!"
        return 1
    }
    echo "${out}" |
        grep -c fifo |
        grep -qx 1 || \
        {
            printf "${fnc}: %s\n" "More than one FIFO found!"
            return 2
        }
    [ -n "${tgt:-}" ] || {
        printf "${fnc}: %s\n" \
                "Must provide target for commands." \
                "( ie: irc.freenode,#weechat [ '.' is short-hand for 'core.weechat' ] )"
        return 3
    }
    shift
    [ -n "${*}" -o ! -t 0 ] || {
        printf "${fnc}: %s\n" \
                "Must provide commands to send to target ( ${tgt} )." \
                "( ie: Try '/set' to see if it works. )"
        return 4
    }
    [ "${tgt}" != "." ] || tgt="core.weechat"
    {
        {
            [ -t 0 ] || sed "s=^=${tgt} *="
            for cmd in ${@:+"${@}"}
            do
                printf "${tgt} *%s\n" "${cmd}"
            done
        } | tee "${out}"
    } 1>&2
}

function weechat_fifo_set ()
{
    declare {IFS,CMDS,CMD}=
    printf -v IFS "\n"
    [ -t 0 ] || CMDS=($( cat - ))
    CMDS=(${CMDS[@]:+"${CMDS[@]}"} ${@:+"${@}"})
    for CMD in ${CMDS[@]:+"${CMDS[@]}"}
    do
        printf "/set %s\n" "${CMD}"
    done | weechat_fifo .
}

function weechat_list_channels ()
{
    find ~/.weechat/logs/irc/*/. -type f -name "*.weechatlog" -mtime -14 -print0 |
    xargs -0 ls -1rt |
    tr "\n" "\0" |
    xargs -0I@ egrep -inH "....-..-.. ..:..:..[[:blank:]]+[^[:blank:]]*[[:blank:]]+(channel[[:blank:]]+users[[:blank:]]+name|end of channel list|end of /list)" "@" |
    sed "s=^\([^:]*/[^/]*\.weechatlog\):\([0-9]*\):.*=\1${TC_TAB}\2=" |
    paste - - |
    cut -f1-2,4 |
    while read ENT
    do
        LOG="${ENT%%${TC_TAB}*}"
        RNG="${ENT#*${TC_TAB}}"
        RNG="${RNG/${TC_TAB}/,}"
        {
            echo "${LOG}" |
            sed "s=.*/irc/\([^/]*\)/\./\([^/]*\)\.weechatlog=\1${TC_TAB}\2="
            sed -n "${RNG}p" "${LOG}" |
            sed -n "s/^[^#]*\(#[^[:blank:]]*\)(\([0-9]*\)):[[:blank:]]*\(.*\)/\1${TC_TAB}\2${TC_TAB}\3/p"
        } |
        sed "1h;1d;x;p;x" |
        paste - -
    done |
    grep -n "" |
    sed "s/:/${TC_TAB}/" |
    sort -t"${TC_TAB}" -k 2,2 -k 3,3 -k 4,4 -k 1,1g |
    sort -t"${TC_TAB}" -k 2,2 -k 3,3 -k 4,4 -u |
    cut -f2- |
    { [ -t 1 ] && { column -ts"${TC_TAB}" | pager; } || cat -; }
}

function weechat_keys ()
{
    declare {OUT,KEY_KBD,TC_TAB,TC_NLN}=
    printf -v TC_TAB "\t"
    printf -v TC_NLN "\n"
    OUT="$( sed -n "/^\[key.*\]\$/,/^[[:blank:]]*\$/p" ~/.weechat/weechat.conf )"
    OUT="$(
    echo "${OUT}" |
    sed \
        -e "s/^\[\(.*\)\]\$/SEC=\1/" \
        -e tSEC \
        -e bENT \
        -e :SEC \
        -e "h;d" \
        -e :ENT \
        -e "/^[[:blank:]]*\$/d;x;p;x;s/[[:blank:]]*=[[:blank:]]*/${TC_TAB}CMD=/;s/^/KEY=/" |
    tr "\t" "\n"
    )"
    echo "${OUT}" | sed "s/^...=//" | paste - - - | column -ts"${TC_TAB}" | less
    return
    KEY_KBD="$(
    infocmp -1L |
    tr -d "\t" |
    sed -n "s#^[[:blank:]]*\([^=]*\)=\(\\\E.*\),[[:blank:]]*\$#KEY=\2${TC_TAB}KBD=\1#p" |
    tr "\t" "\n" |
    sed "/^KEY=/s/\\\E\[/meta2-/g;/^KEY=/s/\\\E/meta-/g" |
    awk '(/^KEY=/){printf("%s:",length($0))};{print}' |
    paste - - |
    sort -t: -k 1,1gr |
    cut -d: -f2- |
    tr "\t" "\n" |
    sed "s/^...=//;s/[#\^\*\$]/\\\\&/g" |
    paste -d"#" - - |
    sed "s/.*/\/^KBD=\/s#&#g;/" |
    grep -v "%"
    )"
    OUT="$(
    echo "${OUT}" |
    sed \
        -e "/^KEY=/bKEY" \
        -e b \
        -e :KEY \
        -e "p;s/^KEY=/KBD=/"
    )"
    echo "${OUT}" |
    sed -f <( echo "${KEY_KBD}" ) |
    sed "s/^...=//" |
    paste - - - - |
    column -ts"${TC_TAB}" |
    less
}

function weechat_history ()
{
    grep "^/" ~/.weechat/history/global_history |
    sed -n \
        -e "/^\//bISCMD" \
        -e n \
        -e :ISCMD \
        -e "
    h;
    s/[[:blank:]].*//;
    y/$( printf %s {A..Z} )/$( printf %s {a..z} )/;
    p;
    g;
    s=^[^[:blank:]]*==;
    s=^[[:blank:]]*\$=___NOOP___&=;
    p;
    " |
    paste - - |
    sed "s/___NOOP___//;s/${TC_TAB}//" |
    grep -n "" |
    sed "s/^[[:blank:]]*//;s/:/${TC_TAB}/"
}

function weechat_history_latest ()
{
    weechat_history | sort -k 2,2 -k 3,3 -k 1,1gr | sort -u -k 2,2 -k 3,3 | sort -k 1,1g
}

function weechat_alias_input ()
{
    tr "\t" "\0" < ~/.weechat/alias.conf |
    sed \
        -e "1,/^\[cmd\]/d" \
        -e "/^[[:blank:]]*\$/,\$d" \
        -e "/^[^_]/d" \
        -e "s/\"[[:blank:]]*\$//" \
        -e "s/[[:blank:]]*=[[:blank:]]*\"*/${TC_TAB}/" |
    column -ts"${TC_TAB}" |
    tr "\0" "\t" |
    ${PAGER:-less -isR}
}

function random_alnum_lc ()
{
    declare {RGX,STR,LEN,TMP}=
    LEN="${1:-8}"
    CNT=0
    RGX='^[0-9a-z]$'
    while read -n1 TMP; do
        [[ "${TMP}" =~ ${RGX} ]] || continue
        STR="${STR}${TMP}"
        [ "${#STR}" -lt "${LEN}" ] || break
    done < /dev/urandom
    echo "${STR}"
}

function ssh-keygen-rs ()
{
    declare user host
    user="${2:-aaron.river}"
    host="${1:+${1}.rackspace.com}"
    host="${host:-rackspace.com}"
	ssh-keygen-_ "${host}" "${user}"
}

function ssh-keygen-rtit ()
{
    declare user host
    user="${2:-root}"
    host="${1:+${1}.runsthruit.com}"
    host="${host:-runsthruit.com}"
	ssh-keygen-_ "${host}" "${user}"
}

function ssh-keygen-_ ()
{
    declare fnc dts user host key com ans
	fnc="${FUNCNAME[$((${#FUNCNAME[@]}-1))]:-${FUNCNAME}}"
    dts="$( date "+%Y-%m-%d" )"
    user="${2:-nobody}"
    host="${1:-example.com}"
	key=~/.ssh/id_rsa.d/"id_rsa_${user}_${host}"
	com="${user}@${host} ${dts}"
	{
		[[ -r "${key}" ]] && ans="YES" || ans="no"
		printf "${fnc}: %s %s\n" \
				"  User:" "${user}" \
				"  Host:" "${host}" \
				"   DTS:" "${dts}" \
				"   Key:" "${key}" \
				"Exists?" "${ans}"
		printf 'Proceed [y/N]? '
		read -n 1 -p '' ans
		printf '\n'
	} 1>&2
	[[ "${ans}" == [Yy] ]] || return 1
    ssh-keygen -v -P "" -t rsa -b 2048 -C "${com}" -f "${key}"
}

function pathlist ()
{
    declare path_tmp tc_nln tc_tilde
    printf -v tc_nln '\n'
    printf -v tc_tilde '~'
    path_tmp="${PATH//${HOME}/${tc_tilde}}"
    printf '%s\n' "${path_tmp//:/${tc_nln}}"
}

function Maildirs_LFTC ()
{
    declare days mdir mdirs opwd tc_tab
    opwd="${PWD}"
    mdir=~/Source/Maildirs
    days="${1:-30}"
    printf -v tc_tab '\t'
    for mdir in ${mdir}/*
    do
        printf ': %s\n' "${mdir}"
        [[ -d "${mdir}" ]] || continue
        cd "${mdir}" || continue
        {
            find . -mindepth 2 -type f -mtime -${days} -print |
                pv -Wl -bratT -N LFTC.0 > LFTC.0
        } || continue
        [[ -s LFTC.0 ]] || continue
        {
            pv -l -Trapbet -s $( grep -c "" LFTC.0 ) -N LFTC.1 < LFTC.0 |
                tr "\n" "\0" |
                xargs -0 awk \
                '
                    BEGIN{LST="";FROM="";TO="";CC="";FLST=0;FFROM=0;FTO=0;FCC=0;TMP=""};
                    /^./{
                        $0=tolower($0);
                        if(sub(/^[[:blank:]]{1,}/,"")){TMP=TMP" "$0}
                        else{
                            if(TMP~/^list-id: ./){LST=TMP;FLST=1};
                            if(TMP~/^to: ./){TO=TMP;FTO=1};
                            if(TMP~/^cc: ./){CC=TMP;FCC=1};
                            if(TMP~/^from: ./){FROM=TMP;FFROM=1};
                            TMP=$0
                        }
                    };
                    ((/^$/)||(FLST&&FROM&&FTO&&FCC)){
                        if(LST==""){LST="."};
                        if(FROM==""){FROM="."};
                        if(TO==""){TO="."};
                        if(CC==""){CC="."};
                        print(LST"\t"FROM"\t"TO"\t"CC"\t"FILENAME"\t");
                        LST="";
                        FROM="";
                        TO="";
                        CC="";
                        FLST=0;
                        FFROM=0;
                        FTO=0;
                        FCC=0;
                        TMP="";
                        nextfile
                    }
                ' |
                awk '
                    {
                        gsub(/[:,] *("([^"]*([\\]["])+)*[^"]*"|[^"<>\t]*) *</,":");
                        gsub(/>:/,":");
                        gsub(/>\t/,"\t");
                        sub(/ *"</,"");
                        sub(/>" */,"");
                        gsub(/: /,":");
                        print
                    }
                ' |
                cat - \
                    > LFTC.1;
        } || continue
        {
            pv -l -Trapbet -s $( grep -c "" LFTC.1 ) -N LFTC.2 < LFTC.1 |
                grep -ow -f <( sed -n "s/^list-id:\([^${tc_tab}]*\).*/\1/p" LFTC.1 | sort -u | egrep -v "\.github(\.rackspace)?\.com" ) |
                sort -u > LFTC.2
        } || continue
        {
            pv -l -btT -s $( grep -c "" LFTC.2 ) -N LFTC.3 < LFTC.2 |
                grep -v "[@\.]lists\.rackspace\.com\$" |
                while read -r MAIL;
                do
                    ldaps_rs -LLL "(&(objectClass=Person)(mail=${MAIL}))" mail;
                done |
                tr "[:upper:]" "[:lower:]" |
                sed -n "s/^mail: //p" |
                sort -u > LFTC.3
        } || continue
        {
            pv -l -btT -s $( grep -c "" LFTC.2 ) -N LFTC.4 < LFTC.2 |
                grep -v -f <( sed "s/@/./" LFTC.3 ) |
                grep -v @ > LFTC.4
        }
    done
    cd "${opwd}"
}

function ssh_active ()
{
	declare prefix tmp
    for prefix in $(
		sed -n 's/^[[:blank:]]*ControlPath[[:blank:]=][[:blank:]=]*//p' ~/.ssh/config |
		sed 's/%.*//'
	)
    do
        printf -v tmp 'ls -lrtond %s*' "${prefix}"
        eval "${tmp}" |
			sed \
				-e 's/^[^[:blank:]]*[[:blank:]][[:blank:]]*//' \
				-e 's/^[^[:blank:]]*[[:blank:]][[:blank:]]*//' \
				-e 's/^[^[:blank:]]*[[:blank:]][[:blank:]]*//' \
				-e 's/^[^[:blank:]]*[[:blank:]][[:blank:]]*//' \
				-e "s=${prefix}==" \
				-e 's=_= =g' \
				-e 's=   *= =g'
    done |
		column -t
}

function pianobar_played ()
{
	declare tc_tab
	printf -v tc_tab '\t'
    egrep -n '^(_ENT_|(dts|artist|title|album|stationName|songDuration|songPlayed|rating)=..*)$' ~/.config/pianobar/log |
		sed \
			-e '/:dts=/s/=[0-9]*-/=/' \
			-e '/:stationName=/s/ *_ */_/g' \
			-e "s/:/${tc_tab}/" \
			-e :END |
		tr '\t\n' '\0' |
		sed "s/_ENT_/${tc_tab}/g" |
		tr '\t' '\n' |
		tr '\0' '\t' |
		grep title= |
		sed 's/^./order=/' |
		cut -f1-2,4,6,8,10,12,14,16 |
		sed 1p |
		sed \
				-e 1bONE \
				-e bREST \
				-e :ONE \
				-e "s/=[^${tc_tab}]*//g" \
				-e 's/stationName/Station/' \
				-e 's/song//g' \
				-e 's/Duration/sDur/' \
				-e 's/Played/sPlay/' \
				-e 's/rating/R/' \
				-e 's/dts/DTS/' \
				-e 's/artist/Artist/' \
				-e 's/title/Title/' \
				-e bEND \
				-e :REST \
				-e "s/\(${tc_tab}\)[^[:blank:]]*=/\1/g;s/^[^=]*=//" \
				-e :END |
		sort -t"${tc_tab}" -k 3,6 -k 7,7gr -k 8,8gr |
		sort -t"${tc_tab}" -k 3,6 -u |
		sort -k 1,1g |
		cut -f2- |
		cut -f1-3,5- |
		columntT |
		sed '1h;1d;$p;$x'
}

function mutt_BUILD () 
{

    declare {TAB,SRC,TAR,CFGCMD,DEPS}=
    declare {C,CPP,LD}FLAGS=

    printf -v TAB '\t'

    BDIR="${HOME_SRC_DIR}/LOCAL/mutt"
    IDIR="${HOME}/.local"
    CFLAGS="-ggdb"
    DEPS=(
        $( brew deps mutt --with-debug --with-gpgme --with-pgp-verbose-mime-patch --with-s-lang --with-trash-patch )
#        berkeley-db4
        gettext
        patchutils
#        gpatch
    )
    CFGCMD=(
        ./configure
        --prefix="${IDIR}"
        --enable-imap
        --enable-smtp
        --enable-pop
        --enable-hcache
        --with-tokyocabinet
        --with-homespool=".mbox"
        --with-slang
        --with-gss
        --with-ssl
        --enable-gpgme
        --with-regex
        #--disable-debug
        --enable-debug
        #--disable-warnings
        #--quiet
        #--enable-silent-rules
    )

    mkdir -p "${BDIR}"
    cd "${BDIR}" || return 1

    { 

        printf "\n# %s #\n\n" GET

        SRC="https://bitbucket.org/mutt/mutt/downloads"

        TAR="$(
            curl -s "${SRC}/" |
            sed "s#^[[:blank:]]*##;s#[[:blank:]]*\$##" |
            tr -s "\r\n\t" " " |
            sed "s#</[Aa]>#${TAB}#g" |
            tr "\t" "\n" |
            sed -n "s#.*<a[^<>]*href=\"\([^\"]*/downloads/[^\"]*\)\"[^<>]*>\([^<>]*gz\)\$#\2#p" |
            head -1
        )"

        wget --content-disposition --no-check-certificate -nc "${SRC}/${TAR}" || printf "\n"

        printf "# %s #\n\n" REM

        find . -maxdepth 1 -type d -name "mutt-*" -exec rm -rf "{}" \;

        printf "\n# %s #\n\n" ADD

        tar -xzf "${TAR}"

        cd "${TAR%.tar.gz}" || return 2

        printf "\n# %s #\n\n" SET

        aclocal -I m4
        autoheader
        automake -af --foreign
        autoconf

        echo .

        brew install ${DEPS[*]} 2>&1 | grep --line-buffered -v "already installed"

        eval "$(
            {
                {
                echo "${CPPFLAGS}" "${LDFLAGS}" |
                sed "s/[[:blank:]][[:blank:]]*\(-[IL]\)/${TAB}\1/g" |
                tr "\t" "\n"
                brew list ${DEPS[*]} 2>/dev/null |
                sed -n "s#^\(.*\)/include/.*#-I\1#p;s#^\(.*\)/lib/.*#-L\1#p"
                } |
                sort -u |
                tee >( grep ^-I | paste -sd" " - | sed "s#.*#CPPFLAGS='&'#" 1>&2 ) |
                grep ^-L |
                paste -sd" " - |
                sed "s#.*#LDFLAGS='&'#"
            } 2>&1 |
            sed "s/^/export /"
        )" && echo .

        declare -p CFLAGS CPPFLAGS LDFLAGS

        printf "\n# %s #\n\n" CNF

        K=
        for (( I=0; I<${#CFGCMD[@]}; I++ ))
        do
            printf "%s%s\n" "${K}" "${CFGCMD[${I}]}${CFGCMD[$((I+1))]:+ \\}"
            K="${TAB}"
        done
        eval "${CFGCMD[@]}"

        printf "\n# %s #\n\n" PCH

        echo 'curl -skL %URL% | patch -p1 -b -z.BAK --dry-run --verbose'

    } 1>&2

}

function msmtp_BUILD () 
{

    declare {TAB,SRC,TAR,CFGCMD,DEPS}=
    declare {C,CPP,LD}FLAGS=

    printf -v TAB '\t'

    BDIR="${HOME}/Source/LOCAL/msmtp"
    IDIR="${HOME}/.local"
    CFLAGS="-ggdb"
    DEPS=(
        $( brew deps msmtp )
#        berkeley-db4
        gettext
        patchutils
#        gpatch
    )
    CFGCMD=(
        ./configure
        --prefix="${IDIR}"
    )

    mkdir -p "${BDIR}"
    cd "${BDIR}" || return 1

    {

        printf "\n# %s #\n\n" SET

        aclocal -I m4
        autoheader
        automake -af --foreign
        autoconf

        echo .

        brew install ${DEPS[*]} 2>&1 | grep --line-buffered -v "already installed"

        echo "$(
            {
                {
                echo "${CPPFLAGS}" "${LDFLAGS}" |
                sed "s/[[:blank:]][[:blank:]]*\(-[IL]\)/${TAB}\1/g" |
                tr "\t" "\n"
                brew list ${DEPS[*]} 2>/dev/null |
                sed -n "s#^\(.*\)/include/.*#-I\1#p;s#^\(.*\)/lib/.*#-L\1#p"
                } |
                sort -u |
                tee >( grep ^-I | paste -sd" " - | sed "s#.*#CPPFLAGS='&'#" 1>&2 ) |
                grep ^-L |
                paste -sd" " - |
                sed "s#.*#LDFLAGS='&'#"
            } 2>&1 |
            sed "s/^/export /"
        )" && echo .

        declare -p CFLAGS CPPFLAGS LDFLAGS

        printf "\n# %s #\n\n" CNF

        K=
        for (( I=0; I<${#CFGCMD[@]}; I++ ))
        do
            printf "%s%s\n" "${K}" "${CFGCMD[${I}]}${CFGCMD[$((I+1))]:+ \\}"
            K="${TAB}"
        done
        echo "${CFGCMD[@]}"

    } 1>&2

}
