

xrc awk

# awk -v data='abc
# ' 'END { print data; }' <<< ""

SSS="$(cat default.awk)$(cat json.awk jparse.awk jdict.awk)"


f(){
awk -v RS="\t" "$SSS"'

{
    # debug(\$0)
    data = $0
}

END{
    jparse_(data)
    print jdict_value2arr(_, jpath("1.2"), arr)
    print jpath(jpath("1.2"))
    for (i=1; i<=arr[L]; ++i) {
        print i ": "arr[i]
    }
    print jstr(_, jpath("1.2"))
    print jstr1(_, jpath("1.2"))
    print jstr0(_, jpath("1.2"))
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
