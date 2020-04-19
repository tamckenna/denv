#!/usr/bin/env pwsh

#####################################################################################################################################################
# Disable UAC & set ExecutionPolicy to Unrestricted                                                                                                 #
#####################################################################################################################################################
reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

#####################################################################################################################################################
# Windows 10 Decrapifier Script (https://community.spiceworks.com/scripts/show/4378-windows-10-decrapifier-18xx-19xx)                               #
#####################################################################################################################################################
(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/tamckenna/denv/master/os/win/decrapifier.ps1', 'decrapifier.ps1')
./decrapifier.ps1 -clearstart -settingsonly
Remove-Item -Force decrapifier.ps1

#####################################################################################################################################################
# Re-enable several helpful Windows 10 Services in Registry                                                                                         #
#####################################################################################################################################################
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xbgm" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblGameSave" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xboxgip" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" /t REG_DWORD /f /v "Start" /d "3"

#####################################################################################################################################################
# Enable Developer Mode and Win32 long paths for NTFS                                                                                               #
#####################################################################################################################################################
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\FileSystem" /t REG_DWORD /f /v "LongPathsEnabled" /d "1"

#####################################################################################################################################################
# Install Chocolatey Package Manager (https://chocolatey.org/)                                                                                      #
#####################################################################################################################################################
powershell -c "iwr -useb chocolatey.org/install.ps1 | iex"
RefreshEnv

#####################################################################################################################################################
# Install Windows Features using Chocolatey                                                                                                         #
#####################################################################################################################################################
choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"
choco install -y Microsoft-Hyper-V-All --source="'windowsfeatures'"

#####################################################################################################################################################
# Install Applications using Chocolatey                                                                                                             #
#####################################################################################################################################################
echo "Installing Chocolatey apps..."
choco install 7zip git git-lfs openssh ssh-copy-id -y
choco install powershell-core -y --force
choco install docker-desktop -y
echo "Finished installing Chocolatey apps!"

#####################################################################################################################################################
# Install WSL Instance (Ubuntu 18.04)                                                                                                               #
#####################################################################################################################################################
aria2c -o Ubuntu.appx https://aka.ms/wsl-ubuntu-1804
Add-AppxPackage -Path Ubuntu.appx
Remove-Item -Force Ubuntu.appx
echo "Will need to reboot system to utilize WSL features"

#####################################################################################################################################################
# Configurations requiring running as Administrator                                                                                                 #
#####################################################################################################################################################
git config --system core.longpaths true
