# Using it to power jawk

# { "a": "b", "a1": [1, 2, 3], "a2": { "age": 12 } }
# arr[ "a" S 1]
# arr[ "a2" S "age" ]
# arr[ "a" L ]
# arr[ "a" T ]

BEGIN {
    T_DICT = "{" # "\003"
    T_LIST = "[" # "\004"
    T_PRI = "\005"
    T_ROOT = "\006"

    T_KEY = "\007"
    T_LEN = "\010"
}

# Section: handler: jkey, _jpath,
function q(str){
    gsub(/\\/, "\\\\", str)
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}

function jkey(a1, a2, a3, a4, a5, a6, a7, a8, a9,
    a10, a11, a12, a13, a14, a15, a16, a17, a18, a19,
    _ret){
    _ret = ""
    if (a1 == "")   return _ret;  _ret = ret S q(a1)
    if (a2 == "")   return _ret;  _ret = _ret S q(a2)
    if (a3 == "")   return _ret;  _ret = _ret S q(a3)
    if (a4 == "")   return _ret;  _ret = _ret S q(a4)
    if (a5 == "")   return _ret;  _ret = _ret S q(a5)
    if (a6 == "")   return _ret;  _ret = _ret S q(a6)
    if (a7 == "")   return _ret;  _ret = _ret S q(a7)
    if (a8 == "")   return _ret;  _ret = _ret S q(a8)


    if (a9 == "")   return _ret;  _ret = _ret S q(a9)
    if (a10 == "")  return _ret;  _ret = _ret S q(a10)
    if (a11 == "")  return _ret;  _ret = _ret S q(a11)
    if (a12 == "")  return _ret;  _ret = _ret S q(a12)
    if (a13 == "")  return _ret;  _ret = _ret S q(a13)
    if (a14 == "")  return _ret;  _ret = _ret S q(a14)
    if (a15 == "")  return _ret;  _ret = _ret S q(a15)
    if (a16 == "")  return _ret;  _ret = _ret S q(a16)
    if (a17 == "")  return _ret;  _ret = _ret S q(a17)
    if (a18 == "")  return _ret;  _ret = _ret S q(a18)
    if (a19 == "")  return _ret;  _ret = _ret S q(a19)

    return ret
}

function jpathr(_jpath,     _ret ){
    _ret = jpath(_jpath)

    # \034 = S
    gsub(/\*/, "[^\001]+", _ret)
    return _ret
}

function jpath(_jpath,   _arr, _arrl, _i, _ret){
    if (_jpath ~ S) return _jpath
    if (_jpath ~ /^\./) {
        _jpath = "1" _jpath
    }
    _arrl = split(_jpath, _arr, ".")
    _ret = ""
    for (_i = 1; _i<=_arrl; _i++) {
        if (_arr[_i] == "") continue
        _ret = _ret S q(_arr[_i])
    }
    return _ret
}

function jpatharr(arr, a1, a2, a3, a4, a5, a6, a7, a8, a9,
    a10, a11, a12, a13, a14, a15, a16, a17, a18, a19 ){

    if (a1 == "")   return 0;   arr[1] = q(a1)
    if (a2 == "")   return 1;   arr[2] = q(a2)
    if (a3 == "")   return 2;   arr[3] = q(a3)
    if (a4 == "")   return 3;   arr[4] = q(a4)
    if (a5 == "")   return 4;   arr[5] = q(a5)
    if (a6 == "")   return 5;   arr[6] = q(a6)
    if (a7 == "")   return 6;   arr[7] = q(a7)
    if (a8 == "")   return 7;   arr[8] = q(a8)

    if (a9 == "")   return 8;   arr[9] = q(a9)
    if (a10 == "")  return 9;   arr[10] = q(a10)
    if (a11 == "")  return 10;  arr[11] = q(a11)
    if (a12 == "")  return 11;  arr[12] = q(a12)
    if (a13 == "")  return 12;  arr[13] = q(a13)
    if (a14 == "")  return 13;  arr[14] = q(a14)
    if (a15 == "")  return 14;  arr[15] = q(a15)
    if (a16 == "")  return 15;  arr[16] = q(a16)
    if (a17 == "")  return 16;  arr[17] = q(a17)
    if (a18 == "")  return 17;  arr[18] = q(a18)
    if (a19 == "")  return 18;  arr[19] = q(a19)

    return 19
}

function jget(arr, _jpath){
    _jpath = jpath(_jpath)
    if (arr[ _jpath ] == T_LIST || arr[ _jpath ] == T_DICT){
        return ___json_stringify_format_value(arr, _jpath, 4)
    }
    return arr[ _jpath ]
}

function jlen(arr, _jpath){
    return arr[ jpath(_jpath) T_LEN ]
}

function jtype(arr, _jpath){
    return arr[ jpath(_jpath)]
}

function jtokenize(text) {
    return json_to_machine_friendly(text)
}

function jtokenize_trim(text) {
    gsub(/"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    gsub("[:,]" "\n", "", text)
    gsub("\n" "[:,]", "", text)
    gsub("\n" "[ \t\n\r]+", "\n", text)
    return text
}

function json_str_unquote2(str){
    if (str !~ /^"/) { # "
        return str
    }
    gsub(/\\\\/, "\001\001", str)
    gsub(/\\"/, /"/, str)
    gsub("\001\001", "\\\\", str)
    return substr(str, 2, length(str)-2)
}

function json_str_quote2(str){
    gsub(/\\/, "\\\\", str)
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}

# EndSection

# Section: jrange jkey json_jpaths2arr
function ___json_range_trick(arr, max){
    if (arr[3] == "") {
        if (arr[1] > arr[2] && arr[1] > 0 && arr[2] > 0) {
            arr[3] = -1
        } else {
            arr[3] = 1
        }
    }
    if (arr[1] == "") {
        if (arr[3] > 0) arr[1] = 1
        else arr[1] = max
    }
    if (arr[1] < 0) {
        arr[1] = (arr[1] + max) % max + 1
    }
    if (arr[2] == "") {
        if (arr[3] > 0) arr[2] = max
        else arr[2] = 1
    }
    if (arr[2] < 0) {
        if (arr[3] > 0) arr[2] = max + arr[2]
        else arr[2] = max + arr[2] + 2
    }
}

function jrange(range, arrlen){
    if (range == "") {
        jrange_start = 1
        jrange_end = arrlen
        jrange_step = 1
    } else {
        _rangel = split(range, _range, ":")
        ___json_range_trick(_range, arrlen)

        jrange_step = int(_range[3])
        jrange_end = int(_range[2])
        jrange_start = int(_range[1])
    }
}

# For jjoin, different from logic
function ___json_jpath_quote2(_jpath,   _arr, _arrl, _i, _ret){
    _arrl = split(_jpath, _arr, ".")
    _ret = ""
    for (_i = 1; _i<=_arrl; _i++) {
        if (_arr[_i] == "") continue
        if ( _i == 1 )  _ret = q(_arr[_i])
        else _ret = _ret S q(_arr[_i])
    }
    return _ret
}

function json_jpaths2arr(arr,
    jpaths,
    _i, _arrl  ){

    _arrl = split(jpaths, arr, S)
    for (_i=1; _i<=_arrl; ++_i) {
        arr[ _i ] = ___json_jpath_quote2( arr[ _i ] )
    }
    return _arrl
}

function json_namedjpaths2arr(arr,
    jpaths,
    _i, _arrl, _e, _e1, _e2, _idx, _title  ){

    _arrl = split(keystr, arr, S)

    _title = ""

    for (_i=1; _i<=_arrl; ++_i) {
        _e = arr[ _i ]
        if ( _e ~ /=/) {
            _idx = index(_e, "=")
            _e1 = substr(_e, 1, _idx-1)
            _e2 = substr(_e, _idx+1)

            arr[ _i ] = ___json_jpath_quote2( _e2 )

        } else {
            _e1 = _e
            arr[ _i ] = ___json_jpath_quote2( _e )
        }

        if (_i == 1) _title = _e1
        else _title = _title sep2 _e1
    }

    arr[ L ] = _arrl

    return _title
}
# EndSection

# Section: jlist
function jlist_push(arr, keypath, value,  _l){
    _l = arr[ keypath T_LEN ] + 1
    arr[ keypath S "\"" _l "\""] = value
    arr[ keypath T_LEN ] = _l
}

function jlist_has(arr, keypath, value,  _l, _i) {
    _l = arr[ keypath T_LEN ]
    for (_i=1; _i<=_l; ++_i) {
        if ( arr[keypath S "\""_i "\"" ] == value ) {
            return true
        }
    }
    return false
}

function jlist_rm(arr, keypath, value,  _l, _i, _found_idx) {
    _l = arr[ keypath T_LEN ]
    _found_idx = 0
    for (_i=1; _i<=_l; ++_i) {
        if (_found_idx != 0) {
            arr[ keypath S "\"" _i - 1 "\"" ] = arr[ keypath S "\"" _i "\""]
        }
        if ( arr[keypath S "\""_i "\"" ] == value ) {
            _found_idx = _i
        }
    }
    if (_found_idx != 0) {
        arr[ keypath T_LEN ] = arr[ keypath T_LEN ] - 1
    }
    return _found_idx
}

function jlist_len(arr, keypath){
    return arr[ keypath T_LEN ]
}

function jlist_id2arr(obj, keypath, range, arr,    i, l){
    jrange(range, obj[ keypath T_LEN ])

    l=0
    if (jrange_step > 0) {
        for (i=jrange_start; i<=jrange_end; i=i+jrange_step) {
            l = l + 1
            arr[l] = keypath S q(i)
        }
    } else {
        for (i=jrange_start; i>=jrange_end; i=i+jrange_step) {
            l = l + 1
            arr[l] = keypath S q(i)
        }
    }
    return l
}

function jlist_value2arr(obj, keypath, range, arr,    i, l){
    l = jlist_id2arr(obj, keypath, range, arr)
    for (i=1; i<=l; ++i) {
        arr[i] = obj[ arr[i] ]
    }
    return l
}

function jlist_str2arr(obj, keypath, range, arr,    i, l){
    l = jlist_id2arr(obj, keypath, range, arr)
    for (i=1; i<=l; ++i) {
        arr[i] = jstr( obj, arr[i])
    }
    return l
}

function jlist_str02arr(obj, keypath, range, arr,    i, l){
    l = jlist_id2arr(obj, keypath, range, arr)
    for (i=1; i<=l; ++i) {
        arr[i] = jstr0( obj, arr[i] )
    }
    return l
}

function jlist_str12arr(obj, keypath, range, arr,    i, l){
    l = jlist_id2arr(obj, keypath, range, arr)
    for (i=1; i<=l; ++i) {
        arr[i] = jstr1( obj, arr[i] )
    }
    return l
}

# TOTEST
function jlist_join(sep, obj, keypath, range,      _ret_arr, i, l, _ret){
    l = jlist_value2arr(obj, keypath, range, _ret_arr)

    ret = ""
    for (i=1; i<=l; ++i) {
        if (ret != "")  ret = ret sep _ret_arr[i]
        else            ret = _ret_arr[i]
    }
    return ret
}

# TODO
function jlist_totable(){
    return true
}

function jlist_grep_to_arr( obj, keypath, reg,  arr,        _arrl,    _k, _len, _ret, _i, _tmp ){
    _k = keypath
    keypath = jpath(keypath)

    _len = obj[ keypath T_LEN ]
    for(_i=1; _i<=_len; ++_i){
        _tmp = keypath S "\"" _i "\""
        if( match(json_str_unquote2( obj[ _tmp ] ), reg)){
            arr[ ++_arrl ] = _tmp
        }
    }
    return _arrl
}

# EndSection

# Section: jdict
# TODO: rename to jdict_keys2arr
function jdict_keys(arr, keypath, klist, _l){
    _l = split(arr[ keypath T_KEY ], klist, S)
    klist[ L ] = _l
    # TODO: klist[ L ] = _l-1
    return _l
}

function jdict_rm(arr, keypath, key,  _key_str){
    _key_str = arr[ keypath T_KEY]
    if (match(_key_str, S key)){
        arr[ keypath T_KEY ] = substr(_key_str, 1, RSTART - 1) substr(_key_str, RSTART + RLENGTH)
        arr[ keypath T_LEN ] = arr[ keypath T_LEN ] - 1
    }
}

# TODO: We should quote
function jdict_push(arr, keypath, key, value,  _v){
    _v = arr[keypath S key]
    if ( _v != "" ) {
        arr[keypath S key] = value
    } else {
        arr[ keypath T_LEN ] = arr[ keypath T_LEN ] + 1
        arr[ keypath T_KEY ] = arr[ keypath T_KEY ] S key
        # TODO: arr[ keypath T_KEY ] = arr[ keypath T_KEY ] key S
        arr[keypath S key] = value
    }
    return _v
}

function jdict_has(arr, keypath, key,  _v) {
    _v = arr[keypath S key]
    return (_v == "") ? false : true
}

function jdict_get(arr, keypath, key){
    return arr[keypath S key]
}

function jdict_len(arr, keypath){
    return arr[ keypath T_LEN ]
}

# TODO: to check
function jdict_value2arr(obj, keypath, arr,    _keyarr, i, l){
    l = jdict_keys2arr(obj, keypath, _keyarr)
    for (i=1; i<=l; ++i) {
        arr[i] = jstr(obj, keypath S _keyarr[i])
    }
    arr[ L ] = l
    return l
}

function jdict_grep_to_arr( obj, keypath, reg,  arr,    _arrl,  _klist, _k, _tmp, _len, _ret, _i ){
    _k = keypath
    keypath = jpath(keypath)
    print substr(obj[ keypath T_KEY ],2)
    _l = split(substr(obj[ keypath T_KEY ],2), _klist, S)

    _arrl = 0
    for(_i=1; _i<=_l; ++_i){
        _tmp = _klist[_i]
        if( match( obj[ keypath S _tmp ], reg)){
            arr[ ++ _arrl ] = _tmp
        }
    }
    return _arrl
}

# EndSection

# Section: json convert to machine friendly
function json_to_machine_friendly(text){
    gsub(/"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    # gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    gsub("\n" "[ \t\n\r]+", "\n", text)
    return text
}
# EndSection

function draw_space(num,     _i, _ret){
    # _ret=""
    # for(_i=0; _i<num; ++_i){
    #     _ret = _ret " "
    # }
    # return _ret
    return sprintf("%" num "s", "")
}

# Section: jstr jstr0 jstr1
# Human
function jstr(arr, keypath){
    return json_stringify_format(arr, keypath)
}

# Compact
function jstr1(arr, keypath){
    return json_stringify_compact(arr, keypath)
}

# Machine friendly
function jstr0(arr, keypath){
    return json_stringify_machine(arr, keypath)
}
# EndSection

# Section
function jdict_keys2arr(arr, keypath, klist, _l){
    _l = split(substr(arr[ keypath T_KEY ],2), klist, S)
    klist[ L ] = _l
    # TODO: klist[ L ] = _l-1
    return _l
}
# EndSection

# Section: Compact Stringify
function ___json_stringify_compact_dict(arr, keypath,     _klist, _l, _i, _key, _val, _ret){

    _l = jdict_keys2arr(arr, keypath, _klist)

    if (_l == 0) return "{}"

    for (_i=1; _i<=_l; _i++){
        _key = _klist[ _i ]
        # _val = arr[ keypath S _key ]
        _ret = _ret "," _key ":" ___json_stringify_compact_value( arr, keypath S _key )
    }
    _ret = substr(_ret, 3)
    return "{" _ret "}"
}

function ___json_stringify_compact_list(arr, keypath,     _l, _i, _ret){
    _l = arr[ keypath T_LEN ]
    if (_l == 0) return "[]"
    _ret = ___json_stringify_compact_value( arr, keypath S "\"" 1 "\"" )
    for (_i=2; _i<=_l; _i++){
        _ret = _ret "," ___json_stringify_compact_value( arr, keypath S "\"" _i "\"" )
    }
    return "[" _ret "]"
}

function ___json_stringify_compact_value(arr, keypath,      _t, _klist, _i){
    _t = arr[ keypath ]
    if (_t == T_DICT) {
        return ___json_stringify_compact_dict(arr, keypath)
    } else if (_t == T_LIST) {
        return ___json_stringify_compact_list(arr, keypath)
    } else {
        return _t
    }
}

function json_stringify_compact(arr, keypath,      _i, _len,_ret){
    if (keypath != "") {
        keypath=jpath(keypath)
        return ___json_stringify_compact_value(arr, keypath)
    }

    _len = arr[ T_LEN ]
    if (_len < 1)  return ""

    for (_i=1; _i<=_len; ++_i) {
        _ret = _ret ___json_stringify_compact_value( arr,  S "\"" _i "\"" )
    }
    return _ret
}

# EndSection

# Section: Machine Stringify
function ___json_stringify_machine_dict(arr, keypath,     _klist, _l, _i, _key, _val, _ret){

    _l = jdict_keys2arr(arr, keypath, _klist)

    if (_l == 0) return "{\n}"

    for (_i=1; _i<=_l; _i++){
        _key = _klist[ _i ]
        # _val = arr[ keypath S _key ]
        _ret = _ret "\n,\n" _key "\n:\n" ___json_stringify_machine_value( arr, keypath S _key )
    }
    _ret = substr(_ret, 4)
    return "{\n" _ret "\n}"
}

function ___json_stringify_machine_list(arr, keypath,     _l, _i, _ret){
    _l = arr[ keypath T_LEN ]
    if (_l == 0) return "[\n]"
    _ret = ___json_stringify_machine_value( arr, keypath  S "\"" 1 "\"" )

    for (_i=2; _i<=_l; _i++){
        _ret = _ret "\n,\n" ___json_stringify_machine_value( arr, keypath S "\""  _i "\"" )
    }

    return "[\n" _ret "\n]"
}

function ___json_stringify_machine_value(arr, keypath,     _t, _klist, _i, _ret){
    _t = arr[ keypath]
    if (_t == T_DICT) {
        return ___json_stringify_machine_dict(arr, keypath)
    } else if (_t == T_LIST) {
        return ___json_stringify_machine_list(arr, keypath)
    } else {
        return _t
    }
}

function json_stringify_machine(arr, keypath,    _i, _len,_ret){
    if (keypath != "") {
        keypath=jpath(keypath)
        return ___json_stringify_machine_value(arr, keypath)
    }
    _len = arr[ T_LEN ]
    if (_len < 1)  return ""

    _ret = ___json_stringify_machine_value( arr,  S "\"" 1 "\"")
    for (_i=2; _i<=_len; ++_i) {
        _ret = _ret "\n"___json_stringify_machine_value( arr,  S "\"" _i "\"")
    }

    return _ret
}
# EndSection

# Section: Format Stringify
function ___json_stringify_format_dict(arr, keypath, indent,    _klist, _l, _i, _key, _val, _ret){

    _l = jdict_keys2arr(arr, keypath, _klist)

    if (_l == 0) return "{ }"

    for (_i=1; _i<=_l; _i++){
        _key = _klist[ _i ]
        # _val = arr[ keypath S _key ]
        _ret = _ret ",\n" draw_space(indent) _key ": " ___json_stringify_format_value( arr, keypath S _key, indent+INDENT_LEN )
    }
    _ret = substr(_ret, 2)
    return "{" _ret "\n" draw_space(indent-INDENT_LEN) "}"
}

function ___json_stringify_format_list(arr, keypath, indent,    _l, _i, _ret){
    _l = arr[ keypath T_LEN ]
    if (_l == 0) return "[ ]"

    for (_i=1; _i<=_l; _i++){
        _ret = _ret ",\n" draw_space(indent) ___json_stringify_format_value( arr, keypath S "\"" _i "\"", indent+INDENT_LEN)
    }
    _ret = substr(_ret, 2)
    return "[" _ret "\n" draw_space(indent-INDENT_LEN) "]"
}

function ___json_stringify_format_value(arr, keypath, indent,   _t, _klist, _i, _ret){

    _t = arr[ keypath]
    if (_t == T_DICT) {
        return ___json_stringify_format_dict(arr, keypath, indent)
    } else if (_t == T_LIST) {
        return ___json_stringify_format_list(arr, keypath, indent)
    } else {
        return _t
    }
}

function json_stringify_format(arr, keypath, indent,       _i, _len,_ret){
    if (indent == "") indent=4
    INDENT_LEN = indent

    if (keypath != "") {
        keypath=jpath(keypath)
        return ___json_stringify_format_value(arr, keypath, indent)
    }

    _len = arr[ T_LEN ]
    if (_len < 1)  return ""

    _ret = ___json_stringify_format_value( arr, S "\"" 1 "\"", indent )
    for (_i=2; _i<=_len; ++_i) {
        _ret =  _ret "\n" ___json_stringify_format_value( arr, S "\"" _i "\"", indent )
    }

    return _ret
}
# EndSection

function json_split2tokenarr(obj, text){
    return split( json_to_machine_friendly(text), obj, "\n" )
}

function json_split2tokenarr_(text){
    return json_split2tokenarr(_, text)
}

# Section: still strange: should be global search

# TODO: ...
function jgrep_to_arr(obj, keypath, reg, key,      _type){
    _k = keypath
    keypath = jpath(keypath)

    _type = obj[ keypath ]
    if (_type == T_LIST) {
        return jlist_grep_to_arr(obj, keypath, reg, key)
    }

    if (_type == T_DICT) {
        return jdict_grep_to_arr(obj, keypath, reg, key)
    }

    return ""
}
# EndSection
