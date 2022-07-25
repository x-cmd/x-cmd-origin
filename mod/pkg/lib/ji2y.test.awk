END{

    json_split2tokenarr( obj, str ) # This is a problem

    for (i=1; i<=obj[L]; ++i) {
        ji2y( obj[i], "  ", aaa )
    }
}

{
    str = str "\n" $0
}
