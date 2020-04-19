#!/bin/sh

# Ask for sudo password up front and keep timestamp refreshed till end of script
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

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

###############################################################################
# Configure macOS Dock                                                        #
###############################################################################

# Disable recent apps section
defaults write com.apple.dock show-recents -bool FALSE

# Remove all current applications on Dock
defaults delete com.apple.dock persistent-apps
#defaults delete com.apple.dock persistent-others

# Autohide Dock without Animation
defaults write com.apple.dock autohide -bool TRUE
defaults write com.apple.dock autohide-time-modifier -int 0

# Commands to configure Dock
# Reference https://github.com/kcrawford/dockutil

###############################################################################
# Configure VS Code                                                           #
###############################################################################


###############################################################################
# Patch System                                                                #
###############################################################################
sudo softwareupdate -ia --verbose

###############################################################################
# Reboot System                                                               #
###############################################################################
sudo reboot
