#!/bin/sh

# Ask for sudo password up front and keep timestamp refreshed till end of script
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Caffeinate macOS for 1 hour
caffeinate -ismu -t 3600 &

# Disable Password for sudo
# Can't run these commands with sudo; Script itself has to be run with sudo
echo '#!/bin/sh' >> /tmp/disable_sudo_password.sh
echo 'chmod +w /etc/sudoers' >> /tmp/disable_sudo_password.sh
echo 'echo "" >> /etc/sudoers' >> /tmp/disable_sudo_password.sh
echo 'echo "%admin          ALL = (ALL) NOPASSWD:ALL" >> /etc/sudoers' >> /tmp/disable_sudo_password.sh
echo 'echo "" >> /etc/sudoers' >> /tmp/disable_sudo_password.sh
chmod +x /tmp/disable_sudo_password.sh
sudo /tmp/disable_sudo_password.sh
rm /tmp/disable_sudo_password.sh

###############################################################################
# System Preferences                                                          #
###############################################################################

# Disable “natural” scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

###############################################################################
# Finder Preferences                                                          #
###############################################################################

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
#defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Show the main window when launching Activity Monitor
# defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# User Environment                                                            #
###############################################################################
# Copy down .bashrc & .bash_profile from github
sudo chsh -s /bin/bash
sudo chsh -s /bin/bash $USER

# Create .bash_profile file
echo '# bash_profile file (Runs every login shell)' >> $HOME/.bash_profile
echo '[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile ' >> $HOME/.bash_profile
echo '[[ -s "$HOME/.bashrc" ]] && source "$HOME/.bashrc" # Load the .bashrc file ' >> $HOME/.bash_profile
echo '' >> $HOME/.bash_profile

# Curl down .bashrc and Brewfile files
curl https://raw.githubusercontent.com/tamckenna/denv/master/os/mac/.bashrc -O
curl https://raw.githubusercontent.com/tamckenna/denv/master/os/mac/Brewfile -O

# Generate SSH Key
ssh-keygen -q -N "" -f $HOME/.ssh/id_rsa

###############################################################################
# Install Homebrew                                                            #
###############################################################################
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" </dev/null

# Install formulas and casks in Brewfile
    # Make sure to copy down Brewfile to home directory
brew bundle


# Default Applications by File Type
get-app-id(){ osascript -e "id of app \"${1}\"" ; }
set-default-app(){ appId=`get-app-id "$1"` && duti -s "$appId" "$2" all ; }
default-to-code(){ set-default-app "Visual Studio Code" "$1" ;}

default-to-code txt
default-to-code conf
default-to-code bak
#default-to-code html
default-to-code css
default-to-code js
default-to-code json
default-to-code gitignore
default-to-code gitattributes
default-to-code xml
default-to-code csv
default-to-code psv
default-to-code dsv
default-to-code java
default-to-code gradle
default-to-code properties
default-to-code settings
default-to-code out
default-to-code md
default-to-code keep
default-to-code py
default-to-code pl
default-to-code sh
default-to-code bash
default-to-code ksh
default-to-code ps1
default-to-code plist

###############################################################################
# Configure macOS Dock                                                        #
###############################################################################

# Autohide Dock without Animation
defaults write com.apple.dock autohide -bool TRUE
defaults write com.apple.dock autohide-time-modifier -int 0

# Disable recent apps section
defaults write com.apple.dock show-recents -bool FALSE

# Configure Applications on Dock (https://github.com/kcrawford/dockutil)
# Remove all current applications on Dock
    #defaults delete com.apple.dock persistent-apps
    #defaults delete com.apple.dock persistent-others

# Remove default Applications on Dock
dockutil --remove 'Safari' --allhomes
dockutil --remove 'Mail' --allhomes
dockutil --remove 'FaceTime' --allhomes
dockutil --remove 'Messages' --allhomes
dockutil --remove 'Maps' --allhomes
dockutil --remove 'Photos' --allhomes
dockutil --remove 'Contacts' --allhomes
dockutil --remove 'Calendar' --allhomes
dockutil --remove 'Reminders' --allhomes
dockutil --remove 'Notes' --allhomes
dockutil --remove 'Music' --allhomes
dockutil --remove 'Podcasts' --allhomes
dockutil --remove 'TV' --allhomes
dockutil --remove 'News' --allhomes
dockutil --remove 'Numbers' --allhomes
dockutil --remove 'Keynote' --allhomes
dockutil --remove 'Pages' --allhomes

# Add Applications to Dock
dockutil --before "App Store" --add /Applications/Google\ Chrome.app
dockutil --before "App Store" --add /Applications/Firefox\ Developer\ Edition.app
dockutil --before "App Store" --add /Applications/Microsoft\ Edge.app
dockutil --before "App Store" --add /Applications/iTerm.app
dockutil --before "App Store" --add /Applications/Visual\ Studio\ Code.app
dockutil --before "App Store" --add /Applications/Azure\ Data\ Studio.app
dockutil --before "App Store" --add /Applications/DBeaver.app

###############################################################################
# Configure VS Code                                                           #
###############################################################################
# Configure VS Code

###############################################################################
# Setup Next Steps on Desktop                                                 #
###############################################################################
cd $HOME/Desktop
curl https://raw.githubusercontent.com/tamckenna/denv/master/os/mac/Masfile -O
mkdir $HOME/Desktop/mas
mv Masfile $HOME/Desktop/mas/Brewfile
echo "# Next Steps" >> next_steps.md
echo "" >> next_steps.md
echo "### Install macOS App Store applications using mas-cli" >> next_steps.md
echo "" >> next_steps.md
echo "1. Open up App Store and login" >> next_steps.md
echo '2. ```cd $HOME/Desktop/mas && brew bundle```' >> next_steps.md
echo '' >> next_steps.md

###############################################################################
# Patch System                                                                #
###############################################################################
sudo softwareupdate -ia --verbose

###############################################################################
# Reboot System                                                               #
###############################################################################
sudo reboot
