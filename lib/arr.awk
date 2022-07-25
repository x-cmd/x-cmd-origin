BEGIN {
    NULL = "\001"
}

function arr_len(arr,   l){
    return ( "" == (l = arr[ L ]) ) ? 0 : l
}

function arr_seq( arr, s, delta, e,        i, c ){
    for (i=0; s<=e; s+=delta) arr[++i] = s
    arr[ L ] = i
    return i
}

function arr_eq( a1, a2,            i, l ){
    if ((l = arr_len(a1)) != arr_len(a2))       return false
    for (i=1; i<=l; i++) if (a1[i] != a2[i])    return false
    return true
}

function arr_get( a, i ){
    return a[i]
}

function arr_push(arr, elem,        l){
    arr[ L ] = l = arr[ L ] + 1
    arr[ l ] = elem
    return l
}

function arr_pop(arr,   l){
    if ((l = arr[ L ]) < 1)     return NULL
    arr[ L ] = l - 1
    return arr[ l ]
}

function arr_top(arr,   l) {
    if ((l = arr[ L ]) < 1)     return NULL
    return arr[ l ]
}

function arr_join(arr,              _sep, _start, l,              _i, _result) {
    if (_sep == "")             _sep = "\n"
    if (_start == "")           _start = 1
    if (l == "")                l = arr[ L ]

    if (l < 1) return ""

    _result = arr[1]
    for (_i=2; _i<=l; ++_i)      _result = _result _sep arr[_i]
    return _result
}

function arr_clone( src, dst,   l, i ){
    l = src[ L ]
    dst[ L ] = l
    for (i=1; i<=l; ++i)  dst[i] = src[i]
    return l
}

function arr_shift( arr, offset,        l, i ){
    l = arr[ L ] - offset
    for (i=1; i<=l; ++i) arr[i] = arr[i+offset]
    arr[ L ] = l
    return l
}

function arr_unshift( arr, v,        l, i ){
    arr[ L ] = l = arr[ L ] + 1
    for (i=l; i>1; --i) arr[i] = arr[i-1]
    arr[1] = v
    return l
}

