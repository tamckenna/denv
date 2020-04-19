#!/usr/bin/env pwsh

# Install Scoop
iwr -useb get.scoop.sh | iex
scoop install aria2
scoop install curl grep sed less touch sudo

sudo powershell -c "iwr -useb raw.githubusercontent.com/tamckenna/denv/master/os/win/admin_install.ps1 | iex"
RefreshEnv

# Install more scoop applications
scoop bucket add extras
scoop bucket add java
scoop install gow putty windows-terminal ssh-copy-id
scoop install vscode azuredatastudio notepadplusplus sublime-text atom
scoop install jetbrains-toolbox eclipse-jee
scoop install dotnet-sdk nuget nuget-package-explorer
scoop install adoptopenjdk-lts-hotspot
scoop install ant maven gradle
scoop install python
scoop install aws azure-cli
scoop install googlechrome firefox firefox-developer brave chromium
scoop install libreoffice-stable winmerge
scoop install github gh postman soapui xming
scoop install dbeaver mysql-workbench
scoop install psutils nano vim