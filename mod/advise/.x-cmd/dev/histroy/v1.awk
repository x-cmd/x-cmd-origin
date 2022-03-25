BEGIN{
    false = 0;      true = 1

    RS = "\034"
    # KEYPATH_SEP = "\034"  # Not works with regex pattern [^\034]
    KEYPATH_SEP = "\003"
    # KEYPATH_SEP = "-"
    VAL_SEP = "\n"
    FUNC_SEP = "\004"
    FUNC_SEP_LEN = FUNC_SEP "len"
}

function str_wrap(s){
    return "\"" s "\""
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


function rule_add(key, val){
    if (key == "") return
    # key = substr(key, 2)
    RULES_RAW[key] = val
    # print key  "\t----->\t"  val
}

function rule_search(pat,
    key){
    
    pat = "^" pat "$"
    for (key in RULES_RAW) {
        # print "-->" pat "\t\t" key
        if (match(key, pat)) {
            return key
        }
    }
    return ""
}

function rule_get(key){
    return RULES_RAW[key]
}

function json_walk_dict(keypath, indent,    
    data, nth, cur_keypath, cur_indent, key, value){

    if (s != "{") {
        # debug("json_walk_dict() fails" )
        return false
    }
    
    nth = -1
    s = JSON_TOKENS[++s_idx]

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

        if (s == ",") s = JSON_TOKENS[++s_idx]
    }

    rule_add(keypath FUNC_SEP_KEY, data)
    return true
}

function json_walk_array(keypath, indent,
    data, nth, cur_keypath, cur_indent, cur_item, comma, count){
    # debug("json_walk_array start() ")
    if (s != "[")   return false

    nth = -1
    s = JSON_TOKENS[++s_idx]

    data="["
    
    while (1) {
        nth++;
        if (s == "]") {
            s = JSON_TOKENS[++s_idx];   break
        }

        cur_keypath = keypath KEYPATH_SEP nth

        # if (s == ",")  json_walk_panic("json_walk_array() Expect a value but get " s)
        json_walk_value(cur_keypath, cur_indent)
        # debug("json_walk_array() value: " result)
        
        data = data VAL_SEP result

        if (s == ",")   s = JSON_TOKENS[++s_idx]
    }

    rule_add(keypath, data)
    rule_add(keypath FUNC_SEP_LEN, nth + 1)

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
    rule_add(keypath, s)
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

    json_walk_dict(".", "")
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

NR==1{
    json_walk($0)
}

NR==2{
    argstr = $0

    gsub("\n", "\001", argstr)
    parsed_arglen = split(argstr, parsed_argarr, "\002")

    # prev = parsed_argarr[parsed_arglen-1]
    # cur = parsed_argarr[parsed_arglen]
    
    ruleregex = ""

    arglen=0
    used_arg = ""
    rest_argv_len = 0
    # rest_argv

    final_keypath = "."

    for (i=1; i<=parsed_arglen; ++i) {
        arg = parsed_argarr[i]
        gsub("\001", "\n", arg)
        parsed_argarr[i] = arg
    }

    for (i=1; i<parsed_arglen; ++i) {
        arg = parsed_argarr[i]

        argval = ""
        if (arg ~ /^-/) {
            if (match(arg, /^--?[A-Za-z0-9_+-]+=/)){
                argval = substr(arg, RLENGTH+1)
                arg = substr(arg, 1, RLENGTH)
            }

            if (arg ~ /^--/) {
                argarr[++arglen] = arg
                used_arg_add(final_keypath, arg)
            } else {
                if (length(arg) == 2) {
                    argarr[++arglen] = arg
                    used_arg_add(final_keypath, arg)
                } else if (rule_search(final_keypath KEYPATH_SEP pattern_wrap(arg)) != "") {
                    # For some command like java, "java -version"
                    argarr[++arglen] = arg
                    used_arg_add(final_keypath, arg)
                } else {
                    _arg_tmp_arrlen = split(arg, _arg_tmp_arr, "")
                    for (j=2; j<=_arg_tmp_arrlen; ++j) {
                        argarr[++arglen] = "-" _arg_tmp_arr[j]
                        used_arg_add(final_keypath, "-" _arg_tmp_arr[j])
                    }
                    arg = argarr[arglen]
                }
            }

            if (argval != "") {
                argarr[++arglen] = argval
            } else {
                keypath = rule_search(final_keypath KEYPATH_SEP pattern_wrap(arg))
                rule = rule_get(keypath)
                # print "--- " final_keypath KEYPATH_SEP pattern_wrap(arg)
                if (rule != "null") {
                    if (i+1 < parsed_arglen) {
                        argarr[++arglen] = parsed_argarr[++i]
                    }
                }
            } 
            
        } else {
            argarr[++arglen] = arg

            cur_search_path = final_keypath KEYPATH_SEP pattern_wrap(arg)
            keypath = rule_search(cur_search_path)
            
            if (keypath == "") {
                # Must be positional argument
                for (j=i; j<=parsed_arglen; ++j) {
                    rest_argv[++rest_argv_len] = parsed_argarr[j]
                }
                break
            }

            # subcommand
            final_keypath = keypath
            used_arg = ""
        }
        
    }

    # print "aaa\t" parsed_argarr[parsed_arglen-1]
    # print "bbb\t" argarr[arglen-1]
    # print "bbb\t" argarr[arglen]
    argarr[++arglen] = parsed_argarr[parsed_arglen]


    cur = argarr[arglen]

    if (cur == "\177") {    # ascii code 127 0x7F 0177 ==> DEL
        cur = ""
    }

    if (rest_argv_len > 0) {
        # print "used:\t" used_arg
        # print "keypath:\t" final_keypath
        # print "position argument:\t" rest_argv_len

        print_positional_candidates(final_keypath, rest_argv_len)

    } else {
        prev = argarr[arglen-1]

        # print "used:\t" used_arg
        # print "keypath:\t" final_keypath
        # print "prev:\t" prev
        # print "cur:\t" cur


        if (prev ~ /^-/) {
            keypath = rule_search(final_keypath KEYPATH_SEP pattern_wrap(prev))
            rule = rule_get(keypath)
            if (rule == "null") {
                print_candidates(final_keypath, cur)
            } else {
                print_named_param_candidates(rule, cur)
            }
        } else {
            print_candidates(final_keypath, cur)
        }
    }

}

function used_arg_add(keypath, named_arg,
    kp, arr, arrlen, i) {
    kp = rule_search(keypath KEYPATH_SEP pattern_wrap(named_arg))
    arrlen = split(substr(kp, length(keypath)), arr, ":")
    for (i=2; i<arrlen; ++i) {
        used_arg = used_arg " " arr[i] " "
    }
}

function print_positional_candidates(final_keypath, nth,
    kp){

    kp = rule_search(final_keypath KEYPATH_SEP "\"#" nth "\"")
    if (kp != "null") {
        
        if (kp == "") {
            kp = rule_search(final_keypath KEYPATH_SEP "\"#n\"") 
        }


        # print "1111 " rule_get(kp) >"/dev/stderr"
        print_named_param_candidates(rule_get(kp), cur)
    }
}


function print_named_param_candidates(rule, cur,
    es, esl, e, i, data){

    # print "print_named_param_candidates"

    # Must be a list

    if (rule !~ /^\[/) {
        cmd = substr(rule, 4, length(rule)-4)
        # print cmd > "/dev/stderr"
        system(cmd)

        esl = split(data, es, /[\n\ \t]/)
        for (i=1; i<=esl; ++i) {
            if (cur == "") {
                print es[i]
            } else if (index(es[i], cur) == 1) {
                print es[i]
            }
        }
    } else {
        gsub(/\"/, "", rule) #"
        esl = split(rule, es, VAL_SEP)
        for (i=2; i<=esl; ++i) {
            e = es[i]

            if (cur == "") {
                print e
            } else if (index(e, cur) == 1) {
                print e
            }
        }
    }
}

function print_candidates(final_keypath, cur,
    arr, arr_len, e, es, esl, ese, i, j, output_position){

    # print "print_candidates\t" final_keypath "\t|" cur "|"

    if (cur == "") {
        sw = 0
    } else {
        sw = 1
    }

    keypath = rule_search(final_keypath)
    rule = rule_get(keypath FUNC_SEP_KEY)

    # print "print_candidates\t" final_keypath "\t|" rule "|"


    output_position = 0
    

    arr_len = split(rule, arr, VAL_SEP)
    for (i=2; i<=arr_len; ++i) {
        e = arr[i]
        esl = split(e, es, ":")
        for (j=2; j<esl; ++j) {
            ese = es[j]

            # print ese
            if (ese !~ /^[#-]/) {
                output_position = 1
            }

            if (sw == 0) {  
                if (ese !~ /-/){                  
                    print ese
                }
            } else {  
                if (index(ese, cur) == 1) {
                    if (index(used_arg, " " ese " ") == 0) {
                        print ese
                    }
                }
            }
        }
    }



    if (output_position == 0) {
        print_positional_candidates(final_keypath, 1)
    }

}

