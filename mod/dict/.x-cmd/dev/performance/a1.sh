f(){
    case "$1" in
        new)                    echo "$1" ;;
        del)                    echo "$1" ;;
        make)                   echo "$1" ;;
        free)                   echo "$1" ;;
        get)                    echo "$1" ;;
        put)                    echo "$1" ;;
        scope)                  echo "$1" ;;
        remove)                 echo "$1" ;;
        clear)                  echo "$1" ;;
        drop)                   echo "$1" ;;
        dropr)                  echo "$1" ;;
        grep)                   echo "$1" ;;
        grepr)                  echo "$1" ;;
        iter)                   echo "$1" ;;
        load)                   echo "$1" ;;
        load_json)              echo "$1" ;;
        dump)                   echo "$1" ;;
        json)                   echo "$1" ;;
        size)                   echo "$1" ;;
        has)                    echo "$1" ;;
        is_empty)               echo "$1" ;;
        _x_cmd_advise_json)     echo "$1" ;;
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
