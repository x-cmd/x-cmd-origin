
___X_CMD_JSON_AWK_SRC="$(xrc cat awk/lib/json.awk)"
___X_CMD_JSON_AWK_SRC="$(xrc cat awk/lib/default.awk)
$___X_CMD_JSON_AWK_SRC
"


___json_awk_str_compact(){
    awk "$___X_CMD_JSON_AWK_SRC"'
{ jiparse(_, $0) }
END{
    json_stringify_machine(_, )
}
'
}

