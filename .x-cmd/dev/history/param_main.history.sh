
_param_main2() {
    {
        local scope
        local header

        local IFS
        read -r header scope

        if [ $header != "scope:" ]; then
            scope=
            # line 1: global types null
            printf "$PARAM_RS_SEP%s\n" "$header"
        else
            if [ -z "$scope" ]; then
                read -r scope
            fi

            # line 1: global types
            _param_type_print "${scope%%/*}"

            # line 2: config lines
            printf "$PARAM_RS_SEP"
        fi

        cat 
        
        # line 3: running argument lines
        IFS="$PARAM_ARG_SEP"          # ARG_SEP in awk script
        printf "$PARAM_RS_SEP%s$PARAM_RS_SEP" "$*"

        # line 4: default dict
        [ -n "$scope" ] && param_default dump_raw "$scope"
        # printf "%s" "$PARAM_RS_SEP"
    } | awk \
            -v ARG_SEP="$PARAM_ARG_SEP" \
            -v RS="$PARAM_RS_SEP" \
            -f "$PARAM_AWK_PATH"
}

_param_main1() {
    _param_get_scope1 | {
        local scope
        read -r scope

        # line 1: global types
        [ -n "$scope" ] && _param_type_print "${scope%%/*}"

        # line 2: config lines
        printf "$PARAM_RS_SEP"
        cat
        
        # line 3: running argument lines
        local IFS
        IFS="$PARAM_ARG_SEP"          # ARG_SEP in awk script
        printf "$PARAM_RS_SEP%s$PARAM_RS_SEP" "$*"

        # line 4: default dict
        [ -n "$scope" ] && param_default dump_raw "$scope"
        # printf "%s" "$PARAM_RS_SEP"
    } | awk \
            -v ARG_SEP="$PARAM_ARG_SEP" \
            -v RS="$PARAM_RS_SEP" \
            -f "$PARAM_AWK_PATH"
}

_param_get_scope1(){
    awk '
    {
        if ("scope:" == $1) {
            if ($2 != "") {
                print $2
            } else {
                getline
                print $1
            }
        } else {
            print $0
        }
    }'
}


_param_main() {
    {
        local src
        src="$(cat)"
        local scope
        scope="$(echo "$src" | _param_get_scope)"

        # echo "$src" >/dev/stderr
        # line 1: global types
        [ -n "$scope" ] && _param_type_print "${scope%%/*}"

        # line 2: config lines
        printf "$PARAM_RS_SEP%s$PARAM_RS_SEP" "$src"
        
        # line 3: running argument lines
        local IFS
        IFS="$PARAM_ARG_SEP"          # ARG_SEP in awk script
        printf "%s$PARAM_RS_SEP" "$*"

        # line 4: default dict
        [ -n "$scope" ] && param_default dump_raw "$scope"
        # printf "%s" "$PARAM_RS_SEP"
    } | awk \
            -v ARG_SEP="$PARAM_ARG_SEP" \
            -v RS="$PARAM_RS_SEP" \
            -f "$PARAM_AWK_PATH"
}

_param_get_scope(){
    awk '"scope:"==$1{
        if ($2 != "") {
            print $2
        } else {
            getline
            print $1
        }
        exit 0
    }'
}