# shellcheck shell=zsh

___advise_run(){
    local COMP_WORDS=("${words[@]}")
    local COMP_CWORD="$(( ${#words[@]}-1 ))"

    [ -z "$___ADVISE_RUN_CMD_FOLDER" ] && ___ADVISE_RUN_CMD_FOLDER="$___X_CMD_ADVISE_TMPDIR"

    local ___ADVISE_RUN_FILEPATH_;  ___advise_run_filepath_ "${1:-${COMP_WORDS[1]}}" || return 1

    local candidate_arr
    local candidate_exec
    local candidate_exec_arr
    local _message_str

    # Used in `eval "$candidate_exec"`
    local cur="${COMP_WORDS[COMP_CWORD+1]}"
    local offset

    eval "$(___advise_get_result_from_awk "$___ADVISE_RUN_FILEPATH_")" 2>/dev/null
    local IFS=$'\n'
    eval "$candidate_exec" 2>/dev/null

    [ -z "$candidate_arr" ] || _describe 'commands' candidate_arr
    [ -z "$candidate_exec_arr" ] || _describe 'commands' candidate_exec_arr
    [ -z "$_message_str" ] || _message -r "$_message_str"
}
