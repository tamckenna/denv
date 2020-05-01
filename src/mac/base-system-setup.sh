
# Disable SIP protection
csrutil disable

# Create aliases for flag removal
alias remove-all-flags='chflags nouchg,noschg,nouappnd,nosappnd,noopaque,dump,nohidden,norestricted,nosunlnk'
alias remove-all-flags-link='chflags -h nouchg,noschg,nouappnd,nosappnd,noopaque,dump,nohidden,norestricted,nosunlnk'
alias remove-all-flags-recursive='chflags -R nouchg,noschg,nouappnd,nosappnd,noopaque,dump,nohidden,norestricted,nosunlnk'

# Go to Mac Root Directory
cd "$ROOT_PATH"

# Remove macOS System Flags
remove-all-flags .
remove-all-flags .vol
remove-all-flags-recursive Applications
remove-all-flags-recursive Library
remove-all-flags-recursive System
remove-all-flags Users
remove-all-flags Volumes
remove-all-flags-recursive bin
remove-all-flags-recursive cores
remove-all-flags-recursive dev
remove-all-flags-link etc
remove-all-flags-recursive opt
remove-all-flags-recursive private
remove-all-flags-recursive sbin
remove-all-flags-link tmp
remove-all-flags-recursive usr
remove-all-flags-link var

# Re-enable SIP protection without FileSytem Protections
csrutil enable --without fs
