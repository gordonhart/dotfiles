# # # # # # # # # #
#                 #
#   GORDON HART   #
#                 #
#   LAST EDITED   #
#   SEP 18 2015   #
#                 #
# # # # # # # # # #

export BASH_SILENCE_DEPRECATION_WARNING=1

# PATHS =========================================================================================

export PATH="/usr/local/bin:usr/local:$PATH"

### DIFFERENT PYTHON DISTRIBUTIONS
# export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
# export PATH="/usr/local/Cellar/python/2.7.9/Frameworks/Python.framework/Versions/2.7/bin:$PATH"
# export PATH="/Library/Frameworks/Python.framework/Versions/3.4/bin:${PATH}"
export PATH="/users/gordonhart/.anaconda/bin:$PATH" # added by Anaconda 2.3.0 installer

export PATH="$HOME/.cargo/bin:$PATH"

export NODE_PATH="/usr/local/lib/node_modules"

export EDITOR="/usr/bin/vim"

### PYTHONPATH
export PYTHONPATH="${HOME}/Projects/caffe_2/caffe/python:$PYTHONPATH"
# export DYLD_FALLBACK_LIBRARY_PATH="${HOME}/.anaconda/include:$DYLD_FALLBACK_LIBRARY_PATH"

# lynx setup
export WWW_HOME="https://www.google.com/ncr"
export LYNX_LSS="$HOME/.lynx.lss"
alias lynx="lynx -accept_all_cookies"

# alias ssh-vm-ub="ssh -Y -p 3022 syntech@127.0.0.1"
alias ssh-vm-deb="ssh -Y -p 4022 syntech@127.0.0.1"

# gpg-connect-agent updatestartuptty /bye >/dev/null
# export SSH_AUTH_SOCK=/Users/gordonhart/.gnupg/S.gpg-agent.ssh

setup-docker() {
    eval $(docker-machine env vbox-docker-machine)
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

syn-clone() {
    if [ -z "$1" ]; then
        echo "Usage: syn-clone REPO [REPO [REPO [...]]]"
        return 1
    fi
    for REPO in "$@"; do
        git clone https://github.com/SyntechCorporation/$REPO.git;
    done
}

syn-premerge-check() {
    if [ -n "$2" ]; then
        echo "Usage: syn-premerge-check [BASE_BRANCH]"
        return 1
    fi
    BASE_BRANCH="$1"
    if [ -z "$1" ]; then
        BASE_BRANCH="origin/develop"
        echo "No branch specified, using $BASE_BRANCH"
    fi
    git diff --no-commit-id --name-only -r "$BASE_BRANCH" |  xargs pre-commit run --files
}

# ALIASES =======================================================================================

# list aliases
alias ls="ls -p" # put slash after directories
alias lsa="ls -plA"
alias ks="ls -p"
alias sl="ls -p"

alias rm="rm -i" # warn before deleting file

alias cd="changedir" # rename tmux pane on directory change
# alias cat="catnonbinary"

# naviagation aliases
# alias .="ls -p" # ls alias
alias ..="cd .." # back one
alias ...="cd ../.." # two
alias ....="cd ../../.." # three
# alias ~="cd" # go home

alias work="cd $HOME/Work/Synapse && ls"
alias school="cd '${SCHOOLPATH}' && ls"


alias git-tree="git log --oneline --color --graph --decorate"
# alias bashprof="printf \"> lime ~/.bash_profile\n\"; lime ~/.bash_profile"

# aliases to quickly change finder preferences to show or hide hidden files (. prefix)
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES; \
	killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO; \
	killall Finder /System/Library/CoreServices/Finder.app"

alias kts="kick_the_speakers"

alias dns_flush="dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# get the battery percentage as a raw number
# alias battery_pct="BATTERY_PCT=\"$(pmset -g batt | cut -d' ' -f3 | tail -n1 | sed 's/[[:space:];%]*//g')\""

# better racket (scheme) repl by default
alias racket="racket -il xrepl"


# FUNCTIONS =====================================================================================

c() { # compile and run c programs with a single command
	if [ -z "$1" ]; then # no new script name
		echo; echo "Improper input."
		echo "Type \"c <FILENAME (no extension)>\""; echo
	else
		echo "> gcc -o $1 $1.c"
		gcc -o $1 $1.c &> compile_output.txt # write temp file compile.txt

		if [ -z "$(cat compile_output.txt)" ]; then # if there is no output, run it
			echo "> ./$1"; echo
			./$1
		else
			cat compile_output.txt
		fi

		rm -rf compile_output.txt
	fi
}

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

comp() { # switch to assignment for COMP courses
	if [ -z "$1" ]; then echo "> comp XYZ <assignment number>"
	else course comp "${@:1}"; fi
}

course() { # generic command for the 'comp' function above, where any course can be called
	if [ -z "$2" ]; then # no course number
		echo "> course ABCD XYZ <assignment number>"
	else
		CNAME="$(echo "$1$2" | tr '[:lower:]' '[:upper:]')"
		# search for course name in academics folder, quit once first result is returned
		# COURSEPATH="$(find ~/Documents/Academics/McGill -name "$CNAME" -print -quit)"
		# get rid of McGill on coursepath to allow for abroad directory to be searched
    COURSEPATH="$(find ~/Academics -name "$CNAME" -print -quit)"
		if [ -z "$COURSEPATH" ]; then
			echo "You haven't taken any course named $CNAME..."
		else
			if [ -z "$3" ]; then
        cd "$COURSEPATH"
				pwd; ls
			elif [ "$3" == "-d" ]; then # allow -d tag to swtich directly to folder
        cd "$COURSEPATH/$4"
				pwd; ls # ex: comp 424 -d Project/src
			elif [ -d "$COURSEPATH/Assignments/$3" ]; then
        cd "$COURSEPATH/Assignments/$3"
				pwd; ls
			else
				echo "No assignment '$3' found for $CNAME."; pwd; ls
			fi
		fi
	fi
}

endall() { # kill all commands named $1
	if [ -z "$1" ]; then echo "> endall <proc identifier>"
	else pgrep "$1" | xargs kill; fi
}

kick_the_speakers() { # restart pi that runs the speakers
	echo "> ssh -t speakers@10.0.1.20 sudo reboot"
	ssh -t speakers@10.0.1.20 sudo reboot
}

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

val() { # alias to run Valgrind memory checker for C programs
	if [ -z "$1" ]; then
		echo "Improper input : one argument expected"
	else
		echo "> valgrind --tool=memcheck --leak-check=full --dsymutil=yes ./$1"
		valgrind --tool=memcheck --leak-check=full --dsymutil=yes ./$1
	fi
}


# PROMPT ========================================================================================

# colors for prompt
# C_GRAY="\[\033[0;96m\]"
C_GRAY="\[\033[38;5;246m\]" # nice gray color, using term-256
# C_PINK="\[\033[0;95m\]"
C_PINK="\[\033[38;5;183m\]" # pale pinkish-purple
# C_WHITE="\[\033[0;97m\]"
C_WHITE="\[\033[38;5;255m\]" # eeeeee

setPrompt(){
  LEN=60
  OUT=$(truncate $LEN "`pwd`")
  # OUT="$(pwd)"
	# PS1="$C_GRAY`whoami`$C_WHITE : $C_PINK$OUT$C_WHITE : $C_GRAY[\A] $C_WHITE$ "
	PS1="$C_GRAY`whoami`$C_WHITE in $C_PINK$OUT $C_GRAY$ $C_WHITE"
  # PS1="$C_GRAY[$C_PINK> $C_WHITE"
}
export PROMPT_COMMAND=setPrompt
# END ===========================================================================================
