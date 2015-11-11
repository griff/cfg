function list-patch {
  git log --oneline --decorate --numstat -1 $1 | tail -n +2 | awk {'print $3'}
}

function f {
  find . -type f | grep -v .svn | grep -v .git | grep -i $1
}

function gr {
  find . -type f | grep -v .svn | grep -v .git | xargs grep -i $1 | grep -v Binary
}

# print only column x of output
function col {
  awk -v col=$1 '{print $col}'
}

# skip first x words in line
function skip {
    n=$(($1 + 1))
    cut -d' ' -f$n-
}


function xr {
  case $1 in
  1)
    xrandr -s 1680x1050
    ;;
  2)
    xrandr -s 1440x900
    ;;
  3)
    xrandr -s 1024x768
    ;;
  esac
}

# shows last modification dat for trunk and $1 branch
function glm {
  echo master $(git fl master $2 | grep -m1 Date:)
  echo $1 $(git fl $1 $2 | grep -m1 Date:)
}

# git search for extension $1 and occurrence of string $2
function gfe {
  git f \.$1 | xargs grep -i $2 | less
}

#open with vim from a list of files, nth one (vim file number x)
function vfn {
  last_command=$(history 2 | head -1 | cut -d" " -f2- | cut -c 2-);
  $EDITOR $($last_command | head -$1 | tail -1)
}

#autocomplete list of possible files and ask which one to open
function gv {
  search_count=1
  search_command="git f"
  search_result=$($search_command $1)
  editor=$EDITOR

  for f in $search_result; do echo $search_count. $f;search_count=$(($search_count+1)); done

  arr=($search_result)
  case "${#arr[@]}" in
    0)
       ;;
    1) nohup $editor ${search_result} 2>/dev/null &
       ;;
    *) echo "enter file number:"
       read fn
       nohup $editor ${arr[fn-1]} 2>/dev/null &
       ;;
  esac
}

#open a scratch file in Dropbox
function sc {
  $EDITOR ~/Dropbox/$(openssl rand -base64 10 | tr -dc 'a-zA-Z').txt
}
function scratch {
  $EDITOR ~/Dropbox/$(openssl rand -base64 10 | tr -dc 'a-zA-Z').txt
}

case "$(uname)" in
  Darwin)
    function alert {
      terminal-notifier -sender com.apple.Terminal -activate com.apple.Terminal -message "$([ $? = 0 ] && echo terminal || echo error)" -title "$(history|tail -n1|sed -E -e 's/^[ ]*[0-9]+[ ]*//;s/[;&|][ ]*alert$//')"
    }
    ;;
  Linux)
    function alert {
      echo notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
    }
    ;;
esac

if [ -n "$(command -v noidle)" ]; then
  if [ -n "$(command -v alert)" ]; then
    function mvn {
      command noidle mvn "$@"; alert
    }
  else
    function mvn {
      command noidle mvn "$@"
    }
  fi
elif [ -n "$(command -v alert)" ]; then
  function mvn {
    command mvn "$@"; alert
  }
fi
function mvn-debug-test {
  local run_test=$1
  shift
  mvn -Dtest=$run_test -Dmaven.surefire.debug $@  
}
