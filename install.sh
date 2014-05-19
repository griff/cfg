#!/bin/bash

debug=false;
version="0.1";
#fixing installation folder if user is root
if [ $(whoami) = "root" ];
  then
    home="/root";
  else
    home=$HOME;
fi
cfgname=".cfg";
bkpname="backup.cfg";
gitrepo="git@github.com:griff/cfg.git";
gitrepo_ro="git://github.com/griff/cfg.git";
gitrepo_archive="https://github.com/griff/cfg/archive/master.tar.gz"
ignored="install.sh|.git$|.gitmodule|.gitignore|README|bin|install|lib|libexec";

#----debug setup----
#home=$1
#gitrepo=$2;
#------------------

cfg_folder=$home/$cfgname;
backup_folder=$home/$bkpname;

md5prog() {
  if [ $(uname) = "Darwin" ]; then
    md5 -q $1
  fi
  if [ $(uname) = "Linux" ]; then
    md5sum $1 | awk {'print $1'}
  fi
}

update_submodules() {
  return;
  if [ $debug == true ];
    then
      cd $cfg_folder
      echo "|-> initializing submodules [fake]"
      echo "|-> updating submodules [fake]"
    else
      echo "|-> initializing submodules"
      cd $cfg_folder && git submodule -q init
      echo "|-> updating submodules"
      cd $cfg_folder && git submodule update
  fi
}

link_assets() {
  for asset in $assets ;
  do
    if [ ! -e $home/$asset ];
      then
        #asset does not exist, can just copy it
        echo "N [new] $home/$asset";
        if [ $debug = false ];
          then ln -s $cfg_folder/$asset $home/$asset;
          else echo ln -s $cfg_folder/$asset $home/$asset;
        fi
      else
        #asset is there already
        if [ -d $home/$asset ];
          then
            if [ -h $home/$asset ];
              then echo "Id[ignore dir] $home/$asset";
              else
                echo "Cd[conflict dir] $home/$asset";
                mv $home/$asset $backup_folder/$asset;
                ln -s $cfg_folder/$asset $home/$asset;
            fi
          else
            ha=$(md5prog $home/$asset);
            ca=$(md5prog $cfg_folder/$asset);
            if [ $ha = $ca ];
              #asset is exactly the same
              then
                if [ -h $home/$asset ];
                  #asset is exactly the same and as link, all good
                  then echo "I [ignore] $home/$asset";
                  else
                    #asset must be relinked
                    echo "L [re-link] $home/$asset";
                    if [ $debug = false ];
                      then
                        mv $home/$asset $backup_folder/$asset;
                        ln -s $cfg_folder/$asset $home/$asset;
                      else
                        echo mv $home/$asset $backup_folder/$asset;
                        echo ln -s $cfg_folder/$asset $home/$asset;
                    fi
                fi
              else
                #asset exist but is different, must back it up
                echo "C [conflict] $home/$asset";
                if [ $debug = false ];
                  then
                    mv $home/$asset $backup_folder/$asset;
                    ln -s $cfg_folder/$asset $home/$asset;
                  else
                    echo mv $home/$asset $backup_folder/$asset;
                    echo ln -s $cfg_folder/$asset $home/$asset;
                fi
            fi
        fi
    fi
  done
  for asset in $bad_assets; do
    echo "D [delete] $home/$asset";
    if [ $debug = false ]; then
      unlink $home/$asset
    else
      echo unlink $home/$asset
    fi
done
}

install_commands() {
  local uroot="$cfg_folder/install/$(uname)"
  for command in $commands; do
    if [ -z "$(command -v $command)" ]; then
      echo "N [new] $command"
      local path="$uroot/$command"
      if [ ! -f "$path" ]; then
        path="$cfg_folder/install/$command"
      fi
      source $path;
    else
      echo "I [ignore] $command"
    fi
  done
}

echo "|* cfg version" $version
echo "|* debug is" $debug
echo "|* home is" $home
echo "|* backup folder is" $backup_folder
echo "|* cfg folder is" $cfg_folder

if [ ! -e $backup_folder ];
  then mkdir -p $backup_folder;
fi

#clone config folder if not present, update if present
if [ ! -e $cfg_folder ];
  then 
    if [ -z $(command -v git) ]
      then
        #git is not available, juzt unpack the zip file
        echo "|* git not available downloading zip file..."
        curl -LsO "$gitrepo_archive"
        tar zxvf master.tar.gz
        mv cfg-master $home/.cfg
        rm master.tar.gz
    else
      #git is available, clone from repo
      echo "|-> git clone from repo $gitrepo"
      git clone --recursive $gitrepo $cfg_folder;
      if [ ! -e $cfg_folder ];
        then
          echo "!!! ssh key not installed on github for this box, cloning read only repo"
          git clone --recursive $gitrepo_ro $cfg_folder
          echo "|* changing remote origin to read/write repo: $gitrepo"
          cd $cfg_folder && git config remote.origin.url $gitrepo
          if [ -e $home/id_rsa.pub  ];
            then
              echo "|* please copy your public key below to github or you won't be able to commit";
              echo
              cat $home/.ssh/id_rsa.pub
            else
              echo "|* please generate your public/private key pair with the command:"
              echo
              echo "ssh-keygen"
              echo
              echo "|* and copy the public key to github"
          fi
        else
          update_submodules
      fi
    fi
  else
    echo "|-> cfg already cloned to $cfg_folder"
    echo "|-> pulling origin master"
    cd $cfg_folder && git pull origin master
    update_submodules
fi

assets=$(ls -A1 $cfg_folder | egrep -v $ignored | xargs);
bad_assets=$(find $home -maxdepth 1 -type l ! -exec test -e {} \; -exec readlink {} \; | egrep "^$cfg_folder" | xargs basename -a | xargs)
echo "|* tracking assets: [ $assets $bad_assets ] "
echo "|* linking assets in $home"
link_assets

commands=$(ls -A1 $cfg_folder/install | egrep -v Darwin | xargs);
if [ -d "$cfg_folder/install/$(uname)" ]; then
  commands="$commands $(ls -A1 $cfg_folder/install/$(uname) | xargs)"
fi
echo "|* checking commands: [ $commands ] "
echo "|* installing commands"
install_commands
