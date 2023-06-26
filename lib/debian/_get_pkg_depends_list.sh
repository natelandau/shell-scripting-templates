#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to the Debian
#
# @author  Alexei Kharchev
#
# @file
# Defines function: bfl::get_pkg_depends_list().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets required packages list for Debian package.
#
# @param String $pkg
#   Debian package.
#
# @return String $list
#   Required packages list for $pkg.
#
# @example
#   bfl::get_pkg_depends_list "libapr1"
#------------------------------------------------------------------------------
bfl::get_pkg_depends_list() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
#     case $paramName in
#         -print | --print ) listScript=true ;;
#         *) pkg="$1"
#     esac

  # first call apt-cache depends ...
  local str=$(apt-cache depends "$1")
  bfl::is_blank "$str" && { bfl::writelog_fail "${FUNCNAME[0]}: Failed apt-cache depends '$1'"; return 1; }

  local dependsArr=()
#  dependsArr=(`echo "$str" | sed -n '/Depends:/p' | sed 's/^[ ]*.*epends: //' | sed '/^<.*>$/d'`)
  dependsArr=(`echo "$str" | sed -n '/Зависит:/p' | sed 's/^[ ]*.*ависит: //' | sed '/^<.*>$/d'`)
  #IFS=$'\n' read -r -a dependsArr <<< "$str"

  if [[ $BASH_INTERACTIVE == true ]]; then
      for str in ${dependsArr[@]}; do
          printf "${Green}$str${NC}\n" > /dev/tty
      done
  fi

  #--------------------------------------------------------------------------------
  local -i i
  local -i k=${#dependsArr[@]}
  local dep=1
  local -a depthArr=()  # массив глубины зависимостей
  for ((i = 0; i < k; i++)); do
      depthArr+=( $dep )
  done

  local temparr=(); local b=true
  local -i ii=0
  local -i t=0
  local tel el
  for ((i = 0; i < k; i++)); do
      t=${dependsArr[$i]}; dep=${depthArr[$i]}
      [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$t : ---${NC}\n" > /dev/tty
      str=$(apt-cache depends "$t")
      [[ -z "$str" ]] && continue

#    temparr=(`echo "$str" | sed -n '/Depends:/p' | sed 's/^[ ]*.*epends: //' | sed '/^<.*>$/d'`)
      temparr=(`echo "$str" | sed -n '/Зависит:/p' | sed 's/^[ ]*.*ависит: //' | sed '/^<.*>$/d'`)

      for tel in ${temparr[@]}; do
          b=true; ii=0
          for el in ${dependsArr[@]}; do
              [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$el - $tel${NC}\n" > /dev/tty
              if [[ "$tel" = "$el" ]]; then
                  [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$tel : ${depthArr[ii]}{NC}\n" > /dev/tty
                  if [[ ${depthArr[ii]} -le $((dep+1)) ]]; then
                      depthArr[$ii]=$((dep+1))
                      [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$tel : ${depthArr[ii]}${NC}\n" > /dev/tty
                  fi
                  b=false; break
              fi
              ((ii++))
          done
          if $b; then
              dependsArr+=( $tel )
              depthArr+=( $((dep+1)) )
              [[ $BASH_INTERACTIVE == true ]] && printf "${Green}added $tel : ${depthArr[ii]}${NC}\n" > /dev/tty
          fi
        done
        k=${#dependsArr[@]}
    done

# теперь необходимо сделать синхронный bubble sort
  local s=$(bfl::array_synchro_bubble_sort "${dependsArr[*]}" "${depthArr[*]}")
  bfl::is_blank "$s" && { bfl::writelog_fail "${FUNCNAME[0]}: Failed synchro bubble sort"; return 1; }

  #dependsArr+=("$1"); depthArr+=(0)

  if [[ $BASH_INTERACTIVE == true ]]; then # Вывод итога
      # обратно в массив
      str=$(echo "$s" | sed 's/^\([^;]*\);.*$/\1/')
      dependsArr=( $str )
      str=$(echo "$s" | sed 's/^[^;]*;//')
      depthArr=( $str )

      printf "${Green}"${#dependsArr[*]}"${NC}\n" > /dev/tty
      for ((i = 0; i < k; i++)); do
          printf "${Green}${dependsArr[i]} - ${depthArr[i]}${NC}\n" > /dev/tty
      done

      echo "${dependsArr[*]}"
   else # Ничего вычленять и преобразовывать не нужно
      echo "$s" | sed 's/^\([^;]*\);.*$/\1/'
  fi

  return 0
  }
