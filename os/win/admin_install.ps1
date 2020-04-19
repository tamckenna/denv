#!/usr/bin/env pwsh

# Execute Decrapifier Powershell Script and remove after execution
(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/tamckenna/denv/master/os/win/decrapifier.ps1', 'decrapifier.ps1')
./decrapifier.ps1 -allusers -clearstart -settingsonly
Remove-Item -Force decrapifier.ps1

# Registry Edits
# Re-enable Xbox Windows Services
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xbgm" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblGameSave" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xboxgip" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /t REG_DWORD /f /v "Start" /d "3"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" /t REG_DWORD /f /v "Start" /d "3"

#Enable Developer Mode Windows 10
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

# Install Choclatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
RefreshEnv

# Install WSL: Ubuntu 18.04
choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx
RefreshEnv

# Configure/Patch WSL Instance
Ubuntu1804 install --root
Ubuntu1804 run apt update
Ubuntu1804 run apt upgrade -y
Ubuntu1804 run adduser $USER
