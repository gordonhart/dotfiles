# PATHS =========================================================================================

export EDITOR="/usr/bin/vim"

# ALIASES =======================================================================================

# list aliases
alias ls="ls -p" # put slash after directories
alias lsa="ls -plA"
alias ks="ls -p"
alias sl="ls -p"

alias rm="rm -i" # warn before deleting file

# naviagation aliases
alias ..="cd .." # back one
alias ...="cd ../.." # two
alias ....="cd ../../.." # three

# FUNCTIONS =====================================================================================

cdl(){ cd "$@"; ls; } # alias to both change directory and list files
cdla(){ cd "$@"; lsa; }

mkcd() { # function to make directory and change to directory
	if [ -z "$1" ]; then
        echo "> mkcd <new directory name>"
	else
        mkdir -p "$1"
        cd "$1"
	fi
}

# kind of a monster
truncate() { # <truncate len dir> modifies the path to fit in the given size
  if [ ! -z "$2" ]; then
    MAX="$1"
    DIR="$2" # `pwd`
    DIR=$(echo "$2" | sed "s!$HOME!~!g") # with shortened "home" dir
    # echo "$DIR"

    IFS='/' read -ra FOLDERS <<< "$DIR" # split pwd by '/' into array FOLDERS
    OUT="${FOLDERS[${#FOLDERS[@]} - 1]}" # set to last element in FOLDERS array

    unset FOLDERS[${#FOLDERS[@]}-1] # pop out last element in FOLDERS

    # this loop will format the current directory for display on the command line
    if [ "${#OUT}" -gt "$(( $MAX - 4 ))" ]; then # if top directory is too long, cut it
      SHORT="$(( ${#OUT} - $(( $MAX - 5 )) ))"
      OUT="//..$(echo $OUT | cut -c$SHORT-${#OUT})" # "..$DIRECTORY"
    else
      if [ "${#DIR}" -lt "$MAX" ]; then # if the total length of pwd is less than max
        OUT="$DIR" # set the prompt to just be the pwd
      else
        while [ "${#FOLDERS[@]}" -gt 0 ]; do # while we still have folders
          if [ "${#OUT}" -lt "$(( $MAX - 3 ))" ]; then # if there's still space
            NEW="${FOLDERS[${#FOLDERS[@]} - 1]}" # set NEW to last element in FOLDERS

            # if we don't have enough space for the full word
            if [ "$(( ${#OUT} + ${#NEW} + 2*${#FOLDERS[@]} ))" -gt "$(( $MAX + 1 ))" ]; then
              NEW="${NEW:0:1}" # set NEW to first letter of last element
            fi

            unset FOLDERS[${#FOLDERS[@]}-1] # pop out last element in FOLDERS
            OUT="$NEW/$OUT" # add NEW to OUT

          elif [ "${FOLDERS[${#FOLDERS[@]} - 1]}" == "~" ]; then # if only one folder left is root, place ~ at front
            OUT="~/$OUT"
            unset FOLDERS[${#FOLDERS[@]}-1] # pop out last element in FOLDERS
            break

          else # not enough space for all folder, just put '/' at beginning
            OUT="/$OUT" # this will be turned into '//' after this loop
            break
          fi
        done
        if [ "${OUT:0:1}" != "~" ]; then
          OUT="/$OUT" # add leading slash only if the root isn't shortformed to ~
        fi
      fi
    fi
    echo "$OUT"
  fi
}

# PROMPT ========================================================================================

# colors for prompt
C_GRAY="\[\033[38;5;246m\]" # nice gray color, using term-256
C_ORANGE="\[\033[38;5;214m\]" # orange
C_WHITE="\[\033[38;5;255m\]" # eeeeee

setPrompt(){
  LEN=60
  OUT=$(truncate $LEN "`pwd`")
  SEP="$(if [[ $EUID -ne 0 ]]; then echo '$'; else echo '#'; fi)"
  PS1="$C_GRAY`whoami`$C_WHITE in $C_ORANGE$OUT $C_GRAY$SEP $C_WHITE"
}
export PROMPT_COMMAND=setPrompt

# END ===========================================================================================
