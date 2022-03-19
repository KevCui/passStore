#!/usr/bin/env bash
#
# A command-line password store on your local machine
#
#/ Usage:
#/   ./passStore.sh [-a] [-u] [-p] [-h|--help]
#/
#/ Options:
#/   -a                      add new credential
#/   -u                      display selected username
#/   -p                      display selected password
#/   -h | --help             display this help message

set -e
set -u

usage() {
    printf "%b\n" "$(grep '^#/' "$0" | cut -c4-)" && exit 1
}

print_info() {
    # $1: info message
    [[ -z "${_LIST_LINK_ONLY:-}" ]] && printf "%b\n" "\033[32m[INFO]\033[0m $1" >&2
}

print_warn() {
    # $1: warning message
    [[ -z "${_LIST_LINK_ONLY:-}" ]] && printf "%b\n" "\033[33m[WARNING]\033[0m $1" >&2
}

print_error() {
    # $1: error message
    printf "%b\n" "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

command_not_found() {
    # $1: command name
    print_error "$1 command not found!"
}

set_command() {
    _FZF="$(command -v fzf)" || command_not_found "fzf"
    _OPENSSL="$(command -v openssl)" || command_not_found "openssl"
}

set_var() {
    [[ -z "${PASSSTORE_KEY:-}" ]] && print_error "Please set global variable:\nexport PASSSTORE_KEY=<path_to_symmetric_keyfile>"
    _SCRIPT_PATH=$(dirname "$(realpath "$0")")
    _CREDENTIAL_LIST="${_SCRIPT_PATH}/.credential.list"
    _SELECTED_USERNAME="${_SCRIPT_PATH}/.username.selected"
    _SELECTED_PASSWORD="${_SCRIPT_PATH}/.password.selected"
    touch "$_CREDENTIAL_LIST"
    touch "$_SELECTED_USERNAME"
    touch "$_SELECTED_PASSWORD"
}

set_args() {
    expr "$*" : ".*--help" > /dev/null && usage
    while getopts ":hpua" opt; do
        case $opt in
            a)
                _ADD_CREDENTIAL=true
                ;;
            u)
                cat "${_SELECTED_USERNAME:-}"
                exit 0
                ;;
            p)
                decrypt "$(cat "${_SELECTED_PASSWORD:-}")"
                exit 0
                ;;
            h)
                usage
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
        esac
    done
}

check_command_status() {
    # $1: command execution status code
    if [[ "$1" == "1" ]]; then
        print_error "Execution aborted!"
    fi
}

encrypt() {
    #1: secret string
    "$_OPENSSL" enc -aes-128-cbc -pbkdf2 -a -A -salt -k "${PASSSTORE_KEY:-}" <<< "$1"
    check_command_status "$?"
}

decrypt() {
    #1: encrypted string
    "$_OPENSSL" enc -aes-128-cbc -pbkdf2 -a -d -salt -k "${PASSSTORE_KEY:-}" <<< "$1"
    check_command_status "$?"
}

select_password() {
    local s
    s="$("$_FZF" < "$_CREDENTIAL_LIST")"
    awk -F '❚' '{print $2}' <<< "$s" > "$_SELECTED_USERNAME"
    ep="$(awk -F '❚' '{print $3}' <<< "$s" | tee "$_SELECTED_PASSWORD")"
    decrypt "$ep"
}

add_password() {
    local s u p ep
    read -rp $'\e[34mSite:\e[0m ' s
    read -rp $'\e[34mUsername:\e[0m ' u
    read -srp $'\e[34mPassword:\e[0m ' p
    ep="$(encrypt "$p")"
    echo "${s}❚${u}❚${ep}" >> "$_CREDENTIAL_LIST"
}

main() {
    set_var
    set_command
    set_args "$@"

    if [[ -z ${_ADD_CREDENTIAL:-} ]]; then
        select_password
    else
        add_password
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
