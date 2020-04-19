#!/usr/bin/env pwsh

# Execute Decrapifier Powershell Script
(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/tamckenna/denv/master/os/win/decrapifier.ps1', 'decrapifier.ps1')
./decrapifier.ps1 -allusers -clearstart -settingsonly
Remove-Item -Force decrapifier.ps1

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"

#--- Ubuntu ---
# TODO: Move this to choco install once --root is included in that package
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx
# run the distro once and have it install locally with root user, unset password

RefreshEnv
Ubuntu1804 install --root
Ubuntu1804 run apt update
Ubuntu1804 run apt upgrade -y
Ubuntu1804 run adduser $
