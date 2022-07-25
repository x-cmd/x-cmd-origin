
END {
    testcase_assert( test_arr_basic(), "basic")
    testcase_assert( test_arr_pushpop(), "push/pop")
    testcase_assert( test_arr_shiftunshift(),"shift/unshift")
    testcase_assert(test_arr_clone(), "clone" )
    testcase_assert(test_arr_join(), "join")
}

# Section: basic
function test_arr_basic(num,    i){
    for (i=1; i<=10; i+=3){
        test_arr_basic_( i )
    }
    return true
}

function test_arr_basic_(num,      _a1, _a2, j, i){
    for (i=1; i<=num; i+=2)  _a1[++j] = i
    _a1[ L ] = j
    arr_seq(_a2, 1, 2, num)
    testcase_assert( arr_eq( _a1, _a2 ), sprintf("Basic Expect arr _a1 == _a2") )
    testcase_assert( arr_len( _a2 ) == int((num-1)/2)+1,
        sprintf("Basic Expect len of seq(1, 2, %s) is %s", num, int((num-1)/2)+1) )
}
# EndSection

# Section: push/pop
function test_arr_pushpop(num,    i){
    for (i=1; i<=10; i+=3){
        test_arr_pushpop_( i )
    }
    return true
}

function test_arr_pushpop_( num,     _a, _b, _c, _d, _f, i){
    arr_seq(_a, 1, 1, num)

    for (i=num; i >= 1; --i) {
        testcase_assert( arr_pop( _a ) == i,
            sprintf("Expect pop() == %s", i) )
    }

    arr_seq(_f, 1, 1, num)
    testcase_assert( _f[1] == 1, "Pop Expect arr[1] == 1" )
    testcase_assert( _f[ arr_len(_f) ] == num, sprintf("Expect tail to be %s", num) )


    for (i=1; i<=5 ; ++i) arr_push( _d, i )
    arr_seq(_c, 1, 1, 5)

    testcase_assert( arr_eq(_c, _d ),
        "Push Expect to be seq(10) after push" )
 }

# EndSection

# Section: shift/unshift
function test_arr_shiftunshift(num,    i){
    for (i=1; i<=10; i+=3){
        test_arr_shiftunshift_( i )
    }
    return true
}

function test_arr_shiftunshift_(num,         _a, _b, _c, _d){
    arr_seq(_a, 1, 1, 10)
    arr_seq(_b, 3, 1,  10)
    arr_shift( _a, 2)
    testcase_assert( arr_eq( _a, _b ), "Shift Expect array _a == _b")


    arr_seq(_c, 2, 1, 10)
    arr_seq(_d, 1, 1,  10)
    arr_unshift( _c, 1)
    testcase_assert( arr_eq( _c, _d ), "Unshift Expect array _c == _d")
}
# EndSection

# Section: clone
function test_arr_clone(num,    i){
    for (i=1; i<=10; i+=3){
        test_arr_clone_( i )
    }
    return true
}

function test_arr_clone_( num, _a1, _a2, i ){
    arr_seq(_a1, 1, 1, num)
    arr_clone( _a1, _a2 )

    testcase_assert( arr_eq( _a1, _a2 ),
        "Clone Expect array _a1 == _a2" )

    _a1[1] = _a1[1]+1
    testcase_assert( ! arr_eq( _a1, _a2 ),
        "Clone Expect array _a1 != _a2" )
}
# EndSection

#Section: join
function test_arr_join(num,    i){
    for (i=1; i<=10; i+=3){
        test_arr_join_( i )
    }
    return true
}

function test_arr_join_( num, _a1, _a2, i ){
    arr_seq(_a1, 1, 1, num)
    delete _a1[ L ]
    split(arr_join( _a1, "," ), _a2, ",")
    testcase_assert( arr_eq( _a1, _a2 ),
        "Join Expect _a1 == _a2" )
}
#EndSection
