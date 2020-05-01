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

startDiskSleep=`get-current-disk-sleep-setting`
startComputerSleep=`get-current-computer-sleep-setting`
set-disk-sleep-setting "Never"
set-computer-sleep-setting "Never"

cd $HOME/Desktop/denv && brew bundle

set-disk-sleep-setting "$startDiskSleep"
set-computer-sleep-setting "$startComputerSleep"
