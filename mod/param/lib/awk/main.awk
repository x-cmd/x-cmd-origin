
function exec_help(){
    print "___x_cmd_param_int _x_cmd_help ;"
    if (exit_code == "")    exit_code = 0
    print "return " exit_code
    exit_now(1) # TODO: should I return 0?
}

BEGIN{
    HAS_SPE_ARG = false
}

NR==4 {
    if( arg_arr[1] == "_dryrun" ){
        DRYRUN_FLAG = true
        IS_INTERACTIVE = false
        for(i=1; i < arg_arr[ L ]; ++i){
            arg_arr[i]=arg_arr[i+1]
        }
        handle_arguments()
        print "return 0"
        exit_now(0)
    }

    if ( "help" == arg_arr[1] ) {
        has_help_subcmd = false
        for (i=1; i <= subcmd_len(); ++i) {
            if ( "help" == subcmd_id( i ) )  has_help_subcmd = true
        }
        if (has_help_subcmd == false)                                   exec_help()
    }
    if ( ( "--help" == arg_arr[1] ) || ( "-h" == arg_arr[ 1 ] ) ) {
        if ("" == option_alias_2_option_id[ arg_arr[ 1 ] ])             exec_help()
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
        code_append_assignment( arg_var_name, arg_val )
    } else if ( false == IS_INTERACTIVE ) {
        panic_error( _ret )
    } else {
        code_query_append(   arg_var_name,
            option_desc_get( option_id ),
            oparr_join_quoted( optarg_id )       )
    }
}

function handle_arguments_restargv_typecheck(is_interative, i, argval, is_dsl_default,
    tmp, _option_id, _optarg_id){
    _option_id = option_alias_2_option_id[ "#" i ]
    _optarg_id = _option_id S 1

    if (argval != "") {
        _ret = assert(_optarg_id, "$" i, argval)
        if (_ret == true)                       return true
        else if (false == is_interative) {
            if (is_dsl_default == true)         panic_param_define_error(_ret)
            else                                panic_error( _ret )
        } else {
            # TODO: XXX
            code_query_append(  "_X_CMD_PARAM_ARG_" i,
                option_desc_get( _option_id ),
                oparr_join_quoted( _optarg_id )      )
            return false
        }
    }

    if (option_arr[ "#n" ] == "")     return true               # nth_rule

    _ret = assert(_optarg_id, "$" i, argval)
    if (_ret == true)                           return true
    else if (false == is_interative) {
        if (is_dsl_default == true)             panic_param_define_error(_ret)
        else                                    panic_error( _ret )
    } else {
        # TODO: XXX
        code_query_append(  "_X_CMD_PARAM_ARG_" i,
            option_desc_get( _option_id ),
            oparr_join_quoted( _optarg_id )          )
        return false
    }
}

function handle_arguments_restargv(         final_rest_argv_len, i, arg_val, option_id,
    named_value, _need_set_arg, set_arg_namelist, tmp, _index ){

    final_rest_argv_len = final_rest_argv[ L ]
    for ( i=1; i<=final_rest_argv_len; ++i) {
        set_arg_namelist[ i ] = i
    }

    _need_set_arg = false
    for ( i=1; i<=final_rest_argv_len; ++i) {
        if ( i <= arg_arr[ L ]) {
            arg_val = arg_arr[ i ]
            # To set the input value and continue
            if ( true != handle_arguments_restargv_typecheck( IS_INTERACTIVE, i, arg_val, false ) ) {
                set_arg_namelist[ i ] = "_X_CMD_PARAM_ARG_" i
                _need_set_arg = true
            }

            option_id = option_alias_2_option_id[ "#" i ]
            tmp = option_name_get_without_hyphen( option_id )
            if( tmp != "" ) {
                code_append_assignment( tmp, arg_val )
                set_arg_namelist[ i ] = tmp
                _need_set_arg = true
            } else {
                code_append_assignment( "_X_CMD_PARAM_ARG_" i , arg_val )
                set_arg_namelist[ i ] = "_X_CMD_PARAM_ARG_" i
                _need_set_arg = true
            }

            continue
        } else {
            option_id = option_alias_2_option_id[ "#" i ]
            named_value = rest_arg_named_value[ option_id ]

            # TODO: Using something better, like OPTARG_DEFAULT_REQUIRED_VALUE
            if (named_value != "") {
                tmp = option_name_get_without_hyphen( option_id )
                set_arg_namelist[ i ] = tmp
                _need_set_arg = true
                continue                # Already check
            }

            arg_val = optarg_default_get( option_id SUBSEP 1 )
            if ( optarg_default_value_eq_require(arg_val) ) {
                # Don't define a default value
                # TODO: Why can't exit here???
                if (false == IS_INTERACTIVE)   return panic_required_value_error( option_id )

                tmp = option_name_get_without_hyphen( option_id )
                if( tmp != "" ) {
                    code_query_append( tmp,
                        option_desc_get( option_id ),
                        oparr_join_quoted( optarg_id ) )
                    set_arg_namelist[ i ] = tmp
                } else {
                    code_query_append( "_X_CMD_PARAM_ARG_" i,
                        option_desc_get( option_id ),
                        oparr_join_quoted( optarg_id ) )
                    set_arg_namelist[ i ] = "_X_CMD_PARAM_ARG_" i
                }
                _need_set_arg = true
                continue
            } else {
                # Already defined a default value
                # TODO: Tell the user, it is wrong because of default definition in DSL, not the input.
                handle_arguments_restargv_typecheck( false, i, arg_val, true )
                tmp = option_name_get_without_hyphen( option_id )
                if( tmp != "" ) {
                    code_append_assignment( tmp, arg_val )
                    set_arg_namelist[ i ] = tmp
                    _need_set_arg = true
                } else {
                    code_append_assignment( "_X_CMD_PARAM_ARG_" i , arg_val )
                    set_arg_namelist[ i ] = "_X_CMD_PARAM_ARG_" i
                    _need_set_arg = true
                }
            }
        }
    }

    #TODO: You should set the default value, if you have no .

    if (QUERY_CODE != ""){
        QUERY_CODE = "local ___X_CMD_UI_FORM_EXIT_STRATEGY=\"execute|exit\"; x ui form " substr(QUERY_CODE, 9)
        QUERY_CODE = QUERY_CODE ";\nif [ \"$___X_CMD_UI_FORM_EXIT\" = \"exit\" ]; then return 1; fi;"
        code_append(QUERY_CODE)
        if( HAS_PATH == true){
            code_append( "local path >/dev/null 2>&1" )
            code_append( "path=$___x_cmd_param_path" )
        }
    }

    if (_need_set_arg == true) {
        tmp = "set -- "
        for ( _index=1; _index<=final_rest_argv_len; ++_index ) {
            tmp = tmp " " "\"$" set_arg_namelist[ _index ] "\""
        }
        code_append( tmp )
    }

}

function handle_arguments(          i, j, arg_name, arg_name_short, arg_val, option_id, option_argc, count, sw, arg_arr_len, _tmp, _subcmd_id ) {

    # code_append( "local PARAM_SUBCMD" )     # Avoid the external environment influence.

    arg_arr_len = arg_arr[ L ]
    i = 1
    arr_clone(arg_arr, tmp_arr)
    while (i <= arg_arr_len) {

        arg_name = arg_arr[ i ]
        # ? Notice: EXIT: Consider unhandled arguments are rest_argv
        if ( arg_name == "--" )  break

        if ( ( arg_name == "--help") && ( arg_name == "-h") ) {
            exec_help()
        }

        option_id     = option_alias_2_option_id[arg_name]
        if ( option_id == ""  ) {
            if (arg_name ~ /^-[^-]/) {
                arg_name = substr(arg_name, 2)
                arg_len = split(arg_name, arg_arr, //)
                for (j=1; j<=arg_len; ++j) {
                    arg_name_short  = "-" arg_arr[ j ]
                    option_id       = option_alias_2_option_id[ arg_name_short ]
                    option_name     = option_name_get_without_hyphen( option_id )

                    if (option_name == "") {
                        HAS_SPE_ARG = true
                        break
                    }
                    code_append_assignment( option_name, "true" )
                }
                continue
            } else if( arg_name ~ /^--?/ ) {
                break
            }
        }
        if( HAS_SPE_ARG == true )        arr_clone(tmp_arr, arg_arr)

        option_arr_assigned[ option_id ] = true

        option_argc     = option_argc_get( option_id )
        option_m        = option_multarg_get( option_id )
        option_name     = option_name_get_without_hyphen( option_id )

        # If option_argc == 0, op
        if ( option_multarg_is_enable( option_id ) ) {
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
            code_append_assignment( option_name, "true" )
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

            arg_typecheck_then_generate_code( option_id, option_id S 1,
                option_name,
                arg_val)
        } else {
            for ( j=1; j<=option_argc; ++j ) {
                i += 1
                arg_val = arg_arr[i]
                if (i > arg_arr_len) {
                    panic_required_value_error(option_id)
                }

                arg_typecheck_then_generate_code( option_id, option_id S j,
                    option_name "_" j,
                    arg_val)
            }
        }
        i += 1
    }

    check_required_option_ready()

    # if subcommand declaration exists
    if ( HAS_SUBCMD == true ) {
        _subcmd_id = subcmd_id_by_name( arg_arr[i] )
        if (! subcmd_exist_by_id( _subcmd_id ) ) {
            HAS_SUBCMD = false  # No subcommand found
        } else {
            split( _subcmd_id , _tmp, "|" )
            code_append_assignment( "PARAM_SUBCMD", _tmp[1] )
            code_append( "shift " i )
            return
            # i += 1
        }
    }

    code_append( "shift " (i-1) )

    if (final_rest_argv[ L ] < arg_arr_len - i + 1) {
        final_rest_argv[ L ] = arg_arr_len - i + 1
    }

    #Remove the processed arg_arr and move the arg_arr back forward
    for ( j=i; j<=arg_arr_len; ++j ) {
        arg_arr[ j-i+1 ] = arg_arr[j]
    }
    arg_arr[ L ]=arg_arr[ L ]-i+1

    handle_arguments_restargv()
    if( HAS_PATH == true ){
        code_append( "local path >/dev/null 2>&1" )
        code_append( "path=$___x_cmd_param_path" )
    }
}

END{

    if (EXIT_CODE == "000") {
        code_print()
    }
    if (EXIT_CODE == 0) {
        handle_arguments()
        # debug( CODE )
        code_print()
    }
}
# EndSection
