BEGIN{
    false = 0;      true = 1

    RS = "\034"
    # KEYPATH_SEP = "\034"  # Not works with regex pattern [^\034]
    KEYPATH_SEP = "\003"
    # KEYPATH_SEP = "-"
    VAL_SEP = "\n"
    FUNC_SEP = "\004"
    FUNC_SEP_LEN = FUNC_SEP "len"

    table["."] = ""
    tablen = 0
    tablemax[0] = 0
}

function rep(ch, num,
    i, ret){

    ret = ""
    for (i=0; i<num; ++i) {
        ret = ret ch
    }
    return ret
}

function println(msg){
    print "|" msg "|"
}

function pattern_wrap(s){
    return "\"[^\003]*:" s ":[^\003]*\""
    # return "\"[^-\034\035]*:" s ":[^-\034\035]*\""
    # return "\"[^-]*:" s ":[^-]*\""
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
    data, nth, cur_keypath, cur_indent, key, value,
    dict, i, line){

    if (s != "{") {
        # debug("json_walk_dict() fails" )
        return false
    }
    
    nth = -1
    s = JSON_TOKENS[++s_idx]

    ### value

    ###

    data = "{"

    while (1) {
        nth ++
        if (s == "}") {
            s = JSON_TOKENS[++s_idx];  break
        }

        # if (s == ":") { json_walk_panic("json_walk_dict() Expect A value NOT :") }
        key = s
        cur_keypath = keypath KEYPATH_SEP key

        data = data VAL_SEP key

        s = JSON_TOKENS[++s_idx]
        if (s != ":") json_walk_panic("json_walk_dict() Expect :")
        
        s = JSON_TOKENS[++s_idx]            # Value
        json_walk_value(cur_keypath, cur_indent)
        dict[key] = result

        if (s == ",") s = JSON_TOKENS[++s_idx]
    }

    ##### Handle the table format code
    for (i=1; i<=topics_len; ++i) {
        key = topics[i]
        value = dict[key]
        table[keypath key] = value

        n = tablemax[key] 
        if (n < length(value)) {
            tablemax[key] = length(value)
        }
    }
    tablen = keypath
    ##### Handle the table format code


    return true
}

function json_walk_array(keypath, indent,
    data, nth, cur_keypath, cur_indent, cur_item, comma, count){
    debug("json_walk_array start() ")
    if (s != "[")   return false

    nth = 0 # -1
    s = JSON_TOKENS[++s_idx]

    data="["
    
    while (1) {
        nth++;
        if (s == "]") {
            s = JSON_TOKENS[++s_idx];   break
        }

        cur_keypath = nth # keypath KEYPATH_SEP nth

        # if (s == ",")  json_walk_panic("json_walk_array() Expect a value but get " s)
        json_walk_value(cur_keypath, cur_indent)
        debug("json_walk_array() value: " result)
        
        data = data VAL_SEP result

        if (s == ",")   s = JSON_TOKENS[++s_idx]
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

    result = s
    s = JSON_TOKENS[++s_idx]
    return true
}

function _json_walk(    final, idx, nth){
    if (s == "")  s = JSON_TOKENS[++s_idx]

    # nth = 0
    # while (s_idx <= s_len) {
    #     if (json_walk_value(nth++, "") == false) {
    #        json_walk_panic("json_walk() Expect a value")
    #     }
    # }

    # json_walk_dict(".", "")
    json_walk_array("", "")
}

# global variable: text, s, s_idx, s_len
function json_walk(text,   final, b_s, b_s_idx, b_s_len){
    b_s = s;    b_s_idx = s_idx;    b_s_len = s_len;

    RULES_RAW["."]=text
    
    result = "";
    gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    # gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
	gsub("\n" "[ \t\n\r]+", "\n", text)

    s_len = split(text, JSON_TOKENS, /\n/)
    s = JSON_TOKENS[s_idx];     s_idx = 1;

    _json_walk()

    s = b_s;    s_idx = b_s_idx;    s_len = b_s_len;
}


# Topics
NR==1{
    argstr = $0

    gsub("\n", "\001", argstr)
    topics_len = split($0, topics, /\002/)

    for (i=1; i<=topics_len; ++i) {
        key = topics[i]
        gsub("\001", "\n", key)
        topics[i] = "\"" key "\""
    }
}

function printValue(value, max){
    if (length(value) > max) {
        printf("%s ", substr(value, 1, max))
    } else {
        printf("%s%s ", value, rep(" ", max - length(value)))
    }
}

function str_unwrap(v){
    if (v ~ /^\"/) { #"
        return substr(v, 2, length(v)-2)
    }
    return v
}

function printTable(i){

    dash_len = 0
    for (i=1; i<=topics_len; ++i) {
        key = topics[i]
        dash_len = dash_len + tablemax[key] + 1
    }

    # print rep("-", dash_len)

    for (i=1; i<=topics_len; ++i) {
        key = topics[i]
        value = str_unwrap(key)
        printValue(str_unwrap(value), tablemax[key])
    }
    print ""
    print rep("-", dash_len)

    for (i=1; i<=tablen; ++i) {

        if (tablen >= 10) {
            if (i%5 == 0) {
                # printf "\033[7m"
                printf "\033[0;44m"
                # printf "\033[1m"
            } else {
                # printf "\033[0;31m"
                printf "\033[0m"
            }
        }
        
        for (j=1; j<=topics_len; ++j) {
            key = topics[j]
            value = str_unwrap(table[i key])
            printValue(value, tablemax[key])
        }
        print "\033[0m"
    }

    printf "\033[0m"
}

NR==2{
    for (i=1; i<=topics_len; ++i) {
        key = topics[i]
        tablemax[key] = 4
    }

    # print $0
    json_walk($0)

    print "\n"

    printTable()
}

