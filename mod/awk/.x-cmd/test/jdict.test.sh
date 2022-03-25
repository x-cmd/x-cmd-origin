

xrc awk

# awk -v data='abc
# ' 'END { print data; }' <<< ""

SSS="$(cat default.awk)$(cat json.awk jparse.awk)"


f(){
awk -v RS="\t" "$SSS"'

{
    data = $0
}

END{
    jparse(data, _)
    # print jdict_value2arr(_, jpath("1.2"), arr)
    # for (i=1; i<=arr[L]; ++i) {
    #     print i ": "arr[i]
    # }
    jdict_push(_, jpath("1.2"), q("d"), "122")
    jdict_rm(_, jpath("1.2"), q("a"))

    arrlen = jdict_grep_to_arr(_, "1.2.c", "{", arr)
    # arrlen = jgrep_to_arr(_, "1.2.c", "c", arr)
    for(i=1; i<=arrlen; ++i){
        print arr[i]
    }

    # print jstr(_)
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
    },
    "e": [
        {"sha":"17b952bbc9fa014ac33dc732510aaaa2d616c5eb","date":"2021-08-01T10:44:41+00:00"},
        {"sha":"088ffaaf2808e34a4c108a5103e385ef5d853392","date":"2021-08-01T07:32:52+00:00"},
        {"sha":"zz088ffaaf2808e34a4c108a5103e385ef5d853392","date":"2021-08-01T07:32:52+00:00"}
    ]
}
]
A

}

time (f)
