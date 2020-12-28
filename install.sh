#!/bin/bash

main() {
    ask_for_sudo
    ask_for_github_access
    install_xcode_command_line_tools
    clone_dotfiles_repo
    clone_mackup_repo
    run_dotfiles
}

DOTFILES_REPO=~/dotfiles
MACKUP_REPO=~/Mackup
GITHUB_USER=alxstu
GITHUB_TOKEN=

function ask_for_sudo() {
    info "Prompting for sudo password"
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; \
            sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
        success "Sudo password updated"
    else
        error "Sudo password update failed"
        exit 1
    fi
}

function ask_for_github_access() {
while true; do
    read -p "Enter github user token: " TOKEN
    GITHUB_TOKEN=$TOKEN
    break
done
} 

function install_xcode_command_line_tools() {
    info "Installing Xcode command line tools"
    if softwareupdate --history | grep --silent "Command Line Tools"; then
        success "Xcode command line tools already exists"
    else
        xcode-select --install
        read -n 1 -s -r -p "Press any key once installation is complete"

        if softwareupdate --history | grep --silent "Command Line Tools"; then
            success "Xcode command line tools installation succeeded"
        else
            error "Xcode command line tools installation failed"
            exit 1
        fi
    fi
}

function clone_dotfiles_repo() {
    info "Cloning dotfiles repository into ${DOTFILES_REPO}"
    if test -e $DOTFILES_REPO; then
        substep "${DOTFILES_REPO} already exists"
        pull_latest $DOTFILES_REPO
        success "Pull successful in ${DOTFILES_REPO} repository"
    else
        url=https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/dotfiles.git
        if git clone "$url" $DOTFILES_REPO && \
           git -C $DOTFILES_REPO remote set-url origin git@github.com:${GITHUB_USER}/dotfiles.git; then
            success "Dotfiles repository cloned into ${DOTFILES_REPO}"
        else
            error "Dotfiles repository cloning failed"
            exit 1
        fi
    fi
}

function clone_mackup_repo() {
    info "Cloning mackup repository into ${MACKUP_REPO}"
    if test -e $MACKUP_REPO; then
        substep "${MACKUP_REPO} already exists"
        pull_latest $MACKUP_REPO
        success "Pull successful in ${MACKUP_REPO} repository"
    else
        url=https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/mackup.git
        if git clone "$url" $MACKUP_REPO && \
           git -C $MACKUP_REPO remote set-url origin git@github.com:${GITHUB_USER}/mackup.git; then
            success "mackup repository cloned into ${MACKUP_REPO}"
        else
            error "mackup repository cloning failed"
            exit 1
        fi
    fi
}

function run_dotfiles() {
	${DOTFILES_REPO}/bootstrap.sh
}

function pull_latest() {
    substep "Pulling latest changes in ${1} repository"
    if git -C $1 pull origin master &> /dev/null; then
        return
    else
        error "Please pull latest changes in ${1} repository manually"
    fi
}

function coloredEcho() {
    local exp="$1";
    local color="$2";
    local arrow="$3";
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput bold;
    tput setaf "$color";
    echo "$arrow $exp";
    tput sgr0;
}

function info() {
    coloredEcho "$1" blue "========>"
}

function substep() {
    coloredEcho "$1" magenta "===="
}

function success() {
    coloredEcho "$1" green "========>"
}

function error() {
    coloredEcho "$1" red "========>"
}

main "$@"
