# TODO: Which repo and license do we refer here? Figure it out.

BEGIN {
    ord_init()
}

function ord_init(    low, high, i, t) {
    low = sprintf("%c", 7) # BEL is ascii 7
    if (low == "\a") {    # regular ascii
        low = 0
        high = 127
    } else if (sprintf("%c", 128 + 7) == "\a") {
        # ascii, mark parity
        low = 128
        # low = 0
        high = 255
    } else {        # ebcdic(!)
        low = 0
        high = 255
    }

    for (i = low; i <= high; i++) {
        t = sprintf("%c", i)
        _ord_[t] = i
    }
}

function ord(c){
    return _ord_[c]
}

function ord_is_number(o) {
    if ( (o >= 48) && (o <= 57) ) {
        return true
    }
    return false
}

function ord_is_letter(o) {
    if ((ord_is_uppercase(o) == false) && (ord_is_lowercase(o) == false)){
        return false
    }
    return true
}

function ord_is_uppercase(o) {
    if ( (o >= 65) && (o <= 90) ) {
        return true
    }
    return false
}

function ord_is_lowercase(o) {
    if ( (o >= 97) && (o <= 122) ) {
        return true
    }
    return false
}
