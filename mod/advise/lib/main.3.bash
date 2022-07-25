# shellcheck disable=SC2207
# Section : main
___advise_run(){
    [ -z "$___ADVISE_RUN_CMD_FOLDER" ] && ___ADVISE_RUN_CMD_FOLDER="$___X_CMD_ADVISE_TMPDIR"

    local ___ADVISE_RUN_FILEPATH_;  ___advise_run_filepath_ "${1:-${COMP_WORDS[0]}}" || return 1

    local candidate_arr
    local candidate_exec
    local candidate_exec_arr

    # Used in `eval "$candidate_exec"`
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local offset

    eval "$(___advise_get_result_from_awk)" 2>/dev/null
    local IFS=$'\n'
    eval "$candidate_exec" 2>/dev/null

    IFS=$' '$'\t'$'\n'
    COMPREPLY=(
        $(
            compgen -W "${candidate_arr[*]} ${candidate_exec_arr[*]}" -- "$cur"
        )
    )

    __ltrim_completions "$cur" "@"
    __ltrim_completions "$cur" ":"
    __ltrim_completions "$cur" "="
}
## EndSection
