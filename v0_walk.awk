BEGIN{
    false = 0;      true = 1;   true2 = 2;

    RS="\034"

    KEYPATH_SEP = "\034"
    # KEYPATH_SEP = ","

    enable_comment_parsing = false
    enable_pseudo_string = true

    OP_DEL          = 1
    OP_LENGTH       = 2
    OP_PUTVAL       = 3
    OP_PUTKV        = 4
    OP_PREPEND      = 5
    OP_APPEND       = 6
    OP_POP          = 7

    OP_REPLACE      = 60
    OP_EXTRACT      = 61
    OP_FLAT         = 62
    OP_FLAT_LEAF    = 63

    if (compact != false)   out_compact = true;
    else    out_compact = false

    if (color != false)     out_color = true

    if (format != false)    out_format = true;  # Using compilation switch to enable or disable code
    else                    out_format = false

    out_indent_step = 2
    out_indent_space = "  "

    if (out_color_key == 0)     out_color_key = "\033[0;33m"
    if (out_color_string == 0)  out_color_string = "\033[0;36m"
    if (out_color_number == 0)  out_color_number = "\033[1;32m"
    if (out_color_null == 0)    out_color_null = "\033[1;35m"   # "\033[0;31m"
    if (out_color_true == 0)    out_color_true = "\033[7;32m"
    if (out_color_false == 0)   out_color_false = "\033[7;31m"

    inner_content_generate = true  # For extract
}

function unwrap(str){
    if (substr(str, 1) != "\"") return str
    gsub(/\\"/, "\"", str) #"
    gsub("\\n", "\n", str) #"
    gsub("\\t", "\t", str) #"
    gsub("\\v", "\v", str) #"
    gsub("\\b", "\b", str) #"
    gsub("\\r", "\r", str) #"
    return substr(str, 2, length(str)-2)
}

function _query_(s,       KEYPATH_SEP,    arr, tmp, idx, n, item){
    if (KEYPATH_SEP == 0) KEYPATH_SEP = "\034"

    if (s == ".")  return "0"

    s1 = s

    gsub(/\\\\/, "\001\001", s)
    gsub(/\\"/, "\002\002", s)  # "
    gsub(/\\\./, "\003\003", s)

    # gsub(/\./, "\034", s)
    # gsub(/\./, "|", s) # for debug

    n = split(s, arr, ".")
    if (arr[1] == "") tmp = 0
    else tmp = arr[1]
    for (idx=2; idx<=n; idx ++) {
        item = arr[idx]
        if ( match( item, /\/[^\/]+\// ) ) {
            tmp = tmp KEYPATH_SEP "\"(" substr(item, 2, length(item)-2) ")\""
            # tmp = tmp KEYPATH_SEP substr(item, 2, length(item)-2)
        } else if ( (match( item, /(^\[)|(^")|(^\*$)|(^\*\*$)/ ) == false) ) {   #"
            tmp = tmp KEYPATH_SEP "\"" item "\""
        } else {
            tmp = tmp KEYPATH_SEP item
        }
    }
    s = tmp

    gsub("\003\003", ".", s)
    gsub("\002\002", "\\\"", s)  # "
    gsub("\001\001", "\\\\", s)

    # gsub(/\*/, "[^|]+", s)   # for debug
    # gsub(/\*\*/, "([^|]+|)*[^|]+", s)    # for debug

    gsub(/\*/, "[^" KEYPATH_SEP "]*", s) #gsub(/\*/, "[^\034]+", s)
    gsub(/\*\*/, "([^" KEYPATH_SEP "]*" KEYPATH_SEP ")*[^" KEYPATH_SEP "]*", s) # gsub(/\*\*/, "([^\034]+\034)*[^\034]+", s)

    # gsub(/\*/, "[^" KEYPATH_SEP "]+", s) #gsub(/\*/, "[^\034]+", s)
    # gsub(/\*\*/, "([^" KEYPATH_SEP "]+" KEYPATH_SEP ")*[^" KEYPATH_SEP "]+", s) # gsub(/\*\*/, "([^\034]+\034)*[^\034]+", s)


    # gsub(/"[^"]+"/, "([^\034]+\034)*[^\034]+", s)   #"
    return s
}

function query(s,       KEYPATH_SEP) {
    return "^" _query_(s, KEYPATH_SEP) "$"
}

function query_split(formula, KEYPATH_SEP,    arr, len, final){
    formula = _query_(formula, KEYPATH_SEP)
    len = split(formula, arr, KEYPATH_SEP)
    final = arr[1]
    for (idx=2; idx<len; idx ++) {
        final = final KEYPATH_SEP arr[idx]
    }
    QUERY_SPLIT_FA = "^" final "$"
    QUERY_SPLIT_KEY = arr[len]
    return true
}

function debug(msg){
    if (dbg == false) return
	print "idx[" s_idx "]  DEBUG:" msg > "/dev/stderr"
}

function json_walk_panic(msg,       start){
    start = s_idx - 10
    if (start <= 0) start = 1
    print ("value " _ord_[substr(s, s_idx, 1)]) > "/dev/stderr"
    print (msg " [index=" s_idx "]:\n-------------------\n" substr(text, start, s_idx - start)  "|"  substr(text, s_idx, 1) "|" substr(text, s_idx+1, 30) "\n-------------------") > "/dev/stderr"
    exit 1
}

function json_walk_pseudo_string_idx(     ss, pos){
    ss = substr(s, s_idx, 64)

    match(ss, /(^"[^"]*"?)|(^[^\n#\/\[{}\],:]*[^\n #\/\[{}\],:])/)   # " TO Try ... Maybe it will slow down the system
    # match(ss, /(^"[^"]*"?)|(^[^\n\ #\/\[{}\],:]+)/)
    # match(ss, /(^"[^"]*"?)|(^[A-Za-z0-9_-\/$]+)/)
    
    if (RLENGTH <= 0) return false

    if (RLENGTH != 64) {
        result = substr(text, s_idx, RLENGTH)
        s_idx += RLENGTH
        if (match(result, /^"/) == false) return true2      #"
        # result = "\"" result "\""
        return true
    }

    # match(substr(s, s_idx), /(^"[^"]*")|(^[A-Za-z0-9_-\/$]+)/);   
    match(substr(s, s_idx), /(^"[^"]*")|(^[^\n#\/\[{}\],:]*[^\n #\/\[{}\],:])/)   # " # TO Try ... Maybe it will slow down the system
    # match(substr(s, s_idx), /(^"[^"]*"?)|(^[^\n\ #\/\[{}\],:]+)/)   # "
    pos = RLENGTH  # index() is no way better then match()
    if (pos <= 0) return false; # json_walk_panic("json_walk_string_idx() Expect \"")

    # TODO. Optimize
    if (match(ss, /^"/) == false) return true2      #"
    s_idx += pos
    return true
}

# If found not starts with ", go to another pattern.
# Check true, false, null, number, then try string.

function json_walk_strict_string_idx(     pos){
    # debug("json_walk_string start() ")

    match(substr(s, s_idx, 64), /^("[^"]*"?)/)  # "
    if (RLENGTH <= 0) return false
    # if (substr(s, s_idx + RLENGTH - 1, 1) == "\"") { # Performance defect design
    if (RLENGTH != 64) {
        s_idx += RLENGTH
        return true
    }

    s_idx ++
    # match(substr(s, s_idx), /[^"]+"/);    pos = RLENGTH  # index() is no way better then match()
    pos = index(substr(s, s_idx), "\"")
    if (pos <= 0) return false; # json_walk_panic("json_walk_strict_string_idx() Expect \"")

    s_idx += pos
    return true
}

function json_walk_string_idx(){
    if (enable_pseudo_string == true) {
        return json_walk_pseudo_string_idx()
    }
    return json_walk_strict_string_idx()
}

function json_walk_empty(   sw, o_idx, oo_idx){
    if (enable_comment_parsing == false) {
        o_idx = s_idx
        sw = json_walk_empty0()
        if (out_compact == true) {
            result = ""
        } else {
            result = substr(text, o_idx, s_idx - o_idx)
        }
        return sw
    }

    sw = false
    oo_idx = s_idx
    while (1) {
        o_idx = s_idx
        json_walk_empty0()
        json_walk_comment()
        if (o_idx == s_idx) break
        sw = true
    }

    if (sw == true) {
        if (out_compact == true) {
            result = ""
        } else {
            result = substr(text, oo_idx, s_idx - oo_idx)
        }
    }
    return sw
}

function json_walk_comment(     ss, pos){
    ss = substr(s, s_idx, 2)
    # debug("json_walk_comment() starts ->" ss)

    # TODO: Using preload tecknique to accelerate
    if (( ss == "//") || (substr(s, s_idx, 1) == "#") ) {
        pos = index(substr(s, s_idx), "\n")
        if (pos <= 0) {
            s_idx = s_len + 1
        } else {
            s_idx += pos
        }
        
        return true
    }

    if ( ss == "/*" ) {
        pos = index(substr(s, s_idx), "*/")
        if (pos <= 0) json_walk_panic("json_walk_comment() Expect */")
        s_idx += pos + 1    # Notice "*/"
        return true
    }
    return false
}

function json_walk_empty0(   o_idx){
    # if (substr(s, s_idx, 1) != " ") return false
    match(substr(s, s_idx, 16), /^[ \n]+/)
    if (RLENGTH <= 0) return false
    o_idx = s_idx
    if (RLENGTH == 16) {   
        s_idx += 16
        match(substr(s, s_idx), /^[ \n]+/)
    }
    if (RLENGTH > 0) s_idx += RLENGTH
    return true
}

# tmp1, tmp2, tmp3 are for putkv
function json_walk_dict(keypath, indent,        
    ret, cur_indent, cur_keypath, comma_sw, nth, o_idx,
    enable_delete, enable_putkv, key_result, val_result, tmp, tmp0, tmp1, tmp2, tmp3, tmp4 ){

    if (substr(s, s_idx, 1) != "{") {
        # debug("json_walk_dict() fails" )
        return false
    }
    s_idx ++;

    ret = "{"
    
    nth = 0
    cur_indent = indent out_indent_space

    # Notice: putkv code
    if ( op == OP_PUTKV ) {
        if (match(keypath, opv1)) {
            enable_putkv = 1
            op = 0; opv3 = json_walk(opv3, cur_indent)
            op = OP_PUTKV
        }
    }
    # Notice: putkv code - END

    if ( (op == OP_DEL) && (match(keypath, opv1)) ) {
        enable_delete = 1
    }

    comma_sw = ""
    while (1) {
        tmp0 = "";  if (json_walk_empty() == true) tmp0 = result     # optional

        if (substr(s, s_idx, 1) == "}") {
            # Notice: putkv code
            if ( enable_putkv == 1 ) {
                if (out_format) ret = ret comma_sw "\n" cur_indent  opv2bak         ": "        opv3
                else            ret = ret comma_sw tmp1             opv2bak tmp2    ":" tmp3    opv3
                nth ++
            }
            # Notice: putkv code - END

            if (inner_content_generate) {
                if (out_format == true) {
                    if (nth == 0) ret = ret tmp0 "}"
                    else ret = ret "\n" indent "}"
                } else {
                    ret = ret tmp0 "}"
                }
            }
            s_idx ++;  break
        }

        nth ++
        tmp1 = tmp0
        o_idx = s_idx
        tmp = json_walk_string_idx()
        if (tmp == false) {    # key
            json_walk_panic("json_walk_dict() Expect a key")
        } else if (tmp == true) {
            key_result = substr(text, o_idx, s_idx - o_idx)
        } else {
            key_result = "\"" substr(text, o_idx, s_idx - o_idx) "\""
        }

        cur_keypath = keypath KEYPATH_SEP key_result
        if ( enable_delete == 1 ) {
            if (match(key_result, "^" opv2 "$")) {
                enable_delete = 2
                inner_content_generate = false  # optimize
            }
        }

        if (inner_content_generate) {
            # if.def color
            if (out_color == true) key_result = out_color_key key_result "\033[0m"
            # end.if[]
        }

        tmp2 = "";      if (json_walk_empty() == true)  tmp2 = result     # optional        
        if (substr(s, s_idx, 1) != ":") json_walk_panic("json_walk_dict() Expect :")
        s_idx ++;

        tmp3 = "";      if (json_walk_empty() == true)  tmp3 = result    # optional
        # Notice: putkv code
        if (enable_putkv == 1) {
            if (opv2bak == key_result) {
                enable_putkv = 2
                inner_content_generate = false
            }
        }
        # # Notice: putkv code - END

        json_walk_value(cur_keypath, cur_indent) # if (json_walk_value() == false)  json_walk_panic("json_walk_dict() Expect a value")

        # Notice: putkv code
        if (enable_putkv == 2) {
            enable_putkv = 3
            inner_content_generate = true
            val_result = opv3
        } else {
            val_result = result
        }
        # # Notice: putkv code - END

        tmp4 = "";  if (json_walk_empty() == true) tmp4 = result     # optional

        if (inner_content_generate == true) {
            if (out_format == true) ret = ret comma_sw "\n" cur_indent  key_result      ": "        val_result
            else                    ret = ret comma_sw tmp1             key_result tmp2 ":" tmp3    val_result tmp4
        }

        if (substr(s, s_idx, 1) == ",") s_idx ++; # TODO: We have to check it for some error.

        if (enable_delete == 2)  {
            inner_content_generate = true
            enable_delete = 1
        } else {
            comma_sw = ","
        }
    }

    if (inner_content_generate)   result = ret

    if ( (op == OP_LENGTH) && (match(keypath, opv1))) {
        print nth
    }

    return true
}

function json_walk_array(keypath, indent,       cur_indent, data, nth, count, cur_item, last_item, tmp, sp0, sp1, sp2){
    # debug("json_walk_array start() ")
    if (substr(s, s_idx, 1) != "[") return false
    s_idx ++

    nth = -1
    cur_indent = indent out_indent_space

    while (1) {
        sp0 = "";   if (json_walk_empty() == true) sp0 = result   # optional

        nth ++

        if (substr(s, s_idx, 1) == "]") {
            if (inner_content_generate) {
                if (out_format == true) {
                    if (nth == 0) last_item = "]"
                    else last_item = "\n" indent "]"
                } else {
                    last_item = sp0 "]"
                }
            }
            s_idx ++;   break
        }

        sp1 = sp0 
        if (inner_content_generate) {
            if (out_format == true) sp1 = "\n" cur_indent
        }

        json_walk_value(keypath KEYPATH_SEP nth, cur_indent)  # if (json_walk_value() == false)  json_walk_panic("json_walk_array() Expect a value")
        cur_item = result

        sp2 = "";   if (json_walk_empty() == true) sp2 = result    # optional
        if (substr(s, s_idx, 1) == ",") s_idx ++;

        if ( (nth==0) && (op == OP_PREPEND) && (match(keypath, opv1)) ) {
            op = 0
            if (out_format == true)     data[nth++] = "\n" cur_indent   json_walk(opv2, cur_indent)
            else                        data[nth++] = sp1               json_walk(opv2, cur_indent) sp2
            op = OP_PREPEND
        }

        if (out_format == true)     data[nth] = "\n" cur_indent cur_item
        else                        data[nth] = sp1             cur_item sp2
    }

    count = nth

    if ( (op == OP_LENGTH) && (match(keypath, opv1))) {
        print nth
    } else if ((op == OP_DEL) && (match(keypath, opv1)) && (match(opv2, /^\[[0-9]+\]$/))) {
        tmp = int(substr(opv2, 2, length(opv2) - 2))
        # print data[tmp]
        for (; tmp < count; tmp ++ ){
            data[tmp] = data[tmp+1]
        }
        count --
    } else if ((op == OP_APPEND) && (match(keypath, opv1)) ) {
        op = 0
        data[nth] = sp1 json_walk(opv2, cur_indent) sp2
        op = OP_APPEND
        nth ++
        count ++
    } else if ((op == OP_POP) && (match(keypath, opv1)) ) {
        # print data[nth-1]
        data[--nth] = ""
        count --
    } else if ((op == OP_PUTVAL) && (match(keypath, opv1)) ) {
        opv2 = int(opv2)
        if (out_format == true)     data[opv2] = "\n" cur_indent opv3
        else                        data[opv2] = sp1             opv3 sp2
        if (opv2 >= nth) {
            nth = opv2 + 1
            count = opv2 + 1
        }
    }

    if (inner_content_generate)   {
        result = "[";   comma = ""
        for (tmp=0; tmp<nth; tmp++) {
            cur_item = data[tmp]
            if (cur_item != "")  {
                result = result comma cur_item
                comma = ","
            }
        }
        if (out_format == true) {
            if (count == 0)     result = result "]"
            else                result = result "\n" indent "]"
        } else {
            result = result sp0 "]"
        }
    }

    return true
}

function json_walk_number(      o_idx, ch) {
    # if (substr(s, s_idx, 1) != "0") return false
    match(substr(s, s_idx, 8), /^0+/)
    if (RLENGTH <= 0) return false
    o_idx = s_idx
    if (RLENGTH == 8) {
        s_idx += 8
        match(substr(s, s_idx), /^0+/)
    }
    if (RLENGTH > 0)   s_idx += RLENGTH
    
    if ( (enable_pseudo_string)  ) { 
        if (match(substr(s, s_idx, 1), /[ \n,\]\}]/) == 0) {
            s_idx = o_idx
            return false
        }
    }

    # if.def color
    if (inner_content_generate) {
        if (out_color == true)  result = out_color_number substr(text, o_idx, s_idx - o_idx) "\033[0m"
        else                    result = substr(text, o_idx, s_idx - o_idx)
    }
    # end.if
    # debug("json_walk_number() return true " RLENGTH)
    return true
}

function json_walk_primitive(     tmps){
    if (json_walk_number() == true) return true

    # true => tru0, false => fals0
    tmps = substr(s, s_idx, 4)
    if (tmps == "tru0") {
        s_idx += 4
        if (inner_content_generate) {
            # if.def color
            if (out_color == true)  result = out_color_true "true" "\033[0m"
            else                    result = "true"
            # end.if
        }
        return true
    } 
    
    if (tmps == "null") {
        s_idx += 4
        if (inner_content_generate) {
            # if.def color
            if (out_color == true)  result = out_color_null "null" "\033[0m"
            else                    result = "null"
            # end.if
        }
        return true
    } 
    
    if ( substr(s, s_idx, 5) == "fals0" ) {
        s_idx += 5;
        if (inner_content_generate) {
            # if.def color
            if (out_color == true)  result = out_color_false "false" "\033[0m"
            else                    result = "false"
            # end.if
        }
        return true
    }
    return false
}

# TODO: make it better ... It will slow down the performance ...
function json_walk_value(keypath, indent,    
    res, keypath_tmp_arr, keypath_tmp_arr_len){
    if ( op < OP_REPLACE ) return json_walk_value_(keypath, indent)
    else if (op == OP_REPLACE) {
        if (match(keypath, opv1)){
            inner_content_generate = false
            res = json_walk_value_(keypath, indent)

            inner_content_generate = true
            result = json_walk(opv2, indent)
            return res
        }
    } else if (op == OP_EXTRACT) {
        if (match(keypath, opv1)) {
            inner_content_generate = true
            res = json_walk_value_(keypath, indent)
            if (opv2 == "kv") { print keypath "\t-->\t" result }
            else if (opv2 == "k") { 
                keypath_tmp_arr_len = split(keypath, keypath_tmp_arr, KEYPATH_SEP)
                print keypath_tmp_arr[keypath_tmp_arr_len]
            }
            else if (opv2 == "k-r") { 
                keypath_tmp_arr_len = split(keypath, keypath_tmp_arr, KEYPATH_SEP)
                print unwrap(keypath_tmp_arr[keypath_tmp_arr_len])
            }
            else if (opv2 == "v-r") { 
                print unwrap(result)
            }
            else  { print result }
            inner_content_generate = false
            return res
        }
    } else if (op == OP_FLAT) {
        inner_content_generate = true
        res = json_walk_value_(keypath, indent)
        print keypath "\t--->\t"  result
        return res
    } else if (op == OP_FLAT_LEAF) { 
        inner_content_generate = true
        res = json_walk_value_(keypath, indent)
        if (result) print keypath "\t--->\t"  result
        inner_content_generate = false
        return res
    }

    return json_walk_value_(keypath, indent)
}

# string | primitive | dict | array
function json_walk_value_(keypath, indent,     o_idx, tmp){

    o_idx = s_idx
    # Must before the json_walk_string in case of pseudostring enable
    # NOTE: Number Boolean null parse
    if (json_walk_primitive() == true) {
        return true
    }

    tmp = json_walk_string_idx()
    if (tmp != false) {    # key
        if (inner_content_generate) {
            # if.def color
            if (tmp == true) result = substr(text, o_idx, s_idx - o_idx)
            else result = "\"" substr(text, o_idx, s_idx - o_idx) "\""  # true 2
            if (out_color == true) result = out_color_string result "\033[0m"
            # end.if
        }
        return true
    }

    if ( op == "flat-leaf" ) {
        inner_content_generate = false
        result = false
    }

    if (json_walk_dict(keypath, indent) == true) return true
    if (json_walk_array(keypath, indent) == true) return true

    json_walk_panic("json_walk_value() Expect a value")
    return false
}

function _json_walk(keypath, indent,   
    final, idx, nth){

    final = ""

    nth = 0
    while (s_idx <= s_len) {
        idx = s_idx
        
        if (json_walk_empty() == true) {     # optional
            # Do some thing in stringify()
        }

        result = ""
        if (json_walk_value(nth++, indent) == false) {
            # debug("json_walk_value() Out -> " s_idx " : " )
            # break
            return
        }

        if (final == "") final = result
        else final = final "\n" result
        # consume value: Do some thing in stringify()

        if (json_walk_empty() == true) {     # optional
            # Do some thing in stringify()
        }

        if (s_idx == idx) {
            json_walk_panic("json_walk() Expect a value")
        }
    }

    return final
}

# global variable: text, s, s_idx, s_len
function json_walk(text_to_parsed,          json_indent,        b_s, b_result, b_s_idx, b_s_len, b_text, final){
    b_result = result;  b_text = text;
    b_s = s;    b_s_idx = s_idx;    b_s_len = s_len;

    result = "";        text = text_to_parsed;  

    # if (out_compact == true) {
    #     gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
	#     gsub("\n" "[ \t\n\r]+", "\n", text)
    # }

    s = text;   s_idx = 1;          s_len = length(s)
    
    if (json_indent == 0) json_indent = ""

    out_indent_space=sprintf("%" out_indent_step "s", "")

    gsub(/\\\\/, "__", s)
    gsub(/\\"/, "__", s)    #"
    gsub(/[0123456789eE\.\+\-]/, 0, s) # number value
    
    gsub(/[\t\b\r\v]/, " ", s)

    final = _json_walk("", json_indent)

    result = b_result;
    text = b_text;  s = b_s;    s_idx = b_s_idx;    s_len = b_s_len;

    JSON_WALK_KP_IDX = JSON_WALK_KP_IDX_BAK
    JSON_WALK_KEY_PATH = JSON_WALK_KEY_PATH_BAK
    JSON_INDENT = JSON_INDENT_BAK
    
    return final
}

{
    if (color != false)     out_color = true
    else                    out_color = false

    # if (out_format) out_compact = true
    if ( out_format != false ) out_compact = true

    if (op == "flat-leaf") {
        op = OP_FLAT_LEAF
        if (opv1 == false)      KEYPATH_SEP = "\t"
        else                    KEYPATH_SEP = opv1
        inner_content_generate = false

        json_walk($0)
        exit 0
    }


    if (op == "flat") {
        op = OP_FLAT
        out_compact = true
        out_format = false
        if (opv1 == false)  KEYPATH_SEP = "\t"
        else                KEYPATH_SEP = opv1
        # out_color = false
        inner_content_generate = true
        json_walk($0)
        exit 0
    }

    if (op == "values") {
        op = "extract"
        debug("op_original_pattern: " opv1)
        opv1 = opv1 ".*"
    }

    if (op == "values-r") {
        op = "extract"
        opv2 = "v-r"
        debug("op_original_pattern: " opv1)
        opv1 = opv1 ".*"
    }

    if (op == "keys") {
        op = "extract"
        opv2 = "k"
        debug("op_original_pattern: " opv1)
        if (opv1 ~ /\.$/) {
            opv1 = opv1 "*"
        } else {
            opv1 = opv1 ".*"
        }
    }

    if (op == "keys-r") {
        op = "extract"
        opv2 = "k-r"
        debug("op_original_pattern: " opv1)
        if (opv1 ~ /\.$/) {
            opv1 = opv1 "*"
        } else {
            opv1 = opv1 ".*"
        }
    }

    if (op == "extract") {
        out_compact = true
        out_format = false
        inner_content_generate = false
        debug("op_original_pattern: " opv1)
        opv1 = query(opv1, KEYPATH_SEP)
        debug("op_pattern: " opv1)
        op = OP_EXTRACT
        json_walk($0)
        exit 0
    }

    if (op == "replace") {
        op = OP_REPLACE
        opv1 = query(opv1, KEYPATH_SEP)
        # opv2 = json_walk(opv2)
        debug("op_pattern: " opv1)
        print json_walk($0)
        exit 0
    }

    if (op == "shift") {
        op = "del"
        if (opv1 == ".") { opv1 = ".[0]" }
        else opv1 = opv1 ".[0]"
        debug("op_pattern: " opv1)
    }

    if (op == "del") {
        op = OP_DEL
        query_split(opv1, KEYPATH_SEP)
        opv1 = QUERY_SPLIT_FA
        opv2 = QUERY_SPLIT_KEY
        debug("op_pattern: " opv1)
        inner_content_generate = true
        print json_walk($0)
        exit 0
    }

    if (op == "length") {
        op = OP_LENGTH
        opv1 = query(opv1, KEYPATH_SEP)
        debug("op_pattern: " opv1)
        inner_content_generate = false
        json_walk($0)
        exit 0
    }

    # If it is done, it will substitute the replace function.
    if (op == "put") {
        opv3 = opv2
        query_split(opv1, KEYPATH_SEP)
        opv1 = QUERY_SPLIT_FA
        opv2 = QUERY_SPLIT_KEY

        if (match(opv2, /^\[[0-9]+\]/)) {
            opv2=int(substr(opv2, 2, length(opv2)-2))
            op = OP_PUTVAL
        } else {
            op = OP_PUTKV
            if (out_color) opv2bak = out_color_key opv2 "\033[0m"
            else opv2bak = opv2
        }

        debug("op: " op)
        debug("op_pattern: " opv1)
        debug("op_key: " opv2)
        debug("op_value: " opv3)
        inner_content_generate = true
        print json_walk($0)
        exit 0
    }

    if (op == "prepend") {
        opv1 = query(opv1, KEYPATH_SEP)
        debug("prepend --- op_pattern: " opv1)
        inner_content_generate = true
        op = OP_PREPEND
        print json_walk($0)
        exit 0
    }

    if (op == "append") {
        op = OP_APPEND
        opv1 = query(opv1, KEYPATH_SEP)
        inner_content_generate = true
        print json_walk($0)
        exit 0
    }

    if (op == "pop") {
        op = OP_POP
        opv1 = query(opv1, KEYPATH_SEP)
        inner_content_generate = true
        print json_walk($0)
        exit 0
    }

    # if (op == "preppend") {
    #     opv1 = query(opv1, KEYPATH_SEP)
    #     print json_walk($0)
    #     exit 0
    # }

    # if (op == "append") {
    #     opv1 = query(opv1, KEYPATH_SEP)
    #     print json_walk($0)
    #     exit 0
    # }

    inner_content_generate = true
    print json_walk($0)
}
