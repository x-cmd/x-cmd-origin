o=echo
f(){

    case "$1" in
        new | \
        del | \
        make | \
        free | \
        get | \
        put | \
        scope | \
        remove | \
        clear | \
        drop | \
        dropr | \
        grep | \
        grepr | \
        iter | \
        load | \
        load_json | \
        dump | \
        json | \
        size | \
        has | \
        is_empty | \
        _x_cmd_advise_json)     "$o" "$1" ;;
        ""|help)                : help ;;
        *)                      : help ;;
    esac
}

f load


fff(){
    for i in $(seq 100000); do
        f is_empty
    done >/dev/null
}


fff
