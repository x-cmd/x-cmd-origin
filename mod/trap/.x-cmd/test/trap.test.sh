g(){
    trap 'echo hi' INT
    awk '{}'
    code=$?
    printf "%s" "$code"
    return $code
}

f(){
    trap ':' INT
    local a
    if ! a=$(g); then
        code=$?
        echo "--- $a $code"
    fi
    return 111

}

f