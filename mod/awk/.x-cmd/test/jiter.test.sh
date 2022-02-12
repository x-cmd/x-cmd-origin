

xrc awk

SSS="$(cat default.awk)$(cat json.awk jdict.awk jiparse.awk jiter.awk)"


f1(){
    awk "$SSS"'
    {
        pat[1] = q("1")
        patl=1

        if ($0 != "") {
            # jiter_print_rmatch($0, "commi", "", "\n")



            jiter_target_rmatch(_, $0, "comm")

            # print jiter_target_rmatch_val($0, "comm")

            # print ($0)
        }
    }
    END{
        for (i in _){
            print i "\t\t\t" _[i]
        }
        print jstr(_)
    }
    '
}

f(){
{
    awk "$SSS
    {
        printf(\"%s\", json_to_machine_friendly(\$0) )
    }" | f1
}<<A
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
        "aaa": {
            "a1": "www",
            "a2": "www",
            "a3": "www",
            "a4": "www",
            "a5": "www",
            "b1": ["eee1", "eee2"]
        },
        "name": "v1.0.1",
        "message": null,
        "commit": {
            "sha": "zz088ffaaf2808e34a4c108a5103e385ef5d853392",
            "date": "2021-08-01T07:32:52+00:00"
        }
    }
]
A
}

time f

