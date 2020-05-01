#!/bin/bash

bundleFile=os/mac/BaseBrewfile

replaceMe="REPLACE_ME_DEFAULT_EDITOR"
replaceMe="REPLACE_ME_DEFAULT_ARCHIVE_TOOL"
replaceMe="REPLACE_ME_DEFAULT_BROWSER"


editor=visual-studio-code
browser=google-chrome
archiver=keka

sed -i ""  "s/REPLACE_ME_DEFAULT_EDITOR/$editor/g" $bundleFile
sed -i ""  "s/REPLACE_ME_DEFAULT_BROWSER/$browser/g" $bundleFile
sed -i ""  "s/REPLACE_ME_DEFAULT_ARCHIVE_TOOL/$archiver/g" $bundleFile
