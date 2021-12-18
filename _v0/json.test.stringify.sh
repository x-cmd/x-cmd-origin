
___X_CMD_JSON_AWK_SRC="$(xrc cat awk/_v0/json.awk)"
___X_CMD_JSON_AWK_SRC="$(xrc cat awk/_v0/default.awk)
$___X_CMD_JSON_AWK_SRC
"


___json_awk_str_compact(){
    awk "$___X_CMD_JSON_AWK_SRC"'
{ jiter(_, $0) }
END{
    json_stringify_machine(_, )
}
'
}

