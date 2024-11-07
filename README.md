# Shell Scripting Assignment
 
This assignment consists of two parts - **Project 1** and **Project 2**

**Project 1 - System Setup Scripts**
**Project 1 - System Setup Scripts**
- Develop several small scripts that automate the installation of software packages and create symbolic links to configuration systems stored in a remote git Repository.

**Project 2 - User Creation Scripts**
- Automate the process of creating new users on the system. This would include setting a password, establishing the user's groups, creating a home directory and specifying their shell.

## Table of Contents

- [Project 1 - System Setup Scripts](#project-1-system-setup-scripts)
    - [Scripts Overview](#scripts-overview)
    - [Usage Instructions](#usage-instructions)
- [Project 2 - User Creation Scripts](#project-2-user-creation-scripts)
    - [Script Overview](#script-ov)
    - [Usage Instructions](#usage-intructions)
- [Sources](#sources)

## Project 1 - System Setup Scripts
Project 1 deals with creating configuration scripts that help with the system setup of a new system. Configuration scripts are important as they allow us to streamline the setup process. 

### Scripts Overview
In this project, we will be creating three scripts:
- `package-installer.sh` - Install a list of packages that is required for the configuration setup
- `symlink-script.sh` - Create symbolic links for the configuration files in the repository to help set up the environment
- `master-script.sh` - Coordinates the setup by calling the two scripts

## Usage Instructions
`package-installer.sh`:

1. To run the `package-installer.sh` file, you will need a `package-file.txt` with the following contents:

```
kakuone
tmux
```

> Note: you can add more packages, but these two are mandatory to run the scripts in this assignment

2. After you have the `package-file.txt` file, you can import `package-installer.sh`:

```
#!/usr/bin/env bash

# description: installs a list of packages that is required for the configuration setup

# source:
# https://www.freecodecamp.org/news/how-to-manage-users-in-linux/ [1]
# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#List_of_installed_packages [2]
# https://www.gnu.org/software/bash/manual/bash.html [3]
# https://dev.to/rpalo/bash-brackets-quick-reference-4eh6 [4]
# https://ss64.com/bash/syntax-file-operators.html [5]

# we use the dollar sign parentheses to get the current user running the script. If we just used id, then it would go through the whole list of user id's [4]
# -ne means not equal to, so -ne 0 is saying if the user id is not equal to 0 (which is the root users id) then we do
# next step [1][3] 
# if user id is not 0, then we tell the user that they need higher privleges to run the script and we exit with the status code 1 which indicates an error [3]
if [[ $(id -u) -ne 0 ]]; then
  echo "You have to be root user or use sudo to run this script"
  exit 1
fi

# let the user know that we are starting the installing process
echo "Installing Packages..."

# turn our list into a variable so it is easier to work with
package_list="package-file.txt"

# check if the package list exists with -f [5]
if [[ -f "$package_list" ]]; then
  
  # installs packages from a saved list of packages while not reinstalling previously installed packages [2]
  # pacman is the command used to install packages
  # -S option stands for sync and tells pacman to install packages from remote repositories
  # --needed tells pacman to install packages that aren't already installed. It will skip packages that are installed
  # - this makes pacman expect to take in a list of package names.
  # < "$package_list" uses input redirection to redirect the contents of package_list into pacman -S --needed - command
  pacman -S --needed --noconfirm - < "$package_list"

  # if the pacman exit code is equal to 0, then we tell the users that packages have been installed successfully
  if [[ $? -eq 0 ]]; then
    echo "Packages have been installed successfully!"
  else
    echo "There has been an error while installing packages"
  fi
else
  echo "The "$package_list" file could not be found"
fi
```
3. To run the `package-installer.sh` file, you **MUST** have root privileges or you can run it with `sudo`:

```
sudo ./package-installer.sh
```
Once you get a message saying **Packages have been installed successfully**, you have successfully ran the `package-installer.sh` script!

---
`symlink-script.sh`:

1. Import the script into a directory:

```
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

# use mkdir with -p to create the directory if it doesn't exist. -p stands for parents and it creates a directory and any necessary parent directories that do not exist. This helps us create nested directories in one command
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
```

2. To run the script, you must add your user to the end of the script:
```
./symlink-script.sh <user>
```
> **Note**: you can find which user you are by running this command in your termnial:
```
whoami
```
Once you get a multiple message saying **Created symlink for < Path >**, then you have successfully created symbolic links to the configuration files!

---
`master-script.sh`:
1. To run the master script, you must have the `package-installer.sh` script, the `symlink-script.sh` script and the `package-file.txt` file in the same directory as your `master-script.sh`:

  - Directory/
    - `master-script.sh`
    - `package-installer.sh`
    - `package-file.txt`
    - `symlink-script.sh`

2. After you have all the files in the right place, you can run the master script:

`master-script`:
```
#!/usr/bin/env bash

# description: coordinates the setup of the new system by calling the package installer and symbolic link creation scripts

# get opts. Make it take in 5 options, run package install, run symlink script, run both, show usage, or give user a help message

# sources: 
# https://learning.oreilly.com/videos/bash-shell-scripting/9780137689064/9780137689064-BSS2_04_10_01/ (O'Reilly 10.1 working with options) [1]
# https://www.gnu.org/software/bash/manual/bash.html [2]
# https://www.ibm.com/docs/en/zos/2.4.0?topic=descriptions-getopts-parse-utility-options [3]
# https://www.baeldung.com/linux/identify-user-called-by-sudo [4]

# $SUDO_USER is an environmental variable that is used to store the name of the user who used sudo command. We store the name of the user in the user variable for easy access [4]
user=$SUDO_USER

# usage function that displays the usage of the script to the user. We exit with exit code 1 
usage() {
  echo "usage: master-script [-b both scripts] [-p package installer] [-s symbolic link creator] [-h help]"
  exit 1
}

# help message function that displays help message of each option and what they do
helpmessage() {
  echo "Master-script is a script that allows you to install packages and access configuration files in a remote repository by creating symbolic links to them"
  echo " -b will run both the package installer and the symbolic link creator script. Must be run with root privileges"
  echo " -p will run the package installer script. Must be run with root privileges"
  echo " -s will run the symbolic link creator script"
  echo " -h displays this help message"
}

# we use getopts to get options of either b, p, s, h. If we get those options, we specify in the code block below what each option will do. [1]
while getopts "bpsh" opt; do
  # case is used to take in a specific number of cases, in this case bpsh and *
  case $opt in
    # runs both scripts 
    b) ./package-installer.sh && ./symlink-script.sh $user ;;
    # runs package installer script
    p) ./package-installer.sh ;;
    # runs symbolic link creator script
    s) ./symlink-script.sh $user ;;
    # displays the help message function
    h) helpmessage ;;
    # displays the usage function
    *) echo "Invalid option $OPTARG"
    usage ;;
  esac
done

# if no options were supplied we use the usage function
# $OPTIND is a shell variable that stores the arguments, therefore if it is equal to 1, that means no arguments were provided [3] [2]
if [[ $OPTIND -eq 1 ]]; then
  usage
fi
```

To run the script:
```
sudo ./master-script.sh < option >
```
The options:
- -b: runs both the `package-installer.sh` and `symlink-script.sh` scripts
- -p: runs the `package-installer.sh` script
- -s: runs the `symlink-script.sh` script
- -h: runs the help message function

Example:
```
sudo ./master-script.sh -b # this will run both scripts
```
Now you know how to use the master script!

## Project 2 - User Creation Scripts