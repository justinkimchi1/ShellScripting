#!/usr/bin/env bash

# description: this script allows users to create new users with a specified shell, a home directory with the contents of /etc/skel, and add them to additional groups

# sources:
# https://dev.to/rpalo/bash-brackets-quick-reference-4eh6 [1]
# https://www.freecodecamp.org/news/how-to-manage-users-in-linux/ [2]
# https://www.gnu.org/software/bash/manual/bash.html [3]
# https://learning.oreilly.com/videos/bash-shell-scripting/9780137689064/9780137689064-BSS2_04_10_01/ (O'Reilly 10.1 working with options) [4]
# https://www.gnu.org/software/coreutils/manual/html_node/The-cut-command.html [5]
# https://www.gnu.org/software/grep/manual/grep.html [6]
# https://learning.oreilly.com/library/view/linux-for-system/9781803247946/B18575_07.xhtml#_idParaDest-105 [7]
# https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html [8]
# https://www.cyberciti.biz/faq/linux-append-text-to-end-of-file/ [9]
# https://learning.oreilly.com/library/view/linux-for-system/9781803247946/B18575_07.xhtml [10]
# https://www.gnu.org/software/sed/manual/sed.html [11]

# default shell
shell="/bin/bash"

# make the user run this script with root privileges by checking if the current user id is equal to 0, if not then we tell the user that they need to run with root privileges [1][2] 
# we exit with the exit code 1 which indicates an error
if [[ $(id -u) -ne 0 ]]; then
  echo "This script must be run with root privileges"
  exit 1
fi

# usage function that displays how to use the script
helpmessage() {
echo "Usage: $0 -u <username> -s <shell> -g <"group1 group2 group3...."> -c <"comments">"
echo "-u <username> you must provide a username for the new user"
echo "-s <shell> the default shell is /bin/bash"
echo "-g <groups> will add the user to additional groups"
echo "-c <comments> add any comments about the user"
echo "-h will display the help messsage"
}

# getopts function that takes in our arguments from user [4]
while getopts ":u:s:g:c:h" opt; do
  case $opt in
    # sets the name of the new user
    u) username="$OPTARG"
      ;;
    # sets the shell for the new user
    s) shell="$OPTARG"
      ;;
    # name of groups the user is added to
    g) groups="$OPTARG"
      ;;
    # any additional information of the new user
    c) comments="$OPTARG"
      ;;
    # help message function
    h) helpmessage
        exit 0
      ;;
    # exits if no argument is provided
    :) exit 1
      ;;
    # exits script if they type an option that is not part of the options 
    ?) exit 1
      ;;
  esac
done

# check if they supplied a username [8]
if [[ -z "$username" ]]; then
  # tell user that they need to enter a username, show them the help message and we exit with exit code 1 which indicates an error
  echo "You must enter a username"
  helpmessage
  exit 1
fi

# loop through the user id until we find a unique uid. Source [4]
# we set the default user id to 1000 because all the id's below 1000 are reserved for different type of users [7]
# we use a while to loop through all the user ids until we find a unique one
# cut is a command that extracts specific fields from each line and we select the : as the delimiter with -d [5][3]
# we use -f3 to select the third field in the /etc/passwd, which is the UID line [5]
# so basically the cut -d : -f3 /etc/passwd combined, will give us the output of all the UIDs in the system
# we then pipe the output of the UIDs to grep which searches for instances of our user_id [6]
# -q option supresses any output from grep and -x ensures that grep matches the whole instance and not partial match [6]
user_id=1000
while cut -d : -f3 /etc/passwd | grep -qx $user_id; do 
    user_id=$((user_id + 1))
done


# assign GID based on UID (they should be the same)
# if by chance, another group is occupying the same group id, we use the same logic as above and find a unique group id in the /etc/group by incrementing by 1 
group_id="$user_id"
while cut -d : -f3 /etc/group | grep -qx $group_id; do
    group_id=$((group_id + 1))
done

# we check if the user gives us an input for comments with -z which is true if the length of the string is 0 [8]
# if no input for comments, we set the default to "regular user"
if [[ -z "$comments" ]]; then
    comments="Regular User"
fi

# create home directory path
home_dir="/home/$username"

# creating the primary group of the user by appending the string with >> to /etc/group (where all groups are located) [9][10]
echo "$username:x:$group_id:" >> /etc/group

# adding user to /etc/passwd (where all users are located) [9][10]
echo "$username:x:$user_id:$group_id:$comments:$home_dir:$shell" >> /etc/passwd


# adding user to the /etc/shadow (where the encrypted passwords are) [9][10]
echo "$username::::::::" >> /etc/shadow


# create their home directory and copy /etc/skel into it
mkdir -p "$home_dir"
cp -r /etc/skel/. "$home_dir"

# give permissions 
chown -R "$user_id:$group_id" "$home_dir"
chmod 700 "$home_dir"

# checks if there are groups with -n. -n returns true if the length of the string is not zero [8]
if [[ -n "$groups" ]]; then

    # we loop through the groups with a for loop 
    for group in $groups; do
    
        # checks if the name of the group exists in the /etc/group. grep -q suppresses the outputs and returns an exit code of 0 or 1.
        # "^$group:" is a regular expression pattern. We use ^ to signifies the start of the line and $group: matches the exact group name followed by a colon
        # /etc/group is the groups file that we are searching
        if grep -q "^$group:" /etc/group; then
            
            # if the group exists, we use sed to append it to the /etc/group 
            # sed -i allows us to directly /etc/group [11]
            # /^$group:/ part finds lines that begin with the group name [11]
            # s/$/,$username/ will append ,$username to the end of the line that /^$group:/ finds [11]
            sed -i "/^$group:/ s/$/,$username/" /etc/group
        else
            echo "$group doesn't exist!"
        fi
    done
fi

# prompts the user to enter a password for the new user
passwd $username