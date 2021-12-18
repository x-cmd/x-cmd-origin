

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
    json_dict_push(arr, S "\"" 1 "\"" S "\"" 2 "\"","\"d\"",9)
    json_list_push(arr, json_handle_jpath("1.2.b"),9)
    # print( jkey(1, "b", 6) )
    # print ( json_handle_jpath(".b.1"))
    # print("---"  arr[ jkey(1, "b", 6) ])


    print json_stringify_format(arr, ".", 6)
    print json_stringify_machine(arr, "1.2.b")
    print json_stringify_compact(arr, ".")
}

' <<A
[
    { "a": 1, "b": 2, "c": 3 },
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
            "c21": 12,
            "c22": [
                3,
                4
            ]
        }
    }
}
]
A

}

time f
