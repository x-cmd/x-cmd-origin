BEGIN {
    LEN = "\001"
    NULL = "\001"
}

function arr_len(arr){
    return arr[ LEN ]
}

function arr_push(arr, elem, _len){
    _len = arr[ LEN ] + 1
    arr[ _len ] = elem
    arr[ LEN ] = _len
}

function arr_pop(arr, _len){
    _len = arr[ LEN ]
    if (_len < 1) {
        return NULL
    }
    arr[ LEN ] = _len - 1

    _len = arr[ _len + 1 ]
    arr[ _len + 1 ] = ""
    return _len
}

function arr_top(arr) {
    _len = arr[ LEN ]
    if (_len < 1) {
        return NULL
    }
    return arr[ _len ]
}

function arr_join(arr, sep, _start, _len, _i, _result) {
    if (sep == "")      sep = "\n"
    if (_start == "")   _start = 1
    if (_len == "" )    _len = arr[ LEN ]

    if (_len < 1) return ""

    _result = arr[1]
    for (_i=2; _i<=_len; ++_i) {
        _result = _result sep arr[_i]
    }
    return _result
}

