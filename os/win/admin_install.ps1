#!/usr/bin/env pwsh

# Disable UAC & unrestrict ExecutionPolicy
reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

# Execute Decrapifier Powershell Script and remove after execution
(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/tamckenna/denv/master/os/win/decrapifier.ps1', 'decrapifier.ps1')
./decrapifier.ps1 -clearstart -settingsonly
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

# Install Chocolatey
powershell -c "iwr -useb chocolatey.org/install.ps1 | iex"
RefreshEnv

# Install Applications through Chocolatey
choco install 7zip git openssh -y
choco install powershell-core -y
choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"
choco install -y Microsoft-Hyper-V-All --source="'windowsfeatures'"
choco install docker-desktop -y
aria2c -o Ubuntu.appx https://aka.ms/wsl-ubuntu-1804
Add-AppxPackage -Path Ubuntu.appx
Remove-Item -Force Ubuntu.appx
RefreshEnv
