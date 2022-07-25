
END{
    if (TESTC_EXIT_CODE != "") {
        exit( TESTC_EXIT_CODE )
    }
}

function testcase_panic( errmsg ){
    print( errmsg ) > "/dev/stderr"
    exit(1)
    return 0
}

function testcase( description, ok ){
    if ((ok != "") && (ok != 1)) {
        TESTC_EXIT_CODE = 1
        testcase_panic( errmsg )
        return 0
    }
    return 1
}

function testcase_assert( ok, errmsg ){
    if (ok != true) {
        TESTC_EXIT_CODE = 1
        if (errmsg != "") {
            testcase_panic( errmsg )
        } else {
            testcase_panic( ok )
        }
        return 0
    }
    return 1
}
