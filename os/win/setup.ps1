#!/usr/bin/env pwsh

# Install Scoop
iwr -useb get.scoop.sh | iex
scoop install aria2
scoop install curl grep sed less touch sudo

sudo powershell -c "iwr -useb raw.githubusercontent.com/tamckenna/denv/master/os/win/admin_install.ps1 | iex"
RefreshEnv
