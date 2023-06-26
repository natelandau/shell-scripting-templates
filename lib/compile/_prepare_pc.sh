#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of useful utility functions for compiling sources
#
# @author  Alexei Kharchev
#
# @file
# Defines function: bfl::prepare_pc().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prepares .pc files for libraries in given directory.
#
# @option String --dry-run, -dry-run
#   Enable test mode.
#
# @param String --library, --lib, -lib
#   lib directory to make .la file
#
# @param String --version
#   library version to write
#
# @param Array $lib_names
#   A list of libraries' names.
#
# @example
#   bfl::prepare_pc  --dry-run --lib=/tools/binutils-2.40/lib/pkgconfig --version='0.0.0' libctf.so.0
#------------------------------------------------------------------------------
bfl::prepare_pc() {
  bfl::verify_arg_count "$#" 3 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [3..999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

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

  local str=''    # Verify argument values.
  [[ -z ${curDir+x} ]]      && str="$str\nlibrary is not defined!" || { [[ -z "$curDir" ]] && str="$str\nlibrary path is empty!"; }
  [[ -z ${FullVersion+x} ]] && str="$str\nVersion is not defined!" || { [[ -z "$FullVersion" ]] && str="$str\nVersion is empty!"; }

  local -i i=${#arr_pcFiles[@]}
  [[ $i -eq 0 ]] && str="$str\npc files list is not defined!"
  bfl::is_blank $str || { bfl::writelog_fail "${FUNCNAME[0]}: $str"; return ${BFL_ErrCode_Not_verified_arg_values}; }

# printf '//----------------------------------- libraries -----------------------------------\n'
local FileName pcFile
local str2=''; local b=false; local reslt=''
for str in ${arr_pcFiles[@]}; do
    FileName=${str:0: -3} # Название библиотеки
    pcFile="$curDir/$FileName.pc"

    b=false
    if [[ -f "$pcFile" ]]; then
        b=true
        [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}File $pcFile will be overwritten${NC}\n" > /dev/tty
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

      ! $b && [[ $BASH_INTERACTIVE == true ]] && printf "${Green}File $pcFile created${NC}\n" > /dev/tty
      reslt="$reslt;$pcFile"
  done

  reslt=${reslt: 1}
  echo "$reslt"
  return 0
  }
