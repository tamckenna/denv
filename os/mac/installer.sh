#!/bin/bash

function caffeinate-mac-one-hour(){
    caffeinate -ismu -t 3600 >/dev/null 2>&1 &
}
function stop-caffeinate(){
    killall caffeinate >/dev/null 2>&1
}

caffeinate-mac-one-hour

cd $HOME/Desktop/denv && brew bundle

stop-caffeinate
