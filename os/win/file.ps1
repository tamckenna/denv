#!/usr/bin/env pwsh

#######################################################################################################
# Configure Default Editor                                                                            #
#######################################################################################################
$editor="`"${env:USERPROFILE}\scoop\apps\vscode\current\Code.exe`""
# $editor="`"${env:USERPROFILE}\scoop\apps\atom\current\atom.exe`""
# $editor="`"${env:USERPROFILE}\scoop\apps\sublime-text\current\sublime_text.exe`""
# $editor="`"${env:USERPROFILE}\scoop\apps\notepadplusplus\current\notepad++.exe`""

#######################################################################################################
# Configure/Set Editor for Unknown File Types                                                         #
#######################################################################################################
$key="Registry::HKEY_CLASSES_ROOT\Unknown\shell"
If (!(Test-Path $key)) { New-Item "$key" -Force ; }
Set-ItemProperty -Path "$key" -name '(Default)' -Value "editor"

$key = "Registry::HKEY_CLASSES_ROOT\Unknown\shell\editor\command"
If (!(Test-Path $key)) { New-Item "$key" -Force ; }
Set-ItemProperty -Path "$key" -name '(Default)' -Value "$editor `"%1`""

#######################################################################################################
# Configure/Set Editor for Textual File Types                                                         #
#######################################################################################################
$key = "Registry::HKEY_CLASSES_ROOT\Unknown\shell\Open\command"
If (!(Test-Path $key)) { New-Item "$key" -Force ; }
Set-ItemProperty -Path "$key"  -name '(Default)' -Value "$editor `"%1`""

#######################################################################################################
# Configure/Set Editor for Known Textual File Types                                                   #
#######################################################################################################
$filetypes = @("txtfile", "inifile", "xmlfile")
foreach ($filetype in $filetypes) {
    $key = (Join-Path (Join-Path Registry::HKEY_CLASSES_ROOT $filetype) shell\open\command)
    If (!(Test-Path $key)) { New-Item "$key" -Force }
    Set-ItemProperty -Path "$key"  -name '(Default)' -Value "$editor `"%1`""
}
