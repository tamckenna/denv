# .bashrc file

# Custom Bash Profile for macOS Catalina(10.15.4)
    export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
    export BASH_SILENCE_DEPRECATION_WARNING=1
    export CLICOLOR=1
    export LSCOLORS=ExFxBxDxCxegedabagacad

# Custom Environment Variables
    # export JAVA_HOME=/opt/java/jdk
    # export PATH=$JAVA_HOME/bin:$PATH

# #Functions
    ffr() { find . -name "$1" 2>/dev/null ; }
    # enable-nvm(){ export NPM_CONFIG_PREFIX=$HOME/.npm-global && export PATH=$NPM_CONFIG_PREFIX/bin:$PATH && export NVM_DIR="$HOME/.nvm" && source $NVM_DIR/nvm.sh && source $NVM_DIR/bash_completion ; }
    enable-nvm(){ export NVM_DIR="$HOME/.nvm" && source $NVM_DIR/nvm.sh && source $NVM_DIR/bash_completion ; }
    status-docker() { dResp=$(docker ps 2>&1) ; if [[ $dResp == *"Cannot connect to the Docker daemon"* ]] || [[ $dResp == *"Error response from daemon"* ]]; then return 1 ; fi ; return 0 ; }
    kill-container() { if status-docker ; then docker stop "$1" > /dev/null 2>&1 ; docker rm "$1" > /dev/null 2>&1 ; fi ; }
    convert-icns-to-png() { sips -s format png $1 --out $1.png ; }
    get-app-id(){ osascript -e "id of app \"${1}\"" ; }
    set-default-app(){ appId=`get-app-id "$1"` && duti -s "$appId" "$2" all ; }
    create-python-venv(){
        export PYENV_ROOT="$HOME/.pyenv" && export PATH="$PYENV_ROOT/bin:$PATH" && \
            if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)" ; fi && \
            pyenv install -s $1 && pyenv global $1 && pip install virtualenv && \
            virtualenv .env && . .env/bin/activate
    }
    install-portable-vscode(){
        initialDir=$PWD && cd /tmp && wget https://update.code.visualstudio.com/latest/darwin/stable
        unzip -q stable && rm -f stable && mv Visual\ Studio\ Code.app PortableCode.app
        mkdir -p $HOME/Applications/msft/code-portable-data && rm -rf $HOME/Applications/msft/PortableCode.app
        mv PortableCode.app $HOME/Applications/msft && cd $initialDir
    }

# Custom Aliases
    alias la='ls -al'
    alias sysinfo='sw_vers'
    alias update-docker-images='docker run -d --rm -it -v "/var/run/docker.sock:/var/run/docker.sock:rw" tmckenna/maintainer:verbose'
    alias upgrade='brew update && brew upgrade && brew cask upgrade && brew cleanup && update-docker-images'
    alias senv='env | sort'
    alias xcode='open /Applications/Xcode.app'
    alias reset-dns='sudo killall -HUP mDNSResponder'
    alias remount='sudo mount -uw / && sudo killall Finder'
    alias kill-java="killall -9 java"
    alias list-ec2="aws ec2 describe-instances --output text --query 'Reservations[].Instances[].[Tags[?Key==\`Name\`].Value]'"
    alias msft-update='open /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app'
    alias stop-docker='killall Docker'
    alias start-docker='open /Applications/Docker.app'
    alias restart-docker='stop-docker && start-docker'
    alias init-git='git init && git add . && git commit -m "Initial Commit" && git remote add origin '
    alias portable-code="$HOME/Applications/msft/PortableCode.app/Contents/Resources/app/bin/code"
    alias 3.8pyenv='create-python-venv 3.8.2'
    alias 3.7pyenv='create-python-venv 3.7.7'
    alias 2.7pyenv='create-python-venv 2.7.17'
