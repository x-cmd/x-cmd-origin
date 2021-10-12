f(){
    COMPREPLY=(
        aaa
        bbb
        ccc
    )
}

alias fff=f

complete -F "f" ff
