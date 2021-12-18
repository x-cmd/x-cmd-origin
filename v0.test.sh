
# Section: json facility using awk

___X_CMD_JSON_AWK_SRC="$(xrc cat awk/_v0/json.awk)"
___X_CMD_JSON_AWK_SRC="$(xrc cat awk/_v0/default.awk)
$___X_CMD_JSON_AWK_SRC
"

___json_awk_end(){
    local func=jiter_after_tokenize
    if [ -n "$ALREADY_TOKENIZED" ]; then
        func=jiter
    fi

        awk "$___X_CMD_JSON_AWK_SRC
{ $func(_, \$0); }
$1"

}

___json_awk_tokenize(){
    awk "$___X_CMD_JSON_AWK_SRC"'
{
    printf(jtokenize($0))
}
'
}

___json_awk_tokenize_trim(){
    awk "$___X_CMD_JSON_AWK_SRC"'
{
    printf(jtokenize_trim($0))
}
'
}

___json_awk_parse_flat_stream(){
    awk "$___X_CMD_JSON_AWK_SRC"'
{ jiter(arr, $0) }
END{
    print jget(arr, "3.1.id")
    print jget(arr, "1.1.full_name")
}
'
}

___json_awk_print_exact(){
    awk -v key="$1" "$___X_CMD_JSON_AWK_SRC"'

BEGIN{
    key = json_handle_jpath( key )
}
{
    jiter_print_exact_after_tokenize(_, $0, key)
}
'
}

___json_awk_parse_flat_stream1(){
    awk "$___X_CMD_JSON_AWK_SRC"'
{ jiter_($0) }
END{
    print jget(_, "3.1.id")
    print jget(_, "1.1.full_name")
}
'
}

___json_awk_parse_stream(){
    awk "$___X_CMD_JSON_AWK_SRC"'
{ jiter_after_tokenize(jobj, $0) }
END{
    print jget(jobj, "3.1.id")
}
'
}

___json_awk_parse(){
    awk -v RS="$(printf "\001")" "$___X_CMD_JSON_AWK_SRC"'
{ r = $0 }
END{
    json_parse(r, jobj)
    print jget(jobj, "3.1.id")
}
'
}

___json_awk_parse_flat(){
    awk -v RS="$(printf "\001")" "$___X_CMD_JSON_AWK_SRC"'
{ r = $0 }
END{
    ___json_parse(r, jobj)
    print jget(jobj, "3.1.id")
}
'
}

# EndSection
