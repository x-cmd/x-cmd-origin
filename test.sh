
# The last argument is

if [ -z "$BASH_VESRION" ]; then

f(){
    X_VAR=
    local lastargument
    lastargument="${@:-1:1}"
    case "$lastargument" in
        =*)
            X_VAR="${lastargument#=}"
            printf "%s" 'set -- "${@:1:$(($#-1))}"'
            ;;
    esac
}

else

# handle
f(){
    X_VAR=
    local lastargument
    lastargument="$(eval printf "%s" "\$$#")"
    case "$lastargument" in
        =*)
            X_VAR="${lastargument#=}"
            local code="set --"
            local i=1
            while [ "$i" -lt $# ]; do
                code="$code \"$i\""
                i=$((i+1))
            done
            printf "%s" "$code"
            ;;
    esac
}

fi



