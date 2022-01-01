# Using it to power jawk

# { "a": "b", "a1": [1, 2, 3], "a2": { "age": 12 } }
# arr[ "a" S 1]
# arr[ "a2" S "age" ]
# arr[ "a" L ]
# arr[ "a" T ]

BEGIN {
    T = "\002"
    T_DICT = "\003"
    T_LIST = "\004"
    T_PRI = "\005"
    T_ROOT = "\006"

    T_KEY = "\007"
    T_LEN = "\010"

    S="\001"
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
    jpath = json_handle_jpath(jpath)
    if (arr[ jpath ] == T_LIST || arr[ jpath ] == T_DICT){
        return ___json_stringify_format_value(arr, jpath, 4)
    }
    return arr[ jpath ]
}

function jlen(arr, jpath){
    return arr[ json_handle_jpath(jpath) T_LEN ]
}

function jtype(arr, jpath){
    return arr[ json_handle_jpath(jpath)]
}

function jparse(text, arr){
    return json_parse(text, arr)
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

function jiter_after_tokenize(jobj, text,       _arr, _arrl, _i){
    _arrl = split( json_to_machine_friendly(text), _arr, "\n" )
    for (_i=1; _i<=_arrl; ++_i) {
        jiter( jobj, _arr[_i] )
    }
}

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

function ___json_unwrap(){

}

function ___json_join_handle_jpath(jpath,   _arr, _arrl, _i, _ret){
    _arrl = split(jpath, _arr, ".")
    _ret = ""
    for (_i = 1; _i<=_arrl; _i++) {
        if (_arr[_i] == "") continue
        if ( _i == 1 )  _ret = q(_arr[_i])
        else _ret = _ret S q(_arr[_i])
    }
    return _ret
}

# jjoin(arr, jpath, start:end, sep1)
# jjoin(arr, jpath, start:end, sep1, keystr, sep2)

BEGIN{
    JJOIN_KEYLIST_SEPERATOR="\001"
}

function jjoin_str_unquote2(str){
    if (str !~ /^"/) { # "
        return str
    }

    gsub(/\\\\/, "\001\001", str)
    gsub(/\\"/, /"/, str)
    gsub("\001\001", "\\\\", str)
    return substr(str, 2, length(str)-2)
}

function jjoin(arr, jpath, range, sep1, keystr, sep2,   _keyl, _key){
    if (keystr == "") {
        return _jjoin(arr, jpath, range, sep1)
    }

    _keyl = split(keystr, _key, S)
    for (_i=1; _i<=_keyl; ++_i) {
        _key[ _i ] = ___json_join_handle_jpath( _key[ _i ] )
    }

    return _jjoin(arr, jpath, range, sep1, _keyl, _key, sep2)
}

function jjoin_to_table( arr, jpath, range, sep1, keystr, sep2,   _keyl, _key ){
    if (keystr == "") {
        return _jjoin(arr, jpath, range, sep1)
    }

    _keyl = split(keystr, _key, S)

    _title = ""

    for (_i=1; _i<=_keyl; ++_i) {
        _e = _key[ _i ]
        if ( _e ~ /=/) {
            _idx = index(_e, "=")
            _e1 = substr(_e, 1, _idx-1)
            _e2 = substr(_e, _idx+1)

            _key[ _i ] = ___json_join_handle_jpath( _e2 )

        } else {
            _e1 = _e
            _key[ _i ] = ___json_join_handle_jpath( _e )
        }

        if (_i == 1) _title = _e1
        else _title = _title sep2 _e1
    }

    printf("%s", _title sep1)

    return _jjoin(arr, jpath, range, sep1, _keyl, _key, sep2)
}



function _jjoin(arr, jpath, range, sep1, _keyl, _key, sep2,
    _kp, _len, _i, _j, _range, _rangel, _start, _end, _step) {

    _kp = json_handle_jpath(jpath)

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
            # TODO: arr[ _kp S "\"" _i "\"" ] is null
            printf("%s", arr[ _kp S "\"" _i "\"" ])
            if (_i<_end) printf(sep1)
        }
        return
    }


    for (_i=_start; _i<=_end; _i = _i + _step) {

        printf("%s", jjoin_str_unquote2( arr[ _kp S "\"" _i "\"" S _key[1] ] ) )
        for (_j=2; _j<=_keyl; ++_j) {
            printf(sep2 "%s" , jjoin_str_unquote2( arr[ _kp S "\"" _i "\"" S _key[_j] ] ) )
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
    if (s != "{") return false
    arr[ keypath ] = T_DICT

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
        arr[ cur_keypath ] = _result

        if (s == ",") s = ___JSON_TMP_TOKENS[++s_idx]
    }
    arr[ keypath T_LEN ] = nth - 1  # starts from 1
    arr[ keypath T_KEY ] = _klist
    return true
}

function ___json_parse_walk_list(arr, keypath,
    nth, cur_keypath, _result){

    if (s != "[")   return false
    arr[ keypath ] = T_LIST

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
        arr[ cur_keypath ] = _result

        # TODO: just skip that token without judgement
        if (s == ",")   s = ___JSON_TMP_TOKENS[ ++s_idx ]
    }

    arr[ keypath T_LEN ] = nth - 1  # starts from 1
    return true
}

function ___json_parse_walk_value(arr, keypath,  _result){
    if (___json_parse_walk_dict(arr, keypath) == true) {
        return T_DICT
    }

    if (___json_parse_walk_list(arr, keypath) == true) {
        return T_LIST
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

function json_dict_rm(arr, keypath, key,  _key_str){
    _key_str = arr[ keypath T_KEY]
    if (match(_key_str, S key)){
        arr[ keypath T_KEY ] = substr(_key_str, 1, RSTART - 1) substr(_key_str, RSTART + RLENGTH)
        arr[ keypath T_LEN ] = arr[ keypath T_LEN ] - 1
    }
}

# TODO: We should quote
function json_dict_push(arr, keypath, key, value,  _v){
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
    arr[ keypath S "\"" _l "\""] = value
    arr[ keypath T_LEN ] = _l
}

function json_list_has(arr, keypath, value,  _l, _i) {
    _l = arr[ keypath T_LEN ]
    for (_i=1; _i<=_l; ++_i) {
        if ( arr[keypath S "\""_i "\"" ] == value ) {
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

function json_list_len(arr, keypath){
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
        keypath=json_handle_jpath(keypath)
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

    _l = json_dict_keys(arr, keypath, _klist)

    if (_l == 0) return "{\n}"
    _key = _klist[ 1 ]
    _val = arr[ keypath S _key ]
    _ret = _key "\n:\n" _val

    for (_i=2; _i<=_l; _i++){
        _key = _klist[ _i ]
        _val = arr[ keypath S _key ]
        _ret = _ret "\n,\n" _key "\n:\n" ___json_stringify_machine_value( arr, keypath S _key )
    }
    _ret = substr(_ret, 7)
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
        keypath=json_handle_jpath(keypath)
        return ___json_stringify_machine_value(arr, keypath)
    }
    _len = arr[ T_LEN ]
    if (_len < 1)  return ""

    for (_i=1; _i<=_len; ++_i) {
        _ret = _ret "\n"___json_stringify_machine_value( arr,  S "\"" _i "\"")
    }
    return _ret
}
# EndSection

# Section: Format Stringify
function ___json_stringify_format_dict(arr, keypath, indent,    _klist, _l, _i, _key, _val, _ret){

    _l = json_dict_keys(arr, keypath, _klist)

    if (_l == 0) return "{ }"

    for (_i=2; _i<=_l; _i++){
        _key = _klist[ _i ]
        _val = arr[ keypath S _key ]
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
    INDENT_LEN = indent

    if (keypath != "") {
        keypath=json_handle_jpath(keypath)
        return ___json_stringify_format_value(arr, keypath, indent)
    }

    _len = arr[ T_LEN ]
    if (_len < 1)  return ""

    for (_i=1; _i<=_len; ++_i) {
        _ret =  _ret "\n" ___json_stringify_format_value( arr, S "\"" _i "\"", indent )
    }

    return _ret
}
# EndSection

# Section: filter
function json_filter(obj, keypath, key, reg,      _k, _len, _ret){
    _k = keypath
    keypath = json_handle_jpath(keypath)
    if (obj[ keypath ] == T_LIST) {
        _len = obj[ keypath T_LEN ]
        if (_len > 0) {
            for(_i=1; _i<=_len; ++_i){
                if( match(jjoin_str_unquote2(obj[json_handle_jpath(_k "." _i key)]), reg)){
                    _ret = _ret "\n" json_stringify_format(obj, _k "." _i, 4)
                }
            }
            _ret = substr(_ret, 2)
            return _ret
        }
    } else {
        exit(0)
        return
    }
}

# EndSection

# Section: return json list's key value
    # type: return format, compact or machine stringify
function json_get_list_value(obj, keypath, key, type, arr,      _k, _i, _len, _ret, _list_key_arr){
    _k = keypath
    keypath = json_handle_jpath(keypath)

    if (obj[ keypath ] == T_LIST) {
        _len = obj[ keypath T_LEN ]
        if (_len > 0) {
            for (_i=1; _i<=_len; ++_i) {

                if (type == "format") {
                    _list_key_arr = json_stringify_format(obj, _k "." _i key, 4)
                } else if (type == "compact") {
                    _list_key_arr = json_stringify_compact(obj, _k "." _i key, 4)
                } else {
                    _list_key_arr = json_stringify_machine(obj, _k "." _i key, 4)
                }

                if (_list_key_arr != ""){
                    arr[ _i ] = _list_key_arr
                    _ret = _ret "\n" _list_key_arr
                }
            }
            _ret = substr(_ret, 2)
            # print _ret
            return _ret
        }else {
            exit(0)
            return
        }
    } else {
        exit(0)
        return
    }
}

# EndSection

# Section: jiter

BEGIN{
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""   # keypath
}

function init_jiter(){
    JITER_FA_KEYPATH = ""
    JITER_STATE = T_ROOT
    JITER_LAST_KP = ""
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""
    JITER_CURLEN = 0

    JITER_LAST_KL = ""
}

function jiter( obj, item ){

    if (item ~ /^[,:]*$/) {
        return
    } else if (item ~ /^[tfn"0-9+-]/) { #"
    # } else if (item !~ /^[\{\}\[\]]$/) {
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != T_DICT ) {
            obj[ JITER_FA_KEYPATH S "\"" JITER_CURLEN "\"" ] = item
        } else {
            if ( JITER_LAST_KP != "" ) {
                JITER_CURLEN = JITER_CURLEN - 1
                obj[ JITER_FA_KEYPATH S JITER_LAST_KP ] = item
                JITER_LAST_KP = ""
            } else {
                JITER_LAST_KP = item
                obj[ JITER_FA_KEYPATH T_KEY ] = obj[ JITER_FA_KEYPATH T_KEY ] S item
            }
        }
    } else if (item ~ /^\[$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_LIST
        JITER_CURLEN = 0

        obj[ JITER_FA_KEYPATH ] = T_LIST

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else if (item ~ /^\]$/) {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    } else if (item ~ /^\{$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_DICT
        JITER_CURLEN = 0

        obj[ JITER_FA_KEYPATH ] = T_DICT

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else if (item ~ /^\}$/) {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    }
}

# EndSection

# Section: jiter_

function init_jiter_(){
    JITER_FA_KEYPATH = ""
    JITER_STATE = T_ROOT
    JITER_LAST_KP = ""
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""
    JITER_CURLEN = 0

    JITER_LAST_KL = ""
}

function jiter_( item ){
    # efficiency defect 1%
    jiter( _, item )
}

# EndSection


# Section: jiter_print_exact

BEGIN{
    START_PRINT=0
    START_PRINT_S = 0
    START_PRINT_B = 0
}

function _jiter_print_exact_setprint(kp, key){
    if (kp == key) {
        START_PRINT = 1
    }
}

# TODO: Optimize. If key not match, then we SKIP.
function jiter_print_exact( obj, item, key ){
    if (START_PRINT == 2) {
        exit(0)
        return
    }

    if (START_PRINT == 1) {

        if (item ~ /^\[$/) {
            START_PRINT_S = START_PRINT_S + 1
        } else if (item ~ /^\]$/) {
            START_PRINT_S = START_PRINT_S - 1
        } else if (item ~ /^\{$/) {
            START_PRINT_B = START_PRINT_B + 1
        } else if (item ~ /^\}$/) {
            START_PRINT_B = START_PRINT_B - 1
        }

        if ( (START_PRINT_B == 0) && (START_PRINT_S == 0) ) {
            START_PRINT = 2
        }

        print item

        # if (START_PRINT == 2) {
        #     # print item
        # } else {
        #     print item
        # }

        return
    }

    if (item ~ /^[,:]*$/) {
        return
    } else if (item ~ /^[tfn"0-9+-]/) { #"
    # } else if (item !~ /^[\{\}\[\]]$/) {
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != T_DICT ) {
            # start printing
            # print JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""  "\t" item
            if ( JITER_FA_KEYPATH S "\"" JITER_CURLEN "\"" == key ) {
                print item
                START_PRINT = 2
            }
        } else {
            if ( JITER_LAST_KP != "" ) {
                # start printing
                # print JITER_FA_KEYPATH S JITER_LAST_KP "\t" item
                if ( JITER_FA_KEYPATH S JITER_LAST_KP == key ) {
                    print item
                    START_PRINT = 2
                }
                JITER_LAST_KP = ""
            } else {
                JITER_LAST_KP = item
            }
        }
    } else if (item ~ /^\[$/) {
        JITER_CURLEN = JITER_CURLEN + 1
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
        if ( JITER_STATE != T_DICT ) {
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_LIST
        JITER_CURLEN = 0

        # start-printing
        if (JITER_FA_KEYPATH == key) {
            START_PRINT_S = START_PRINT_S + 1
            START_PRINT = 1
            print item
        }
        obj[ JITER_FA_KEYPATH ] = T_LIST

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else if (item ~ /^\]$/) {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    } else if (item ~ /^\{$/) {
        JITER_CURLEN = JITER_CURLEN + 1
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
        if ( JITER_STATE != T_DICT ) {
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_DICT
        JITER_CURLEN = 0

        # start-printing
        if (JITER_FA_KEYPATH == key) {
            START_PRINT_B = START_PRINT_B + 1
            START_PRINT = 1
            print item
        }
        obj[ JITER_FA_KEYPATH ] = T_DICT

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else if (item ~ /^\}$/) {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    }
}

function jiter_print_exact_after_tokenize(jobj, text, key,      _arr, _arrl, _i){
    _arrl = split( json_to_machine_friendly(text), _arr, "\n" )
    for (_i=1; _i<=_arrl; ++_i) {
        jiter_print_exact( jobj, _arr[_i], key )
    }
}

# EndSection

