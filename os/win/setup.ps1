#!/usr/bin/env pwsh

#####################################################################################################################################################
# Install Scoop Package Manager (https://github.com/lukesampson/scoop)                                                                              #
#####################################################################################################################################################
iwr -useb get.scoop.sh | iex
scoop install aria2 sudo

#####################################################################################################################################################
# Execute admin install script as an Administrator                                                                                                  #
#####################################################################################################################################################
sudo powershell -c "iwr -useb raw.githubusercontent.com/tamckenna/denv/master/os/win/admin_install.ps1 | iex"
RefreshEnv

#####################################################################################################################################################
# Add Commonly used Scoop buckets                                                                                                                   #
#####################################################################################################################################################
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

# IDEs/SQL Editors
scoop install jetbrains-toolbox eclipse-jee
scoop install azuredatastudio mysql-workbench dbeaver

# Development Tools
scoop install github postman soapui xming windows-terminal libreoffice-stable winmerge

# Browsers
scoop install googlechrome firefox firefox-developer chromium brave
