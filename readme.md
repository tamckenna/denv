# Development Environment Setup

## Scripts by OS

### Windows

```bash
powershell - c "iwr -useb raw.githubusercontent.com/tamckenna/denv/master/os/win/setup.ps1 | iex"
```

### macOS

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/tamckenna/denv/master/os/mac/setup.sh)"
```

---

## Configuration Details

### Windows Configuration

* Windows Settings
  * Runs [decrapifier.ps1](https://community.spiceworks.com/scripts/show/4378-windows-10-decrapifier-18xx-19xx) script to remove default services and disable data sharing
  * Enable Developer Mode
  * Set PowerShell Execution Policy to Unrestricted
  * Disable Windows Defender Firewall and corresponding notifications
  * Add C drive to Windows Defender exception list
  * Enable Dark Mode
  * Configure File Explorer Default Settings
    * Show all file extensions
    * Show hidden files
    * Show full directory path in title bar
    * New window opens to __This PC__
    * Disable recent/frequent viewed files feature
    * Set default file view to detail list
  * Default an assortment of file types to open with Visual Studio Code
  * Enable Win32 Long File Paths
* Windows Features to enable:
  * Microsoft-Hyper-V-All
  * Microsoft-Windows-Subsystem-Linux
  * OpenSSH.Server
* User Settings
  * Enable git long file paths
  * Generate SSH keys
* Applications
  * Package Managers
    * [Scoop](https://scoop.sh/)
    * [Chocolatey](https://chocolatey.org/)
  * System Utilities
    * 7zip
    * openSSH
    * PuTTY
    * Ubuntu 18.04 WSL
    * PowerShell Core(7.0)
  * CLI Utilities
    * gow
    * curl
    * wget
    * grep
    * sed
    * less
    * touch
  * SDKs
    * dotnet-sdk
    * AdoptOpenJDK
    * Python
    * Go
    * nvm
  * Editors
    * Visual Studio Code
    * notepad++
    * Sublime Text
    * Atom
    * vim
    * nano
  * IDE/SQL Editors
    * Eclipse JEE
    * Jetbrains Toolbox
    * Azure Data Studio
    * MySQL Workbench
    * DBeaver
  * Development Utilities
    * git
    * Docker Desktop
    * windows-terminal
    * postman
    * soapUI
    * xming
  * Browsers
    * Google Chrome
    * Google Chromium
    * Mozilla Firefox
    * Mozilla Firefox Developer
    * Brave Browser

### macOS Configuration

* System Settings
  * Disable password for sudo
  * Disable "natural" scrolling
  * Finder Settings
    * Show all hidden files
    * Show all file extensions
    * Disable __.DS_Store__ creation on network shares
    * Search functionality searches recursively in current directory
    * Show path in bar
    * Default new window to Desktop directory
    * Disable file extension change warning
  * Activity Monitor Settings
    * Visualize CPU in dock icon
    * Show all processes
    * Sort processes by CPU usage
* User Settings
  * Change shell to bash shell
  * Pulls down custom [.bashrc](mac/os/.bashrc)
  * Disable zshell warning
  * Generates SSH keys
  * Installs Homebrew
  * Runs homebrew bundle
    * Will install formulas/casks specified in: [Brewfile](mac/os/Brewfile)
  * Configures default application for file types (Visual Studio Code)
* Applications
  * Package Managers
    * [Homebrew](https://brew.sh/)
  * CLI Utilities
    * wget
    * curl
    * telnet
    * htop
    * p7zip
    * dtrx
    * dos2unix
    * tldr
    * fio
    * speedtest-cli
    * dockutil
    * mas
    * duti
    * powershell
  * SDKs
    * go
    * node
    * python
    * adoptopenjdk
    * adoptopenjdk8
    * dotnet-sdk
  * Build Tools
    * ant
    * maven
    * gradle
    * yarn
    * mono
    * nuget
  * Editors
    * Visual Studio Code
    * Sublime Text
    * Atom
  * IDE/SQL Editors
    * Eclipse JEE
    * Jetbrains Toolbox
    * DBeaver
    * Azure Data Studio
    * MySQL Workbench
  * Development Utilities
    * git
    * Docker Desktop
    * iTerm
    * Postman
    * VNC Viewer
    * React Native Debugger
    * GitHub
  * Development CLI
    * awscli
    * aws-sam-cli
    * azure-cli
    * firebase-cli
    * google-cloud-sdk
    * kubectl
    * terraform
    * mysql-client
    * nativefier
    * gh
  * Browsers
    * Google Chrome
    * Google Chromium
    * Mozilla Firefox
    * Mozilla Firefox Developer
    * Microsoft Edge
  * Content
    * Adobe Acrobat Reader
    * VLC
    * MPV
    * ffmpeg
    * youtube-dl
  * System Utilities
    * AppCleaner
    * BalenaEtcher
    * Cinch
    * Macs Fan Control
    * Keka
    * SkyFonts
