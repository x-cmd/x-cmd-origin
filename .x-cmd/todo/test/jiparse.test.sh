

xrc awk

# DSL: json_get(_, ".b")

SSS="$(cat default.awk)$(cat json.awk jiter.awk)"

f1(){
    awk "$SSS"'
    {
        if ($0 != "") {
            jiparse(_, $0)
            # print ($0)
        }
    }
    END{
        # print jstr(_)
    }
    '
}

f2(){
    awk "$SSS
    {
        printf(\"%s\", json_to_machine_friendly(\$0) )
    }" | f1
}

f(){
    x json data 10 | f2
}

time (f)
