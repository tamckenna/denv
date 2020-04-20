#!/usr/bin/env pwsh

#####################################################################################################################################################
# Install Scoop Package Manager (https://github.com/lukesampson/scoop)                                                                              #
#####################################################################################################################################################
iwr -useb get.scoop.sh | iex
scoop install aria2 sudo

#####################################################################################################################################################
# Execute admin install script as an Administrator                                                                                                  #
#####################################################################################################################################################
sudo powershell -c "iwr -useb raw.githubusercontent.com/tamckenna/denv/master/os/win/admin.ps1 | iex"
RefreshEnv

#####################################################################################################################################################
# Add Commonly used Scoop buckets                                                                                                                   #
#####################################################################################################################################################
$env:PATH="C:\Program Files\Git\cmd;${env:PATH}"
scoop bucket add extras
scoop bucket add java
scoop bucket add jetbrains

#####################################################################################################################################################
# Install Scoop Apps                                                                                                                                #
#####################################################################################################################################################

# nix Utilities
scoop install curl wget grep sed less touch putty

# Text Editors
scoop install vscode notepadplusplus sublime-text atom

# CLI Utilities
scoop install psutils nano vim gh aws azure-cli

# SDKs
scoop install dotnet-sdk adoptopenjdk-lts-hotspot python go nvm

# Dependency/Build Tools
scoop install nuget nuget-package-explorer
scoop install ant maven gradle

# IDE/SQL Editors
scoop config aria2-enabled false
scoop install eclipse-jee
scoop config aria2-enabled true
scoop install jetbrains-toolbox
scoop install azuredatastudio mysql-workbench dbeaver

# Development Tools
scoop install github postman soapui xming windows-terminal libreoffice-stable winmerge

# Browsers
scoop install googlechrome firefox firefox-developer chromium brave

#####################################################################################################################################################
# User Configuration                                                                                                                                #
#####################################################################################################################################################
reg import "${env:USERPROFILE}/scoop/apps/vscode/current/vscode-install-context.reg"
ssh-keygen -f "${env:USERPROFILE}/.ssh/id_rsa" -t rsa -N '""'

# Enable Windows Dark Mode
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0

# Disable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Exclude C drive from Windows Defender antivirus scanning
Add-MpPreference -ExclusionPath "C:\"

#####################################################################################################################################################
# File Explorer Configuration                                                                                                                       #
#####################################################################################################################################################
# Disable Windows Defender Notifications
$key="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer"
reg add "$key" /t REG_DWORD /f /v "DisableNotificationCenter" /d "1"

# Configure Default File Explorer View Settings
$key="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0
Set-ItemProperty $key LaunchTo 1
Set-ItemProperty $key ShowRecent 0
Set-ItemProperty $key ShowFrequent 0
$key="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState"
Set-ItemProperty $key FullPath 1

# Set Default View to Detail List
$key="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams"
$inputValue="08,00,00,00,04,00,00,00,00,00,00,00,00,77,7e,13,73,35,cf,11,ae,69,08,00,2b,2e,12,62,04,00,00,00,01,00,00,00,43,00,00,00"
$hexValue = $inputValue.Split(',') | ForEach-Object { "0x$_"}
New-ItemProperty -Path $key -Name Settings -PropertyType Binary -Value ([byte[]]$hexValue) -verbose -ErrorAction 'Stop'

# Reset Explorer
Stop-Process -processname explorer

#####################################################################################################################################################
# Reboot System                                                                                                                                     #
#####################################################################################################################################################
Restart-Computer
