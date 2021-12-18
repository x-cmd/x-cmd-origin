

xrc awk

# DSL: json_get(_, ".b")

SSS="$(cat default.awk)$(cat json.awk)"

f1(){
    awk -v key="$1" "$SSS"'
    {
        jiter_print_exact(_, $0, json_handle_jpath( key ) )
    }
    '
}

f(){

{
    awk "$SSS
    {
        printf(\"%s\", json_to_machine_friendly(\$0) )
    }" | f1 .b
} <<A
{
    "a": 3,
    "b": [
        31,
        4,
        5,
        6,
        7,
        8
    ],
    "c": {
        "a": 1
    }
}
A
}

time f # >/dev/null

