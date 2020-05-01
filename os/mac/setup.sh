#!/bin/bash

echo ""
###############################################################################
# Script Level Functions                                                      #
###############################################################################
function user-input-selection(){
    echo "${1}:"
    count=0
    export selection=""
    for o in "${list[@]}"; do
        echo "   - ${count} ${o}"
        ((count++))
    done
    read -p "Default [0]: " id
    echo ""
    export selection="${list[id]:=${list[0]}}"
}

function configure-system-name(){
    sudo scutil --set HostName "$1.$2"
    sudo scutil --set LocalHostName "$1.$2"
    sudo scutil --set ComputerName "$1"
}

function get-cask-artifact(){
    appLine=`brew cask info $1 | sed '1,/Artifacts/d'`
    appName="${appLine%%.app*}"
    echo "${appName}.app"
}

function get-app-bundle-id(){
    osascript -e "id of app \"${1}\"" ; 
}
function get-cask-bundle-id(){
    appName=`get-cask-artifact "$1"`
    get-app-bundle-id "$appName"
}
function set-default-app(){
    duti -s "$1" "$2" all
}
function set-default-browser(){
    duti -s "$browserId" "$1" all
}
function set-default-editor(){
    duti -s "$editorId" "$1" all
}
function set-default-archiver() {
    duti -s "$archiverId" "$1" all
}
function caffeinate-mac-one-hour(){
    caffeinate -ismu -t 3600 &
}
function stop-caffeinate(){
    killall caffeinate >/dev/null 2>&1
}
function patch-sytem(){
    sudo softwareupdate -ia > /dev/null
}
function configure-git-env(){
    ssh-keygen -q -N "" -f $HOME/.ssh/id_rsa
    git config --global user.name "$fullName"
    git config --global user.email "$userEmail"
    echo ".DS_Store" >> $HOME/.gitignore_global
    git config --global core.excludesfile ~/.gitignore_global
}
function autohide-dock(){
    defaults write com.apple.dock autohide -bool TRUE ; defaults write com.apple.dock autohide-time-modifier -int 0
}

function disable-sudo-password(){
    # Can't run these commands each with sudo; Script itself has to be run with sudo
    echo '#!/bin/sh' >> /tmp/disable_sudo_password.sh
    echo 'chmod +w /etc/sudoers' >> /tmp/disable_sudo_password.sh
    echo 'echo "" >> /etc/sudoers' >> /tmp/disable_sudo_password.sh
    echo 'echo "%admin          ALL = (ALL) NOPASSWD:ALL" >> /etc/sudoers' >> /tmp/disable_sudo_password.sh
    echo 'echo "" >> /etc/sudoers' >> /tmp/disable_sudo_password.sh
    chmod +x /tmp/disable_sudo_password.sh
    sudo /tmp/disable_sudo_password.sh
    rm /tmp/disable_sudo_password.sh
}

function build-system-setup-script(){
    scriptFile=$HOME/Desktop/denv/system-setup.sh
    tmpfFile=$scriptFile.tmp
    curl "${baseUrl}/master/os/mac/AddonBrewfile" -o $scriptFile
    echo "export ROOT_PATH=${macVolume}" | cat - $scriptFile > $tmpfFile && mv -f $tmpfFile $scriptFile
    echo "" | cat - $scriptFile > $tmpfFile && mv -f $tmpfFile $scriptFile
    echo "#!/bin/sh" | cat - $scriptFile > $tmpfFile && mv -f $tmpfFile $scriptFile
    chmod +x $scriptFile
}

function build-denv-desktop-readme(){
    readmeFile=$HOME/Desktop/README.md
    curl "${baseUrl}/master/os/mac/desktop-readme.md" -o $readmeFile > /dev/null
    echo "    ${macVolume}/Users/$USER/Desktop/denv/system-setup.sh" >> $readmeFile > /dev/null
    echo "    \`\`\`" >> $readmeFile > /dev/null
    echo "" >> $readmeFile > /dev/null
}

function setup-denv-desktop(){
    denvDir=$HOME/Desktop/denv
    mkdir -p $denvDir
    curl "${baseUrl}/master/os/mac/AddonBrewfile" -o $denvDir/Brewfile > /dev/null
    build-system-setup-script > /dev/null
    build-denv-desktop-readme > /dev/null
}

function run-sudo-and-keep-alive(){
    echo $userPassword | sudo -vS 2> /dev/null
    # while true ; do
    #     sudo -n true; sleep 60; kill -0 "$$" || exit ;
    # done 2>/dev/null &
}

function get-mac-volume(){
    for a in /Volumes/*; do
        dest=`readlink "$a"`
        if [ "$dest" = "/" ]; then
            macVolume="${a/ /\\ }"
        fi
    done
    echo "$macVolume"
}

function set-finder-preferences(){
    # Set Desktop as the default location for new Finder windows; For other paths, use `PfLo` and `file:///full/path/here/`
    defaults write com.apple.finder NewWindowTarget -string "PfDe"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

    # Show icons for hard drives, servers, and removable media on the desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
    #defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

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
}

set-activity-monitor-preferences(){
    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0
}

set-bash-shell(){
    sudo chsh -s /bin/bash
    sudo chsh -s /bin/bash $USER

    # Create .bash_profile file
    echo '# bash_profile file (Runs every login shell)' >> $HOME/.bash_profile
    echo '[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile ' >> $HOME/.bash_profile
    echo '[[ -s "$HOME/.bashrc" ]] && source "$HOME/.bashrc" # Load the .bashrc file ' >> $HOME/.bash_profile
    echo '' >> $HOME/.bash_profile
    
    # Curl down .bashrc
    curl "${baseUrl}/master/os/mac/.bashrc" -o "$HOME/.bashrc"
}

function remove-dock-default-apps(){
    declare removeDockList=(
        "Mail" "FaceTime" "Messages" "Maps" "Photos" "Contacts" "Calendar" "Reminders"
        "Notes" "Music" "Podcasts" "TV" "News" "Numbers" "Keynote" "Pages"
    )
    for a in "${removeDockList[@]}"; do
        dockutil --remove "$a" --allhomes >/dev/null 2>&1
    done
    if [ "$browser" != "safari" ]; then
        dockutil --remove 'Safari' --allhomes >/dev/null 2>&1
    fi
}

function configure-default-browser(){
    if [ "$browser" = "google-chrome" ]; then
        defaultBrowser="chrome"
    elif [ "$browser" = "brave-browser" ]; then
        defaultBrowser="browser"
    elif [ "$browser" = "microsoft-edge" ]; then
        defaultBrowser="edgemac"
    elif [ "$browser" = "tor-browser" ]; then
        defaultBrowser="torbrowser"
    else
        defaultBrowser="$browser"
    fi
    defaultbrowser "$defaultBrowser"
}

# Enable Remote Login(SSH Server) & Remote Management(VNC Server)
function enable-remote-services(){
    sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist > /dev/null
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users admin -privs -all -restart -agent -menu > /dev/null
}

# Disable Remote Login(SSH Server) & Remote Management(VNC Server)
function disable-remote-services(){
    sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist > /dev/null
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate > /dev/null
}

function install-homebrew(){
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" </dev/null
}

# Setup Homebrew
function setup-homebrew(){
    echo "Installing xCode Command Line tools & Homebrew. This may take a few minutes..."
    install-homebrew >/dev/null 2>&1
    curl "${baseUrl}/master/os/mac/BaseBrewfile" -o $HOME/Brewfile >/dev/null

    sed -i ""  "s/REPLACE_ME_DEFAULT_EDITOR/$editor/g" $HOME/Brewfile
    sed -i ""  "s/REPLACE_ME_DEFAULT_BROWSER/$browser/g" $HOME/Brewfile
    sed -i ""  "s/REPLACE_ME_DEFAULT_ARCHIVE_TOOL/$archiver/g" $HOME/Brewfile
    echo "Installing dependency forumulas and casks. This may take a few minutes..."
    brew bundle --global >/dev/null 2>&1
}

# Export all script functions
export -f user-input-selection
export -f get-cask-artifact
export -f configure-system-name
export -f get-app-bundle-id
export -f get-cask-bundle-id
export -f set-default-app
export -f set-default-browser
export -f set-default-editor
export -f set-default-archiver
export -f caffeinate-mac-one-hour
export -f stop-caffeinate
export -f patch-sytem
export -f configure-git-env
export -f autohide-dock
export -f disable-sudo-password
export -f build-system-setup-script
export -f build-denv-desktop-readme
export -f setup-denv-desktop
export -f run-sudo-and-keep-alive
export -f get-mac-volume
export -f set-finder-preferences
export -f set-activity-monitor-preferences
export -f set-bash-shell
export -f remove-dock-default-apps
export -f configure-default-browser
export -f enable-remote-services
export -f disable-remote-services
export -f install-homebrew
export -f setup-homebrew

###############################################################################
# User Input Configurations                                                   #
###############################################################################
echo "Please input your configuration below."
echo "Defaults will be inside of the brackets [...]"
echo ""
while [ "$confirm" != "y" ]; do

    # System Name
    echo "System Name"
    read -p "   Domain Name [local]: " newDomainName
    read -p "   Computer Name [my-mac]: " newComputerName

    # Local User
    echo "Local System Account"
    echo "   Username: ${USER}"
    read -s -p "   Password: " userPassword && echo ""
    echo ""

    # Git User Setup
    echo "Git User Setup"
    read -p "   Full Name: " fullName
    read -p "   Git Email: " userEmail
    echo ""

    # Select Default Browser
    export declare list=("google-chrome" "safari" "firefox" "microsoft-edge" "tor-browser" "opera" "brave-browser")
    user-input-selection "Default Browser"
    export browser=$selection

    # Select Default GUI Text Editor
    export declare list=("visual-studio-code" "sublime-text" "atom" "bbedit" "textmate")
    user-input-selection "Default Text Editor"
    export editor=$selection

    # Select Default Archive Tool
    # export declare list=("keka")
    # user-input-selection "Default Archive Tool"
    # export editor=$selection
    export archiver="keka"

    echo "System Settings"
    echo ""

    # Enable Apple "Natural" scrolling
    read -p "   - Enable \"Natural\" Scrolling? [y/n]: " appleScroll
    appleScroll=`echo "${appleScroll:=n}" | tr '[:upper:]' '[:lower:]'`

    # Enable Remote Services (openSSH server & VNC Server)
    read -p "   - Enable Remote Services(SSH/VNC Servers)? [y/n]: " remoteServices
    remoteServices=`echo "${remoteServices:=y}" | tr '[:upper:]' '[:lower:]'`

    # Base Git Repo Raw URL
    defaultUrl="https://raw.githubusercontent.com/tamckenna/denv"
    read -p "   - Custom Content URL: " baseUrl
    baseUrl="${baseUrl:=${defaultUrl}}"

    echo ""
    echo "System Name"
    echo "   Domain: $newDomainName"
    echo "   Computer: $newComputerName"
    echo "   FQDN: $newComputerName.$newDomainName"
    echo ""
    echo "Local System Account"
    echo "   Username: $USER"
    echo "   Password: ${userPassword//?/*}"
    echo ""
    echo "Git User Config"
    echo "   Full Name: $fullName"
    echo "   Email: $userEmail"
    echo ""
    echo "Default Applications:"
    echo "   Browser: $browser"
    echo "   Editor: $editor"
    echo "   Arhive Tool: $archiver"
    echo ""
    echo "System Settings"
    echo "   Apple Scroll: $appleScroll"
    echo "   Remote Services: $remoteServices"
    echo ""
    echo "Custom Git URL: $baseUrl"
    echo ""
    read -p "Confirm? (y/n): " confirm
    confirm=`echo $confirm | tr '[:upper:]' '[:lower:]'`
    echo ""
done

# Export Configuration Variables
export userPassword
export browser
export editor
export archiver
export appleScroll
export baseUrl
export fullName
export userEmail
export newComputerName
export newDomainName

###############################################################################
# Execute Configuration Inputed                                               #
###############################################################################

# Caffeinate macOS for 1 hour so it doesn't fall asleep during install
caffeinate-mac-one-hour

# Run sudo and keep timestamp refreshed till end of script
run-sudo-and-keep-alive

# Disable Password for sudo
disable-sudo-password

# Set System Name
configure-system-name "$newComputerName" "$newDomainName"

# Identify volume macOS is running on
defaultVolume=/Volumes/Macintosh\ HD
macVolume=`get-mac-volume`
export macVolume="${macVolume:=${defaultVolume}}"

###############################################################################
# System Preferences                                                          #
###############################################################################

# Apple's "Natural" Scrolling
scrollBool="false"
if [ "$appleScroll" = "y" ]; then
    scrollBool="true"
fi
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool $scrollBool

# Set Default Finder Preferences
set-finder-preferences

# Set Activity Monitor Preferences
set-activity-monitor-preferences

###############################################################################
# User Environment                                                            #
###############################################################################

# Install Homebew and base formulas and casks in Brewfile
setup-homebrew

# Setup Git User environment
configure-git-env

# Gather Default Bundle Ids for default applications
if [ "$browser" = "safari" ]; then
    browserId="com.apple.Safari"
else
    browserId=`get-cask-bundle-id "$browser"`
fi
editorId=`get-cask-bundle-id "$editor"`
archiverId=`get-cask-bundle-id "$archiver"`
export browserId
export editorId
export archiverId

# Browser URLs/Files handled by default browser
declare webUrisFiles=( "http" "https" "public.html" "public.xhtml" )

# Plain Text Files handled by default text editor
declare textFiles=(
    "public.plain-text" "public.unix-executable" "public.data"
    "public.comma-separated-values-text" "public.shell-script" "public.php-script"
    "txt" "md" "conf" "yml" "yaml" "public.yaml" "properties" "settings"
    "gitignore" "gitattributes" "keep" "gitkeep" "bak"
    "css" "public.css" "js" "map"
    "xml" "plist" "com.apple.property-list" "json" "csv" "psv" "dsv"
    "java" "gradle" "groovy" "kt" "kotlin" "rb" "cs" "c" "m"
    "sh" "bash" "ksh" "zsh" "py" "pl" "ps1" "run"
    "out" "log"
)

# Archive Files handled by default archive tool
declare archiveFiles=(
    "org.gnu.gnu-zip-archive" "org.7-zip.7-zip-archive" "public.tar-archive"
    "zip" "tar" "7z" "gz"
    "jar" "war" "ear" "msi" "exe"
)

# Set default applications
# for t in "${webUrisFiles[@]}"; do set-default-browser "$t" ; done
configure-default-browser
for t in "${textFiles[@]}"; do
    set-default-editor "$t"
done
for t in "${archiveFiles[@]}"; do
    set-default-archiver "$t"
done

# Configure macOS Dock Settings
autohide-dock

# Disable recent apps section
defaults write com.apple.dock show-recents -bool FALSE

# Remove most default apps on dock
remove-dock-default-apps

# Add Applications to Dock
browserApp=`get-cask-artifact $browser`
editorApp=`get-cask-artifact $editor`

# Items in array will be placed from right to left on dock
declare addDockList=(
    "/Applications/${editorApp}" "/Applications/iTerm.app"
    "/Applications/${browserApp}"
)

# Add apps in list to dock
for a in "${addDockList[@]}"; do
    dockutil --before "App Store" --add "$a"
done

# Enable/Disable Remote Services
if [ "$remoteServices" = "y" ]; then
    enable-remote-services
else
    disable-remote-services
fi

# Patch System if update available
patch-sytem

# Setup denv desktop for next steps
setup-denv-desktop

# Stop Caffeinate
stop-caffeinate

# Open Up App Store for login
open /System/Applications/App\ Store.app

# Open up Readme.md for next steps
open "$HOME/Desktop/README.md"

echo ""
