f(){
    echo 1
}

ff(){
    for i in `seq 10000`; do
        eval f
    done >/dev/null
}

ff
