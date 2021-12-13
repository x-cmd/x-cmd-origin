# Using it to power jawk

# { "a": "b", "a1": [1, 2, 3], "a2": { "age": 12 } }
# arr[ "a" S 1]
# arr[ "a2" S "age" ]
# arr[ "a" L ]
# arr[ "a" T ]

BEGIN {
    T = "\002"
    T_DICT = "\003"
    T_ARRAY = "\004"
    T_PRI = "\005"
    T_ROOT = "\006"

    T_KEY = "\007"
    T_LEN = "\010"

    S=","
}

# Section: handler

function q(str){
    gsub(/\\/, "\\\\", str)
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}


function draw_space(num,     _i, _ret){
    _ret=""
    for(_i=0; _i<num; ++_i){
        _ret = _ret " "
    }
    return _ret
}

function jkey(a1, a2, a3, a4, a5, a6, a7, a8,   _ret){
    _ret = ""
    if (a1 == "") return _ret
    _ret = ret S q(a1)
    if (a2 == "") return _ret
    _ret = _ret S q(a2)
    if (a3 == "") return _ret
    _ret = _ret S q(a3)
    if (a4 == "") return _ret
    _ret = _ret S q(a4)
    if (a5 == "") return _ret
    _ret = _ret S q(a5)
    if (a6 == "") return _ret
    _ret = _ret S q(a6)
    if (a7 == "") return _ret
    _ret = _ret S q(a7)
    if (a8 == "") return _ret
    _ret = _ret S q(a8)
    return ret
}

function json_handle_jpath(jpath,   _arr, _arrl, _i, _ret){
    if (jpath ~ /^\./) {
        jpath = "1" jpath
    }
    _arrl = split(jpath, _arr, ".")
    _ret = ""
    for (_i = 1; _i<=_arrl; _i++) {
        if (_arr[_i] == "") continue
        _ret = _ret S q(_arr[_i])
    }
    return _ret
}

function jget(arr, jpath){
    return arr[ json_handle_jpath(jpath) ]
}

function jlen(arr, jpath){
    return arr[ json_handle_jpath(jpath) T_LEN ]
}

function jtype(arr, jpath){
    return arr[ json_handle_jpath(jpath) T ]
}

function jparse(text, arr){
    return json_parse(text, arr)
}

function jtokenize(text) {
    return json_to_machine_friendly(text)
}


# jjoin(arr, jpath, start:end, sep1)
# jjoin(arr, jpath, start:end, sep1, keystr, sep2)

function ___json_range_trick(arr, max){
    if (arr[1] == "") arr[1] = 1
    if (arr[2] == "") {
        if (arr[1] > 0) {
            arr[2] = max
        } else {
            arr[2] = 1
        }
    }
    if (arr[3] == "") {
        if (arr[1] > arr[2]) {
            arr[3] = -1
        } else {
            arr[3] = 1
        }
    }
}


function jjoin(arr, jpath, range, sep1, keystr, sep2,
    _kp, _len, _i, _range, _rangel, _start, _end, _step) {

    _kp = json_handle_jpath(jpath)

    _keyl = split(keystr, _key, ",")
    for (_i=1; _i<=_keyl; ++_i) {
        _key[ _i ] = q( _key[ _i ] )
    }

    _len = arr[ _kp T_LEN ]
    if (range == "") {
        _start = 1
        _end = _len
        _step = 1
    } else {
        _rangel = split(range, _range, ":")
        ___json_range_trick(_range, _len)

        _step = int(_range[3])
        _end = int(_range[2])
        _start = int(_range[1])
    }

    if (_keyl < 1) {
        for (_i=_start; _i<=_end; _i = _i + _step) {
            printf("%s", arr[ _kp S "\"" _i "\"" ])
            if (_i<_end) printf(sep1)
        }
        return
    }


    for (_i=_start; _i<=_end; _i = _i + _step) {

        printf("%s", arr[ _kp S "\"" _i "\"" S _key[1] ])
        for (_j=2; _j<=_keyl; ++_j) {
            printf(sep2 "%s" , arr[ _kp S "\"" _i "\"" S _key[_j] ])
        }

        if (_i<_end) printf(sep1)
    }
}


# EndSection

# Section: json parser

function ___json_parse_walk_panic(msg,       start){
    start = s_idx - 10
    if (start <= 0) start = 1
    print (msg " [index=" s_idx "]:\n-------------------\n" ___JSON_TMP_TOKENS[s_idx -2] "\n" ___JSON_TMP_TOKENS[s_idx -1] "\n" s "\n" ___JSON_TMP_TOKENS[s_idx + 1] "\n-------------------") > "/dev/stderr"
    exit 1
}

function ___json_parse_walk_dict(arr, keypath,
    nth, cur_keypath, _result, _klist){
    if (s != "{") {
        # debug("___json_parse_walk_dict() fails" )
        return false
    }


    nth = 0
    s = ___JSON_TMP_TOKENS[++s_idx]
    _klist=""

    while (1) {
        nth ++
        if (s == "}") {
            s = ___JSON_TMP_TOKENS[++s_idx];  break
        }

        cur_keypath = keypath S s
        _klist = _klist S s

        s = ___JSON_TMP_TOKENS[++s_idx]
        if (s != ":")   ___json_parse_walk_panic("___json_parse_walk_dict() Expect :")

        s = ___JSON_TMP_TOKENS[++s_idx]
        _result = ___json_parse_walk_value(arr, cur_keypath)
        if ( (_result == T_DICT) || (_result == T_ARRAY) ) {
            arr[ cur_keypath T ] = _result
        } else {
            arr[ cur_keypath T ] = T_PRI
            arr[ cur_keypath ] = _result
        }

        if (s == ",") s = ___JSON_TMP_TOKENS[++s_idx]
    }
    arr[ keypath T_LEN ] = nth + 1  # starts from 1
    arr[ keypath T_KEY ] = _klist
    return true
}

function ___json_parse_walk_list(arr, keypath,
    nth, cur_keypath, _result){

    if (s != "[")   return false

    nth = 0
    s = ___JSON_TMP_TOKENS[++s_idx]

    while (1) {
        nth++;
        if (s == "]") {
            s = ___JSON_TMP_TOKENS[++s_idx];   break
        }

        cur_keypath = keypath S "\"" nth "\""

        # if (s == ",")  ___json_parse_walk_panic("___json_parse_walk_list() Expect a value but get " s)
        _result = ___json_parse_walk_value(arr, cur_keypath)
        if ( (_result == T_DICT) || (_result == T_ARRAY) ) {
            arr[ cur_keypath T ] = _result
        } else {
            arr[ cur_keypath T ] = T_PRI
            arr[ cur_keypath ] = _result
        }

        # TODO: just skip that token without judgement
        if (s == ",")   s = ___JSON_TMP_TOKENS[ ++s_idx ]
    }

    arr[ keypath T_LEN ] = nth  # starts from 1

    return true
}

function ___json_parse_walk_value(arr, keypath,  _result){
    if (___json_parse_walk_dict(arr, keypath) == true) {
        return T_DICT
    }

    if (___json_parse_walk_list(arr, keypath) == true) {
        return T_ARRAY
    }

    _result = s
    s = ___JSON_TMP_TOKENS[++s_idx]
    return _result
}

function ___json_parse_walk(arr,    final, idx, nth){
    if (s == "")  s = ___JSON_TMP_TOKENS[++s_idx]

    nth = 0
    while (s_idx <= s_len) {
        if (___json_parse_walk_value(arr, S "\"" ++nth "\"", "") == false) {
           ___json_parse_walk_panic("json_walk() Expect a value")
        }
    }
    arr[ T_LEN ] = nth
}

# global variable: text, s, s_idx, s_len,___JSON_TMP_TOKENS
function ___json_parse(text, arr,       b_s, b_s_idx, b_s_len){
    b_s = s;    b_s_idx = s_idx;    b_s_len = s_len;

    s_len = split(text, ___JSON_TMP_TOKENS, /\n/)
    s = ___JSON_TMP_TOKENS[s_idx];     s_idx = 1;

    ___json_parse_walk(arr)

    s = b_s;    s_idx = b_s_idx;    s_len = b_s_len;
}

# global variable: text, s, s_idx, s_len
function json_parse(text, arr){
    ___json_parse(json_to_machine_friendly(text), arr)
}

# Acc version for data exchange
# if acc == 0
function json_parse0(text){
    ___json_parse(text)
}

# EndSection

# Section: json machine friendly

function json_to_machine_friendly(text){
    gsub(/"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    # gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    gsub("\n" "[ \t\n\r]+", "\n", text)
    return text
}

# EndSection

# Section: json dict handler

function json_dict_keys(arr, keypath, klist, _l){
    _l = split(arr[ keypath T_KEY ], klist, S)
    klist[ L ] = _l
    return _l
}

function json_dict_rm(arr, keypath, key){
    # substr()
}

# TODO: We should quote
function json_dict_push(arr, keypath, key, value,  _v){
    keypath=json_handle_jpath(keypath)
    key=q(key)
    _v = arr[keypath S key]
    if ( _v != "" ) {
        arr[keypath S key] = value
    } else {
        arr[ keypath T_LEN ] = arr[ keypath T_LEN ] + 1
        arr[ keypath T_KEY ] = arr[ keypath T_KEY ] S key
        arr[keypath S key] = value
    }
    return _v
}

function json_dict_has(arr, keypath, key,  _v) {
    _v = arr[keypath S key]
    return (_v == "") ? false : true
}

function json_dict_get(arr, keypath, key){
    return arr[keypath S key]
}

function json_dict_len(arr, keypath){
    return arr[ keypath T_LEN ]
}


# EndSection

# Section: json list handler
function json_list_push(arr, keypath, value,  _l){
    _l = arr[ keypath T_LEN ] + 1
    arr[ _l ] = value
    arr[ keypath T_LEN ] = _l
}

function json_list_has(arr, keypath, value,  _l, _i) {
    _l = arr[ keypath T_LEN ]
    for (_i=1; _i<=_l; ++_i) {
        if ( arr[keypath S _i ] == value ) {
            return true
        }
    }
    return false
}

function json_list_rm(arr, keypath, value,  _l, _i, _found_idx) {
    _l = arr[ keypath T_LEN ]
    _found_idx = 0
    for (_i=1; _i<=_l; ++_i) {
        if (_found_idx != 0) {
            arr[ _i - 1 ] = arr[ _i ]
        }
        if ( arr[keypath S _i ] == value ) {
            _found_idx = _i
        }
    }
    if (_found_idx != 0) {
        arr[ keypath T_LEN ] = arr[ keypath T_LEN ] - 1
    }
    return _found_idx
}

function json_list_len(arr, dict_keypath){
    return arr[ keypath T_LEN ]
}




# EndSection

# Section: Compact Stringify
function ___json_stringify_compact_dict(arr, keypath,     _klist, _l, _i, _key, _val, _ret){

    _l = json_dict_keys(arr, keypath, _klist)

    if (_l == 0) return "{}"
    _key = _klist[ 1 ]
    _val = arr[ keypath S _key ]
    _ret = _key ":" _val

    for (_i=2; _i<=_l; _i++){
        _key = _klist[ _i ]
        _val = arr[ keypath S _key ]
        _ret = _ret "," _key ":" ___json_stringify_compact_value( arr, keypath S _key )
    }
    _ret = substr(_ret, 3)
    return "{" _ret "}"
}

function ___json_stringify_compact_list(arr, keypath,     _l, _i, _ret){
    _l = arr[ keypath T_LEN ]
    if (_l == 0) return "[]"
    _ret = ___json_stringify_compact_value( arr, keypath S "\"" 1 "\"" )
    for (_i=2; _i<_l; _i++){
        _ret = _ret "," ___json_stringify_compact_value( arr, keypath S "\"" _i "\"" )
    }
    return "[" _ret "]"
}

function ___json_stringify_compact_value(arr, keypath,      _t, _klist, _klist_l, _i){
    _t = arr[ keypath T ]
    if (_t == T_DICT) {
        return ___json_stringify_compact_dict(arr, keypath)
    } else if (_t == T_ARRAY) {
        return ___json_stringify_compact_list(arr, keypath)
    } else if (_t == T_PRI) {
        return arr[ keypath ]
    }else {
        _klist_l = json_dict_keys(arr, keypath, _klist)
        if ( _klist_l == 0 ) return ""
        for (_i=2; _i<=_klist_l; ++_i){
            _ret = _ret _klist[ _i ] ":"___json_stringify_compact_value(arr, keypath S _klist[ _i ]) ","
        }
        return _ret
    }
}

function json_stringify_compact(arr, keypath, i, len){
    if (keypath != "") {
        keypath=json_handle_jpath(keypath)
        return ___json_stringify_compact_value(arr, keypath)
    }

    len = arr[ T_LEN ]
    if (len < 1)  return ""

    for (i=1; i<=len; ++i) {
        ret = ret ___json_stringify_compact_value( arr,  S "\"" i "\"" )
    }
    return ret
}

# EndSection

# Section: Machine Stringify
function ___json_stringify_machine_dict(arr, keypath,     _klist, _l, _i, _key, _val, _ret){

    _l = json_dict_keys(arr, keypath, _klist)

    if (_l == 0) return "\n{\n}"
    _key = _klist[ 1 ]
    _val = arr[ keypath S _key ]
    _ret = _key "\n:\n" _val

    for (_i=2; _i<=_l; _i++){
        _key = _klist[ _i ]
        _val = arr[ keypath S _key ]
        _ret = _ret "\n,\n" _key "\n:\n" ___json_stringify_machine_value( arr, keypath S _key )
    }
    _ret = substr(_ret, 7)
    return "\n{\n" _ret "\n}"
}

function ___json_stringify_machine_list(arr, keypath,     _l, _i, _ret){
    _l = arr[ keypath T_LEN ]
    if (_l == 0) return "\n[\n]"
    _ret = ___json_stringify_machine_value( arr, keypath  S "\"" 1 "\"" )

    for (_i=2; _i<_l; _i++){
        _ret = _ret "\n,\n" ___json_stringify_machine_value( arr, keypath S "\""  _i "\"" )
    }

    return "\n[\n" _ret "\n]"
}

function ___json_stringify_machine_value(arr, keypath,     _t, _klist, _klist_l, _i){
    _t = arr[ keypath T ]
    if (_t == T_DICT) {
        return ___json_stringify_machine_dict(arr, keypath)
    } else if (_t == T_ARRAY) {
        return ___json_stringify_machine_list(arr, keypath)
    } else if (_t == T_PRI) {
        return arr[ keypath ]
    }else {
        _klist_l = json_dict_keys(arr, keypath, _klist)
        if ( _klist_l == 0 ) return ""
        for (_i=2; _i<=_klist_l; ++_i){
            _ret = _ret _klist[ _i ] "\n:\n"___json_stringify_machine_value(arr, keypath S _klist[ _i ]) "\n,\n"
        }
        return _ret
    }
}

function json_stringify_machine(arr, keypath, i, len){
    if (keypath != "") {
        keypath=json_handle_jpath(keypath)

        return ___json_stringify_machine_value(arr, keypath)
    }

    len = arr[ T_LEN ]
    if (len < 1)  return ""

    for (i=1; i<=len; ++i) {
        ret = ret "\n"___json_stringify_machine_value( arr,  S "\"" i "\"")
    }
    return ret
}
# EndSection

# Section: Format Stringify
function ___json_stringify_format_dict(arr, keypath, indent,    _klist, _l, _i, _key, _val, _ret){

    _l = json_dict_keys(arr, keypath, _klist)

    if (_l == 0) return "{ }"
    _key = _klist[ 1 ]
    _val = arr[ keypath S _key ]
    _ret = _key ": " _val

    for (_i=2; _i<=_l; _i++){
        _key = _klist[ _i ]
        _val = arr[ keypath S _key ]
        _ret = _ret ",\n" draw_space(indent + indent)  _key ": " ___json_stringify_format_value( arr, keypath S _key, indent + indent )
    }
    _ret = substr(_ret, 3+indent)
    return "{\n" _ret "\n" draw_space(indent) "}"
}

function ___json_stringify_format_list(arr, keypath, indent,    _l, _i, _ret){
    _l = arr[ keypath T_LEN ]
    if (_l == 0) return "[ ]"
    _ret = ___json_stringify_format_value( arr, keypath S "\"" 1 "\"", indent + indent )

    for (_i=2; _i<_l; _i++){
        _ret = _ret ","  ___json_stringify_format_value( arr, keypath S "\"" _i "\"", indent + indent)  # arr[ keypath S _i ]
    }
    return "[" _ret "]"
}

function ___json_stringify_format_value(arr, keypath, indent,   _t, _klist, _klist_l, _i){

    _t = arr[ keypath T ]

    if (_t == T_DICT) {
        return ___json_stringify_format_dict(arr, keypath, indent)
    } else if (_t == T_ARRAY) {
        return ___json_stringify_format_list(arr, keypath, indent)
    } else if (_t == T_PRI) {
        return arr[ keypath ]
    }else {
        _klist_l = json_dict_keys(arr, keypath, _klist)
        if ( _klist_l == 0 ) return ""
        for (_i=2; _i<=_klist_l; ++_i){
            _ret = _ret draw_space(indent) _klist[ _i ] ": "___json_stringify_format_value(arr, keypath S _klist[ _i ], indent) ",\n"
        }
        return _ret
    }
}

function json_stringify_format(arr, keypath, indent,      i, len,   _indent){


    if (keypath != "") {
        keypath=json_handle_jpath(keypath)
        return ___json_stringify_format_value(arr, keypath, indent)
    }

    len = arr[ T_LEN ]
    if (len < 1)  return ""

    for (i=1; i<=len; ++i) {
        ret =  ret "\n" ___json_stringify_format_value( arr, S "\"" i "\"", indent )
    }

    return ret
}
# EndSection


# Section: jiter

BEGIN{

    JITER_TOKEN_LLEFT   = 1 # "["
    JITER_TOKEN_LRIGHT  = 2 # "]"
    JITER_TOKEN_LCOMMA  = 3 #  "[,"
    # JITER_TOKEN_LVALUE  = 4
    JITER_TOKEN_DLEFT   = 5     # "{"
    JITER_TOKEN_DRIGHT  = 6    # "}"
    JITER_TOKEN_DCOMMA  = 7    # ",}"
    JITER_TOKEN_DCOLON  = 8    # ":}"
    JITER_TOKEN_DKEY    = 9
    # JITER_TOKEN_DVALUE  = 10

    JITER_LAST_TOKEN = ""

    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""   # keypath
}

function _jiter_handle_keypath(arr, item,     _cur_keypath, _cur_state, _len){
    _cur_keypath = JITER_STACK[ JITER_LEVEL ]

    _cur_state = arr[ _cur_keypath T ]

    _len = int(arr[ _cur_keypath T_LEN ] + 1)
    arr[ _cur_keypath T_LEN ] = _len

    if ( _cur_state == T_DICT ) {
        if ( JITER_LAST_TOKEN == JITER_TOKEN_DCOLON ) {
            _cur_keypath = _cur_keypath S JITER_LAST_KP
            if (item != "") {
                arr[ _cur_keypath ] = item
            }
            return _cur_keypath
        } else {
            JITER_LAST_KP = item
        }
    } else {
        # ( _cur_state != T_PRI )
        _cur_keypath = _cur_keypath S "\"" _len "\""
        if (item != "") {
            arr[ _cur_keypath ] = item
        }
        return _cur_keypath
    }
}


function jiter(arr, item,      s, _t, _p_s, _cur_state, _len, _this_keypath){
    _last_token = JITER_LAST_TOKEN

    if (item == "[") {

        _this_keypath = _jiter_handle_keypath(arr)
        print "_this_keypath: " _this_keypath
        arr[ _this_keypath T ] = T_LIST

        JITER_STACK[ ++JITER_LEVEL ] = _this_keypath
        JITER_LAST_TOKEN = JITER_TOKEN_LLEFT
    } else if (item == "]") {
        JITER_LEVEL --
        JITER_LAST_TOKEN = JITER_TOKEN_LRIGHT
    } else if (item == "{") {

        _this_keypath = _jiter_handle_keypath(arr)
        arr[ _this_keypath T ] = T_DICT

        JITER_STACK[ ++JITER_LEVEL ] = _this_keypath
        JITER_LAST_TOKEN = JITER_TOKEN_DLEFT
    } else if (item == "}") {
        JITER_LEVEL --
        JITER_LAST_TOKEN = JITER_TOKEN_DLEFT
    } else if (item == ":") {

        JITER_LAST_TOKEN = JITER_TOKEN_DCOLON
    } else if (item == ",") {
        JITER_LAST_TOKEN = ""   # Needless to distinguish
    } else {

        _this_keypath = _jiter_handle_keypath( arr, item )
        JITER_LAST_TOKEN = ""
    }
}

# EndSection