#!/usr/bin/env bash

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
