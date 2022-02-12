gt.repo.list(){
    command -v emulate 1>/dev/null && {
        emulate bash
        trap RETURN "emulate off"
    }
    emulate bash
    @src.run gitee/index.bash gt.repo.list "$@"
    emulate off
}

f(){
    command -v emulate 1>/dev/null && {
        emulate bash
        trap "emulate off" return 
    }
    local a=(1 2 3)
    echo "${a[1]}"
}
