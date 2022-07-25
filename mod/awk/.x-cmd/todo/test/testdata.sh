

xrc awk

SSS="$(xrc cat awk/lib/default.awk awk/lib/json.awk awk/lib/jiter.awk)"

f1(){
    awk "$SSS"'
    {
        jiparse_after_tokenize(_, $0)
    }
    END{
        # print jstr(_)
    }
    '
}

f(){
    x json data | f1
}

time (f)