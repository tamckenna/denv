#!/bin/bash

function get-current-computer-sleep-setting(){
    currentSleepConfig=`sudo systemsetup -getcomputersleep`
    removePhrase1="Computer Sleep: "
    removePhrase2="after "
    removePhrase3=" minutes"
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase1/}"`
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase2/}"`
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase3/}"`
    echo "$currentSleepConfig"
}

function get-current-disk-sleep-setting(){
    currentSleepConfig=`sudo systemsetup -getharddisksleep`
    removePhrase1="Hard Disk Sleep: "
    removePhrase2="after "
    removePhrase3=" minutes"
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase1/}"`
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase2/}"`
    currentSleepConfig=`printf '%s\n' "${currentSleepConfig//$removePhrase3/}"`
    echo "$currentSleepConfig"
}

function set-computer-sleep-setting(){
    sudo systemsetup -setcomputersleep "$1" > /dev/null
}

function set-disk-sleep-setting(){
    sudo systemsetup -setharddisksleep "$1" > /dev/null
}

function enable-do-not-disturb(){
    defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true
    defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturbDate -date "`date -u +\"%Y-%m-%d %H:%M:%S +0000\"`"
    killall NotificationCenter
}

function disable-do-not-disturb(){
    defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false
    killall NotificationCenter
}

startDiskSleep=`get-current-disk-sleep-setting`
startComputerSleep=`get-current-computer-sleep-setting`
set-disk-sleep-setting "Never"
set-computer-sleep-setting "Never"
enable-do-not-disturb

cd $HOME/Desktop/denv && brew bundle

set-disk-sleep-setting "$startDiskSleep"
set-computer-sleep-setting "$startComputerSleep"
disable-do-not-disturb
