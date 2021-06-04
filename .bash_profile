# # # # # # # # # #
#                 #
#   GORDON HART   #
#                 #
#   LAST EDITED   #
#   SEP 18 2015   #
#                 #
# # # # # # # # # #


# VARIABLES =====================================================================================

export BASH_SILENCE_DEPRECATION_WARNING=1
export PATH="/usr/local/bin:usr/local:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export EDITOR="/usr/bin/vim"

# ALIASES =======================================================================================

# list aliases
alias ls="ls -p" # put slash after directories
alias lsa="ls -plA"
alias ks="ls -p"
alias sl="ls -p"

alias rm="rm -i" # warn before deleting file

alias cd="changedir" # rename tmux pane on directory change

# naviagation aliases
alias ..="cd .." # back one
alias ...="cd ../.." # two
alias ....="cd ../../.." # three
alias .....="cd ../../../.." # four
alias ......="cd ../../../../.." # five
alias .......="cd ../../../../../.." # six
alias ........="cd ../../../../../../.." # seven
alias .........="cd ../../../../../../../.." # eight

alias git-tree="git log --oneline --color --graph --decorate"
# alias bashprof="printf \"> lime ~/.bash_profile\n\"; lime ~/.bash_profile"

# aliases to quickly change finder preferences to show or hide hidden files (. prefix)
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES; \
	killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO; \
	killall Finder /System/Library/CoreServices/Finder.app"

alias dns_flush="dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# FUNCTIONS =====================================================================================

changedir() { # wrapper to cd to set tmux pane title on change
  if [ -z "$1" ]; then builtin cd ~
  else builtin cd "$1"; fi # only try to name pane if the TMUX variable is set
  if [ -n "$TMUX" ]; then tmuxpanetitle "`pwd`"; fi
}

check() { # spell check tex files
	if [ -z "$1" ]; then
		echo; echo "Improper input."
		echo "Type \"check <FILENAME(S)>\""; echo
	else
		for arg in "$@"; do
			echo "> aspell --mode=tex --ignore=2 -c $arg" # ignore <= 2 character strings
			aspell --mode=tex --ignore=2 -c $arg
		done
		echo
	fi
}

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

pause() { # pause all processes of a name
  if [ -z "$1" ]; then echo "> pause process_name"
  else pgrep -i "$1" | xargs kill -STOP
  fi
}

resume() { # resume all paused processes of a given name
  if [ -z "$1" ]; then echo "> resume process_name"
  else pgrep -i "$1" | xargs kill -CONT
  fi
}

reTeX() { # compile and open LaTeX file
	if [ -z "$1" ]; then
		echo; echo "Improper input."
		echo "Type \"reTeX <new name>\""; echo
	else
		FILENAME="$1" # this allows the input to have an extension, or not
		BASENAME="${FILENAME%.*}" # get filename before extension (if exists)

		if [ "$1" = "-p" ]; then # also re-gnuplot
			FILENAME="$2" # this allows the input to have an extension, or not
			BASENAME="${FILENAME%.*}" # get filename before extension (if exists)
			echo "> gnuplot $BASENAME.gp"; echo
			gnuplot $BASENAME.gp
		fi

		echo "> pdflatex $BASENAME.tex"; echo
		pdflatex $BASENAME.tex
		echo; echo "> backup saved to ~/.LaTeX_history"
		cp $BASENAME.pdf ~/.LaTeX_history
		cp $BASENAME.tex ~/.LaTeX_history/TeX_files
		# echo "> open $BASENAME.pdf"; echo
		# open $BASENAME.pdf
	fi
}

rustrun() {
    if [ -n "$2" ] || [ -z "$1" ]; then
        echo "Usage: rustrun PROGRAM.rs"
        return 1
    fi
    rustc $1.rs || return 1
    ./$1
    rm -f $1
}


sizeof() {
	if [ -z "$1" ]; then echo "Improper input : >= one argument expected"
	else echo "> du -sh $@"; du -sh $@; fi
}

ssh() { # ssh wrapper to rename tmux pane to host
  if [ -n "$TMUX" ]; then
    PANENAME="" # initialize empty pane name
    for ARG in "$@"; do # append client being ssh'ed into to pane name
      PANENAME="$PANENAME`echo $ARG | grep "@"`"
    done
    tmuxpanetitle "$PANENAME"
  fi
  command ssh "$@" # use "command" to avoid nonterminating loop
  tmuxpanetitle "`pwd`" # reset pane name
}

trash() { # simple alias to move files to trash
	mv "$@" ~/.trash
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
      # while [ ${#OUT} -lt "$(( $MAX ))" ]; do
      # 	OUT="$OUT " # add spaces to make it the right length always
      # done
    fi
    echo "$OUT"
  fi
}

tmuxpanetitle() {
  RESP=$(truncate 60 "$@")
  printf "\033]2;$RESP\033\\"
} # set title of new pane if inside tmux environment
if [ ! -z "$TMUX" ]; then tmuxpanetitle "$PWD"; fi


# PROMPT ========================================================================================

# colors for prompt
# C_GRAY="\[\033[0;96m\]"
C_GRAY="\[\033[38;5;246m\]" # nice gray color, using term-256
# C_PINK="\[\033[0;95m\]"
C_PINK="\[\033[38;5;183m\]" # pale pinkish-purple
# C_WHITE="\[\033[0;97m\]"
C_WHITE="\[\033[38;5;255m\]" # eeeeee

setPrompt(){
  LEN=120
  OUT=$(truncate $LEN "`pwd`")
  # OUT="$(pwd)"
	# PS1="$C_GRAY`whoami`$C_WHITE : $C_PINK$OUT$C_WHITE : $C_GRAY[\A] $C_WHITE$ "
	PS1="$C_GRAY`whoami`$C_WHITE in $C_PINK$OUT $C_GRAY$ $C_WHITE"
  # PS1="$C_GRAY[$C_PINK> $C_WHITE"
}
export PROMPT_COMMAND=setPrompt
# END ===========================================================================================
