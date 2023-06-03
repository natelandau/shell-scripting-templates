#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::prepare_pc().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prepares .pc files for libraries in given directory.
#
# @option string --dry-run, -dry-run
#   test mode
#
# @param string --library, --lib, -lib
#   lib directory to make .la file
#
# @param string --version
#   library version to write
#
# @param array $lib_names
#   A list of libraries' names.
#
# @example
#   bfl::prepare_pc  --dry-run --lib=/tools/binutils-2.40/lib/pkgconfig --version='0.0.0' libctf.so.0
#------------------------------------------------------------------------------
bfl::prepare_pc() {
  bfl::verify_arg_count "$#" 3 999 || exit 1  # Verify argument count.

  local arr=(); local arr_pcFiles=()
  local dryrun=false; local IFS=''
  for arg do
      IFS=$'=' read -r -a arr <<< "$arg"
      case ${arr[0]} in
          -dry-run | --dry-run)       dryrun=true; shift ;;
          -lib | --lib | --library )  local curDir=${arr[1]}; shift ;;
          --version )                 local FullVersion=${arr[1]}; shift ;;
          (*)  # set -- "$@" "$arg"
          arr_pcFiles+=("$arg") ;;  # Поддержка любого количества shared libraries
      esac
  done
  unset IFS

  local str=''  # ----------------------- Проверки ---------------------------
  [[ -z ${curDir+x} ]] && str="$str\nlibrary is not defined!" || [[ -z "$curDir" ]] && str="$str\nlibrary path is empty!"
  [[ -z ${FullVersion+x} ]] && str="$str\nVersion is not defined!" || [[ -z "$FullVersion" ]] && str="$str\nVersion is empty!"

  local i=${#arr_pcFiles[@]}
  [[ $i -eq 0 ]] && str="$str\npc files list is not defined!"

  if [[ -n $str ]]; then
      [[ $BASH_INTERACTIVE == true ]] && printf "${Red}$str${bfl_aes_reset}\n" > /dev/tty
      echo '' && return 1
  fi

# printf '//----------------------------------- libraries -----------------------------------\n'
local FileName pcFile
local str2=''; local b=false; local reslt=''
for str in ${arr_pcFiles[@]}; do
    FileName=${str:0: -3} # Название библиотеки
    pcFile="$curDir/$FileName.pc"

    b=false
    if [[ -f "$pcFile" ]]; then
        b=true
        [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}File $pcFile will be overwritten${bfl_aes_reset}\n" > /dev/tty
    fi

    if ! $dryrun; then
        echo 'prefix=/usr/local
exec_prefix=${prefix}
libdir=${prefix}/lib
includedir=${prefix}/include
' > $pcFile
      echo "Name: $FileName
Description:
Version: $FullVersion" >> $pcFile
      #echo 'URL: ' >> $pcFile
      str2=${FileName:0:3}
      [[ $str2='lib' ]] && echo 'Libs: -L${libdir} -l'${FileName:3} >> $pcFile || echo 'Libs: ' >> $pcFile
      echo 'Cflags: -I${includedir}' >> $pcFile
  fi

      ! $b && [[ $BASH_INTERACTIVE == true ]] && printf "${Green}File $pcFile created${bfl_aes_reset}\n" > /dev/tty
      reslt="$reslt;$pcFile"
  done

  reslt=${reslt: 1}
  echo "$reslt"
  return 0
  }
