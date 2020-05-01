#!/bin/bash

echo ""

# Script Level Functions


function user-input-selection(){
    echo "${1}:"
    count=0
    export selection=""
    for o in "${list[@]}"; do
        echo "   - ${count} ${o}"
        ((count++))
    done
    read -p "Selection [0]: " id
    echo ""
    export selection="${list[id]:=${list[0]}}"
}

function default-input-selection(){
    id="$1"
    export selection="${list[id]:=${list[0]}}"
}

function configure-system-name(){
    # Can't run these commands each with sudo; Script itself has to be run with sudo
    scriptFile=/tmp/set-system-name.sh
    echo '#!/bin/sh' > $scriptFile
    echo "scutil --set HostName $1.$2" >> $scriptFile
    echo "scutil --set LocalHostName $1" >> $scriptFile
    echo "scutil --set ComputerName $1" >> $scriptFile
    chmod +x $scriptFile
    sudo $scriptFile
    rm $scriptFile
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
    caffeinate -ismu -t 3600 >/dev/null 2>&1 &
}
function stop-caffeinate(){
    killall caffeinate >/dev/null 2>&1
}
function patch-sytem(){
    sudo softwareupdate -ia > /dev/null
}
function configure-git-env(){
    if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -q -N "" -f $HOME/.ssh/id_rsa
    fi

    if [ ! -f ~/.gitignore_global ]; then
        echo ".DS_Store" >> $HOME/.gitignore_global
    fi
    
    git config --global user.name "$fullName"
    git config --global user.email "$userEmail"
    git config --global core.excludesfile ~/.gitignore_global
}
function autohide-dock(){
    defaults write com.apple.dock autohide -bool TRUE ; defaults write com.apple.dock autohide-time-modifier -int 0
}

function disable-sudo-password(){
    sudoFile="/etc/sudoers"
    sudoPassEnabled=`printf '%%admin\t\tALL = (ALL) ALL'`
    sudoPassDisabled=`printf '%%admin\t\tALL = (ALL) NOPASSWD:ALL'`
    sudo sed -i ""  "s/$sudoPassEnabled/$sudoPassDisabled/g" $sudoFile
}

function enable-sudo-password(){
    sudoFile="/etc/sudoers"
    sudoPassEnabled=`printf '%%admin\t\tALL = (ALL) ALL'`
    sudoPassDisabled=`printf '%%admin\t\tALL = (ALL) NOPASSWD:ALL'`
    sudo sed -i ""  "s/$sudoPassDisabled/$sudoPassEnabled/g" $sudoFile
}

function build-system-setup-script(){
    scriptFile=$HOME/denv-setup.sh
    tmpfFile=$scriptFile.tmp
    curl -s "${baseUrl}/master/os/mac/base-system-setup.sh" -o $scriptFile
    echo "export ROOT_PATH=${macVolume}" | cat - $scriptFile > $tmpfFile && mv -f $tmpfFile $scriptFile
    echo "" | cat - $scriptFile > $tmpfFile && mv -f $tmpfFile $scriptFile
    echo "#!/bin/sh" | cat - $scriptFile > $tmpfFile && mv -f $tmpfFile $scriptFile
    chmod +x $scriptFile
}

function build-installer-script(){
    scriptFile=$HOME/Desktop/denv/installer.sh
    curl -s "${baseUrl}/master/os/mac/installer.sh" -o $scriptFile
    chmod +x $scriptFile
}

function build-denv-desktop-readme(){
    readmeFile=$HOME/Desktop/README.md
    curl -s "${baseUrl}/master/os/mac/desktop-readme.md" -o $readmeFile
    echo "" >> $readmeFile
    echo "    ${macVolume}/Users/$USER/denv-setup.sh" >> $readmeFile
    echo "    \`\`\`" >> $readmeFile
    echo "" >> $readmeFile
}

function setup-denv-desktop(){
    denvDir=$HOME/Desktop/denv
    mkdir -p $denvDir
    curl -s "${baseUrl}/master/os/mac/CustomBrewfile" -o $denvDir/Brewfile > /dev/null
    build-system-setup-script
    build-installer-script
    build-denv-desktop-readme
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

function get-current-computer-sleep-setting(){
    currentSleepConfig=`sudo systemsetup -getcomputersleep`
    removePhrase1="Computer Sleep: "
    removePhrase2="after "
    removePhrase3=" minutes"
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase1/}"`
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase2/}"`
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase3/}"`
    echo "$currentSleepConfig"
}

function get-current-disk-sleep-setting(){
    currentSleepConfig=`sudo systemsetup -getharddisksleep`
    removePhrase1="Hard Disk Sleep: "
    removePhrase2="after "
    removePhrase3=" minutes"
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase1/}"`
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase2/}"`
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase3/}"`
    echo "$currentSleepConfig"
}

function set-computer-sleep-setting(){
    sudo systemsetup -setcomputersleep "$1" > /dev/null
}

function set-disk-sleep-setting(){
    sudo systemsetup -setharddisksleep "$1" > /dev/null
}

function disable-app-verification(){
    sudo spctl --master-disable
}

function enable-do-not-disturb(){
    defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true
    defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturbDate -date "`date -u +\"%Y-%m-%d %H:%M:%S +0000\"`"
    killall NotificationCenter
}

function disable-do-not-disturb(){
    defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false
    killall NotificationCenter
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
    curl -s "${baseUrl}/master/os/mac/.bashrc" -o "$HOME/.bashrc"
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
    sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist > /dev/null 2>&1
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users admin -privs -all -restart -agent -menu > /dev/null 2>&1
}

# Disable Remote Login(SSH Server) & Remote Management(VNC Server)
function disable-remote-services(){
    sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist > /dev/null
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate > /dev/null
}

function install-homebrew(){
    which -s brew
    if [[ $? != 0 ]] ; then
        caffeinate -s /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" </dev/null
    fi
}

function install-base-bundle(){
    caffeinate -s brew bundle --global
}

# Setup Homebrew
function setup-homebrew(){
    echo "Installing Command Line Tools for Xcode & Homebrew..."
    install-homebrew >/dev/null 2>&1
    bundleFile=$HOME/.Brewfile
    curl -s "${baseUrl}/master/os/mac/GlobalBrewfile" -o $bundleFile >/dev/null

    sed -i ""  "s/REPLACE_ME_DEFAULT_EDITOR/$editor/g" $bundleFile
    sed -i ""  "s/REPLACE_ME_DEFAULT_BROWSER/$browser/g" $bundleFile
    sed -i ""  "s/REPLACE_ME_DEFAULT_ARCHIVE_TOOL/$archiver/g" $bundleFile
    echo "Installing base Formulaes and Casks from Homebrew..."
    install-base-bundle >/dev/null 2>&1
    echo "Finished installing base Formulaes and Casks!"
}

# Export all script functions
export -f disable-app-verification
export -f default-input-selection
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
export -f enable-sudo-password
export -f build-system-setup-script
export -f build-installer-script
export -f build-denv-desktop-readme
export -f setup-denv-desktop
export -f run-sudo-and-keep-alive
export -f get-mac-volume
export -f get-current-computer-sleep-setting
export -f get-current-disk-sleep-setting
export -f set-computer-sleep-setting
export -f set-disk-sleep-setting
export -f enable-do-not-disturb
export -f disable-do-not-disturb
export -f set-finder-preferences
export -f set-activity-monitor-preferences
export -f set-bash-shell
export -f remove-dock-default-apps
export -f configure-default-browser
export -f enable-remote-services
export -f disable-remote-services
export -f install-homebrew
export -f install-base-bundle
export -f setup-homebrew


# User Input Configurations


echo "Please input your configuration below."
echo "   - Defaults will be inside of brackets [...]"
echo "   - Leave input empty if you are unsure."
echo ""
while [ "$confirm" != "y" ]; do

    # Local User
    echo "Local System Account"
    echo "   Username: ${USER}"
    read -s -p "   Password: " userPassword && echo ""
    echo ""

    # Ask if just want to use default inputs
    read -p "Use Default Setup (y/n): " defaultSetup
    defaultSetup=`echo "${defaultSetup:=n}" | tr '[:upper:]' '[:lower:]'`

    # System Name
    
    defaultComputerName="${USER}-mbp"
    defaultDomainName="local"

    if [ "$defaultSetup" != "y" ]; then
        echo ""
        echo "System Name"
        read -p "   Domain Name [${defaultDomainName}]: " newDomainName
        read -p "   Computer Name [${defaultComputerName}]: " newComputerName
        echo ""
    fi
    
    newDomainName="${newDomainName:=${defaultDomainName}}"
    newComputerName="${newComputerName:=${defaultComputerName}}"

    # Git User Setup
    if [ ! -f ~/.gitconfig ]; then
        if [ "$defaultSetup" = "y" ]; then
            fullName="$USER"
            userEmail="${USER}@${newDomainName}"
        else
            echo "Git User Setup"
            read -p "   Full Name: " fullName
            read -p "   Git Email: " userEmail
            echo ""
        fi
    fi

    if [ "$defaultSetup" != "y" ]; then
        echo "Select your option by number for the following prompts."
        echo ""
    fi 
    
    # Select Default Browser
    
    export declare list=("google-chrome" "safari" "firefox" "microsoft-edge" "tor-browser" "opera" "brave-browser")
    if [ "$defaultSetup" = "y" ]; then
        default-input-selection "0"
    else
        user-input-selection "Default Browser"
    fi
    export browser=$selection

    # Select Default GUI Text Editor
    export declare list=("visual-studio-code" "sublime-text" "atom" "bbedit" "textmate")
    if [ "$defaultSetup" = "y" ]; then
        default-input-selection "0"
    else
        user-input-selection "Default Text Editor"
    fi
    export editor=$selection

    # Select Default Archive Tool
    # export declare list=("keka")
    # user-input-selection "Default Archive Tool"
    # export editor=$selection
    export archiver="keka"

    if [ "$defaultSetup" != "y" ]; then
        echo "System Settings - Answer by either y/n"
        echo ""
    fi

    # Configure Apple "Natural" scrolling
    if [ "$defaultSetup" != "y" ]; then
        read -p "   - \"Natural\" Scrolling? [n]: " appleScroll
    fi
    appleScroll=`echo "${appleScroll:=n}" | tr '[:upper:]' '[:lower:]'`

    # Configure sudo password required
    if [ "$defaultSetup" != "y" ]; then
        read -p "   - Require Sudo Password? [n]: " sudoPassRequired
    fi
    sudoPassRequired=`echo "${sudoPassRequired:=n}" | tr '[:upper:]' '[:lower:]'`

    # Enable Remote Services (openSSH server & VNC Server)
    if [ "$defaultSetup" != "y" ]; then
        read -p "   - Remote Services(SSH/VNC)? [y]: " remoteServices
    fi
    remoteServices=`echo "${remoteServices:=y}" | tr '[:upper:]' '[:lower:]'`

    # Base Git Repo Raw URL
    if [ "$defaultSetup" != "y" ]; then
        read -p "   - Custom Content URL if available: " baseUrl
    fi
    defaultUrl="https://raw.githubusercontent.com/tamckenna/denv"
    baseUrl="${baseUrl:=${defaultUrl}}"

    echo ""
    echo "Local System Account"
    echo "   Username: $USER"
    echo "   Password: ${userPassword//?/*}"
    echo ""
    echo "System Name"
    echo "   Domain: $newDomainName"
    echo "   Computer: $newComputerName"
    echo "   FQDN: $newComputerName.$newDomainName"
    if [ ! -f ~/.gitconfig ]; then
        echo ""
        echo "Git User Config"
        echo "   Full Name: $fullName"
        echo "   Email: $userEmail"
    fi
    echo ""
    echo "Default Applications:"
    echo "   Browser: $browser"
    echo "   Editor: $editor"
    echo "   Arhive Tool: $archiver"
    echo ""
    echo "System Settings"
    echo "   Apple Scroll: $appleScroll"
    echo "   Require Sudo Password: $sudoPassRequired"
    echo "   Remote Services: $remoteServices"
    echo ""
    if [ "$baseUrl" != "$defaultUrl" ]; then
        echo "Custom Git URL: $baseUrl"
        echo ""
    fi
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
export sudoPassRequired
export remoteServices


# Execute Input Configuration
echo "We'll automate the rest from here. Take a break; you deserve it!"
echo ""

# Run sudo and keep timestamp refreshed till end of script
run-sudo-and-keep-alive

# Disable Password for sudo for at least the rest of the script
disable-sudo-password

# Disable system sleep for disk/computer and turn on do not disturb mode
startDiskSleep=`get-current-disk-sleep-setting`
startComputerSleep=`get-current-computer-sleep-setting`
set-disk-sleep-setting "Never"
set-computer-sleep-setting "Never"
enable-do-not-disturb

# Disable App Verificaiton
disable-app-verification

# Set System Name
configure-system-name "$newComputerName" "$newDomainName"

# Identify volume macOS is running on
defaultVolume=/Volumes/Macintosh\ HD
macVolume=`get-mac-volume`
export macVolume="${macVolume:=${defaultVolume}}"


# System Preferences


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


# User Environment


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

# Dock app order will follow order in arry (left to right)
declare addDockList=(
    "/Applications/${browserApp}" "/Applications/iTerm.app"
    "/Applications/${editorApp}"
)

# Add apps in list to dock
for a in "${addDockList[@]}"; do
    dockutil --before "App Store" --add "$a" > /dev/null 2>&1
done

# Enable/Disable Remote Services
if [ "$remoteServices" = "n" ]; then
    disable-remote-services
else
    enable-remote-services
fi

# Patch System if update available
patch-sytem

# Setup denv desktop for next steps
setup-denv-desktop

# Reset sleep settings to original values & turn off do not disturb mode
set-disk-sleep-setting "$startDiskSleep"
set-computer-sleep-setting "$startComputerSleep"
disable-do-not-disturb

# Require Sudo Password if required
if [ "$sudoPassRequired" = "y" ]; then
    enable-sudo-password
fi

# Open Up App Store for login
open /System/Applications/App\ Store.app

# Open up Readme.md for next steps
open "$HOME/Desktop/README.md"

echo ""
