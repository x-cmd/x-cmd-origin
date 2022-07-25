
END {
    testcase( "test: [:seq:]", test_seq() )
}

function test_seq(){
    test_seq_(1, 3, 100)
    test_seq_(1, 1, 100, "100")
    test_seq_(3, 1, 100, "3:100")
    test_seq_(3, 3, 100, "3:3:100")
}

function test_seq_(begin, delta, end, s){
    if (s == "")  s = begin ":" delta ":" end
    for (i=begin; i<=end; i+=delta){
        testcase_assert( seq_within( i, s ), sprintf("Expect %s inside %s", i, s) )
        testcase_assert( ! seq_within( i+(end-begin)+1, s ), sprintf("Expect %s outside %s", i+(end-begin)+1, s) )
    }
}
