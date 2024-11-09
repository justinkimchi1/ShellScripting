# Shell Scripting Assignment
 
This assignment consists of two parts - **Project 1** and **Project 2**

**Project 1 - System Setup Scripts**
- Develop several small scripts that automate the installation of software packages and create symbolic links to configuration systems stored in a remote git Repository.

**Project 2 - User Creation Scripts**
- Automate the process of creating new users on the system. This would include setting a password, establishing the user's groups, creating a home directory and specifying their shell.

## Table of Contents

- [Project 1 - System Setup Scripts](#project-1-system-setup-scripts)
    - [Scripts Overview](#scripts-overview)
    - [Usage Instructions](#usage-instructions)
- [Project 2 - User Creation Scripts](#project-2-user-creation-scripts)
    - [Usage Instructions](#usage-instructions)
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

```bash
#!/usr/bin/env bash

# description: installs a list of packages that is required for the configuration setup

# source:
# https://www.freecodecamp.org/news/how-to-manage-users-in-linux/ [1]
# https://wiki.archlinux.org/title/PacmanTips_and_tricks#List_of_installed_packages [2]
# https://www.gnu.org/software/bash/manual/bash.html [3]
# https://dev.to/rpalo/bash-brackets-quick-reference-4eh6 [4]
# https://ss64.com/bash/syntax-file-operators.html [5]

# we use the dollar sign parentheses to get the current user running the script. If we just used id, then it would go through the whole list of user id's [4]
# -ne means not equal to, so -ne 0 is saying if the user id is not equal to 0 (which is the root users id) then we do next step [1][3] 
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

```bash
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
Once you get multiple messages saying **Created symlink for < Path >**, then you have successfully created symbolic links to the configuration files!

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
```bash
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
In this part of the assignment, we created a user creation script that will allow users to create new users with a specified shell, home directory with /etc/skel contents copied into it, and allow the user to be added to addtional groups.

### Usage Instructions
`new-user-script`:
1. Import the script into your directory:
```bash
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
```

2. You **Must** run the script with root privileges or with sudo. You can run the script with this:
```
sudo ./new-user-script.sh < options >
```
Options for the script:
- -u: < username > the name of the new user
- -s: < shell > a specified shell, by default the new user has bash shell
- -g: < "group1 group2 group3" > adds user to additional groups 
- -c: < "comments" > adds any additional information about the new user
- -h: displays the help message to use this script

Example usage:
```
sudo ./new-user-script.sh -u joe -s /bin/zsh -g "wheel project cheese" -c "Admin User"
```

Congratulations! You now know how to use the `new-user-script.sh` script!

## Sources
1. Baeldung. "Identify User Called by Sudo." https://www.baeldung.com/linux/identify-user-called-by-sudo
2. Baeldung. "Bash Check Script Arguments." https://www.baeldung.com/linux/bash-check-script-arguments#:~:text=Check%20Whether%20No%20Arguments%20Are,may%20miss%20the%20arguments%20completely.&text=The%20%24%23%20variable%20gives%20us,its%20two%20operands%20is%20equal.
3. CyberCiti. "Append Text to End of File in Linux." https://www.cyberciti.biz/faq/linux-append-text-to-end-of-file/
4. dev.to. "Bash Brackets Quick Reference." https://dev.to/rpalo/bash-brackets-quick-reference-4eh6
5. DigitalOcean. "Read Command Line Arguments in Shell Scripts." https://www.digitalocean.com/community/tutorials/read-command-line-arguments-in-shell-scripts
6. FreeCodeCamp. "How to Manage Users in Linux." https://www.freecodecamp.org/news/how-to-manage-users-in-linux/
7. GNU. "Bash Manual." https://www.gnu.org/software/bash/manual/bash.html
8. GNU. "Coreutils Manual: The Cut Command." https://www.gnu.org/software/coreutils/manual/html_node/The-cut-command.html
9. GNU. "Grep Manual." https://www.gnu.org/software/grep/manual/grep.html
10. GNU. "Sed Manual." https://www.gnu.org/software/sed/manual/sed.html
11. IBM. "Getopts: Parse Utility Options." https://www.ibm.com/docs/en/zos/2.4.0?topic=descriptions-getopts-parse-utility-options
12. O'Reilly. *Bash Shell Scripting* (Video). "Working with Options (10.1)." https://learning.oreilly.com/videos/bash-shell-scripting/9780137689064/9780137689064-BSS2_04_10_01/
13. O'Reilly. *Linux for System Administrators.* https://learning.oreilly.com/library/view/linux-for-system/9781803247946/B18575_07.xhtml
14. SS64. "Bash File Operators." https://ss64.com/bash/syntax-file-operators.html
15. The Linux Documentation Project. "Bash Beginners Guide: Section 7.1." https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
16. Tutorialspoint. "Unix Special Variables." https://www.tutorialspoint.com/unix/unix-special-variables.htm
17. ArchWiki. "Pacman Tips and Tricks: List of Installed Packages." https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#List_of_installed_packages
18. Atlassian. "Setting Up a Repository with Git Clone." https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-clone
