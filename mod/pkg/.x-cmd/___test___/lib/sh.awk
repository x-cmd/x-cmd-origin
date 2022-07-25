BEGIN{
    a="a\033[36mb\033\001[0m$ccc\"ee'e\\"
    # a="aaac'cc"
    print a
    print "-----"
    print shqu1(a)
    print shuq1( shqu1(a) )
    print shqu(a)
    print shuq( shqu(a))
    print "-----"
    if ( a != shuq1( shqu1(a) )) {
        print a "=" shuq1( shqu1(a) ) " "
        print "shuq1 shqu1 error"
        exit(1)
    }
    if (a != shuq( shqu(a) )) {
        print a "=" shuq( shqu(a) ) " "
        print "shuq shqu error"
        exit(1)
    }
}