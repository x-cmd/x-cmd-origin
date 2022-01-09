BEGIN {
    false = 0;  true = 1
    LEN   ="len"
    KSEP  = "\034"

    if (IS_TTY == true) {
        FG_RED        = "\033[31m"
        FG_LIGHT_RED  = "\033[91m"
        FG_BLUE       = "\033[36m"
        FG_YELLOW     = "\033[33m"
        UI_END        = "\033[0m"
    }

    EXIT_CODE = 0
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
    print FG_LIGHT_RED "param define error: " UI_END msg "\nFor more information try to read the demo in " FG_BLUE "https://gitee.com/x-bash/param/blob/main/testcase/v0_test" UI_END > "/dev/stderr"
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
    append_code( "local " varname " >/dev/null 2>&1" )
    append_code( varname "=" single_quote_string( value ) )
}

function append_query_code(varname, description, typestr){
    append_code( "local " varname " >/dev/null 2>&1" )
    append_code( "ui prompt main " quote_string(description) " " varname " " typestr )
}

# EndSection

# Section: utils
# option_string is a string of option, each option is separated by ','
# example:
#   1. --option1,-o1
#   2. --option1,-o1 <arg1> <arg2> ...
function get_option_string(option_id,
    _option_string, _j){
    _option_string = option_id
    gsub("\\|m", "", _option_string)
    gsub("\\|", ",", _option_string)

    option_argc      = option_arr[ option_id KSEP LEN ]
    for ( _j=1; _j<=option_argc; ++_j ) {
        _option_string = _option_string " <" option_arr[ option_id KSEP _j KSEP OPTARG_NAME ] ">"
    }

    return _option_string
}

# TOKEN_ARRAY
function tokenize_argument_into_TOKEN_ARRAY(astr,
    _len, _tmp ){

    original_astr = astr

    gsub(/\\\\/,    "\001", astr)
    gsub(/\\"/,     "\002", astr) # "
    gsub("\"",      "\003", astr) # "
    gsub(/\\ /,    "\004", astr)

    astr = str_trim(astr)

    TOKEN_ARRAY[LEN] = 0
    while (length(astr) > 0){

        if (match(astr, /^\003[^\003]*\003/)) {
            _len = TOKEN_ARRAY[LEN] + 1
            _tmp = substr(astr, 1, RLENGTH)
            gsub("\004", " ",   _tmp)      # Unwrap
            gsub("\003", "",    _tmp)      # Unwrap
            gsub("\002", "\"",  _tmp)
            gsub("\001", "\\",  _tmp)      # Unwrap
            TOKEN_ARRAY[_len] = _tmp
            TOKEN_ARRAY[LEN] = _len
            astr = substr(astr, RLENGTH+1)

        } else if ( match(astr, /^[^ \n\t\v\003]+/) ){ #"

            _len = TOKEN_ARRAY[LEN] + 1
            _tmp = substr(astr, 1, RLENGTH)
            gsub("\004", " ",       _tmp)
            gsub("\003", "",        _tmp)
            gsub("\002", "\"",      _tmp)
            gsub("\001", "\\\\",    _tmp)   # Notice different
            TOKEN_ARRAY[_len] = _tmp
            TOKEN_ARRAY[LEN] = _len
            astr = substr(astr, RLENGTH+1)

            if ( match(astr, /^\003[^\003]*\003/) ) {
                _tmp = substr(astr, 1, RLENGTH)
                gsub(" ", "\005",   _tmp)
                gsub("\004", " ",   _tmp)      # Unwrap
                gsub("\003", "",    _tmp)      # Unwrap
                gsub("\002", "\"",  _tmp)
                gsub("\001", "\\",  _tmp)      # Unwrap
                TOKEN_ARRAY[_len] = TOKEN_ARRAY[_len] _tmp

                astr = substr(astr, RLENGTH+1)
            }
        } else {
            panic_param_define_error("Fail to tokenzied following line:\n  original_astr:" original_astr "\n  astr:|" astr "\n  _tmp: |" _tmp)
        }

        astr = str_trim_left(astr)
    }
}

# EndSection

# Section: Assert

### Type check
function join_optarg_oparr(optarg_id,
    _len, _idx, _result, _oparr_keyprefix){

    _oparr_keyprefix = optarg_id KSEP OPTARG_OPARR

    _result = ""
    _len = option_arr[ _oparr_keyprefix KSEP LEN ]
    for (_idx=1; _idx<=_len; ++_idx) {
        _result = _result " " option_arr[ _oparr_keyprefix KSEP _idx ]
    }

    return _result
}

function assert_arr_eq(optarg_id, arg_name, value, sep,
    op_arr_len, i, idx, value_arr_len, value_arr, candidate, sw,
    oparr_keyprefix){

    oparr_keyprefix = optarg_id KSEP OPTARG_OPARR
    op_arr_len = option_arr[ oparr_keyprefix KSEP LEN ]

    value_arr_len = split(value, value_arr, sep)
    for (i=1; i<=value_arr_len; ++i) {
        sw = false
        for (idx=2; idx<=op_arr_len; ++idx) {
            candidate = option_arr[ oparr_keyprefix KSEP idx ]
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

    oparr_keyprefix = optarg_id KSEP OPTARG_OPARR

    len = option_arr[ oparr_keyprefix KSEP LEN ]

    value_arr_len = split(value, value_arr, sep)
    for (i=1; i<=value_arr_len; ++i) {
        sw = false
        for (idx=2; idx<=len; ++idx) {
            val = option_arr[ oparr_keyprefix KSEP idx ]
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

    oparr_keyprefix = optarg_id KSEP OPTARG_OPARR
    op = option_arr[ oparr_keyprefix KSEP 1 ]
    # debug("assert: optarg_id: " optarg_id " arg_name: " arg_name " arg_val: " arg_val " op: " op " oparr_keyprefix: " oparr_keyprefix)

    if (op == "=int") {
        if (! match(arg_val, /[+-]?[0-9]+/) ) {    # float is: /[+-]?[0-9]+(.[0-9]+)?/
            return "Arg: [" arg_name "] value is [" arg_val "]\n  Is NOT an integer."
        }
    } else if (op == "=") {
        sw = false
        len = option_arr[ oparr_keyprefix KSEP LEN ]
        for (idx=2; idx<=len; ++idx) {
            val = option_arr[ oparr_keyprefix KSEP idx ]
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
        len = option_arr[ oparr_keyprefix KSEP LEN ]
        for (idx=2; idx<=len; ++idx) {
            val = option_arr[ oparr_keyprefix KSEP idx ]
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
    type_arr[LEN]=0
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

function subcmd_arr_add(idx, line_trimed,                 _id, _name_arr, _name_arr_len, _i){
    if (! match(line_trimed, /^[A-Za-z0-9_\|-]+/)) {
        panic_param_define_error( "Expect subcommand in the first token, but get:\n" line )
    }

    _id = substr( line_trimed, 1, RLENGTH )
    subcmd_arr[ idx ] = _id
    subcmd_map[ _id ] = str_trim( substr( line_trimed, RLENGTH+1 ) )

    _name_arr_len = split(_id, _name_arr, "|")
    for (_i=1; _i<=_name_arr_len; _i++) {
        subcmd_id_lookup[ _name_arr[ _i ] ] = _id
    }
}

# EndSection

# Section: Step 2 Utils: Parse param DSL
BEGIN {
    advise_arr[ LEN ]=0
    arg_arr[ LEN ]=0
    subcmd_arr[ LEN ]=0
    # subcmd_map

    # RS="\001"

    rest_option_id_list[ LEN ] = 0
}

BEGIN {
    final_rest_argv[ LEN ] = 0

    option_arr[ LEN ]=0
    option_id_list[ LEN ] = 0

    # OPTION_ARGC = "num" # Equal LEN
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
}

function handle_option_id(option_id,            _arr, _arr_len, _arg_name, _index){

    # Add option_id to option_id_list
    _index = option_id_list[ LEN ] + 1
    option_id_list[ LEN ] = _index
    option_id_list[ _index ] = option_id

    option_arr[ option_id KSEP OPTION_M ] = false

    _arr_len = split( option_id, _arr, /\|/ )

    # debug("handle_option_id \t" _arr_len)
    for ( _index=1; _index<=_arr_len; ++_index ) {
        _arg_name = _arr[ _index ]
        # Prevent name conflicts
        if (option_alias_2_option_id[ _arg_name ] != "") {
            panic_param_define_error("Already exsits: " _arg_name)
        }

        if (_arg_name == "m") {
            option_arr[ option_id KSEP OPTION_M ] = true
            continue
        }

        if (_arg_name !~ /^-/) {
            panic_param_define_error("Unexpected option name: \n" option_id)
        }

        if ( _index == 1 ) {
            option_arr[ option_id KSEP OPTION_NAME ] = _arg_name
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

    # debug( "handle_optarg_definition:\t" optarg_definition )
    # debug( "handle_optarg_declaration:\t" optarg_definition_token1 )

    if (! match( optarg_definition_token1, /^<[-_A-Za-z0-9]*>/) ) {
        panic_param_define_error("Unexpected optarg declaration: \n" optarg_definition)
    }

    optarg_name = substr( optarg_definition_token1, 2, RLENGTH-2 )
        option_arr[ optarg_id KSEP OPTARG_NAME ] = optarg_name

    optarg_definition_token1 = substr( optarg_definition_token1, RLENGTH+1 )

    if (match( optarg_definition_token1, /^:[-_A-Za-z0-9]+/) ) {
        optarg_type = substr( optarg_definition_token1, 2, RLENGTH-1 )
        optarg_definition_token1 = substr( optarg_definition_token1, RLENGTH+1 )
    }

    if (match( optarg_definition_token1 , /^=/) ) {
        default_value = substr( optarg_definition_token1, 2 )
        option_arr[ optarg_id KSEP OPTARG_DEFAULT ] = str_unquote_if_quoted( default_value )
    } else {
        # It means, it is required.
        option_arr[ optarg_id KSEP OPTARG_DEFAULT ] = OPTARG_DEFAULT_REQUIRED_VALUE
        EXISTS_REQUIRED_OPTION = true
    }

    if (TOKEN_ARRAY[ LEN ] >= 2) {
        for ( i=2; i<=TOKEN_ARRAY[ LEN ]; ++i ) {
            option_arr[ optarg_id KSEP OPTARG_OPARR KSEP i-1 ] = TOKEN_ARRAY[i]
        }
        option_arr[ optarg_id KSEP OPTARG_OPARR KSEP LEN ] = TOKEN_ARRAY[ LEN ] - 1
    } else {
        type_rule = type_arr[ optarg_type ]
        if (type_rule == "") {
            return
        }

        tokenize_argument_into_TOKEN_ARRAY( type_rule )

        for ( i=1; i<=TOKEN_ARRAY[ LEN ]; ++i ) {
            option_arr[ optarg_id KSEP OPTARG_OPARR KSEP i ] = TOKEN_ARRAY[i]
        }
        option_arr[ optarg_id KSEP OPTARG_OPARR KSEP LEN ] = TOKEN_ARRAY[ LEN ]
    }

}

# options like #1, #2, #3 ...
function parse_param_dsl_for_positional_argument(line,
    option_id, option_desc, tmp, _arr_len, _arr, _index, _arg_name, _arg_no, _optarg_id){

    tokenize_argument_into_TOKEN_ARRAY( line )

    option_id = TOKEN_ARRAY[1]

    tmp = rest_option_id_list[ LEN ] + 1
    rest_option_id_list[ LEN ] = tmp
    rest_option_id_list[ tmp ] = option_id
    option_arr[ option_id KSEP LEN ] = 1
    option_arr[ option_id KSEP OPTION_M ] = 0

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
            option_arr[ option_id KSEP OPTION_NAME ] = _arg_name
        }
        option_alias_2_option_id[ _arg_name ] = option_id
    }

    option_desc = TOKEN_ARRAY[2]
    option_arr[ option_id KSEP OPTION_DESC ] = option_desc

    if ( TOKEN_ARRAY[ LEN ] >= 3) {
        tmp = ""
        for ( _index=3; _index<=TOKEN_ARRAY[LEN]; ++_index ) {
            tmp = tmp " " TOKEN_ARRAY[ _index ]
        }

        option_arr[ option_id ] = tmp

        _optarg_id = option_id KSEP 1
        handle_optarg_declaration( tmp, _optarg_id )

        # NOTICE: this is correct. Only if has default value, or it is required !
        if (final_rest_argv[ LEN ] < _arg_no)   final_rest_argv[ LEN ] = _arg_no
        final_rest_argv[ _arg_no ] = option_arr[ _optarg_id KSEP OPTARG_DEFAULT ]
        # debug( "final_rest_argv[ " _arg_no " ] = " final_rest_argv[ _arg_no ] )
    }

}

# options #n
function parse_param_dsl_for_all_positional_argument(line,
    option_id, option_desc, tmp){

    tokenize_argument_into_TOKEN_ARRAY( line )

    option_id = TOKEN_ARRAY[1]  # Should be #n

    tmp = rest_option_id_list[ LEN ] + 1
    rest_option_id_list[ LEN ] = tmp
    rest_option_id_list[ tmp ] = option_id

    option_desc = TOKEN_ARRAY[2]
    option_arr[ option_id KSEP OPTION_DESC ] = option_desc

    if ( TOKEN_ARRAY[ LEN ] >= 3) {
        tmp = ""
        for (i=3; i<=TOKEN_ARRAY[LEN]; ++i) {
            tmp = tmp " " TOKEN_ARRAY[i]
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
        } else if ( (line ~ /^subcommands?:/) || (line ~ /^subcmds?:/) ){
            state = STATE_SUBCOMMAND
        } else if (line ~ /^arguments?:/) {
            state = STATE_ARGUMENT
        } else {

            if (state == STATE_ADVISE) {
                tmp = advise_arr[ LEN ] + 1
                advise_arr[ LEN ] = tmp
                advise_arr[ tmp ] = line

            } else if ( state == STATE_TYPE ) {
                type_arr_add( line )

            } else if ( state == STATE_SUBCOMMAND ) {
                HAS_SUBCMD = true

                tmp = subcmd_arr[ LEN ] + 1
                subcmd_arr[ LEN ] = tmp

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
                    if (HAS_SUBCMD != true) {
                        HAS_SUBCMD = false
                    }

                    parse_param_dsl_for_positional_argument( line )
                    continue
                }

                # HANDLE:   option like --user|-u, or --verbose
                if (line !~ /^-/) {
                    panic_param_define_error("Expect option starting with - or -- :\n" line)
                }

                len = option_arr[ LEN ] + 1
                option_arr[ LEN ] = len
                option_arr[ len ] = line

                tokenize_argument_into_TOKEN_ARRAY( line )
                option_id = TOKEN_ARRAY[1]
                handle_option_id( option_id )

                option_desc = TOKEN_ARRAY[2]
                option_arr[ option_id KSEP OPTION_DESC ] = option_desc

                j = 0
                if ( TOKEN_ARRAY[ LEN ] >= 3) {

                    tmp = ""
                    for (k=3; k<=TOKEN_ARRAY[LEN]; ++k) {
                        tmp = tmp " " TOKEN_ARRAY[k]
                    }

                    j = j + 1
                    option_arr[ option_id KSEP j ] = tmp
                    handle_optarg_declaration( tmp, option_id KSEP j )
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
                    option_arr[ option_id KSEP j ] = nextline
                    handle_optarg_declaration( nextline, option_id KSEP j )
                }

                option_arr[ option_id KSEP LEN ] = j
            }
        }
    }
}

# EndSection

# Section: Step 3 Utils: Handle code

function oparr_join(oparr_keyprefix,              _index, _len, _ret ){
    _ret = ""
    _len = option_arr[ oparr_keyprefix KSEP LEN ]
    for ( _index=1; _index<=_len; ++_index ) {
        _ret = _ret " " str_quote_if_unquoted( option_arr[ oparr_keyprefix KSEP _index ] )
    }
    return _ret
}

function check_required_option_ready(       i, j, option, option_argc, option_id, option_m, option_name, _ret, _varname ) {

    for ( i=1; i<=option_id_list[ LEN ]; ++i ) {
        option_id       = option_id_list[ i ]
        option_m        = option_arr[ option_id KSEP OPTION_M ]
        option_name     = option_arr[ option_id KSEP OPTION_NAME ]
        gsub(/^--?/, "", option_name)

        # if assign, continue
        if ( option_arr_assigned[ option_id ] == true ) {
            if (option_m == true) {
                # count the number of arguments
                append_code_assignment( option_name "_n",    option_assignment_count[ option_id ] )
            }
            continue
        }

        option_argc      = option_arr[ option_id KSEP LEN ]

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
                    val = option_arr[ option_id KSEP 1 KSEP OPTARG_DEFAULT ]
                }
                _varname = option_name
            } else {
                # if argc >= 2
                val = option_arr[ option_id KSEP j KSEP OPTARG_DEFAULT ]
                _varname = option_name "_" j
            }

            if (val == OPTARG_DEFAULT_REQUIRED_VALUE) {

                if ( true == IS_INTERACTIVE ) {
                    append_query_code( _varname,
                        option_arr[ option_id KSEP OPTION_DESC ],
                        oparr_join( option_id KSEP j KSEP OPTARG_OPARR )    )
                    continue
                }
                return panic_required_value_error( option_id )
            }

            _ret = assert(option_id KSEP j, _varname, val)
            if ( _ret == true ) {
                append_code_assignment( _varname, val )
            } else if ( false == IS_INTERACTIVE ) {
                panic_error( _ret )
            } else {
                append_query_code(  _varname,
                    option_arr[option_id KSEP OPTION_DESC ],
                    oparr_join( option_id KSEP j KSEP OPTARG_OPARR )        )
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
    subcmd_arr[ LEN ] = subcmd_arr_len
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

# Section: Generate Help Doc

function print_helpdoc_getitem(oparr_keyprefix,
    op, oparr_string, op_arr_len,
    k){

    op = option_arr[ oparr_keyprefix KSEP 1 ]
    if ( op == "" ) return ""

    oparr_string    = "<"
    op_arr_len = option_arr[ oparr_keyprefix KSEP LEN ]
    for ( k=2; k<=op_arr_len; ++k ) {
        oparr_string = oparr_string option_arr[ oparr_keyprefix KSEP k ] "|"
    }

    oparr_string = substr(oparr_string, 1, length(oparr_string)-1) ">"
    if (oparr_string == ">") oparr_string = ""

    return op "\t" oparr_string
}

function get_space(space_len,
    _space, _j){
    _space = ""
    for ( _j=1; _j<=space_len; ++_j ) {
        _space = _space " "
    }
    return _space
}

function cut_line(_line,_space_len,_option_line,_len_line,_max_len_line,_option_after_len,_option_after_arr_len){
    if( COLUMNS == "" ){
        return _line
    }
    _option_line = ""
    _option_after_arr_len = 0
    _len_line = length(_line)
    _max_len_line = COLUMNS-_space_len-3-4
    _option_after_len = split(_line,_option_after_arr," ")
    if (_len_line >= _max_len_line) {
        # for(key in _option_after_arr){
        for(key=1; key<=_option_after_len; ++key){
            _option_after_arr_len=_option_after_arr_len+length(_option_after_arr[key])+1
            if(_option_after_arr_len >= _max_len_line) {
                _option_after_arr_len = _option_after_arr_len-length(_option_after_arr[key])-1
                break
            }
        }
        # debug("_option_after_arr_len:"_option_after_arr_len";\t\tspace:"_space_len+7)
        _option_line = _option_line substr(_line, 1, _option_after_arr_len) "\n" get_space(_space_len+7)  cut_line(substr(_line,_option_after_arr_len+1),_space_len)
    } else {
        _option_line = _option_line _line
    }
    return _option_line
}

# There are two types of options:
# 1. Options without arguments, is was flags.
# 2. Options with arguments.
#   For example, --flag1, --flag2, --flag3, ...
#   For example, --option1 value1, --option2 value2, --option3 value3, ...
function generate_option_help(         _option_help, i, j, k, option_list, flag_list,_option_after) {

    # If option has no argument, push it to flag_list.
    # Otherwise, push it to option_list.
    for (_i=1; _i<=option_id_list[ LEN ]; ++_i) {
        option_id     = option_id_list[ _i ]
        option_argc   = option_arr[ option_id KSEP LEN ]

        if (option_argc == 0) {
            flag_list[ LEN ] = flag_list[ LEN ] + 1
            flag_list[ flag_list[ LEN ] ] = option_id
        } else {
            option_list[ LEN ] = option_list[ LEN ] + 1
            option_list[ option_list[ LEN ] ] = option_id
        }
    }

    # Generate help doc for options without arguments.
    if (0 != flag_list[ LEN ]) {
        # Get max length of _opt_help_doc, and generate _opt_help_doc_arr.
        _max_len = 0
        _option_after = ""
        for (i=1; i<=flag_list[ LEN ]; ++i) {
            option_id = flag_list[ i ]
            _opt_help_doc = get_option_string(option_id)

            if (length(_opt_help_doc) > _max_len) _max_len = length(_opt_help_doc)
            _opt_help_doc_arr[ i ] = _opt_help_doc
        }
        # Generate help doc.
        _option_help = _option_help "\nFLAGS:\n"
        for (i=1; i<=flag_list[ LEN ]; ++i) {
            option_id = flag_list[ i ]
            _space = get_space(_max_len-length(_opt_help_doc_arr[ i ]))
            _option_after = option_arr[option_id KSEP OPTION_DESC ] UI_END
            _option_after = cut_line(_option_after,_max_len)
            _option_help = _option_help "    " FG_BLUE _opt_help_doc_arr[ i ] _space "   " FG_LIGHT_RED _option_after"\n"
        }
    }

    # Generate help doc for options with arguments.
    if (0 != option_list[ LEN ]) {
        # Get max length of _opt_help_doc, and generate _opt_help_doc_arr.
        _max_len = 0
        _option_after = ""
        for (i=1; i<=option_list[ LEN ]; ++i) {
            _opt_help_doc = get_option_string( option_list[ i ] )

            if (length(_opt_help_doc) > _max_len) _max_len = length(_opt_help_doc)
            _opt_help_doc_arr[ i ] = _opt_help_doc
        }

        # Generate help doc.
        _option_help = _option_help "\nOPTIONS:\n"
        for (i=1; i<=option_list[ LEN ]; ++i) {
            # Generate default/candidate/regex help doc.
            # Example: [default: fzf] [candidate: fzf, skim] [regex: ^(fzf|skim)$ ] ...
            option_id = option_list[ i ]
            option_argc   = option_arr[ option_id KSEP LEN ]
            oparr_string  = ""
            for(j=1; j<=option_argc; ++j) {
                oparr_keyprefix = option_id KSEP j KSEP OPTARG_OPARR
                _default = option_arr[ option_id KSEP j KSEP OPTARG_DEFAULT ]
                _op = option_arr[ oparr_keyprefix KSEP 1 ]
                _regex = ""
                _candidate = ""
                gsub("\005", " ", _default)
                if (_default != "" && _default != OPTARG_DEFAULT_REQUIRED_VALUE) {
                    _default = " [default: " _default "]"
                }

                if ( _op == "=~" ) {
                    _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
                    for ( k=2; k<=_optarr_len; ++k ) {
                        _regex = _regex "\"" option_arr[ oparr_keyprefix KSEP k ] "\"" "|"
                    }
                    _regex = " [regex: " substr(_regex, 1, length(_regex)-1) "]"

                } else if ( _op == "=" ) {
                    _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
                    for ( k=2; k<=_optarr_len; ++k ) {
                        _candidate = _candidate "\"" option_arr[ oparr_keyprefix KSEP k ] "\"" ", "
                    }
                    _candidate = " [candidate: " substr(_candidate, 1, length(_candidate)-2) " ]"
                }

                oparr_string = oparr_string _default _candidate _regex
            }

            if (match(option_id, /\\|m/)) {
                _multiple = " [multiple]"
            } else {
                _multiple = ""
            }

            _space = get_space(_max_len-length(_opt_help_doc_arr[ i ]))
            _option_after = option_arr[ option_list[ i ] KSEP OPTION_DESC ] UI_END oparr_string _multiple
            _option_after = cut_line(_option_after,_max_len)
            _option_help = _option_help "    " FG_BLUE _opt_help_doc_arr[ i ] _space "   " FG_LIGHT_RED _option_after"\n"
        }
    }

    return _option_help
}

function generate_rest_argument_help(        _option_help,_option_after) {

    # Get max length of rest argument name.
    _max_len = 0
    _option_after = ""
    for (i=1; i<=rest_option_id_list[ LEN ]; ++i) {
        if (length(rest_option_id_list[ i ]) > _max_len) _max_len = length(rest_option_id_list[ i ])
    }

    # Generate help doc.
    _option_help = _option_help "\nARGS:\n"
    for (i=1; i <= rest_option_id_list[ LEN ]; ++i) {
        option_id       = rest_option_id_list[ i ]
        oparr_keyprefix = option_id KSEP 1 KSEP OPTARG_OPARR
        oparr_string = print_helpdoc_getitem(oparr_keyprefix)
        _space = get_space(_max_len-length(option_id))

        oparr_string  = ""

        _default = option_arr[ option_id KSEP 1 KSEP OPTARG_DEFAULT ]
        _op = option_arr[ oparr_keyprefix KSEP 1 ]
        _regex = ""
        _candidate = ""

        if (_default != "" && _default != OPTARG_DEFAULT_REQUIRED_VALUE) {
            _default = " [default: " _default "]"
        }

        if ( _op == "=~" ) {
            _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
            for ( k=2; k<=_optarr_len; ++k ) {
                _regex = _regex "\"" option_arr[ oparr_keyprefix KSEP k ] "\"" "|"
            }
            _regex = " [regex: " substr(_regex, 1, length(_regex)-1) "]"

        } else if(_op == "=") {
            _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
            for ( k=2; k<=_optarr_len; ++k ) {
                _candidate = _candidate "\"" option_arr[ oparr_keyprefix KSEP k ] "\"" ", "
            }
            _candidate = " [candidate: " substr(_candidate, 1, length(_candidate)-2) " ]"
        }

        oparr_string = oparr_string _default _candidate _regex
        _option_after = option_arr[option_id KSEP OPTION_DESC ] UI_END oparr_string
        _option_after = cut_line(_option_after,_max_len)
        _option_help = _option_help "    " FG_BLUE option_id _space "   " FG_LIGHT_RED _option_after "\n"
    }

    return _option_help
}

function generate_subcommand_help(        _option_help) {
    # Get max length of subcommand name.
    _max_len = 0
    for (i=1; i<=subcmd_arr[ LEN ]; ++i) {
        if (length(subcmd_arr[ i ]) > _max_len) _max_len = length(subcmd_arr[ i ])
    }

    # Generate help doc.
    _option_help = _option_help "\nSUBCOMMANDS:\n"
    for (i=1; i <= subcmd_arr[ LEN ]; ++i) {
        _cmd_name = subcmd_arr[ i ]
        gsub("\\|", ",", _cmd_name)
        _space = get_space(_max_len-length(_cmd_name))

        _option_help = _option_help "    " FG_BLUE _cmd_name _space "\t" FG_LIGHT_RED str_unquote(subcmd_map[ subcmd_arr[ i ] ]) UI_END "\n"
    }

    _option_help = _option_help "\nRun 'CMD SUBCOMMAND --help' for more information on a command\n"

    return _option_help
}

function print_helpdoc(exit_code,
    HELP_DOC){

    if (0 != option_id_list[ LEN ]) {
        HELP_DOC = HELP_DOC generate_option_help()
    }

    if (0 != rest_option_id_list[ LEN ]) {
        HELP_DOC = HELP_DOC generate_rest_argument_help()
    }

    if (0 != subcmd_arr[ LEN ]) {
        HELP_DOC = HELP_DOC generate_subcommand_help()
    }
    print "printf %s " " " quote_string(HELP_DOC)
    if (exit_code == "")    exit_code = 0
    print "return " exit_code
    exit_now(1) # TODO: should I return 0?
}

# EndSection

# Section: advise

function generate_advise_json_value_candidates(oparr_keyprefix,
    oparr_string, optarg_name, k, op ){

    op = option_arr[ oparr_keyprefix KSEP 1 ]

    oparr_string = ""
    if (op == "=") {
        op_arr_len = option_arr[ oparr_keyprefix KSEP LEN ]
        for ( k=2; k<=op_arr_len; ++k ) {
            oparr_string = oparr_string "\"" option_arr[ oparr_keyprefix KSEP k ] "\"" ", "
        }
        oparr_string = "[ " substr(oparr_string, 1, length(oparr_string)-2) " ],"
    } else if (op == "=~") {
        optarg_name = option_arr[ option_id KSEP OPTARG_NAME ]
        oparr_string = "[  ],"
        if ( advise_map[ optarg_name ] != "" ) {
            oparr_string = "\"" advise_map[ optarg_name ] "\","
            advise_map[ optarg_name ] = ""
        }
    } else {
        oparr_string = "[  ],"
    }

    return oparr_string
}

# Rely on subcmd_arr. Must after
function generate_advise_json(      indent, indent_str,
    i, j,tmp_len,
    option_id, option_argc, advise_map,
    option_id_advise, tmp, _name_arr){
    indent = arg_arr[2] # for recursive gen advise json
    if (indent == "") indent = 0
    indent_str = ""
    for ( i=1; i <= indent; ++i ){
        indent_str = indent_str "  "
    }

    ADVISE_JSON = "{"

    for (i=1; i<=advise_arr[ LEN ]; ++i) {
        # TODO: Can be optimalize.
        tmp_len=split(advise_arr[ i ], tmp)
        if ( option_alias_2_option_id[ tmp[1] ] != "" ){
            option_id = option_alias_2_option_id[ tmp[1] ]
        } else {
            option_id = tmp[1]
        }

        for (j=2; j<=tmp_len; ++j) {
            advise_map[ option_id ] = advise_map[ option_id ] " " tmp[j]
        }
        advise_map[ option_id ] = str_trim( advise_map[ option_id ] )
    }

    # Rule for option
    for (i=1; i<=option_id_list[ LEN ]; ++i) {

        option_id       = option_id_list[ i ]
        option_argc     = option_arr[ option_id KSEP LEN ]

        if (option_argc == 0) {
            ADVISE_JSON = ADVISE_JSON "\n" indent_str "  \"" option_id "\": \"--- " option_arr[ option_id KSEP OPTION_DESC ] " \","
        } else {
            ADVISE_JSON = ADVISE_JSON "\n" indent_str "  \"" option_id "\": " "{\n  "
        }

        for ( j=1; j<=option_argc; ++j ) {
            oparr_keyprefix = option_id KSEP j KSEP OPTARG_OPARR
            oparr_string    = generate_advise_json_value_candidates(oparr_keyprefix)
            oparr_string    = indent_str "  \"#" j "\": " oparr_string "\n  "

            ADVISE_JSON = ADVISE_JSON oparr_string
        }

        if (option_argc > 0) {
            ADVISE_JSON = ADVISE_JSON indent_str "  \"#desc\": \"" option_arr[ option_id KSEP OPTION_DESC ] "\"\n  " indent_str "},"
        }
    }

    # Rules for rest options
    for (i=1; i <= rest_option_id_list[ LEN ]; ++i) {
        option_id       = rest_option_id_list[ i ]
        if (advise_map[ option_id ] != "") continue
        oparr_keyprefix = option_id KSEP OPTARG_OPARR
        oparr_string    = generate_advise_json_value_candidates(oparr_keyprefix)
        ADVISE_JSON     = ADVISE_JSON "\n" indent_str "  \"" option_id "\": " oparr_string
    }

    # Rules in DSL's advise section
    for (key in advise_map) {
        if ( advise_map[ key ] != "") {
            ADVISE_JSON = ADVISE_JSON "\n" indent_str "  \"" key "\": \"" advise_map[key] "\","
        }
    }

    for (i=1; i <= subcmd_arr[ LEN ]; ++i) {
        split(subcmd_arr[ i ], _name_arr, "|") # get the subcmd name list
        subcmd_funcname = "${X_CMD_ADVISE_FUNC_NAME}_" _name_arr[ 1 ]

        subcmd_invocation = "X_CMD_ADVISE_FUNC_NAME=${X_CMD_ADVISE_FUNC_NAME}_" _name_arr[ 1 ] " "
        subcmd_invocation = subcmd_invocation subcmd_funcname " _x_cmd_advise_json " (indent + 1) " 2>/dev/null "
        subcmd_invocation = "s=$(" subcmd_invocation "); "

        value = subcmd_invocation "if [ $? -eq 126 ] && [ ${#s} != " (indent*2+5) " ] ; then printf \002,${s#{}\002 ; else printf '\n" indent_str "  }'; fi"
        value = "$( " value  " )"

        key = quote_string( subcmd_arr[ i ] )
        ADVISE_JSON = ADVISE_JSON "\n  " indent_str key ": {\n"  indent_str "    \"#desc\": " subcmd_map[ subcmd_arr[ i ] ] value ","
    }

    if (ADVISE_JSON != "{"){
        ADVISE_JSON = substr(ADVISE_JSON, 1, length(ADVISE_JSON)-1)
    }
    ADVISE_JSON = ADVISE_JSON "\n" indent_str "}"

    ADVISE_JSON = quote_string(ADVISE_JSON)
    gsub(/\002/, "\"", ADVISE_JSON)
    print "printf \"%s\" " ADVISE_JSON
    print "return 126"
}

# EndSection

# Section: 4-Arguments and intercept for help and advise            5-DefaultValues
NR==4 {

    # handle arguments
    arguments = $0
    gsub("\n", "\004", arguments)
    arg_arr_len = split(arguments, arg_arr, ARG_SEP)
    arg_arr[ LEN ] = arg_arr_len
    for (i=1; i<=arg_arr[ LEN ]; ++i) {
        gsub("\004", "\n", arg_arr[ i ])
    }

    # Optimization
    append_code_assignment( "PARAM_SUBCMD", "" )
    if ( (EXISTS_REQUIRED_OPTION == false) && (subcmd_map[ subcmd_id_lookup[ arg_arr[1] ] ] != "") ) {
        split(subcmd_id_lookup[ arg_arr[1] ], _tmp, "|")
        append_code_assignment( "PARAM_SUBCMD", _tmp[1] )
        append_code( "shift " 1 )

        tmp = ""
        # reset the rest_argv
        for (j=2; j<=arg_arr_len; ++j) {
            tmp = tmp " " quote_string(arg_arr[j])
        }
        append_code("set -- " tmp)
        exit_now("000")
    }

    if ( arg_arr[1] == "_param_list_subcmd" ) {
        for (i=1; i <= subcmd_arr[ LEN ]; ++i) {
            subcmd_elearr_len = split( subcmd_arr[ i ], subcmd_elearr, "|" )
            for (j=1; j<=subcmd_elearr_len; ++j)
                print "printf \"%s\n\" " subcmd_elearr[ j ]
        }
        print "return 0"
        exit_now(1)
    }

    if( arg_arr[1] == "_has_subcmd" ){
        for(i=1; i<=subcmd_arr[ LEN ]; ++i){
            if( subcmd_arr[i] == arg_arr[2] ){
                print "return 0"
                exit_now(0)
            }
        }
        print "return 1"
        exit_now(1)
    }

    if( arg_arr[1] == "_dryrun" ){
        DRYRUN_FLAG = true
        IS_INTERACTIVE = false
        for(i=1; i < arg_arr[ LEN ]; ++i){
            arg_arr[i]=arg_arr[i+1]
        }
        handle_arguments()
        print "return 0"
        exit_now(0)
    }

    if ( arg_arr[1] == "_x_cmd_advise_json" ) {
        generate_advise_json()
        # debug(CODE)
        exit_now(1)
    }

    if ( "_param_help_doc" == arg_arr[1] )                              print_helpdoc(1)
    if ( "help" == arg_arr[1] ) {
        has_help_subcmd = false
        for (i=1; i <= subcmd_arr[ LEN ]; ++i) {
            if ( "help" == subcmd_arr[i] )  has_help_subcmd = true
        }
        if (has_help_subcmd == false)                                   print_helpdoc(1)
    }
    if ( ( "--help" == arg_arr[1] ) || ( "-h" == arg_arr[ 1 ] ) ) {
        if ("" == option_alias_2_option_id[ arg_arr[ 1 ] ])               print_helpdoc(1)
    }
}

###############################
# Line 5: Defaults As Map
###############################

NR>=5 {
    # Setting default values
    if (keyline == "") {
        line_arr_len = split($0, line_arr, ARG_SEP)
        if (line_arr[1] == OBJECT_NAME) {
            keyline = line_arr[2]
        }
    } else {
        option_default_map[keyline] = $0
        keyline = ""
    }
}
# EndSection

# Section: handle_arguments
function arg_typecheck_then_generate_code(option_id, optarg_id, arg_var_name, arg_val,
    def, tmp ){

    _ret = assert( optarg_id, arg_var_name, arg_val )
    if ( _ret == true ) {
        append_code_assignment( arg_var_name, arg_val )
    } else if ( false == IS_INTERACTIVE ) {
        panic_error( _ret )
    } else {
        append_query_code(   arg_var_name,
            option_arr[ option_id KSEP OPTION_DESC ],
            oparr_join( optarg_id KSEP OPTARG_OPARR )       )
    }
}

function handle_arguments_restargv_typecheck(is_interative, i, argval, is_dsl_default,
    tmp, _option_id, _optarg_id){
    _option_id = option_alias_2_option_id[ "#" i ]
    _optarg_id = _option_id KSEP 1

    if (argval != "") {
        _ret = assert(_optarg_id, "$" i, argval)

        if (_ret == true) {
            return true
        } else if (false == is_interative) {
            if (is_dsl_default == true) {
                panic_param_define_error(_ret)
            } else {
                panic_error( _ret )
            }
        } else {
            # TODO: XXX
            append_query_code(  "_X_CMD_PARAM_ARG_" i,
                option_arr[ _option_id KSEP OPTION_DESC ],
                oparr_join( _optarg_id KSEP OPTARG_OPARR )      )
            return false
        }
    }

    nth_rule = option_arr[ "#n" ]
    if (nth_rule == "") {
       return true
    }

    _ret = assert(_optarg_id, "$" i, argval)
    if (_ret == true) {
        return true
    } else if (false == is_interative) {
        if (is_dsl_default == true) {
            panic_param_define_error(_ret)
        } else {
            panic_error( _ret )
        }
    } else {
        # TODO: XXX
        append_query_code(  "_X_CMD_PARAM_ARG_" i,
            option_arr[ _option_id KSEP OPTION_DESC ],
            oparr_join( _optarg_id KSEP OPTARG_OPARR )          )
        return false
    }
}

function handle_arguments_restargv(         final_rest_argv_len, i, nth_rule, arg_val, option_id,
    named_value, _need_set_arg, set_arg_namelist, tmp, _index ){

    final_rest_argv_len = final_rest_argv[ LEN ]
    for ( i=1; i<=final_rest_argv_len; ++i) {
        set_arg_namelist[ i ] = i
    }

    _need_set_arg = false
    for ( i=1; i<=final_rest_argv_len; ++i) {
        if ( i <= arg_arr[ LEN ]) {
            arg_val = arg_arr[ i ]
            # To set the input value and continue
            if ( true != handle_arguments_restargv_typecheck( IS_INTERACTIVE, i, arg_val, false ) ) {
                set_arg_namelist[ i ] = "_X_CMD_PARAM_ARG_" i
                _need_set_arg = true
            }

            option_id = option_alias_2_option_id[ "#" i ]
            tmp = option_arr[ option_id KSEP OPTION_NAME ]
            gsub(/^--?/, "", tmp)
            if( tmp != "" ) {
                append_code_assignment( tmp, arg_val )
                set_arg_namelist[ i ] = tmp
                _need_set_arg = true
            } else {
                append_code_assignment( "_X_CMD_PARAM_ARG_" i , arg_val )
                set_arg_namelist[ i ] = "_X_CMD_PARAM_ARG_" i
                _need_set_arg = true
            }

            continue
        } else {
            option_id = option_alias_2_option_id[ "#" i ]
            named_value = rest_arg_named_value[ option_id ]

            # Using something better, like OPTARG_DEFAULT_REQUIRED_VALUE
            if (named_value != "") {
                tmp = option_arr[ option_id KSEP OPTION_NAME ]
                gsub(/^--?/, "", tmp)
                set_arg_namelist[ i ] = tmp
                _need_set_arg = true
                continue                # Already check
            }

            arg_val = option_arr[ option_id KSEP 1 KSEP OPTARG_DEFAULT ]
            if (arg_val == OPTARG_DEFAULT_REQUIRED_VALUE) {
                # Don't define a default value
                # TODO: Why can't exit here???
                if (false == IS_INTERACTIVE)   return panic_required_value_error( option_id )

                append_query_code( "_X_CMD_PARAM_ARG_" i,
                    option_arr[ option_id KSEP OPTION_DESC ],
                    oparr_join( optarg_id KSEP OPTARG_OPARR )   )
                set_arg_namelist[ i ] = "_X_CMD_PARAM_ARG_" i
                _need_set_arg = true
                continue
            } else {
                # Already defined a default value
                # TODO: Tell the user, it is wrong because of default definition in DSL, not the input.
                handle_arguments_restargv_typecheck( false, i, arg_val, true )
                tmp = option_arr[ option_id KSEP OPTION_NAME ]
                gsub(/^--?/, "", tmp)
                if( tmp != "" ) {
                    append_code_assignment( tmp, arg_val )
                    set_arg_namelist[ i ] = tmp
                    _need_set_arg = true
                } else {
                    append_code_assignment( "_X_CMD_PARAM_ARG_" i , arg_val )
                    set_arg_namelist[ i ] = "_X_CMD_PARAM_ARG_" i
                    _need_set_arg = true
                }
            }
        }
    }

    #TODO: You should set the default value, if you have no .

    if (_need_set_arg == true) {
        tmp = "set -- "
        for ( _index=1; _index<=final_rest_argv_len; ++_index ) {
            tmp = tmp " " "\"$" set_arg_namelist[ _index ] "\""
        }
        append_code( tmp )
    }

}

function handle_arguments(          i, j, arg_name, arg_name_short, arg_val, option_id, option_argc, count, sw, tmp, arg_arr_len ) {

    # append_code( "local PARAM_SUBCMD" )     # Avoid the external environment influence.

    arg_arr_len = arg_arr[ LEN ]
    i = 1
    while (i <= arg_arr_len) {

        arg_name = arg_arr[ i ]
        # ? Notice: EXIT: Consider unhandled arguments are rest_argv
        if ( arg_name == "--" )  break

        if ( ( arg_name == "--help") && ( arg_name == "-h") ) {
            print_helpdoc()
        }

        option_id     = option_alias_2_option_id[arg_name]
        if ( option_id == ""  ) {
            if (arg_name ~ /^-[^-]/) {
                arg_name = substr(arg_name, 2)
                arg_len = split(arg_name, arg_arr, //)
                for (j=1; j<=arg_len; ++j) {
                    arg_name_short  = "-" arg_arr[ j ]
                    option_id       = option_alias_2_option_id[ arg_name_short ]
                    option_name     = option_arr[ option_id KSEP OPTION_NAME ]

                    if (option_name == "") {
                        panic_invalid_argument_error(arg_name_short)
                    }
                    append_code_assignment( option_name, "true" )
                }
                continue
            } else if( arg_name ~ /^--?/ ) {
                panic_invalid_argument_error(arg_name)
            }
        }

        option_arr_assigned[ option_id ] = true

        option_argc     = option_arr[ option_id KSEP LEN ]
        option_m        = option_arr[ option_id KSEP OPTION_M ]
        option_name     = option_arr[ option_id KSEP OPTION_NAME ]
        gsub(/^--?/, "", option_name)

        # If option_argc == 0, op
        if (option_m == true) {
            if (option_assignment_count[ option_id ] != "") {
                counter = option_assignment_count[ option_id ] + 1
            } else {
                counter = 1
            }
            option_assignment_count[ option_id ] = counter
            option_name = option_name "_" counter
        }
        # EXIT: Consider unhandled arguments are rest_argv
        if ( !( arg_name ~ /^--?/ ) ) break

        if (option_argc == 0) {
            # print code XXX=true
            append_code_assignment( option_name, "true" )
        } else if (option_argc == 1) {
            i = i + 1
            arg_val = arg_arr[ i ]

            if ( option_id ~ /^#/ )
            {
                # NAMED REST_ARGUMENT
                rest_arg_named_value[ option_id ] = arg_val
            }

            if (i > arg_arr_len) {
                panic_required_value_error(option_id)
            }

            arg_typecheck_then_generate_code( option_id, option_id KSEP 1,
                option_name,
                arg_val)
        } else {
            for ( j=1; j<=option_argc; ++j ) {
                i += 1
                arg_val = arg_arr[i]
                if (i > arg_arr_len) {
                    panic_required_value_error(option_id)
                }

                arg_typecheck_then_generate_code( option_id, option_id KSEP j,
                    option_name "_" j,
                    arg_val)
            }
        }
        i += 1
    }

    check_required_option_ready()

    # if subcommand declaration exists
    if ( HAS_SUBCMD == true ) {
        if (subcmd_map[ subcmd_id_lookup[ arg_arr[i] ] ] == "") {
            HAS_SUBCMD = false  # No subcommand found
        } else {
            split(subcmd_id_lookup[ arg_arr[i] ], _tmp, "|")
            append_code_assignment( "PARAM_SUBCMD", _tmp[1] )
            append_code( "shift " i )
            return
            # i += 1
        }
    }

    append_code( "shift " (i-1) )

    if (final_rest_argv[ LEN ] < arg_arr_len - i + 1) {
        final_rest_argv[ LEN ] = arg_arr_len - i + 1
    }

    #Remove the processed arg_arr and move the arg_arr back forward
    for ( j=i; j<=arg_arr_len; ++j ) {
        arg_arr[ j-i+1 ] = arg_arr[j]
    }
    arg_arr[ LEN ]=arg_arr[ LEN ]-i+1

    handle_arguments_restargv()
}

END{
    if (EXIT_CODE == "000") {
        print_code()
    }

    # print "--------------------------"
    if (EXIT_CODE == 0) {
        handle_arguments()
        print_code()
        # debug(CODE)
    }
}
# EndSection
