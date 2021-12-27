

xrc awk

# DSL: json_get(_, ".b")

SSS="$(cat default.awk)$(cat json.awk)"

f1(){
    awk "$SSS"'
    BEGIN{

    }
    {
        if ($0 != "") {
            # jiter(_, $0)
            jiter_exact(_, $0, "1.1")
            # print ($0)
        }
    }
    END{
        # print "---" _[S q(1) S q("b") S q(6) ]
        # print(_[ jkey(1, 2, "commit", "sha") ])
        # print jget(_, "1.1.name")
        # print jget(_, "1.a")
        # print jget(_, ".a")
        # print jget(_, ".c.a")
        # print json_stringify_machine(_, "1.1.commit")
        # print json_stringify_compact(_)
        print json_stringify_format(_, "1.1", 4)
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
    {
        "name": "v1.0.2",
        "message": "",
        "commit": {
            "sha": "17b952bbc9fa014ac33dc732510aaaa2d616c5eb",
            "date": "2021-08-01T10:44:41+00:00"
        }
    },
    {
        "name": "v1.0.0",
        "message": "",
        "commit": {
            "sha": "088ffaaf2808e34a4c108a5103e385ef5d853392",
            "date": "2021-08-01T07:32:52+00:00"
        }
    },
    {
        "name": "v1.0.1",
        "message": "",
        "commit": {
            "sha": "088ffaaf2808e34a4c108a5103e385ef5d853392",
            "date": "2021-08-01T07:32:52+00:00"
        }
    }
]
A
}

time f # >/dev/null

