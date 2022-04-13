{
    text = $0
    while (1) {
        match( text, "xrc[ \t]+(w|which|c|cat)[ \t]+[A-Za-z/0-9_-]+" )
        if (RLENGTH <= 0) {
            match( text, "xrc[ \t]+[A-Za-z/0-9_-]+" )
        }
       
        if (RLENGTH <= 0) break
        code = substr(text, RSTART, RLENGTH)
        gsub( "xrc[ \t]+((w|which|c|cat)[ \t]+)?", "", code )
        if (code !~ /^(cat|c|which|w|update|log|upgrade|cache|clear|debug|d)$/) {
            print code
        }

        text = substr(text, RSTART + RLENGTH)
    }
}
