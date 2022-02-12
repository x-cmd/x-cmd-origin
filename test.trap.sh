
function trap_abc(){
    trap 'printf "%s" "Caught by: abc"' SIGINT
    cat
    echo "|abc: $?|"
}

function trap_bcd(){
    trap 'printf "%s" "Caught by: bcd"' SIGINT
    cat
    echo "|bcd: $?|"
}

trap_abc | trap_bcd



