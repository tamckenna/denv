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
scoop bucket add extras
scoop bucket add java
scoop bucket add jetbrains

#####################################################################################################################################################
# Install Scoop Apps                                                                                                                                #
#####################################################################################################################################################

# nix Utilities
powershell -c "scoop install curl wget grep sed less touch putty"

# Text Editors
powershell -c "scoop install vscode notepadplusplus sublime-text atom"

# CLI Utilities
powershell -c "scoop install psutils nano vim gh aws azure-cli"

# SDKs
powershell -c "scoop install dotnet-sdk adoptopenjdk-lts-hotspot python go nvm"

# Dependency/Build Tools
powershell -c "scoop install nuget nuget-package-explorer"
powershell -c "scoop install ant maven gradle"

# IDEs/SQL Editors
powershell -c "scoop install jetbrains-toolbox eclipse-jee"
powershell -c "scoop install azuredatastudio mysql-workbench dbeaver"

# Development Tools
powershell -c "scoop install github postman soapui xming windows-terminal libreoffice-stable winmerge"

# Browsers
powershell -c "scoop install googlechrome firefox firefox-developer chromium brave"
