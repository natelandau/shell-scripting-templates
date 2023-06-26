#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to directories manipulation
#
#
#
# @file
# Defines function: bfl::forward_links().
#------------------------------------------------------------------------------
# Dependencies
#------------------------------------------------------------------------------
#source "${BASH_FUNCTION_LIBRARY%/*}"/lib/declarations/_declare_terminal_colors.sh
#------------------------------------------------------------------------------
# @function
#   Gets the files in a directory (recursively or not).
#   If python3 given in parameter $mask, this folder and files in it will be excluded from linking,
#
# @param String $path1
#   A directory path to get files.
#
# @param String $path2
#   A directory path to put file links.
#
# @param Array $mask_list (optional)
#   List of masks for direct linking not files, but whole folders.
#
# @example
#   bfl::forward_links  /tools/binutils-2.40 /usr/local
#------------------------------------------------------------------------------
bfl::forward_links() {
  bfl::verify_arg_count "$#" 2 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2..999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # eval $ask_sudo
  bfl::is_root_available || { bfl::writelog_fail "${FUNCNAME[0]}: failed${NC} - cannot get sudo rights!"; return 1; }

  local dryrun=false

  local el srt strtolink ptrn st3 param
  for param in "$@"; do
      case "$param" in
          -dry-run | --dry-run) dryrun=true ;;
      #    (*) set -- "$@" "$arg" ;;
      esac
  done

  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: source is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  #$1 - source, $2 - destination, $3 ... - unic folder names
  #/usr/local/cmake-3.23.2  /usr/copy   "cmake-3.23"
  local fromParentFolder="${1%/*}"    # $(dirname "$1")
  local -i i=${#fromParentFolder}
  local patternFPF st2
  patternFPF=$(echo "$fromParentFolder" | sed 's|/|\\\/|g;s/\./\\\./g') #  patternFromParentFolder
  st2=$(echo "$1")
  local -i fromLength=${#st2}
  if [[ ${st2: -1} = '/' ]]; then
      st2=${st2:0:$fromLength-1}
      fromLength=${#st2}
  fi
  local toFldrName=${st2: $i-$fromLength+1}

  # просматриваем папку, получаем список всех папок
  local STR
  STR=$(ls -R "$1" | sed -n '/:$/p')
  [[ -n "$STR" ]] && STR=$(echo "$STR" | sed '1d' | sed 's/:$//')

  #i=${#toFldrName}
  #if [[ ${toFldrName: -1} = '/' ]]; then toFldrName=${toFldrName:0:$i-1}; fi
  #echo "$toFldrName"
  #echo "$fromParentFolder"; echo "$STR"

  # Сразу отсекаем из анализа папки, которые были указаны как уникальные
  local -i j
  $dryrun && j=4 || j=3
  i=0; local b=true
  local arr_link=()
  for param in "$@"; do # поддержка любого количества указанных папок
      ((i=i+1))
      ((i<j)) && continue # Читаем с третьего параметра
      param=`echo "$param" | sed 's/\./\\\./g'`          # заменить точку перед применением шаблона
      STR=`echo "$STR" | sed -n "/^$patternFPF\/.*\/$param\/.*/!p"`  # исключаем файлы в интересующей папке
      strtolink=`echo "$STR" | sed -n "/^$patternFPF\/.*$param$/p"`  # пути к папкам, на которые можно в целом можно сделать ссылки
      if [[ $BASH_INTERACTIVE == true ]]; then
          $b && { printf "${Blue}direct links to folder:${NC}\n" > /dev/tty; b=false; }
          printf "${Green}$strtolink${NC}\n" > /dev/tty
      fi
      arr_link+=($strtolink) #&& [[ $BASH_INTERACTIVE == true ]] && printf "arr_link+=$strtolink\n" > /dev/tty
      STR=`echo "$STR" | sed -n "/^$patternFPF\/.*$param$/!p"`       # исключаем пути к искомым папкам
  done

  local -i k=${#arr_link[@]}
  if ((k>0)); then
      [[ $BASH_INTERACTIVE == true ]] && printf "\n${Blue}//----------------------------------- folder links -----------------------------------${NC}\n" > /dev/tty
      for el in ${arr_link[@]}; do
          i=${#el}; st2="$2/"${el: $fromLength-$i+1}
          $dryrun || [[ $st2 =~ '/usr/local/lib/python3.'* ]] || {
              [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$el => $st2${NC}\n" > /dev/tty
              [[ -f "$st2" ]] && rm -fv "$st2"
              if [[ -L "$st2" ]]; then
                  if [[ $BASH_INTERACTIVE == true ]]; then
                      if [[ -d "$st2" ]]; then
                          printf "Ссылка ${Yellow}$st2 на директорию ${Yellow}"$(ls -la "$st2" | sed 's/^.* -> \(.*\)/\1/')"${NC} уже установлена, ${Purple}удаление ...${NC}\n" > /dev/tty
                      else
                          printf "Removing broken symlink ${Yellow}$st2${NC} ...\n" > /dev/tty
                      fi
                      rm -f "$st2"
                  else
                      rm -fv "$st2"
                  fi
              fi

              srt="${st2%/*}"   # $(dirname "$st2")
              [[ -d "$srt" ]] || install -v -d "$srt"

              if [[ -d "$st2" ]]; then
                  [[ $BASH_INTERACTIVE == true ]] && printf "${Purple}Problems: directory $st2 exists, but it is not a symlink!${NC}.\n" > /dev/tty
                  ln -sfv "$el"/* "$st2"/
              else
                  ln -sfv "$el" "$st2"   # или cp -sf ???
              fi

              [[ -e "$st2" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: failed '$st2'."; return 1; }
          }
      done
  fi

  # -----------------------------------------------------------
  local exludeArr=() # исключаем /etc /var /lib64
  for el in 'etc' 'var' 'lib64'; do
      [[ -d "$1/$el" ]] || continue

      exludeArr+=("$el")
      srt=`echo "$1" | sed 's|\/|\\\/|g' | sed 's/\./\\\./g'`
      STR=`echo "$STR" | sed -n "/^$srt\/$el$/!p" | sed -n "/^$srt\/$el\/.*$/!p"`
  done

  [[ $BASH_INTERACTIVE == true ]] && printf "\n${Blue}// --------------------- отвлекаемся - анализ на ненужные симлинки -------------------${NC}\n" > /dev/tty
  local arrInnerLinkFrom=()
  local arrInnerLinkTo=()
  local dirArr=($STR)
  for el in ${dirArr[@]}; do
      srt=`ls -l "$el" | grep '\->' | sed 's/[^:]*:...\(.*\)->.*/\1/'`
      ! [[ -n $srt ]] && continue

      arrInnerLinkFrom+=($srt)
      st2=`ls -l "$el" | grep '\->' | sed 's/[^:]*:....*->\(.*\)/\1/'`

      i=${#arrInnerLinkTo[@]}; arrInnerLinkTo+=($st2); k=${#arrInnerLinkTo[@]}
      while ((i < k)); do
          st2=${arrInnerLinkTo[$i]}
          [[ "$st2" = /* ]] && arrInnerLinkTo[$i]=$(abspath "$st2") || arrInnerLinkTo[$i]=$(abspath "$el/$st2")
          st2=${arrInnerLinkFrom[$i]}
          [[ "$st2" = "$el"/* ]] && arrInnerLinkFrom[$i]=$(abspath "$st2") || arrInnerLinkFrom[$i]=$(abspath "$el/$st2")
          [[ $BASH_INTERACTIVE == true ]] && printf "${Green}"${arrInnerLinkFrom[$i]}"${NC} => ${Green}"${arrInnerLinkTo[$i]}"${NC}\n" > /dev/tty
          ((i=i+1))
      done

  done

  k=${#arrInnerLinkFrom[@]}
  if [[ $BASH_INTERACTIVE == true ]]; then
      ((k>0)) && printf "${Yellow}// Символьные ссылки в источнике${NC}\n" > /dev/tty
      for el in ${arrInnerLinkFrom[@]}; do
          printf "${Yellow}?test rm $el${NC}\n" > /dev/tty
          #rm "$el"
      done
  fi

  b=false # Продолжаем
  local arr=($STR)
  local fromFileArr=()
  local fromDirArr=()
  local tarr
  for el in ${arr[@]}; do
      b=false
      st2=`ls -LA "$el"/`; tarr=($st2)   # /*
      for tEl in ${tarr[@]}; do
          if [[ -f "$el"/"$tEl" ]]; then
              $b || { fromDirArr+=("$el"); b=true; }  #&& [[ $BASH_INTERACTIVE == true ]] && printf "fromDirArr+=$el\n" > /dev/tty
              fromFileArr+=("$el"/"$tEl")
          fi
      done
      unset tarr
  done

  [[ -d "$2" ]] || {
      [[ $BASH_INTERACTIVE == true ]] && printf "Make directory ${Purple}$2${NC}\n" > /dev/tty
      $dryrun || install -d "$2"
  }

  # -------------------------------- надо заменить $1 на $2 !!! --------------------------------
  for el in ${fromDirArr[@]}; do
      i=${#el}; st2="$2"/${el: $fromLength-$i+1}
      if ! [[ -d "$st2" ]]; then
          [[ $BASH_INTERACTIVE == true ]] && printf "Make directory ${Purple}$st2${NC}\n" > /dev/tty
          $dryrun || install -d "$st2"
      fi

      $dryrun || [[ -d "$st2" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: Неудачно"; return 1; }
  done

  # вывести список файлов в данном каталоге и пробросить символьные ссылки
  k=${#fromFileArr[@]}
  if ((k>0)); then
      [[ $BASH_INTERACTIVE == true ]] && printf "\n${Blue}//------------------------------------ file links ------------------------------------${NC}\n" > /dev/tty
      for el in ${fromFileArr[@]}; do
          b=false
          if [[ -L "$el" ]]; then
              for tEl in ${arrInnerLinkFrom[@]}; do
                  if [[ $tEl == $el ]]; then
                      [[ $BASH_INTERACTIVE == true ]] && printf "${DarkGreen}Ссылка ${NC}$el${DarkGreen} перенаправлена, обработка в отдельном блоке${NC}\n" > /dev/tty
                      b=true; break;
                  fi
              done # fromFileArr я не обрезал
          fi
          $b && continue

          i=${#el}
          ((i=fromLength-i+1))
          st2="$2"/${el: $i}

          [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$el${NC} => ${Green}$st2${NC}\n" > /dev/tty

          $dryrun && continue

          if [[ -f "$st2" ]]; then
              rm -f "$st2"
          elif [[ -L "$st2" ]]; then
              [[ $BASH_INTERACTIVE == true ]] && printf "Removing broken link ${Yellow}$st2${NC}\n" > /dev/tty
              rm -f "$st2"
          fi

          if [[ "$el" != '/usr/local/lib/x86_64-linux-gnu/perl/5.30.0' ]]; then # исключения
              if [[ -d "$st2" ]]; then
                  [[ $BASH_INTERACTIVE == true ]] && printf "${Purple}Проблемы: директория '$st2' существует, и это не ссылка!${NC}\n" > /dev/tty
                  ln -sfv "$el"/* "$st2"/
              else
                  ln -sf "$el" "$st2"   # или cp -sf ???
              fi
          else
              [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}$el - НЕ РЕШИЛ ЧТО ДЕЛАТЬ!!!${NC}\n" > /dev/tty
          fi
          $dryrun || [[ -f "$st2" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: failed${NC}\nln -sf '$el' '$st2'."; return 1; }
      done
  fi

  # вместо лишних ссылок в источнике пробрасываем ссылки без промежуточных
  local str=''
  k=${#arrInnerLinkTo[@]}
  if ((k>0)); then
      [[ $BASH_INTERACTIVE == true ]] && printf "\n${Blue}//----------------------------------- direct links -----------------------------------${NC}\n" > /dev/tty
      srt=`echo "$2" | sed 's|/*$||'`
      ptrn=`echo "$1" | sed 's|/|\/|g' | sed 's|\.|\\\.|g'`
      i=0
      while (( $i < $k )); do
          str=${arrInnerLinkFrom[$i]}
          str=`echo "$str" | sed "s|^.*$ptrn\/*\(.*\)|\1|"`
          st2=${arrInnerLinkTo[$i]}
          bfl::is_blank "$st2" && [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}для $srt/$str путь не заполнен!${NC}\n" > /dev/tty

          [[ $BASH_INTERACTIVE == true ]] && printf "${Green}$st2${NC} => ${Green}$srt/$str${NC}\n" > /dev/tty
          if ! $dryrun && [[ -n "$st2" ]]; then
              [[ -f "$srt/$str" ]] && rm "$srt/$str"
              st3=`dirname "$srt/$str"`
              if ! [[ -d "$st3" ]]; then
                  [[ $BASH_INTERACTIVE == true ]] && printf "Make directory ${Purple}$st3${NC}\n" > /dev/tty
                  install -d "$st3"
              fi
              if [[ "$st2" != '/usr/local/lib/x86_64-linux-gnu/perl/5.30.0' ]]; then # исключения
                  if [[ -d "$srt/$str" ]] && [[ ! -L "$srt/$str" ]] ; then
                      [[ $BASH_INTERACTIVE == true ]] && printf "${Purple}Проблемы: директория $srt/$str существует, и это не ссылка!${NC}\n" > /dev/tty
                      ln -sfv "$st2"/* "$srt/$str"/
                  else
                      ln -sf "$st2" "$srt/$str"   # или cp -sf ???
                  fi
              else
                  [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}$el - НЕ РЕШИЛ ЧТО ДЕЛАТЬ!!!${NC}\n" > /dev/tty
              fi
              $dryrun || [[ -e "$srt/$str" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: failed '$srt/$str'.${NC}"; return 1; }
          fi
          ((i=i+1))
      done
  fi

  unset arr
  # неужели придется повторить всю логику?   /etc  /var  /lib64
  for exFldr in ${exludeArr[@]}; do
      [[ $BASH_INTERACTIVE == true ]] && printf "\n${Blue}// ------------------------------------ $exFldr ------------------------------------${NC}\n" > /dev/tty
      st2=`echo "$1" | sed 's|\/|\\\/|g'`
      st2=`ls -R "$1" | sed -n "/^$st2\/$exFldr[:\/].*/p" | sed 's/^\(.*\):$/\1/'`
      arr=($st2); fromFileArr=(); fromDirArr=()
      [[ $BASH_INTERACTIVE == true ]] && printf "clear fromDirArr\n" > /dev/tty
      for el in ${arr[@]}; do
          i=`getFilesCount "$el"`
          if (($i>0)); then
              st2=`ls "$el"/`  # *
              b=false; tarr=($st2)
              for tEl in ${tarr[@]}; do
                  if [[ -f "$el"/"$tEl" ]]; then
                      $b || { fromDirArr+=("$el"); b=true; } #&& [[ $BASH_INTERACTIVE == true ]] && printf "fromDirArr+=$el\n" > /dev/tty
                      fromFileArr+=("$el"/"$tEl")
                  fi
              done
              unset tarr
          else # имеем пустую папку, причем не в списке исключений
              fromDirArr+=("$el")
          fi
      done
      unset arr

      #надо заменить $1 на $2 !!!
      for el in ${fromDirArr[@]}; do
          i=${#el}; st2='/'${el: $fromLength-$i+1}
          if ! [[ -d "$st2" ]]; then
              [[ $BASH_INTERACTIVE == true ]] && printf "Make directory ${Purple}$st2${NC}\n" > /dev/tty
              ! $dryrun && install -d "$st2" # SUDO
          fi
          $dryrun || [[ -d "$st2" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: failed.${NC}"; return 1; }
      done

      #//----------------------------------------------------------------------------------------------------------
      # вывести список файлов в данном каталоге и пробросить символьные ссылки
      for el in ${fromFileArr[@]}; do
          i=${#el}; st2='/'${el: $fromLength-$i+1}
          [[ $BASH_INTERACTIVE == true ]] && printf "${Green}ln -sf $el $st2${NC}\n" > /dev/tty
          if [[ -f "$st2" ]]; then
              [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}$st2 exists, script will not overwrite it!${NC}\n" > /dev/tty
          elif ! $dryrun; then
              if [[ "$st2" != '/usr/local/lib/x86_64-linux-gnu/perl/5.30.0' ]]; then # исключения
                  if [[ -d "$st2" ]]; then
                      [[ $BASH_INTERACTIVE == true ]] && printf "${Purple}Проблемы: директория $st2 существует, и это не ссылка!${NC}\n" > /dev/tty
                      ln -sfv "$el"/* "$st2"/   # SUDO
                  else
                      ln -sf "$el" "$st2"   # или cp -sf ???   SUDO
                  fi
              else
                  [[ $BASH_INTERACTIVE == true ]] && printf "${Yellow}$el - НЕ РЕШИЛ ЧТО ДЕЛАТЬ!!!${NC}\n" > /dev/tty
              fi
              [[ -e "$st2" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: failed."; return 1; }
          fi
      done

  done

  return 0
  }
