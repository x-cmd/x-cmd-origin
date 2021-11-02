BEGIN{
    false = 0;      true = 1

    out_color = false
    out_format = true;  # Using compilation switch to enable or disable code
    out_indent_step = 2
    out_indent_space = "  "

    if (out_color_key == 0)     out_color_key = "\033[0;35m"
    if (out_color_string == 0)  out_color_string = "\033[0;34m"
    if (out_color_number == 0)  out_color_number = "\033[0;32m"
    if (out_color_null == 0)    out_color_null = "\033[0;33m"   # "\033[0;31m"
    if (out_color_true == 0)    out_color_true = "\033[7;32m"
    if (out_color_false == 0)   out_color_false = "\033[7;31m"

    RS="\034"
    KEYPATH_SEP = "\034"

    inner_content_generate = true
}

function debug(msg){
    if (dbg == false) return
	print "idx[" s_idx "]  DEBUG:" msg > "/dev/stderr"
}

function json_walk_panic(msg,       start){
    start = s_idx - 10
    if (start <= 0) start = 1
    print (msg " [index=" s_idx "]:\n-------------------\n" JSON_TOKENS[s_idx -2] "\n" JSON_TOKENS[s_idx -1] "\n" s "\n" JSON_TOKENS[s_idx + 1] "\n-------------------") > "/dev/stderr"
    exit 1
}

function json_walk_dict(keypath, indent,    
    ret, nth, cur_keypath, cur_indent, key, value, comma){

    if (s != "{") {
        # debug("json_walk_dict() fails" )
        return false
    }
    
    nth = -1
    ret = "{"
    s = JSON_TOKENS[++s_idx]
    comma = ""

    cur_indent = indent    out_indent_space
    
    while (1) {
        nth ++
        if (s == "}") {
            if (out_format == true) {
                if (nth == 0) {
                    ret = ret "}"
                } else {
                    ret = ret "\n" indent "}"
                }
            } else {
                ret = ret "}"
            }
            s = JSON_TOKENS[++s_idx];  break
        }

        # if (s == ":") { json_walk_panic("json_walk_dict() Expect A value NOT :") }
        key = s
        cur_keypath = keypath KEYPATH_SEP key

        s = JSON_TOKENS[++s_idx]
        if (s != ":") json_walk_panic("json_walk_dict() Expect :")
        
        s = JSON_TOKENS[++s_idx]            # Value
        json_walk_value(cur_keypath, cur_indent)

        if (inner_content_generate) {
            if (out_color == true) key = out_color_key key "\033[0m"
            if (out_format == true) {
                ret = ret comma "\n" cur_indent key ": " result 
            } else {
                ret = ret comma key ":" result 
            }
        }

        if (s == ",") s = JSON_TOKENS[++s_idx]
        comma = ","
    }
    result = ret
    return true
}

function json_walk_array(keypath, indent,
    data, nth, cur_keypath, cur_indent, cur_item, comma, count){
    # debug("json_walk_array start() ")
    if (s != "[")   return false

    nth = -1
    s = JSON_TOKENS[++s_idx]
    cur_indent = indent     out_indent_space
    
    while (1) {
        nth++;
        if (s == "]") {
            s = JSON_TOKENS[++s_idx];   break
        }

        cur_keypath = keypath KEYPATH_SEP nth

        # if (s == ",")  json_walk_panic("json_walk_array() Expect a value but get " s)
        json_walk_value(cur_keypath, cur_indent)
        # debug("json_walk_array() value: " result)
        data[nth] = result
        if (s == ",")   s = JSON_TOKENS[++s_idx]
    }

    if (inner_content_generate) {
        count = nth
        result = "[";   comma = ""
        for (tmp=0; tmp<nth; tmp++) {
            cur_item = data[tmp]
            if (cur_item != "") {
                if (out_format) result = result comma "\n" cur_item
                else            result = result comma cur_item
                comma = ","
            }
        }
        if (out_format == true) {
            if (count == 0)     result = result "]"
            else                result = result "\n" indent "]"
        } else {
            result = result "]"
        }
    }

    return true
}

function json_walk_value(keypath, indent){
    if (json_walk_dict(keypath, indent) == true) {
        return true
    }

    if (json_walk_array(keypath, indent) == true) {
        return true
    }

    if (out_color == true) {
        if      (match(s, "^\""))   result  = out_color_string  s "\033[0m"
        else if (s == "true")       result  = out_color_true    s "\033[0m"
        else if (s == "false")      result  = out_color_false   s "\033[0m"
        else if (s == "null")       result  = out_color_null    s "\033[0m"
        else                        result  = out_color_number  s "\033[0m"
    } else {
        result = s
    }
    s = JSON_TOKENS[++s_idx]
    return true
}

function _json_walk(    final, idx, nth){
    if (s == "")  s = JSON_TOKENS[++s_idx]

    nth = 0
    while (s_idx <= s_len) {
        if (json_walk_value(nth++, "") == false) {
           json_walk_panic("json_walk() Expect a value")
        }
        final = final "\n" result
    }
    return final
}

# global variable: text, s, s_idx, s_len
function json_walk(text,   final, b_s, b_result, b_s_idx, b_s_len){
    b_result = result;
    b_s = s;    b_s_idx = s_idx;    b_s_len = s_len;
    
    result = "";
    gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    # gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
	gsub("\n" "[ \t\n\r]+", "\n", text)

    s_len = split(text, JSON_TOKENS, /\n/)
    s = JSON_TOKENS[s_idx];     s_idx = 1;

    out_indent_space = sprintf("%" out_indent_step "s", "")

    final = _json_walk()

    result = b_result;  
    s = b_s;    s_idx = b_s_idx;    s_len = b_s_len;
    return final
}

{
    print json_walk($0)
}
