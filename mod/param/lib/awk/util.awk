BEGIN {
    false = 0;  true = 1
    # L-EN   ="len"
    # K-SEP  = "\034"

    S = SUBSEP # "\001"
    T = "\002"
    L = "\003"

    EXIT_CODE = 0
}

# Section: panic and debug and exit

BEGIN{
    if (IS_TTY == true) {
        FG_RED        = "\033[31m"
        FG_LIGHT_RED  = "\033[91m"
        FG_BLUE       = "\033[36m"
        FG_YELLOW     = "\033[33m"
        UI_END        = "\033[0m"
    }
}


function exit_now(code){
    EXIT_CODE = code
    exit code
}

function exit_print(exit_code){
    print "return " exit_code " 2>/dev/null || exit " exit_code
    exit_now( exit_code )
}

function panic_error(msg){
    if( DRYRUN_FLAG == true ){
        print "return 1"
        exit_now(1)
    }
    print FG_LIGHT_RED "error: " UI_END msg "\nFor more information try " FG_BLUE "--help" UI_END > "/dev/stderr"
    print "return 1 2>/dev/null || exit 1 2>/dev/null"
    exit_now(1)
}

function panic_param_define_error( msg ){
    print FG_LIGHT_RED "param define error: " UI_END msg "\nFor more information try to read the demo in " FG_BLUE "https://gitee.com/x-bash/param/blob/main/.x-cmd/testcases/v0_test" UI_END > "/dev/stderr"
    print "return 1 2>/dev/null || exit 1 2>/dev/null"
    exit_now(1);
}

function panic_invalid_argument_error(arg_name){
    panic_error("Option unexpected, or invalid in this context: '" FG_YELLOW arg_name UI_END "'")
}

# TODO: short
function panic_match_candidate_error(option_id, value, candidate_list) {
    panic_error(panic_match_candidate_error_msg(option_id, value, candidate_list))
}

function panic_match_candidate_error_msg(option_id, value, candidate_list) {
    return ("Fail to match any candidate, option '" FG_YELLOW get_option_string(option_id) UI_END "' is part of value is '" FG_LIGHT_RED value UI_END "'\n" candidate_list)
}

function panic_match_regex_error(option_id, value, regex) {
    panic_error(panic_match_regex_error_msg(option_id, value, regex))
}

function panic_match_regex_error_msg(option_id, value, regex) {
    return ("Fail to match any regex pattern, option '" FG_YELLOW get_option_string(option_id) UI_END "' is part of value is '" FG_LIGHT_RED value UI_END "'\n" regex )
}

function panic_required_value_error(option_id) {
    panic_error(panic_required_value_error_msg(option_id))
}

function panic_required_value_error_msg(option_id) {
    return ("Option require value, but none was supplied: '" FG_YELLOW get_option_string(option_id) UI_END "'")
}

function debug(msg){
    print FG_RED msg UI_END > "/dev/stderr"
}

# EndSection

# Section: str module

function str_quote_if_unquoted(str){
    if (str ~ /^".+"$/)
    {
        return str
    }
    return quote_string(str)
}

function s_wrap2(str){
    return "\"" str "\""
}

function quote_string(str){
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}

function single_quote_string(str){
    gsub(/'/, "'\"'\"'", str)
    return "'" str "'"
}

function str_unquote(str){
    gsub(/\\"/, "\"", str)
    return substr(str, 2, length(str)-2)
}

function str_unquote_if_quoted(str){
    if (str ~ /^".+"$/)
    {
        return str_unquote(str)
    }
    return str
}

# output certain kinds of array
function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
}

function str_trim_left(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    return astr
}

function str_rep(char, number, i, _s) {
    for (   i=1; i<=number; ++i  ) _s = _s char
    return _s
}

function str_join(sep, obj, prefix, start, end,     i, _result) {
    _result = (start <= end) ? obj[prefix start]: ""
    for (i=start+1; i<=end; ++i) _result = _result sep obj[prefix i]
    return _result
}

# function str_joinwrap(left, right, obj, prefix, start, end,     i, _result) {
#     _result = ""
#     for (i=start; i<=end; ++i) _result = _result left obj[prefix i] right
#     return _result
# }

function str_joinwrap(sep, left, right, obj, prefix, start, end,     i, _result) {
    _result = (start <= end) ? left obj[prefix start] right : ""
    for (i=start+1; i<=end; ++i) _result = _result sep left obj[prefix i] right
    return _result
}

# EndSection

# Section: Assert

function assert_arr_eq(optarg_id, arg_name, value, sep,
    op_arr_len, i, idx, value_arr_len, value_arr, candidate, sw){

    op_arr_len = option_arr[ oparr_keyprefix L ]

    value_arr_len = split(value, value_arr, sep)
    for (i=1; i<=value_arr_len; ++i) {
        sw = false
        for (idx=2; idx<=op_arr_len; ++idx) {
            candidate = oparr_get( optarg_id, idx )
            candidate = str_unquote_if_quoted( candidate )
            if ( value_arr[i] == candidate ) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_candidate_error_msg( option_id, value_arr[i], oparr_join_plain( optarg_id ))
        }
    }
}

function assert_arr_regex(optarg_id, arg_name, value, sep,
    i, value_arr_len, value_arr, sw){

    len = oparr_len( optarg_id )

    value_arr_len = split(value, value_arr, sep)
    for (i=1; i<=value_arr_len; ++i) {
        sw = false
        for (idx=2; idx<=len; ++idx) {
            val = oparr_get( optarg_id, idx )
            val = str_unquote_if_quoted( val )
            if (match( value_arr[i], val )) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_regex_error_msg( option_id, value_arr[i], oparr_join_plain( optarg_id ) )
        }
    }
}

# op_arg_idx # token_arr_len, token_arr, op_arg_idx,
function assert(optarg_id, arg_name, arg_val,
    op, sw, idx, len, val){

    op = oparr_get( optarg_id, 1 )
    # debug("assert: optarg_id: " optarg_id " arg_name: " arg_name " arg_val: " arg_val " op: " op " oparr_keyprefix: " oparr_keyprefix)

    if (op == "=int") {
        if (! match(arg_val, /[+-]?[0-9]+/) ) {    # float is: /[+-]?[0-9]+(.[0-9]+)?/
            return "Arg: [" arg_name "] value is [" arg_val "]\n  Is NOT an integer."
        }
    } else if (op == "=") {
        sw = false
        len = oparr_len( optarg_id )
        for (idx=2; idx<=len; ++idx) {
            val = oparr_get( optarg_id, idx )
            val = str_unquote_if_quoted( val )
            if (arg_val == val) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_candidate_error_msg(option_id, arg_val, oparr_join_plain(optarg_id) )
        }
    } else if (op == "=~") {
        sw = false
        len = oparr_len( optarg_id )
        for (idx=2; idx<=len; ++idx) {
            val = oparr_get( optarg_id, idx )
            val = str_unquote_if_quoted( val )
            if (match(arg_val, "^"val"$")) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_regex_error_msg( option_id, arg_val, oparr_join_plain(optarg_id) )
        }

    } else if (op ~ /^=.$/) {
        sep = substr(op, 2, 1)
        assert_arr_eq( optarg_id, arg_name, arg_val, sep )
    } else if (op ~ /^=~.$/) {
        sep = substr(op, 3, 1)
        assert_arr_regex( optarg_id, arg_name, arg_val, sep )
    } else if (op == "") {
        # Do nothing.
    } else {
        # debug( "Op[" op "] Not Match any candidates: \n" line )
        panic_param_define_error("Straing op: " op)
    }

    return true
}

# EndSection

# option_string is a string of option, each option is separated by ','
# example:
#   1. --option1,-o1
#   2. --option1,-o1 <arg1> <arg2> ...
function get_option_string(option_id,
    _option_string, j){
    _option_string = option_id
    gsub("\\|m", "", _option_string)
    gsub("\\|", ",", _option_string)

    option_argc      = option_arr[ option_id L ]
    for ( j=1; j<=option_argc; ++j ) {
        # BUG
        _option_string = _option_string " <" option_arr[ option_id S j S OPTARG_NAME ] ">"
    }

    return _option_string
}

function arr_clone( src, dst,   l, i ){
    l = src[ L ]
    dst[ L ] = l
    for (i=1; i<=l; ++i)  dst[i] = src[i]
}

function arr_shift( arr, offset,        l, i ){
    l = arr[ L ] - offset
    for (i=1; i<=l; ++i) arr[i] = arr[i+offset]
    arr[ L ] = l
}
