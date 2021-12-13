BEGIN {
    a = 10000
}

function h(){
    print(a)
    t[1] = 5
}

function w(a, b, t){
    a = 6
    t[1] = 2
    h()
}

BEGIN {
    debug("test default debug function")
    print "HELLO WORLD"
}

END{
    print a
    print t[1]
}
