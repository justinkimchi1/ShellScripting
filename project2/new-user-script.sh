#!/bin/bash

# description: this script allows users to create new users with a specified shell, a home directory with the contents of /etc/skel, and add them to additional groups

# sources:
# https://dev.to/rpalo/bash-brackets-quick-reference-4eh6 [1]
# https://www.freecodecamp.org/news/how-to-manage-users-in-linux/ [2]
# https://www.gnu.org/software/bash/manual/bash.html [3]
# https://learning.oreilly.com/videos/bash-shell-scripting/9780137689064/9780137689064-BSS2_04_10_01/ (O'Reilly 10.1 working with options) [4]
# https://www.gnu.org/software/coreutils/manual/html_node/The-cut-command.html [5]
# https://www.gnu.org/software/grep/manual/grep.html [6]
# https://learning.oreilly.com/library/view/linux-for-system/9781803247946/B18575_07.xhtml#_idParaDest-105 [7]

# default shell
shell="/bin/bash"

# make the user run this script with root privileges by checking if the current user id is equal to 0, if not then we tell the user that they need to run with root privileges [1] [2] 
# we exit with the exit code 1 which indicates an error
if [[ $(id -u) -ne 0 ]]; then
  echo "This script must be run with root privileges"
  exit 1
fi

# usage function that displays how to use the script
helpmessage() {
echo "Usage: $0 -u <username> -s <shell> -g <groups> -c <comments>"
echo "-u <username> you must provide a username for the new user"
echo "-s <shell> the default shell is /bin/bash"
echo "-g <groups> "
echo "-c <comments> add any comments about the user"
echo "-h will display the help messsage"
}

# getopts function that takes in our arguments from user [4]
while getopts ":u:s:g:c:h" opt; do
  case $opt in
    u) username="$OPTARG"
      ;;
    s) shell="$OPTARG"
      ;;
    g) groups="$OPTARG"
      ;;
    c) comments="$OPTARG"
      ;;
    h) helpmessage
      ;;
    :) exit 1
      ;;
    ?) exit 1
      ;;
  esac
done

# check if they supplied a username
if [[ -z "$username" ]]; then
  echo "You must enter a username"
  helpmessage
fi

# loop through the user id until we find a unique uid. Source [4]
# we set the default user id to 1000 because all the id's below 1000 are reserved for different type of users [7]
# we use a while to loop through all the user ids until we find a unique one
# cut is a command that extracts specific fields from each line and we select the : as the delimiter with -d [5] [3]
# we use -f3 to select the third field in the /etc/passwd, which is the UID line [5]
# so basically the cut -d : -f3 /etc/passwd combined, will give us the output of all the UIDs in the system
# we then pipe the output of the UIDs to grep which searches for instances of our user_id [6]
# -q option supresses any output from grep and -x ensures that grep matches the whole instance and not partial match [6]
user_id=1000
while cut -d : -f3 /etc/passwd | grep -qx $user_id; do 
    user_id=$((user_id + 1))
done


# assign GID based on UID (they should be the same)
group_id="$user_id"


# create home directory path
home_dir="/home/$username"


# adding user to /etc/passwd (where all users are located)
echo "$username:x:$user_id:$group_id:$comments:$home_dir:$shell" >> /etc/passwd


# adding user to the /etc/shadow
echo "$username:x::::::" >> /etc/shadow


# create their home directory and copy /etc/skel into it
mkdir -p "$home_dir"
cp -r /etc/skel/. "$home_dir"

# add a password to user
passwd $username
