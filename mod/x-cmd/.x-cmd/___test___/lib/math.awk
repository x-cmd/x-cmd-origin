END {
    testcase( "test: abs",          test_abs() )
    testcase( "test: min/max",      test_minmax() )
    testcase( "test: round/trunc",  test_round() )
    testcase( "test: floor/ceil",  test_floorceil() )
}

function test_abs() {
    for (i=1; i<=65536; ++i) {
        testcase_assert( math_abs( i ) == math_abs( -i ), sprintf("Expect abs(%s) == abs(%s)", i, -i))
    }
}

# Section: min max
function order( a, b ) {
    testcase_assert( math_min( a, b ) == a + b - math_max(a, b), sprintf("Test for min/max fail: %s %s", a, b))
}

function test_minmax() {
    order(-65535, 65535)
    order(-65535, 0)
    order(-65535, 1)
    order(0, 1)
    order(1, 65535)
    for (i=1; i<10; ++i) {
        order( i, i + i )
        order( - ( i + i ), -i )
    }
}
# EndSection

# Section: round
function roundtrunc( a ) {
    # testcase_assert( math_trunc( a ) + 1 == math_round( a ), sprintf("Expect math_trunc(%s) == math_round(%s) + 1", a, a) );
    # testcase_assert( math_trunc( -a ) == math_round( -a ) + 1, sprintf("Expect math_trunc(%s) + 1 == math_round(%s)", -a, -a) );
}

function roundtrunc_eq( a ) {
    testcase_assert( math_trunc( a )  == math_round( a ), sprintf("Expect math_trunc(%s) == math_round(%s)", a, a) )
    testcase_assert( math_trunc( -a ) == math_round( -a ), sprintf("Expect math_trunc(%s) == math_round(%s)", -a, -a) )
}

function test_round() {
    for (i=1; i<100; ++i) {
        for (j=0.5; j<0.9; j+=0.1) roundtrunc(i + j)
        for (j=0.1; j<0.5; j+=0.1) roundtrunc_eq(i + j)
    }
}
# EndSection


# Section: floor/ceil
function floorceil( a ) {
    testcase_assert( math_floor( a ) + 1 == math_ceil( a ),     sprintf("Expect math_floor(%s) == math_ceil(%s) + 1", a, a) )
    testcase_assert( math_floor( -a ) + 1 == math_ceil( -a ),   sprintf("Expect math_floor(%s) + 1 == math_ceil(%s)", -a, -a) )
}

function test_floorceil() {
    for (i=1; i<100; ++i) {
        for (j=0.1; j<0.9; j+=0.1) floorceil(i + j)
    }
}
# EndSection
