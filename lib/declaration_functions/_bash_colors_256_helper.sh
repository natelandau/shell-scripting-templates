#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------ https://github.com/ariver/bash_functions ------------------
# @file
# Defines and calls function: bfl::bash_colors_256_helper().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Builds binary file in /tmp directory with color array.
#
#
# @example:
#   bfl::bash_colors_256_helper
#------------------------------------------------------------------------------
bfl::bash_colors_256_helper() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  local -r OUT="${TMPDIR:-/tmp}/${FUNCNAME[0]}.out"
  #rm -vf "$OUT"
  if [[ -f "$OUT" ]]; then  # compiled file already exists!
      cut -f2- "$OUT" | less -R -p "^:\$"
      return 0
  fi

  # ---------------------------------------------------------------------------------------------------------------
  # http://en.wikipedia.org/wiki/YIQ
  # http://24ways.org/2010/calculating-color-contrast/
  declare {TC_SET,TC_SETQ,TC_DIM,ENT,TMP,END,NLN,BG_HC,BG_YIQ,FG_HC,FG_YIQ,YIQ,HC,HUE,J1,J2,J4}=
  local -i el # originally CC
  local -i I J K
  export {TC_RST,TC_ABS,TC_AFS,TC_C2H}
  printf -v NLN "\n"
  TC_RST="$( tput sgr0 )"
  TC_DIM="$( tput setaf 0 )"
  TC_ABS=(); TC_AFS=(); TC_C2H=()
  TMP=

  touch "$OUT"
  printf "%s:::: %3s " "${FUNCNAME[0]}" "..." 1>&2

  for el in {0..255}; do
      printf "\b\b\b\b%3d " "$el" 1>&2
      # I=.
      HC=0
      if [[ $el -le 15 ]]; then
          I="$el"
          if [[ $el -eq 7 ]]; then
              HC="$(( 0xc0c0c0 ))"
          else
              J1="$(( 0x800000 ))"
              J2="$(( 0x008000 ))"
              J4="$(( 0x000080 ))"

              if [[ $el -eq 8 ]]; then
                  ((I=el-1))
              elif [[ $el -gt 8 ]]; then
                  J1="$(( 0xff0000 ))"
                  J2="$(( 0x00ff00 ))"
                  J4="$(( 0x0000ff ))"
                  ((I=el-8))
              fi

              [[ "$(( I & 1 ))" -eq 0 ]] || HC="$(( HC + J1 ))"
              [[ "$(( I & 2 ))" -eq 0 ]] || HC="$(( HC + J2 ))"
              [[ "$(( I & 4 ))" -eq 0 ]] || HC="$(( HC + J4 ))"
          fi
      elif [[ $el -le 231 ]]; then
          ((I=el-16))
          for J in {0..2}; do
              K=$(( ( I / ( 6 ** J ) ) % 6 ))
              I=$((I=I-K))
              [[ $K -gt 0 ]] && K=$(( K * 0x28 + 0x37 )) || K=0
              HC="$(( HC + ( K * ( 0x0100 ** J ) ) ))"
          done
      else
          ((I=el-232))
          HC="$(( I * 0x0a0a0a + 0x080808 ))"
      fi

      YIQ="$(( ( ( ( HC >> 16 & 0x0000ff ) ) * 299 + ( ( HC >> 8 ) & 0x0000ff ) * 587 + ( HC & 0x0000ff ) * 114 ) / 1000 ))"
      TC_C2H[$el]="$HC:$YIQ"
      TC_ABS[$el]="$( tput setab $el )"
      TC_AFS[$el]="$( tput setaf $el )"

  done
  printf "\b\n" 1>&2

  printf "%s:f_: %3s " "${FUNCNAME[0]}" "..." 1>&2

  local z # temporary
  z="$( sed -n "s/^f_:\([0-9]*\).*/\1/p" "$OUT" | tail -1 )"
  local -i FG=${z:--1}
  while [[ $FG -lt 255 ]]; do
      : $((FG++))
      printf "\b\b\b\b%3d " "$FG" 1>&2
      [[ $FG -gt 0 ]] || { printf ":\t:\n" > "$OUT"; }

      ENT="${TC_C2H[$FG]}"
      HC="${ENT%%:*}"
      ENT="${ENT#*:}"
      YIQ="${ENT%%:*}"
      END="$NLN"
      TC_SET="${TC_AFS[$FG]}"
      printf -v TC_SETQ %q "$TC_SET"
      TC_SETQ="${TC_SETQ#$\'\\E[}"
      TC_SETQ="${TC_SETQ%\'}"
      if [[ $FG -le 15 ]]; then
          [[ "$(( ( FG + 1 ) % 8 ))" -eq 0 ]] || END=" "
          printf -v TMP "%s%s%4s %-8s %s%s" "${TMP:-}" "$TC_SET" "$FG" "$TC_SETQ" "$TC_RST" "$END"
      else
          [[ "$(( ( FG + 1 - 16 ) % 6 ))" -eq 0 ]] || END=" "
          printf -v TMP "%s%s%4s [%3d, %06x] %-9s %s%s" "${TMP:-}" "$TC_SET" "$FG" "$YIQ" "$HC" "$TC_SETQ" "$TC_RST" "$END"
      fi

      [[ "$END" != "$NLN" ]] || { printf "%s\t%s" "f_:$FG" "$TMP" >> "$OUT"; TMP=; }

  done
  printf "\b\n" 1>&2

  printf "%s:_b: %3s " "${FUNCNAME[0]}" "..." 1>&2
  z="$( sed -n "s/^_b:\([0-9]*\).*/\1/p" "$OUT" | tail -1 )"
  local -i BG=${z:--1}
  while [[ $BG -lt 255 ]]; do
      : $((BG++))
      printf "\b\b\b\b%3d " "$BG" 1>&2
      [[ $BG -gt 0 ]] || { printf ":\t:\n" >> "$OUT"; }

      ENT="${TC_C2H[$BG]}"
      HC="${ENT%%:*}"
      ENT="${ENT#*:}"
      YIQ="${ENT%%:*}"
      [[ "$YIQ" -ge 128 ]] && FG=8 || FG=15
      END="$NLN"
      TC_SET="${TC_ABS[$BG]}${TC_AFS[$FG]}"
      printf -v TC_SETQ %q "$TC_SET"
      TC_SETQ="${TC_SETQ#$\'\\E[}"
      TC_SETQ="${TC_SETQ%\\E*}"
      if [[ $BG -le 15 ]]; then
          [[ "$(( ( BG + 1 ) % 8 ))" -eq 0 ]] || END=" "
          printf -v TMP "%s%s%4s %-8s %s%s" "${TMP:-}" "$TC_SET" "$BG" "$TC_SETQ" "$TC_RST" "$END"
      else
          [[ "$(( ( BG + 1 - 16 ) % 6 ))" -eq 0 ]] || END=" "
          printf -v TMP "%s%s%4s [%3d, %06x] %-9s %s%s" "${TMP:-}" "$TC_SET" "$BG" "$YIQ" "$HC" "$TC_SETQ" "$TC_RST" "$END"
      fi

      [[ "$END" != "$NLN" ]] || { printf "%s\t%s" "_b:$BG" "$TMP" >> "$OUT"; TMP=; }

  done
  printf "\b\n" 1>&2

  printf "%s:fb: %3s " "${FUNCNAME[0]}" "..." 1>&2
  z="$( sed -n "s/^fb:\([0-9]*\).*/\1/p" "$OUT" | tail -1 )"
  BG=${z:-16}
  : $((BG--))
  while [[ $BG -lt 255 ]]; do
      : $((BG++))

      printf "\b\b\b\b%3d " "$BG" 1>&2

      ENT="${TC_C2H[$BG]}"
      BG_HC="${ENT%%:*}"
      ENT="${ENT#*:}"
      BG_YIQ="${ENT%%:*}"

      printf "%3s " "..." 1>&2
      z="$( sed -n "s/^fb:$BG:\([0-9]*\).*/\1/p" "$OUT" | tail -1 )"
      FG=${z:-15}
      while [[ $FG -lt 255 ]]; do
          : $((FG++))
          printf "\b\b\b\b%3d " "$FG" 1>&2
          [[ $FG -gt 16 ]] || { printf ":\t:\n" >> "$OUT"; }

          ENT="${TC_C2H[$FG]}"
          FG_HC="${ENT%%:*}"
          ENT="${ENT#*:}"
          FG_YIQ="${ENT%%:*}"
          YIQ="$(( FG_YIQ - BG_YIQ ))"
          YIQ="${YIQ#-}"
          HUE=(
              $(( ( FG_HC >> 16 & 0xff ) - ( BG_HC >> 16 & 0xff ) ))
              $(( ( FG_HC >>  8 & 0xff ) - ( BG_HC >>  8 & 0xff ) ))
              $(( ( FG_HC       & 0xff ) - ( BG_HC       & 0xff ) ))
          )
          HUE="$(( ${HUE[0]#-} + ${HUE[1]#-} + ${HUE[2]#-} ))"
          END="${NLN}"
          [[ "$(( ( FG + 1 - 16 ) % 6 ))" -eq 0 ]] || END=" "

          TC_SET="${TC_ABS[$BG]}${TC_AFS[$FG]}"
          [ "$YIQ" -gt 125 -a "$HUE" -gt 500 ] && {
              printf -v TMP "%s%s%4s%4s  { %3d / %3d } %s%s" "${TMP:-}" "${TC_SET}" "$FG" "$BG" "$YIQ" "$HUE" "$TC_RST" "$END"
          } || {
              printf -v TMP "%s%s%4s%4s %s { %3d / %3d } %s%s" "${TMP:-}" "$TC_DIM" "$FG" "$BG" "$TC_SET" "$YIQ" "$HUE" "$TC_RST" "$END"
          }

          [[ "$END" != "$NLN" ]] || { printf "%s\t%s" "fb:$BG:$FG" "$TMP" >> "$OUT"; TMP=; }
      done
      printf "\b\b\b\b" 1>&2

  done
  printf "\b\n" 1>&2

  cut -f2- "$OUT" | less -R -p "^:\$"
  return 0
  }
