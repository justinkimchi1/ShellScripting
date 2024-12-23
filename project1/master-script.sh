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
while getopts ":bpsh" opt; do
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
