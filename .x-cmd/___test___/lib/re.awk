
END {

    testcase( "test: [:ip:]"   ,     test_ip_pattern() )
    testcase( "test: [:http:]" ,   test_http_pattern() )
    testcase( "test: [:https:]",  test_https_pattern() )
    testcase( "test: [:int:]"  ,    test_int_pattern() )
    testcase( "test: [:float:]",  test_float_pattern() )
}

# Section: range
function re_range_test( _pat ){
    _pat = "^" re_range(0, 65535) "$"

    for (i=0; i<=100000; ++i) {
        if (i<=65535)   testcase_assert(i ~ _pat,   sprintf("Exepct %s inside [0, 65535]", i))
        else            testcase_assert(i !~ _pat,  sprintf("Exepct %s outside [0, 65535]", i))
    }
    return true
}
# EndSection

# Section: IP Test
BEGIN{
    # print "abc" >"/Users/edwinjhlee/x-bash/awk/aaaaaa.txt"
    IP_PAT = re_patgen("[:ip:]")
}

function valid_ip( ip ){
    if (ip ~ IP_PAT) {
        return true
    }
    return testcase_panic( sprintf("Exepct %s as an invalid IP.", ip) )
}

function invalid_ip( ip ){
    if (ip !~ IP_PAT) {
        return true
    }

    return testcase_panic( sprintf("Exepct %s as a valid IP.", ip) )
}

function test_ip_pattern(   s ){
    valid_ip( "255.255.4.5"   )
    valid_ip( "255.255.255.6" )
    valid_ip( "255.255.255.255" )

    invalid_ip( "256.001.2.3")
    invalid_ip( "256.256.004.5")
    invalid_ip( "256.256.256.6")
    invalid_ip( "256.256.256.256")

    return 1
}
# EndSection


# Section: http https httpx
BEGIN{
    http_PAT = re_patgen("[:http:]")
    https_PAT = re_patgen("[:https:]")
    httpx_PAT = re_patgen("[:httpx:]")

}

function valid_http_url( http ){
    return testcase_assert( http ~ http_PAT, sprintf("Exepct %s as an invalid http url.", http)  )
}

function invalid_http_url( http ){
    return testcase_assert( http !~ http_PAT, sprintf("Exepct %s as an valid http url.", http)  )
}

function test_http_pattern(   s ){
    valid_http_url( "http://www.google.com" )
    invalid_http_url( ".google.com")
    return 1
}

function valid_https_url( https ){
    if (match(https, https_PAT)) return true
    return testcase_panic( sprintf("Exepct %s as a invalid https url.", https) )
}

function invalid_https_url( https ){
    if (https !~ https_PAT) return true
    return testcase_panic( sprintf("Exepct %s as an invalid http url.", https) )
}

function test_https_pattern(   s ){
    valid_https_url( "https://www.zhuanlan.com")

    invalid_https_url( "zhuanlan.zhihu.com/")

    return 1
}

# EndSection

# Section: string int float
BEGIN{
    int_PAT = re_patgen("[:int:]")
    float_PAT = re_patgen("[:float:]")
}

function valid_int( intnum ){
    return testcase_assert( match(intnum, int_PAT), sprintf("Exepct %s as an invalid int.", intnum) )
}

function invalid_int( intnum ){
    return testcase_assert( intnum !~ int_PAT, sprintf("Exepct %s as an valid int .", intnum) )
}

function test_int_pattern(   s ){
    valid_int( "666" )
    valid_int( "-66" )
    invalid_int( "0.666")
    return 1
}

function valid_float( floatnum ){
    return testcase_assert( match(floatnum, float_PAT), sprintf("Exepct %s as an valid float.", floatnum) )
}

function invalid_float( floatnum ){
    return testcase_assert( floatnum !~ float_PAT, sprintf("Exepct %s as an invalid float .", floatnum) )
}

function test_float_pattern(   s ){
    valid_float( "1.666" )
    valid_float( "-0.66" )
    # invalid_float("666")
    return 1
}


# EndSection

