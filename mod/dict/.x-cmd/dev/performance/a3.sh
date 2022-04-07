# If we cannot found a way to get rid of 2>, then we will be

o=echo
f(){
    command -v "$o" 2>/dev/null && "$o" hi
    # printf "${o#ec}"
}

f load


fff(){
    for i in $(seq 100000); do
        f is_empty
    done >/dev/null
}


fff
