#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash-function-library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::get_pkg_depends_list().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets required packages list for Debian package.
#
# @param string $pkg
#   Debian package.
#
# @return string $list
#   Required packeges list for $pkg.
#
# @example
#   bfl::get_pkg_depends_list "libapr1"
#------------------------------------------------------------------------------
bfl::get_pkg_depends_list() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.
#     case $paramName in
#         -print | --print ) listScript=true ;;
#         *) pkg="$1"
#     esac

  # first call apt-cache depends ...
  local str=$(apt-cache depends "$1")
  local dependsArr=()
  if [[ -z "$str" ]]; then
      [[ $BASH_INTERACTIVE == true ]] && printf "${Red}Ничего не найдено${bfl_aes_reset}\n" > /dev/tty
      echo '' && return 0
  fi

#  dependsArr=(`echo "$str" | sed -n '/Depends:/p' | sed 's/^[ ]*.*epends: //' | sed '/^<.*>$/d'`)
  dependsArr=(`echo "$str" | sed -n '/Зависит:/p' | sed 's/^[ ]*.*ависит: //' | sed '/^<.*>$/d'`)
  #IFS=$'\n' read -r -a dependsArr <<< "$str"

  if [[ $BASH_INTERACTIVE == true ]]; then
      for str in ${dependsArr[@]}; do
          printf "${Green}$str${bfl_aes_reset}\n" > /dev/tty
      done
  fi

  #--------------------------------------------------------------------------------
  local i=0; local k=${#dependsArr[@]}
  local dep=1; local depthArr=() # массив глубины зависимостей
  while (( $i < $k )); do
      depthArr+=( $dep )
      ((i++))
  done

  local temparr=(); local b=true
  i=0; local ii=0; local t=0
  local tel el
  while (( $i < $k )); do
      t=${dependsArr[$i]}; dep=${depthArr[$i]}
      [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$t : ---${bfl_aes_reset}\n" > /dev/tty
      str=$(apt-cache depends "$t")
      ! [[ -n "$str" ]] && ((i++)) && continue

#    temparr=(`echo "$str" | sed -n '/Depends:/p' | sed 's/^[ ]*.*epends: //' | sed '/^<.*>$/d'`)
      temparr=(`echo "$str" | sed -n '/Зависит:/p' | sed 's/^[ ]*.*ависит: //' | sed '/^<.*>$/d'`)

      for tel in ${temparr[@]}; do
          b=true; ii=0
          for el in ${dependsArr[@]}; do
              [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$el - $tel${bfl_aes_reset}\n" > /dev/tty
              if [[ "$tel" = "$el" ]]; then
                  [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$tel : ${depthArr[ii]}{NC}\n" > /dev/tty
                  if [[ ${depthArr[ii]} -le $((dep+1)) ]]; then
                      depthArr[$ii]=$((dep+1))
                      [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$tel : ${depthArr[ii]}${bfl_aes_reset}\n" > /dev/tty
                  fi
                  b=false; break
              fi
              ((ii++))
          done
          if $b; then
              dependsArr+=( $tel )
              depthArr+=( $((dep+1)) )
              [[ $BASH_INTERACTIVE == true ]] && printf "${Green}added $tel : ${depthArr[ii]}${bfl_aes_reset}\n" > /dev/tty
          fi
        done
        ((i++)); k=${#dependsArr[@]}
    done

# теперь необходимо сделать синхронный bubble sort
  local max=${#depthArr[@]}; k=$max
  while ((max > 0)); do
      i=0
      while ((i < max)); do
          if [ $i != $((k-1)) ]; then #array will not be out of bound "$(($k-1))"
              if [ ${depthArr[$i]} \< ${depthArr[ $((i+1)) ]} ]; then
                  t=${depthArr[$i]}
                  depthArr[$i]=${depthArr[ $((i+1)) ]}
                  depthArr[ $((i+1)) ]=$t

                  tel=${dependsArr[$i]}
                  dependsArr[$i]=${dependsArr[ $((i+1)) ]}
                  dependsArr[ $((i+1)) ]=$tel
              fi
          fi
          ((i++))
      done
      ((max--))
  done

  #dependsArr+=("$1"); depthArr+=(0)

  if [[ $BASH_INTERACTIVE == true ]]; then # Вывод итога
      printf "${Green}"${#dependsArr[*]}"${bfl_aes_reset}\n" > /dev/tty
      i=0
      while (( $i < $k )); do
          printf "${Green}${dependsArr[i]} - ${depthArr[i]}${bfl_aes_reset}\n" > /dev/tty
          ((i++))
      done
  fi

  i=0; str=''
  for t in ${dependsArr[@]}; do
      [[ $i -eq $k ]] && str="$str$t" || str="$str$t "
      ((i++))
  done

  echo "$str"
  return 0
  }
