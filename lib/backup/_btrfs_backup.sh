#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to backups
#
# @author  Alexei Kharchev
#
# @file
# Defines function: bfl::btrfs_backup().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# backup btrfs volume: 1) to temporary directory on the same partition.
#                      2) after that mirroring to another partition.
#                      3) removing all temporary backups except last.
#
# @option String --dry-run, -dry-run
#   Enable test mode.
#
# @option String --help
#   Prints script version, help and exit.
#
# @option String -v, --version
#   Prints script version and exit.
#
# @param String -folder, --folder
#   Btrfs subvolume to backup.
#
# @param String -temp-snapshots-folder, --temp-snapshots-folder
#   Directory on local btrfs partition for building and keeping and least one last snapshot.
#
# @param String -snapshots-folder, --snapshots-folder
#   Directory on other btrfs partition (final copy).
#
# @example
#   bfl::btrfs_backup --dry-run --folder=/etc --temp-snapshots-folder=/temp-backup --snapshots-folder=/mnt/Timeshift
#------------------------------------------------------------------------------
# to have nested local functions without global scope: https://stackoverflow.com/questions/38264873/nested-functions-on-bash
#                  !!!!
bfl::btrfs_backup() ( # !!!
  bfl::verify_arg_count "$#" 3 6 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [3..999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

#  set -o errexit  # Это защищает от игнорирование аварийного завершения команд
#  set -u # или set -o nounset  # Это защищает от попыток использовать необъявленные переменные
#  set +x

  myHelp() {  # Display Help
    printf 'Список предусмотренных опций и параметров:\n'
  #  printf "Syntax: scriptTemplate [-g|h|v|V]"
    printf "\n
${Blue}Parameters:${NC}\n
${Green} -folder, --folder        ${NC}     Btrfs subvolume to backup\n
${Green} -temp-snapshots-folder,\n${NC}
${Green} --temp-snapshots-folder  ${NC}     Directory on local btrfs partition for building\n
                               and keeping and least one last snapshot\n
${Green} -snapshots-folder,\n     ${NC}
${Green}  --snapshots-folder      ${NC}     Directory on other btrfs partition (final copy)\n
\n
${Blue}options:\n${NC}
${Green} -dry-run, --dry-run      ${NC}     "'"'"Холостой"'"'" прогон\n
${Green} --help                   ${NC}     Prints this Help.\n
${Green} -v, --version            ${NC}     Prints software version and exit\n"
#  printf 'g     Print the GPL license notification.\n'
#  printf 'v     Verbose mode.\n'
  printf '\n'
  }

  myVersion() { printf 'Version 1.0.0\n'; }

  local IFS str
  local -a sarr
  for str in "$@"; do
    IFS=$'=' read -r -a sarr <<< "$str"
    case ${sarr[0]} in
      -v | --version )        myVersion; return 0 ;;
      --help )                myVersion; myHelp; return 0 ;;
    esac
  done

  # ----------------------- Read other script' parameters -----------------------
  local dryrun=false
  local paramName fldr srcDir destDir
  local -i k
  for str in "$@"; do
    IFS=$'=' read -r -a sarr <<< "$str"
    paramName=`echo ${sarr[0]} | sed 's/^[ \t]*\(.*\)/\1/'`
    k=${#sarr[@]}
    ((k > 1)) && paramValue=${sarr[1]} || paramValue=''

    case $paramName in
      -folder | --folder)                               fldr="$paramValue" ;;
      -temp-snapshots-folder | --temp-snapshots-folder) srcDir="$paramValue" ;;
      -snapshots-folder | --snapshots-folder)           destDir="$paramValue" ;;

      -dry-run | --dry-run )  dryrun=true ;;
    esac

  done

  # Verify argument values.
  bfl::is_blank "$fldr"    && { bfl::writelog_fail "${FUNCNAME[0]}: parameter --folder is not declared!";                return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_blank "$srcDir"  && { bfl::writelog_fail "${FUNCNAME[0]}: parameter --temp-snapshots-folder is not declared!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_blank "$destDir" && { bfl::writelog_fail "${FUNCNAME[0]}: parameter --snapshots-folder is not declared!";      return ${BFL_ErrCode_Not_verified_arg_values}; }
      [[ -d "$fldr" ]]     || { bfl::writelog_fail "${FUNCNAME[0]}: source folder $fldr doesn't exist!";                 return ${BFL_ErrCode_Not_verified_arg_values}; }
      [[ -d "$srcDir" ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: temp snapshot folder $srcDir doesn't exist!";        return ${BFL_ErrCode_Not_verified_arg_values}; }
      [[ -d "$destDir" ]]  || { bfl::writelog_fail "${FUNCNAME[0]}: backup snapshot folder $destDir doesn't exist!";     return ${BFL_ErrCode_Not_verified_arg_values}; }
# -------------------------
  bfl::is_root_available   || { bfl::writelog_fail "${FUNCNAME[0]}: failed to get sudo rights!"; return 1; }

  [[ -d "$srcDir/$fldr" ]]  || { [[ $BASH_INTERACTIVE == true ]] && install -v -d "$srcDir/$fldr"  || install -d "$srcDir/$fldr" ; }
  [[ -d "$destDir/$fldr" ]] || { [[ $BASH_INTERACTIVE == true ]] && install -v -d "$destDir/$fldr" || install -d "$destDir/$fldr" ; }

  local -i k
  k=`ls -p -d -A "$srcDir"/* | sed '/^$/d' | sed -n '/.*\/$/p' | wc -l`
  (( k > 0)) && lastDir=`ls -pdtA "$srcDir/$fldr"/* | sed '/^$/d' | sed -n '/.*\/$/p' | head -1 | sed 's/\(.*\)\/$/\1/'` && printf "Last snapshot: $lastDir\n"
  local str
  str=`date +"%Y-%m-%d_%H.%M"`
  # printf "btrfs subvolume snapshot -r $fldr $srcDir/$fldr/$str\n"  - excessive comments
  $dryrun || btrfs subvolume snapshot -r "$fldr" "$srcDir/$fldr/$str"

  # there s no previous backups
  if [[ $k -eq 0 ]]; then
    [[ $BASH_INTERACTIVE == true ]] && printf "\n${DarkGreen}Moving btrfs send/receive${NC} ${Green}$srcDir/$fldr/$str => $destDir/$fldr${NC}\n" > /dev/tty
    $dryrun || { btrfs send "$srcDir/$fldr/$str" | btrfs receive "$destDir/$fldr" ; } || { bfl::writelog_fail "${FUNCNAME[0]}: Failed btrfs send '$srcDir/$fldr/$str' | btrfs receive '$destDir/$fldr'"; return 1; }
  else
    [[ $BASH_INTERACTIVE == true ]] && printf "\n${DarkGreen}Making incremental snapshot${NC} ${Green}$lastDir <=> $srcDir/$fldr/$str${NC}\n${DarkGreen}Moving btrfs send/receive${NC} ${Green}$srcDir/$fldr/$str => $destDir/$fldr${NC}\n" > /dev/tty
    $dryrun || { btrfs send -p "$lastDir" "$srcDir/$fldr/$str" | btrfs receive "$destDir/$fldr" ; } || { bfl::writelog_fail "${FUNCNAME[0]}: Failed btrfs send -p '$lastDir' '$srcDir/$fldr/$str' | btrfs receive '$destDir/$fldr'"; return 1; }
    # printf "btrfs subvolume delete $lastDir\n" - excessive comments
    $dryrun || btrfs subvolume delete "$lastDir" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed btrfs subvolume delete '$lastDir'"; return 1; }
  fi

  return 0
  ) # !!!
