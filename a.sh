eval_multiple_single(){
    local s="$(eval "$1")"
    cat
    printf "%s\n" "$s"
}

eval_multiple(){
    case "$#" in
        0)      return 0 ;;
        1)      eval "$1" ;;
        2)      eval "$1" | eval_multiple_single "$2" ;;
        3)      eval "$1" | eval_multiple_single "$2" | eval_multiple_single "$3" ;;
        *)
                s='eval "$1"'
                local i
                for i in $(seq 2 $#); do
                    s="$s | eval_multiple_single \"\$$i\""
                done
                eval "$s"
    esac
}

# time eval_multiple 'git status' 'git config' 'git status' 'git branch' 'git status' 'git branch'

evalm2_(){
    if [ "$#" -eq 1 ]; then
        local s="$(eval "$1")"
        cat
        printf
    else
        local cmd="$1"; shift
        s="$(eval "$cmd" | evalm2_ "$@")"
        cat
        printf "%s" "$s"
    fi


}

evalm2(){

    case "$#" in
        0)      return ;;
        1)      eval "$1" ;;
        *)
                local cmd="$1"; shift
                eval "$cmd" | evalm2_ "$@" ;;
    esac

}

time evalm2 'git status' 'git config' 'git status' 'git branch' 'git status' 'git branch'

