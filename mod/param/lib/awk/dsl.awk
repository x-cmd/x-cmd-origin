BEGIN {
    false = 0;  true = 1
    # L-EN   ="len"
    # K-SEP  = "\034"

    S = "\001"
    T = "\002"
    L = "\003"

    EXIT_CODE = 0
}

BEGIN{
    if (IS_TTY == true) {
        FG_RED        = "\033[31m"
        FG_LIGHT_RED  = "\033[91m"
        FG_BLUE       = "\033[36m"
        FG_YELLOW     = "\033[33m"
        UI_END        = "\033[0m"
    }
}

# Section: panic and debug and exit
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
    gsub("\005", " ",         astr)
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

# Section: token argument
BEGIN{
    PARAM_RE_1 = "<[A-Za-z0-9_ ]*>" "(:[A-Za-z_\\-]+)*"
    PARAM_RE_1_2 = "=" re( RE_STR2 )
    PARAM_RE_1 = PARAM_RE_1 re( PARAM_RE_1_2, "?" )

    PARAM_RE_ARG = re( PARAM_RE_1 ) RE_OR re( RE_STR2 ) RE_OR re( RE_STR0 )# re( "[^ \\t\\v\\n]+" "((\\\\[ ])[^ \\t\\v\\n]*)*" )# re(RE_STR0) # re( "[A-Za-z0-9\\-_=\\#|]+" )
}

BEGIN{
    PARAM_RE_NEWLINE_TRIM_SPACE = "[ \t\v]+"
    PARAM_RE_NEWLINE_TRIM = re("\n" PARAM_RE_NEWLINE_TRIM_SPACE) RE_OR re(PARAM_RE_NEWLINE_TRIM_SPACE "\n" )
}

function param_tokenized(s, arr,       l){
    gsub( PARAM_RE_ARG, "\n&", s )
    gsub( PARAM_RE_NEWLINE_TRIM, "\n", s )
    gsub( "^[\n]+" RE_OR "[\n]+$", "", s)
    gsub( "\"", "", s)
    l = split(s, arr, "\n")
    return l
}

# function param_token_parse(s, arr, prefix, optarr, prefi      l){
#     _option_id = arr[1]

#     #
#     arr[ _option_id , "desc" ] = arr[2]
#     arr[ _option_id , 1, "arg_name" ] = handle()
#     arr[ _option_id , 2, "arg_name" ] = handle()
#     return l
# }

function param_print_tokenized(s, arr){
    print "---------"
    l = param_tokenized(s, arr)
    for (i=1; i<=l; ++i) {
        print arr[ i ]
    }
    print "---------"
}

# BEGIN{
#     s0 = "--license               \"Test regex arg3\"  <regex_arg3>   =   \"MulanPSL-2.0\" \"0BSD\" \"AFL-3.0\" \"AGPL-3.0\" \"\" \"XXXX License\""
#     s1 = "--license               \"Test regex arg3\"  <regex_arg3>=abcb   =   \"MulanPSL-2.0\" \"0BSD\" \"AFL-3.0\" \"AGPL-3.0\" \"\" \"XXXX License\""
#     s2 = "#3|#n|#a|--regex_arg3|-s      \"Repo name 3\"        <>:repo"
#     s3 = "-y|--fsdfsd|-o          \"Test regex arg1\"  <regex_arg1>=888  =~  \"[0-9]+\""

#     param_print_tokenized( s0 )
#     param_print_tokenized( s1 )
#     param_print_tokenized( s2 )
#     exit 0
# }

# EndSection

# Section: code facility
function print_code(){
    print CODE
}

function append_code(code){
    CODE=CODE "\n" code
}

# TODO: check whether all of the invocator correctly quote the value
function append_code_assignment(varname, value) {
    if( varname == "path" ){
        HAS_PATH = true
        varname  = "___x_cmd_param_path"
    }
    append_code( "local " varname " >/dev/null 2>&1" )
    append_code( varname "=" single_quote_string( value ) )
}

function append_query_code(varname, description, typestr){
    if( varname == "path" ){
        HAS_PATH = true
        varname = "___x_cmd_param_path"
    }
    append_code( "local " varname " >/dev/null 2>&1" )
    # append_code( "ui prompt main " quote_string(description) " " varname " " typestr )
    # append_query_code( quote_string(description) " " varname " " "\"\"" " " typestr )
    QUERY_CODE=QUERY_CODE " \"--\" \\" "\n" quote_string(description) " " varname " " "\"\"" " " typestr
}

# EndSection

# Section: utils
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
        _option_string = _option_string " <" option_arr[ option_id S j S OPTARG_NAME ] ">"
    }

    return _option_string
}

# TOKEN_ARRAY
function tokenize_argument_into_TOKEN_ARRAY( astr,  l ) {
    l = param_tokenized( astr, TOKEN_ARRAY )
    TOKEN_ARRAY[ L ] = l
    return l
}
# EndSection

# Section: Assert

function join_optarg_oparr(optarg_id,            _oparr_keyprefix){
    _oparr_keyprefix = optarg_id S OPTARG_OPARR
    return " " str_join( " ", option_arr, _oparr_keyprefix S, 1, option_arr[ _oparr_keyprefix L ] )
}

function assert_arr_eq(optarg_id, arg_name, value, sep,
    op_arr_len, i, idx, value_arr_len, value_arr, candidate, sw,
    oparr_keyprefix){

    oparr_keyprefix = optarg_id S OPTARG_OPARR
    op_arr_len = option_arr[ oparr_keyprefix L ]

    value_arr_len = split(value, value_arr, sep)
    for (i=1; i<=value_arr_len; ++i) {
        sw = false
        for (idx=2; idx<=op_arr_len; ++idx) {
            candidate = option_arr[ oparr_keyprefix S idx ]
            candidate = str_unquote_if_quoted( candidate )
            if ( value_arr[i] == candidate ) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_candidate_error_msg( option_id, value_arr[i], join_optarg_oparr( optarg_id ))
        }
    }
}

function assert_arr_regex(optarg_id, arg_name, value, sep,
    i, value_arr_len, value_arr, sw, oparr_keyprefix){

    oparr_keyprefix = optarg_id S OPTARG_OPARR

    len = option_arr[ oparr_keyprefix L ]

    value_arr_len = split(value, value_arr, sep)
    for (i=1; i<=value_arr_len; ++i) {
        sw = false
        for (idx=2; idx<=len; ++idx) {
            val = option_arr[ oparr_keyprefix S idx ]
            val = str_unquote_if_quoted( val )
            if (match( value_arr[i], val )) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_regex_error_msg( option_id, value_arr[i], join_optarg_oparr( optarg_id ) )
        }
    }
}

# op_arg_idx # token_arr_len, token_arr, op_arg_idx,
function assert(optarg_id, arg_name, arg_val,
    op, sw, idx, len, val,
    oparr_keyprefix){

    oparr_keyprefix = optarg_id S OPTARG_OPARR
    op = option_arr[ oparr_keyprefix S 1 ]
    # debug("assert: optarg_id: " optarg_id " arg_name: " arg_name " arg_val: " arg_val " op: " op " oparr_keyprefix: " oparr_keyprefix)

    if (op == "=int") {
        if (! match(arg_val, /[+-]?[0-9]+/) ) {    # float is: /[+-]?[0-9]+(.[0-9]+)?/
            return "Arg: [" arg_name "] value is [" arg_val "]\n  Is NOT an integer."
        }
    } else if (op == "=") {
        sw = false
        len = option_arr[ oparr_keyprefix L ]
        for (idx=2; idx<=len; ++idx) {
            val = option_arr[ oparr_keyprefix S idx ]
            val = str_unquote_if_quoted( val )
            if (arg_val == val) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_candidate_error_msg(option_id, arg_val, join_optarg_oparr(optarg_id) )
        }
    } else if (op == "=~") {
        sw = false
        len = option_arr[ oparr_keyprefix L ]
        for (idx=2; idx<=len; ++idx) {
            val = option_arr[ oparr_keyprefix S idx ]
            val = str_unquote_if_quoted( val )
            if (match(arg_val, "^"val"$")) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_regex_error_msg( option_id, arg_val, join_optarg_oparr(optarg_id) )
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

# Section: Step 1 Utils: Global types

BEGIN {
    type_arr[ L ]=0
}

function type_arr_add(line_trimed,                 _name, _rest){
    match(line_trimed, /^[\-_A-Za-z0-9]+/)
    if (RLENGTH <= 0) {
        panic_param_define_error("Should not happned for type lines: \n" line_trimed)
    }

    _name = substr(line_trimed, 1, RLENGTH)
    _rest = substr(line_trimed, RLENGTH+1)

    type_arr[ _name ] = str_trim( _rest )
}

function subcmd_arr_add(idx, line_trimed,                 _id, _name_arr, _name_arr_len, i){
    if (! match(line_trimed, /^[A-Za-z0-9_\|-]+/)) {
        panic_param_define_error( "Expect subcommand in the first token, but get:\n" line )
    }

    _id = substr( line_trimed, 1, RLENGTH )
    subcmd_arr[ idx ] = _id
    subcmd_map[ _id ] = str_trim( substr( line_trimed, RLENGTH+1 ) )

    _name_arr_len = split(_id, _name_arr, "|")
    for (i=1; i<=_name_arr_len; i++) {
        subcmd_id_lookup[ _name_arr[ i ] ] = _id
    }
}

# EndSection

# Section: Step 2 Utils: Parse param DSL
BEGIN {
    advise_arr[ L ]=0
    arg_arr[ L ]=0
    subcmd_arr[ L ]=0
    # subcmd_map

    # RS="\001"

    rest_option_id_list[ L ] = 0
}

BEGIN {
    final_rest_argv[ L ] = 0

    option_arr[ L ]=0
    option_id_list[ L ] = 0

    # OPTION_ARGC = "num" # Equal  L
    OPTION_SHORT = "shoft"
    OPTION_TYPE = "type"
    OPTION_DESC = "desc"

    OPTION_M = "M"
    OPTION_NAME = "varname"

    OPTARG_NAME = "val_name"
    OPTARG_TYPE = "val_type"
    OPTARG_DEFAULT = "val_default"

    OPTARG_DEFAULT_REQUIRED_VALUE = "\001"

    OPTARG_OPARR = "val_oparr"

    HAS_SUBCMD = false
    HAS_PATH   = false
}

function handle_option_id(option_id,            _arr, _arr_len, _arg_name, _index){

    # Add option_id to option_id_list
    _index = option_id_list[ L ] + 1
    option_id_list[ L ] = _index
    option_id_list[ _index ] = option_id

    option_arr[ option_id S OPTION_M ] = false

    _arr_len = split( option_id, _arr, /\|/ )

    # debug("handle_option_id \t" _arr_len)
    for ( _index=1; _index<=_arr_len; ++_index ) {
        _arg_name = _arr[ _index ]
        # Prevent name conflicts
        if (option_alias_2_option_id[ _arg_name ] != "") {
            panic_param_define_error("Already exsits: " _arg_name)
        }

        if (_arg_name == "m") {
            option_arr[ option_id S OPTION_M ] = true
            continue
        }

        if (_arg_name !~ /^-/) {
            panic_param_define_error("Unexpected option name: \n" option_id)
        }

        if ( _index == 1 ) {
            option_arr[ option_id S OPTION_NAME ] = _arg_name
        }
        option_alias_2_option_id[ _arg_name ] = option_id
        # debug( "option_alias_2_option_id\t" _arg_name "!\t!" option_id "|" )
    }
}

BEGIN {
    EXISTS_REQUIRED_OPTION = false
}

# name is key_prefix like OPTION_NAME
function handle_optarg_declaration(optarg_definition, optarg_id,
    optarg_definition_token1, optarg_name, optarg_type,
    default_value, tmp, type_rule, i ){

    # debug( "handle_optarg_definition:\t" optarg_definition )
    # debug( "optarg_id:\t" optarg_id )
    tokenize_argument_into_TOKEN_ARRAY( optarg_definition )
    optarg_definition_token1 = TOKEN_ARRAY[ 1 ]

    if (! match( optarg_definition_token1, /^<[-_A-Za-z0-9]*>/) ) {
        panic_param_define_error("Unexpected optarg declaration: \n" optarg_definition)
    }

    optarg_name = substr( optarg_definition_token1, 2, RLENGTH-2 )
    option_arr[ optarg_id S OPTARG_NAME ] = optarg_name

    optarg_definition_token1 = substr( optarg_definition_token1, RLENGTH+1 )

    if (match( optarg_definition_token1, /^:[-_A-Za-z0-9]+/) ) {
        optarg_type = substr( optarg_definition_token1, 2, RLENGTH-1 )
        optarg_definition_token1 = substr( optarg_definition_token1, RLENGTH+1 )
    }

    if (match( optarg_definition_token1 , /^=/) ) {
        default_value = substr( optarg_definition_token1, 2 )
        option_arr[ optarg_id S OPTARG_DEFAULT ] = str_unquote_if_quoted( default_value )
    } else {
        # It means, it is required.
        option_arr[ optarg_id S OPTARG_DEFAULT ] = OPTARG_DEFAULT_REQUIRED_VALUE
        EXISTS_REQUIRED_OPTION = true
    }

    if (TOKEN_ARRAY[ L ] >= 2) {
        for ( i=2; i<=TOKEN_ARRAY[ L ]; ++i ) {
            option_arr[ optarg_id S OPTARG_OPARR S i-1 ] = TOKEN_ARRAY[i]
        }
        option_arr[ optarg_id S OPTARG_OPARR L ] = TOKEN_ARRAY[ L ] - 1
    } else {
        type_rule = type_arr[ optarg_type ]
        if (type_rule == "") {
            return
        }

        tokenize_argument_into_TOKEN_ARRAY( type_rule)

        for ( i=1; i<=TOKEN_ARRAY[ L ]; ++i ) {
            option_arr[ optarg_id S OPTARG_OPARR S i ] = TOKEN_ARRAY[i]
        }
        option_arr[ optarg_id S OPTARG_OPARR L ] = TOKEN_ARRAY[ L ]
    }

}

# options like #1, #2, #3 ...
function parse_param_dsl_for_positional_argument(line,
    option_id, option_desc, tmp, _arr_len, _arr, _index, _arg_name, _arg_no, _optarg_id){

    tokenize_argument_into_TOKEN_ARRAY( line )

    option_id = TOKEN_ARRAY[1]

    tmp = rest_option_id_list[ L ] + 1
    rest_option_id_list[ L ] = tmp
    rest_option_id_list[ tmp ] = option_id
    option_arr[ option_id L ] = 1
    option_arr[ option_id S OPTION_M ] = 0

    _arr_len = split( option_id, _arr, /\|/ )
    for ( _index=1; _index <= _arr_len; ++_index ) {
        _arg_name = _arr[ _index ]
        # Prevent name conflicts
        if (option_alias_2_option_id[ _arg_name ] != "") {
            panic_param_define_error("Already exsits: " _arg_name)
        }

        if ( _index == 1 ) {
            _arg_no = substr( _arg_name, 2)
        } else if ( _index == 2 ) {
            option_arr[ option_id S OPTION_NAME ] = _arg_name
        }
        option_alias_2_option_id[ _arg_name ] = option_id
    }

    option_desc = TOKEN_ARRAY[2]
    option_arr[ option_id S OPTION_DESC ] = option_desc

    if ( TOKEN_ARRAY[ L ] >= 3) {
        tmp = ""
        for ( _index=3; _index<=TOKEN_ARRAY[ L ]; ++_index ) {
            tmp = tmp " " quote_string(TOKEN_ARRAY[ _index ])
        }

        option_arr[ option_id ] = tmp

        _optarg_id = option_id S 1
        handle_optarg_declaration( tmp, _optarg_id )

        # NOTICE: this is correct. Only if has default value, or it is required !
        if (final_rest_argv[ L ] < _arg_no)   final_rest_argv[ L ] = _arg_no
        final_rest_argv[ _arg_no ] = option_arr[ _optarg_id S OPTARG_DEFAULT ]
        # debug( "final_rest_argv[ " _arg_no " ] = " final_rest_argv[ _arg_no ] )
    }

}

# options #n
function parse_param_dsl_for_all_positional_argument(line,
    option_id, option_desc, tmp){

    tokenize_argument_into_TOKEN_ARRAY( line )

    option_id = TOKEN_ARRAY[1]  # Should be #n

    tmp = rest_option_id_list[ L ] + 1
    rest_option_id_list[ L ] = tmp
    rest_option_id_list[ tmp ] = option_id

    option_desc = TOKEN_ARRAY[2]
    option_arr[ option_id S OPTION_DESC ] = option_desc

    if ( TOKEN_ARRAY[ L ] >= 3) {
        tmp = ""
        for (i=3; i<=TOKEN_ARRAY[ L ]; ++i) {
            tmp = tmp " " quote_string(TOKEN_ARRAY[i])
        }

        option_arr[ option_id ] = tmp
        handle_optarg_declaration( tmp, option_id )
    }
}

function parse_param_dsl(line,
    line_arr, i, j, state, tmp, len, nextline, subcmd,
    option_id) {

    state = 0
    STATE_ADVISE        = 1
    STATE_TYPE          = 2
    STATE_OPTION        = 3
    STATE_SUBCOMMAND    = 4
    STATE_ARGUMENT      = 5

    line_arr_len = split(line, line_arr, "\n")

    for (i=1; i<=line_arr_len; ++i) {
        line = line_arr[i]

        # TODO: line should be line_trimed
        line = str_trim( line )

        if (line == "") continue

        if (line ~ /^advise:/) {
            state = STATE_ADVISE
        } else if (line ~ /^type:/) {
            state = STATE_TYPE
        } else if (line ~ /^options?:/) {
            state = STATE_OPTION
        } else if (line ~ /^((subcommand)|(subcmd))s?:/) {
            state = STATE_SUBCOMMAND
        } else if (line ~ /^arguments?:/) {
            state = STATE_ARGUMENT
        } else {

            if (state == STATE_ADVISE) {
                tmp = advise_arr[ L ] + 1
                advise_arr[ L ] = tmp
                advise_arr[ tmp ] = line

            } else if ( state == STATE_TYPE ) {
                type_arr_add( line )

            } else if ( state == STATE_SUBCOMMAND ) {
                HAS_SUBCMD = true

                tmp = subcmd_arr[ L ] + 1
                subcmd_arr[ L ] = tmp

                subcmd_arr_add(tmp, line)
            } else if (state == STATE_OPTION) {
                # debug( line )

                # HANDLE:   option #n
                if ( match(line, /^#n[\s]*/ ) )
                {
                    parse_param_dsl_for_all_positional_argument( line )
                    continue
                }

                # HANDLE:   option #1 #2 #3 ...
                if ( match( line, /^#[0-9]+[\s]*/ ) )
                {
                    if (HAS_SUBCMD != true)     HAS_SUBCMD = false
                    parse_param_dsl_for_positional_argument( line )
                    continue
                }

                # HANDLE:   option like --user|-u, or --verbose
                if (line !~ /^-/) {
                    panic_param_define_error("Expect option starting with - or -- :\n" line)
                }

                len = option_arr[ L ] + 1
                option_arr[ L ] = len
                option_arr[ len ] = line

                tokenize_argument_into_TOKEN_ARRAY( line )
                option_id = TOKEN_ARRAY[1]
                handle_option_id( option_id )

                option_desc = TOKEN_ARRAY[2]
                option_arr[ option_id S OPTION_DESC ] = option_desc

                j = 0
                if ( TOKEN_ARRAY[ L ] >= 3) {

                    tmp = ""
                    for (k=3; k<=TOKEN_ARRAY[ L ]; ++k) {
                        tmp = tmp " " quote_string(TOKEN_ARRAY[k])
                    }

                    j = j + 1
                    option_arr[ option_id S j ] = tmp
                    handle_optarg_declaration( tmp, option_id S j )
                }

                while (true) {
                    i += 1
                    # debug("line_arr[ " i " ]" line_arr[ i ])
                    nextline = str_trim( line_arr[ i ] )
                    if ( nextline !~ /^</ ) {
                        i --
                        break
                    }
                    j = j + 1
                    option_arr[ option_id S j ] = nextline
                    handle_optarg_declaration( nextline, option_id S j )
                }

                option_arr[ option_id L ] = j
            }
        }
    }
}

# EndSection

# Section: Step 3 Utils: Handle code

function oparr_join(oparr_keyprefix,              _index, _len, _ret ){
    _ret = ""
    _len = option_arr[ oparr_keyprefix L ]
    for ( _index=1; _index<=_len; ++_index ) {
        _ret = _ret " " str_quote_if_unquoted( option_arr[ oparr_keyprefix S _index ] )
    }
    return _ret
}

function check_required_option_ready(       i, j, option, option_argc, option_id, option_m, option_name, _ret, _varname ) {

    for ( i=1; i<=option_id_list[ L ]; ++i ) {
        option_id       = option_id_list[ i ]
        option_m        = option_arr[ option_id S OPTION_M ]
        option_name     = option_arr[ option_id S OPTION_NAME ]
        gsub(/^--?/, "", option_name)

        # if assign, continue
        if ( option_arr_assigned[ option_id ] == true ) {
            if (option_m == true) {
                # count the number of arguments
                append_code_assignment( option_name "_n",    option_assignment_count[ option_id ] )
            }
            continue
        }

        option_argc      = option_arr[ option_id L ]

        if ( 0 == option_argc ) {
            continue
        }

        if ( true == option_m ) {
            append_code_assignment( option_name "_n", 1 )
            option_name = option_name "_" 1
        }

        for ( j=1; j<=option_argc; ++j ) {
            if ( (j==1) && (option_argc == 1) ) {
                # if argc == 1
                val = option_default_map[ option_name ]
                if (length(val) == 0) {
                    val = option_arr[ option_id S 1 S OPTARG_DEFAULT ]
                }
                _varname = option_name
            } else {
                # if argc >= 2
                val = option_arr[ option_id S j S OPTARG_DEFAULT ]
                _varname = option_name "_" j
            }

            if (val == OPTARG_DEFAULT_REQUIRED_VALUE) {

                if ( true == IS_INTERACTIVE ) {
                    append_query_code( _varname,
                        option_arr[ option_id S OPTION_DESC ],
                        oparr_join( option_id S j S OPTARG_OPARR )    )
                    continue
                }
                return panic_required_value_error( option_id )
            }

            _ret = assert(option_id S j, _varname, val)
            if ( _ret == true ) {
                append_code_assignment( _varname, val )
            } else if ( false == IS_INTERACTIVE ) {
                panic_error( _ret )
            } else {
                append_query_code(  _varname,
                    option_arr[option_id S OPTION_DESC ],
                    oparr_join( option_id S j S OPTARG_OPARR )        )
            }
        }
    }

}

# EndSection

# Section: 1-GetTypes   2-GetSubcmd     3-DSL

NR==1 {
    type_arr_len = split(str_trim($0), type_arr, ARG_SEP)
    for (i=1; i<=type_arr_len; ++i) {
        _type_elem = str_trim( type_arr[i] )
        if ( 0 != length( _type_elem ) ) {
            type_arr_add(_type_elem)
        }
    }
}

NR==2 {
    code=str_trim($0)
    code=substr(code, 2)

    subcmd_arr_len = split(code, subcmd_arr, ARG_SEP)
    subcmd_arr[ L ] = subcmd_arr_len
    for (i=1; i<=subcmd_arr_len; ++i) {
        _subcmd_elem = str_trim( subcmd_arr[i] )
        if (0 != length( _subcmd_elem ) ) {
            # print i " " subcmd_arr[i] >"/dev/stderr"
            subcmd_arr_add( i, _subcmd_elem )
        }
    }
}

NR==3 {
    parse_param_dsl($0)
}

# EndSection

NR==4 {
    # handle arguments
    arguments = $0
    gsub("\n", "\004", arguments)
    arg_arr_len = split(arguments, arg_arr, ARG_SEP)
    arg_arr[ L ] = arg_arr_len
    for (i=1; i<=arg_arr[ L ]; ++i) {
        gsub("\004", "\n", arg_arr[ i ])
    }

    # Optimization
    append_code_assignment( "PARAM_SUBCMD", "" )
}
