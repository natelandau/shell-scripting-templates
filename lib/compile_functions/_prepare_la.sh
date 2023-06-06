#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::prepare_la().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prepares .la files for libraries in given directory.
#
# @option string--dry-run, -dry-run
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
#   bfl::prepare_la  --dry-run --lib=/tools/binutils-2.40/lib --version='0.0.0' libctf.so.0
#------------------------------------------------------------------------------
bfl::prepare_la() {
  bfl::verify_arg_count "$#" 3 999 || exit 1  # Verify argument count.

  local arr=(); local arr_libNames=()
  local dryrun=false; local IFS=''
  for arg do
      IFS=$'=' read -r -a arr <<< "$arg"
      case ${arr[0]} in
          -dry-run | --dry-run)       dryrun=true; shift ;;
          -lib | --lib | --library )  local curDir=${arr[1]}; shift ;;
          --version )                 local FullVersion=${arr[1]}; shift ;;
          (*)  # set -- "$@" "$arg"
          arr_libNames+=("$arg") ;;  # Поддержка любого количества shared libraries
      esac
  done
  unset IFS

  local str=''  # ------------------------- Проверки -------------------------
  [[ -z ${curDir+x} ]] && str="$str\nlibrary is not defined!" || [[ -z "$curDir" ]] && str="$str\nlibrary path is empty!"
  [[ -z ${FullVersion+x} ]] && str="$str\nVersion is not defined!" || [[ -z "$FullVersion" ]] && str="$str\nVersion is empty!"

  local i=${#arr_libNames[@]}
  [[ $i -eq 0 ]] && str="$str\nfiles were not defined!"

  if [[ -n $str ]]; then
      [[ $BASH_INTERACTIVE == true ]] && printf "${Red}$str${NC}\n" > /dev/tty
      echo '' && return 1
  fi
# --------------------------------------------------

#FullVersion="$2"    # `echo "$2" | sed 's/^\(.*\)-\([0-9][0-9.]*.*\)$/\2/'`
local sCurrent=`echo "$FullVersion" | sed 's/^\([^.]*\)\..*$/\1/'`
local sAge=`echo "$FullVersion" | sed "s/$sCurrent\.\([^.]*\)\..*$/\1/"`
local sRevision=`echo "$FullVersion" | sed "s/$sCurrent\.$sAge\.//"`

# printf '//----------------------------------- libraries -----------------------------------\n'
local libName laName soFiles
local b=false; local reslt=''
for str in ${arr_libNames[@]}; do
    if [[ -z "$str" ]]; then
        [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}Прочитано пустое имя${NC}\n" > /dev/tty
        continue
    fi

    libName=`echo "$str" | sed 's/\.so\.[^.]*$//'` # Название библиотеки
    laName="$curDir/$libName.la"
    soFiles=`ls "$curDir/$libName".so* | sed "s|$curDir/||g" | tr '\n' ' '`
    if [[ -z "$soFiles" ]]; then
        [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}cannot find files $libName.so*${NC}\n" > /dev/tty
        continue
    fi
    soFiles=${soFiles::-1}  # удалил последний символ

    b=false
    if [[ -f "$laName" ]]; then
        b=true
        [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}File $laName will be overwritten${NC}\n" > /dev/tty
    fi

    ! $dryrun && echo "# $libName.la - a libtool library file
# Generated by libtool (GNU libtool) 2.4.7

# Please DO NOT delete this file!
# It is necessary for linking the library.

# The name that we can dlopen(3).
dlname='$str'

# Names of this library.
library_names='$soFiles'

# The name of the static archive.
old_library=''

# Linker flags that cannot go in dependency_libs.
inherited_linker_flags=''

# Libraries that this one depends upon.
dependency_libs=''

# Names of additional weak libraries provided by this library.
weak_library_names=''

# Version information for $libName.
current=$sCurrent
age=$sAge
revision=$sRevision

# Is this an already installed library?
installed=yes

# Should we warn about portability when linking against -modules?
shouldnotlink=no

# Files to dlopen/dlpreopen
dlopen=''
dlpreopen=''
# Directory that this library needs to be installed in:
libdir='/usr/local/lib'" > $laName

      ! $b && [[ $BASH_INTERACTIVE == true ]] && printf "${Green}File $laName created${NC}\n" > /dev/tty
      reslt="$reslt;$laName"
  done

  reslt=${reslt: 1}
  echo "$reslt"
  return 0
  }
