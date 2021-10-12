ffffff(){
    a=("$@")
}

ff(){

    local i

    echo "line: $COMP_LINE" >>aaa.txt

    local cur="${COMP_WORDS[COMP_CWORD]}"
    case "$cur" in
        \"*|\'*)    COMP_LINE=${COMP_LINE%$cur}
    esac

    local a
    eval ffffff $COMP_LINE
    for i in "${a[@]}"; do
        echo "1 * $i" >>aaa.txt
    done

    echo "${COMP_CWORDS}" >>aaa.txt
    for i in "${COMP_WORDS[@]}"; do
        echo "1 - $i" >>aaa.txt
    done

    COMPREPLY=(
        a1:123
        a2:123
        a3:123
    )

    $COMP_LINE


}

complete -F ff f

