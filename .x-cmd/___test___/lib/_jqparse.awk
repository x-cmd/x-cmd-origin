BEGIN{
    obj[1] = 1
}

{
    jqparse_str( obj, "hi", $0 )
    print "hi"
    print obj[ "hi", "\"1\"", "\"a\"" ]
    print obj[ "hi", "\"1\"", "\"c\"", "\"d\"" ]
}
