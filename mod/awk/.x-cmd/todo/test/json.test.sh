
xws install
SSS="$(xrc cat awk/lib/default.awk awk/lib/json.awk awk/lib/jiter.awk)"


f1(){
awk "$SSS"'
{
    if ($0 != "") {
        jiparse(obj, $0)
    }
}

END{
    # jdict_put(obj, jpath(1.2), jqu("d"), 9)
    # jlist_put(obj, jpath("1.2.b"), "aaa")
    # jlist_rm(obj, jpath("1.2.b"), 6)
    # print jstr0(obj, "", "\t")
    # print jlist_join( "\t", obj, jpath("1.2.b"), "1:3:2")
    # print obj[ SUBSEP jqu("1") SUBSEP jqu("2") SUBSEP jqu("d") ]
    # print jget(obj, "2.b")
    # print jtokenize(jstr0(obj, "", "\t"))
    # print jtokenize_trim(jstr0(obj, "", "\t"))

    # print json_jpaths2arr(obj)
    # jdict_rm(obj, jpath("1.2"), q("a"))
     jlist_put(obj, jpath("1.2.b"),9)
    # jlist_rm(obj, jpath("1.2.b"), 6)
    #  print( jkey(1, "b", 6) )
    # print ( jpath(".b.1"))
    # print("--- "  obj[ jpath("1.2.b.6") ])

    # print jdict_value2arr(obj,jpath("2.c",arr))
    # print json_stringify_compact(obj, ".")
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

A

}

time f
