#!/usr/bin/env bash

# description: Create symbolic links for configuration files in a remote repository to help set up the environment

# sources:
# https://www.gnu.org/software/bash/manual/bash.html [1]
# https://www.tutorialspoint.com/unix/unix-special-variables.htm [2]
# https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-clone [3]
# https://www.baeldung.com/linux/bash-check-script-arguments#:~:text=Check%20Whether%20No%20Arguments%20Are,may%20miss%20the%20arguments%20completely.&text=The%20%24%23%20variable%20gives%20us,its%20two%20operands%20is%20equal.[4]
# https://www.digitalocean.com/community/tutorials/read-command-line-arguments-in-shell-scripts [5]

# "$#" is a special character that stores the number of arguments [5]
# if the script is not provided a user for the argument, then we tell the user that they need to give us their user
if [[ "$#" -ne 1 ]]; then
  echo "You must provide your user with the script!"
  exit 1
fi

# set username of the user who uses this file so we can use their username in the paths when we create symlinks
user=$1

# use mkdir with -p to create the directory if it doesn't exist. -p stands for parents and it creates a directory and any necessary parent directories that do not exist. This helps us create nested directories in one command [1]
mkdir -p /home/$user/bin
mkdir -p /home/$user/.config/kak
mkdir -p /home/$user/.config/tmux

# we turn the repository link and config_repo into variables so they are easier to work with
# $user will put in the username that was inputed into this script
repo_link="https://gitlab.com/cit2420/2420-as2-starting-files.git"
config_repo="/home/$user/config_repo"

# the -d checks if the config_repo is a file and is a directory and if it is, then we tell them that the repo exists already [1]
if [[ -d "$config_repo" ]]; then 
  echo "$config_repo directory already exists"
else
  # if the directory doesnt exist, we git clone the repository into the new directory, config_repo [3]
  git clone "$repo_link" "$config_repo"
  # $? "The exit status of the last command executed." [2]
  # check if the cloning is successful by seeing if the exit code is equal to (-eq) 0. If the exit status of a command is equal to 0 it means that the command was executed successfully. [1]
  if [[ $? -eq 0 ]]; then
    echo "Cloning successful!"
  else
    echo "Error while cloning"
  fi
fi

# helper function, create_symlink. Checks if the symlink already exists, and if it doesn't, creates it for us
create_symlink() {
  path_to_folder=$1
  symlink_location=$2

  # the -e checks if the file exists at the specified path of symlink_location, and if a file exists, we skip it since we do not want to override it [1]
  if [[ -e "$2" ]]; then
    echo "Symbolic link $2 already exists"
  else
    # if the symlink doesnt exist, we take in the two paths from the arguments and we create the symlink
    # ln is the command used to create links, and we specify a softlink with -s
    ln -s "$path_to_folder" "$symlink_location"
    echo "Created symlink for $path_to_folder"
  fi

}

# create all the symlinks using our symlink function
create_symlink /home/$user/config_repo/bin/sayhi /home/$user/bin/sayhi
create_symlink /home/$user/config_repo/bin/install-fonts /home/$user/bin/install-fonts
create_symlink /home/$user/config_repo/config/kak/kakrc /home/$user/.config/kak/kakrc
create_symlink /home/$user/config_repo/config/tmux/tmux.conf /home/$user/.config/tmux/tmux.conf
create_symlink /home/$user/config_repo/home/bashrc /home/$user/.bashrc
