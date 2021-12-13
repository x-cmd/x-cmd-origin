

xrc awk

# awk -v data='abc
# ' 'END { print data; }' <<< ""

SSS="$(cat default.awk)$(cat json.awk)"


f(){
awk -v RS="\t" "$SSS"'

{
    # debug(\$0)
    data = $0
}

END{
    json_parse(data, arr)
    json_list_push(arr, ".b.")
    # print( jkey(1, "b", 6) )
    # print ( json_handle_jpath(".b.1"))
    # print("---"  arr[ jkey(1, "b", 6) ])


    print json_stringify_format(arr, ".", 6)
    # print json_stringify_machine(arr, ".b")
    print json_stringify_compact(arr, ".c")
}

' <<A
{
    "b": [
        3,
        4,
        5,
        6,
        7,
        8
    ],
    "a": 9,
    "c": {
        "c1": 12,
        "c2": {
            "c22": [
                3,
                4
            ]
        }
    }
}
A

}

time f
