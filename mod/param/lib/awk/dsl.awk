
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

function tokenize_argument( astr, array,  l ) {
    l = param_tokenized( astr, array )
    array[ L ] = l
    return l
}

function param_print_tokenized(s, arr){
    print "---------"
    l = param_tokenized(s, arr)
    for (i=1; i<=l; ++i) {
        print arr[ i ]
    }
    print "---------"
}

# EndSection

BEGIN {
    arg_arr[ L ]=0
}

# Section: Step 2 Utils: Parse param DSL
BEGIN {
    final_rest_argv[ L ] = 0
    HAS_PATH   = false
}

function handle_option_id(option_id,            _arr, _arr_len, _arg_name, _index){

    # Add option_id to option_id_list

    option_multarg_disable( option_id )

    _arr_len = split( option_id, _arr, /\|/ )

    # debug("handle_option_id \t" _arr_len)
    for ( _index=1; _index<=_arr_len; ++_index ) {
        _arg_name = _arr[ _index ]

        if (option_alias_2_option_id[ _arg_name ] != "")    panic_param_define_error("Already exsits: " _arg_name)       # Prevent name conflicts

        if (_arg_name == "m") {
            option_multarg_enable( option_id )
            continue
        }

        if (_arg_name !~ /^-/) {
            panic_param_define_error("Unexpected option name: \n" option_id)
        }

        if ( _index == 1 )  option_name_set( option_id, _arg_name )
        option_alias_2_option_id[ _arg_name ] = option_id
        # debug( "option_alias_2_option_id\t" _arg_name "!\t!" option_id "|" )
    }
}

BEGIN {
    EXISTS_REQUIRED_OPTION = false
}

function handle_optarg_declaration(_arg_tokenarr, optarg_id,
    optarg_definition_token1, optarg_type,
    tmp, type_rule, i){

    # debug( "handle_optarg_definition:\t" optarg_definition )
    # debug( "optarg_id:\t" optarg_id )
    # tokenize_argument( optarg_definition, _arg_tokenarr )

    optarg_definition_token1 = _arg_tokenarr[ 1 ]

    if (! match( optarg_definition_token1, /^<[-_A-Za-z0-9]*>/) ) {
        panic_param_define_error("Unexpected optarg declaration: \n" optarg_definition)
    }

    optarg_name_set( optarg_id, substr( optarg_definition_token1, 2, RLENGTH-2 )  )

    optarg_definition_token1 = substr( optarg_definition_token1, RLENGTH+1 )

    if (match( optarg_definition_token1, /^:[-_A-Za-z0-9]+/) ) {
        optarg_type = substr( optarg_definition_token1, 2, RLENGTH-1 )
        optarg_definition_token1 = substr( optarg_definition_token1, RLENGTH+1 )
    }

    if (match( optarg_definition_token1 , /^=/) ) {
        optarg_default_set( optarg_id,  str_unquote_if_quoted( substr( optarg_definition_token1, 2 ) )  )
    } else {
        optarg_default_set_required( optarg_id )
        EXISTS_REQUIRED_OPTION = true
    }

    if (_arg_tokenarr[ L ] < 2) {
        type_rule = type_rule_by_name( optarg_type )
        if (type_rule == "")  return
        tokenize_argument( type_rule, _arg_tokenarr )
    }

    for ( i=2; i<=_arg_tokenarr[ L ]; ++i ) oparr_add( optarg_id, _arg_tokenarr[i] )  # quote
}

# options like #1, #2, #3 ...
function parse_param_dsl_for_positional_argument(line,
    option_id, tmp, _arr_len, _arr, _index, _arg_name, _arg_no, _optarg_id, _arg_tokenarr){

    tokenize_argument( line, _arg_tokenarr )

    option_id = _arg_tokenarr[1]

    restopt_add_id( option_id )

    option_argc_set( option_id, 1 )
    option_multarg_disable( option_id )

    _arr_len = split( option_id, _arr, /\|/ )
    for ( _index=1; _index <= _arr_len; ++_index ) {
        _arg_name = _arr[ _index ]
        # Prevent name conflicts
        if (option_alias_2_option_id[ _arg_name ] != "") {
            panic_param_define_error("Already exsits: " _arg_name)
        }

        if ( _index == 1 )              _arg_no = substr( _arg_name, 2)
        else if ( _index == 2 )         option_name_set( option_id, _arg_name )
        option_alias_2_option_id[ _arg_name ] = option_id
    }

    option_desc_set( option_id, _arg_tokenarr[2] )

    if ( _arg_tokenarr[ L ] >= 3 ) {
        _optarg_id = option_id SUBSEP 1

        arr_shift( _arg_tokenarr, 2 )
        handle_optarg_declaration( _arg_tokenarr, _optarg_id )

        # NOTICE: this is correct. Only if has default value, or it is required !
        if (final_rest_argv[ L ] < _arg_no)   final_rest_argv[ L ] = _arg_no
        final_rest_argv[ _arg_no ] = optarg_default_get( _optarg_id )
        # TODO: validate this argument
        # debug( "final_rest_argv[ " _arg_no " ] = " final_rest_argv[ _arg_no ] )
    }

}

# options #n
function parse_param_dsl_for_all_positional_argument(line,
    option_id, tmp, _arg_tokenarr ){

    tokenize_argument( line, _arg_tokenarr )

    option_id = _arg_tokenarr[1]  # Should be #n

    restopt_add_id( option_id )
    option_desc_set( option_id, _arg_tokenarr[2] )

    if ( _arg_tokenarr[ L ] >= 3) {
        arr_shift( _arg_tokenarr, 2 )
        handle_optarg_declaration( _arg_tokenarr, option_id )
    }
}

function parse_param_dsl_for_named_options( line_arr, line, i,            len, nextline, option_id, _arg_tokenarr, j ){
    # HANDLE:   option like --user|-u, or --verbose
    if (line !~ /^-/)   panic_param_define_error( "Expect option starting with - or -- :\n" line )

    len = option_arr[ L ] + 1
    option_arr[ L ] = len
    option_arr[ len ] = line

    tokenize_argument( line, _arg_tokenarr )
    option_id = _arg_tokenarr[1]
    handle_option_id( option_id )
    option_desc_set( option_id, _arg_tokenarr[2] )

    j = 0
    if ( _arg_tokenarr[ L ] >= 3) {
        j = j + 1
        arr_shift( _arg_tokenarr, 2 )
        handle_optarg_declaration( _arg_tokenarr, option_id SUBSEP j )
    }

    while (true) {
        i += 1
        # debug("line_arr[ " i " ]" line_arr[ i ])
        nextline = str_trim( line_arr[ i ] )
        if ( nextline !~ /^</ ) {
            i--
            break
        }

        j = j + 1
        tokenize_argument( nextline, _arg_tokenarr )
        handle_optarg_declaration( _arg_tokenarr, option_id SUBSEP j )
    }

    option_argc_set( option_id, j )
    if (j==0)       flag_add_id( option_id )
    else            namedopt_add_id( option_id )
    return i
}

function parse_param_dsl(line,
    line_arr, i, state, tmp, line_arr_len) {

    state = 0
    STATE_ADVISE        = 1
    STATE_TYPE          = 2
    STATE_OPTION        = 3
    STATE_SUBCOMMAND    = 4
    STATE_ARGUMENT      = 5

    line_arr_len = split(line, line_arr, "\n")

    for (i=1; i<=line_arr_len; ++i) {
        line = line_arr[i]
        line = str_trim( line )         # TODO: line should be line_trimed

        if (line == "") continue

        if (line ~ /^advise:/)                                  state = STATE_ADVISE
        else if (line ~ /^type:/)                               state = STATE_TYPE
        else if (line ~ /^options?:/)                           state = STATE_OPTION
        else if (line ~ /^((subcommand)|(subcmd))s?:/)          state = STATE_SUBCOMMAND
        else if (line ~ /^arguments?:/)                         state = STATE_ARGUMENT
        else {
            if (state == STATE_ADVISE)                          advise_add( line )
            else if ( state == STATE_TYPE )                     type_add_line( line )
            else if ( state == STATE_SUBCOMMAND )               subcmd_add_line( line )
            else if (state == STATE_OPTION) {
                if ( match(line, /^#n[\s]*/ ) )                     parse_param_dsl_for_all_positional_argument( line )         # HANDLE:   option like #n
                else if ( match( line, /^#[0-9]+[\s]*/ ) )          parse_param_dsl_for_positional_argument( line )             # HANDLE:   option like #1 #2 #3 ...
                else                                            i = parse_param_dsl_for_named_options( line_arr, line, i )                # HANDLE:   option like --token|-t
            }
        }
    }
}

# EndSection

# Section: Step 3 Utils: Handle code

function check_required_option_ready(       i, j, option, option_argc, option_id, option_m, option_name, _ret, _varname ) {

    for ( i=1; i<=namedopt_len(); ++i ) {
        option_id       = namedopt_get( i )
        option_m        = option_multarg_get( option_id )
        option_name     = option_name_get_without_hyphen( option_id )

        # if assign, continue
        if ( option_arr_assigned[ option_id ] == true ) {
            if (option_m == true) {
                # count the number of arguments
                code_append_assignment( option_name "_n",    option_assignment_count[ option_id ] )
            }
            continue
        }

        option_argc      = option_argc_get( option_id )
        if ( 0 == option_argc ) continue            # This is a flag

        if ( true == option_m )     option_name = option_name "_" 1

        for ( j=1; j<=option_argc; ++j ) {
            if ( (j==1) && (option_argc == 1) ) {           # if argc == 1
                _varname = option_name
                if (option_name in option_default_map) {
                    val = option_default_map[ option_name ]
                } else {
                    val = optarg_default_get( option_id SUBSEP 1 )
                }
            } else {                                        # if argc >= 2
                _varname = option_name "_" j
                val = optarg_default_get( option_id SUBSEP j )
            }

            if ( optarg_default_value_eq_require( val ) ) {
                if ( false == IS_INTERACTIVE )      panic_required_value_error( option_id )
                code_query_append(      _varname,       option_desc_get( option_id ),  oparr_join_quoted( option_id SUBSEP j ) )
            } else {
                _ret = assert(option_id SUBSEP j, _varname, val)
                if ( _ret == true ) {
                    if ( true != option_m ) {
                        code_append_assignment( _varname, val )
                    } else{
                        if ( val == "" ) {
                            code_append_assignment( option_name "_n", 0 )   # TODO: should be 0. Handle later.
                        } else{
                            code_append_assignment( option_name "_n", 1 )   # TODO: should be 0. Handle later.
                            code_append_assignment( _varname, val )
                        }
                    }
                }
                else {
                    if ( false == IS_INTERACTIVE )     panic_error( _ret )
                    else    code_query_append(  _varname,       option_desc_get( option_id ),  oparr_join_quoted( option_id SUBSEP j ) )
                }
            }
        }
    }

}

# EndSection

# Section: 1-GetTypes   2-GetSubcmd     3-DSL

function parse_type( code,     i, l, _arr, e ){
    l = split(str_trim(code), _arr, ARG_SEP)
    for (i=1; i<=l; ++i) {
        e = str_trim( _arr[i] )
        if ( 0 != length( e ) )     type_add_line(e)
    }
}

function parse_plugin_subcmd( code,     i, l, _arr, e ){
    code = substr( str_trim( code ), 2 )
    l = split(code, _arr, ARG_SEP)
    for (i=1; i<=l; ++i) {
        e = str_trim( _arr[i] )
        if (0 != length( e ))  subcmd_add_line( e )
    }
}

NR==1 {     parse_type( $0 )  }
NR==2 {     parse_plugin_subcmd( $0 )  }
NR==3 {     parse_param_dsl($0)         }

# EndSection

NR==4 {
    # handle arguments
    gsub("\n", "\004", $0)
    arg_arr_len = split($0, arg_arr, ARG_SEP)
    arg_arr[ L ] = arg_arr_len
    for (i=1; i<=arg_arr[ L ]; ++i) {
        gsub("\004", "\n", arg_arr[ i ])
    }

    # Optimization
    code_append_assignment( "PARAM_SUBCMD", "" )
}
