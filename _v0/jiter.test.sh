

xrc awk

# DSL: json_get(arr, ".b")

SSS="$(cat default.awk)$(cat json.awk)"

f1(){
    awk "$SSS
    {
        if (\$0 != \"\") {
            jiter(arr, \$0)
            # print (\$0)
        }
    }
    END{
        print \"---\" arr[S q(1) S q(\"b\") S q(6) ]
        print(arr[ jkey(1, \"b\", 6) ])
        print jget(arr, \"1.b.6\")
        jget(arr, \".b.6\")
        jget(arr, \".c.a\")
    }
    "
}

f(){

{
    awk "$SSS
    {
        printf(\"%s\", json_to_machine_friendly(\$0) )
    }" | f1
} <<A
{
    "a": 3,
    "b": [
        3,
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

