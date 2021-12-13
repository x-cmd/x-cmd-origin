
BEGIN {
    # a = 10000
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
    w(1, 2)
}

END{
    print a
    print t[1]
}
