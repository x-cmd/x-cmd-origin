

SSS="$(xrc cat awk/lib/default.awk awk/lib/json.awk awk/lib/jiter.awk)"


f1(){
awk "$SSS"'
{
    if ($0 != "") {
        jiparse(arr, $0)
    }
}

END{
    jdict_push(arr, S "\"" 1 "\"" S "\"" 2 "\"","\"d\"",9)
    print jstr1(arr)
    # jdict_rm(arr, jpath("1.2"), q("a"))
    # jlist_push(arr, jpath("1.2.b"),9)
    # jlist_rm(arr, jpath("1.2.b"), 6)
    # print( jkey(1, "b", 6) )
    # print ( jpath(".b.1"))
    # print("--- "  arr[ jpath("1.2.b.6") ])


    # print json_stringify_format(arr, ".", 6)
    # print json_stringify_machine(arr, "1.2.b")
    # print json_stringify_compact(arr, ".")
}
'
}
f(){

{
    awk "$SSS
    {
        printf(\"%s\", json_to_machine_friendly(\$0) )
    }" | f1
} <<A
[
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
