# .kshrc file

# Default Korn Shell PS1 prompt
export PS1='$(whoami)@$(hostname -s):$(pwd | sed "s,^$HOME,~,")$ '
