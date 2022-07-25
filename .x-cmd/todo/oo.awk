
# Object design not practical.

function oget( obj, k1, k2, k3, k4, k5, k6, k7, k8, k9 ){
    return obj[ oo_key( k1, k2, k3, k4, k5, k6, k7, k8, k9 ) ]
}

function okey( k1, k2, k3, k4, k5, k6, k7, k8, k9, _res ){
    _res = k1
    if (k2 == "")      return _res;         _res = _res SUBSEP k2
    if (k3 == "")      return _res;         _res = _res SUBSEP k3
    if (k4 == "")      return _res;         _res = _res SUBSEP k4
    if (k5 == "")      return _res;         _res = _res SUBSEP k5
    if (k6 == "")      return _res;         _res = _res SUBSEP k6
    if (k7 == "")      return _res;         _res = _res SUBSEP k7
    if (k8 == "")      return _res;         _res = _res SUBSEP k8
    if (k9 == "")      return _res;         _res = _res SUBSEP k9
    return _res
}

function oput( obj, key, value ){
    return obj[ okey( k1, k2, k3, k4, k5, k6, k7, k8, k9 ) ]
}
