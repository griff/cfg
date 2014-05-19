# durdn/cfg related commands {{{
function dur {
  case $1 in
  list|li)
    curl --user $2:$3 https://api.bitbucket.org/1.0/user/repositories 2> /dev/null | grep "name" | sed -e 's/\"//g' | col 2 | sort | uniq | column
    ;;
  clone|cl)
    git clone git@bitbucket.org:durdn/$2.git
    ;;
  install|i)
    $HOME/.cfg/install.sh
    ;;
  reinstall|re)
    curl -Ls https://raw.github.com/griff/cfg/master/install.sh | bash
    ;;
  check|chk)
    if [ $(whoami) = "root" ];
      then
        home="/root";
      else
        home="$HOME";
    fi
    (
      cd $home/.cfg
      if git check -q; then
        branch_orig_hash="$(git show-ref -s --verify refs/heads/master 2> /dev/null)"
        if [ ! -f $home/.cfg-check ]; then
          echo ".cfg fetch"
          git fetch -q origin master
          touch $home/.cfg-check
        elif [ -n "$(find $home/.cfg-check -mmin +1440)" ]; then
          echo ".cfg fetch"
          git fetch -q origin master
          touch $home/.cfg-check
        fi
        ahead=$(git rev-list --right-only --boundary @{u}... | egrep "^-" | wc -l)
        behind=$(git rev-list --left-only --boundary @{u}... | egrep "^-" | wc -l)
        if [ $ahead -gt 0 -o $behind -gt 0 ]; then
          if [ $ahead -gt 0 -a $behind -eq 0 ]; then
            echo ".cfg ahead by $ahead. Pushing..."
            git push -q origin master
          elif [ $ahead -eq 0 -a $behind -gt 0 ]; then
            echo ".cfg behind by $behind. Merging..."
            if ! git merge --ff-only -q origin master 2> /dev/null; then
              echo ".cfg could not be fast-forwarded"
            fi
          else
            echo ".cfg could not be fast-forwarded"
          fi
        fi
        branch_hash="$(git show-ref -s --verify refs/heads/master 2> /dev/null)"
        if [ "$branch_orig_hash" != "$branch_hash" ]; then
          echo ".cfg has been updated. Reinstalling..."
          $home/.cfg/install.sh
        fi
      else
        echo ".cfg has uncommitted changes"
      fi
    )
    ;;
  move|mv)
    git remote add bitbucket git@bitbucket.org:durdn/$(basename $(pwd)).git
    git push --all bitbucket
    ;;
  trackall|tr)
    #track all remote branches of a project
    for remote in $(git branch -r | grep -v master ); do git checkout --track $remote ; done
    ;;
  fun|f)
    #list all custom bash functions defined
    typeset -F | col 3 | grep -v _ | xargs | fold -sw 60
    ;;
  def|d)
    #show definition of function $1
    typeset -f $2
    ;;
  help|h|*)
    echo "[dur]dn shell automation tools - (c) 2011 Nicola Paolucci nick@durdn.com"
    echo "commands available:"
    echo " [cr]eate, [li]st, [cl]one"
    echo " [i]nstall,[m]o[v]e, [re]install"
    echo " [f]fun lists all bash functions defined in .bashrc"
    echo " [def] <fun> lists definition of function defined in .bashrc"
    echo " [tr]ackall], [h]elp"
    ;;
  esac
}