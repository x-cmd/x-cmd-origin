

xrc awk

# DSL: json_get(_, ".b")

SSS="$(cat default.awk)$(cat json.awk)"

f1(){
    awk "$SSS
    BEGIN{
        init_jiter_()
    }
    {
        if (\$0 != \"\") {
            jiter_(\$0)
            # print (\$0)
        }
    }
    END{
        print \"---\" _[S q(1) S q(\"b\") S q(6) ]
        print(_[ jkey(1, \"b\", 6) ])
        print jget(_, \"1.b.6\")
        print jget(_, \"1.a\")
        print jget(_, \".b.6\")
        print jget(_, \".c.a\")
        print json_stringify_machine(_, \".b\")
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

