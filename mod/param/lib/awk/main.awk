
function exec_help(){
    print "___x_cmd_param_int _x_cmd_help ;"
    if (exit_code == "")    exit_code = 0
    print "return " exit_code
    exit_now(1) # TODO: should I return 0?
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
        for (i=1; i <= subcmd_arr[ L ]; ++i) {
            if ( "help" == subcmd_arr[i] )  has_help_subcmd = true
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
        append_code_assignment( arg_var_name, arg_val )
    } else if ( false == IS_INTERACTIVE ) {
        panic_error( _ret )
    } else {
        append_query_code(   arg_var_name,
            option_arr[ option_id S OPTION_DESC ],
            oparr_join( optarg_id S OPTARG_OPARR )       )
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
            append_query_code(  "_X_CMD_PARAM_ARG_" i,
                option_arr[ _option_id S OPTION_DESC ],
                oparr_join( _optarg_id S OPTARG_OPARR )      )
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
        append_query_code(  "_X_CMD_PARAM_ARG_" i,
            option_arr[ _option_id S OPTION_DESC ],
            oparr_join( _optarg_id S OPTARG_OPARR )          )
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
            tmp = option_arr[ option_id S OPTION_NAME ]
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
                tmp = option_arr[ option_id S OPTION_NAME ]
                gsub(/^--?/, "", tmp)
                set_arg_namelist[ i ] = tmp
                _need_set_arg = true
                continue                # Already check
            }

            arg_val = option_arr[ option_id S 1 S OPTARG_DEFAULT ]
            if (arg_val == OPTARG_DEFAULT_REQUIRED_VALUE) {
                # Don't define a default value
                # TODO: Why can't exit here???
                if (false == IS_INTERACTIVE)   return panic_required_value_error( option_id )

                tmp = option_arr[ option_id S OPTION_NAME ]
                gsub(/^--?/, "", tmp)
                if( tmp != "" ) {
                    append_query_code( tmp,
                        option_arr[ option_id S OPTION_DESC ],
                        oparr_join( optarg_id S OPTARG_OPARR ) )
                    set_arg_namelist[ i ] = tmp
                } else {
                    append_query_code( "_X_CMD_PARAM_ARG_" i,
                        option_arr[ option_id S OPTION_DESC ],
                        oparr_join( optarg_id S OPTARG_OPARR ) )
                    set_arg_namelist[ i ] = "_X_CMD_PARAM_ARG_" i
                }
                _need_set_arg = true
                continue
            } else {
                # Already defined a default value
                # TODO: Tell the user, it is wrong because of default definition in DSL, not the input.
                handle_arguments_restargv_typecheck( false, i, arg_val, true )
                tmp = option_arr[ option_id S OPTION_NAME ]
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

    if (QUERY_CODE != ""){
        QUERY_CODE="___x_cmd_ui form " substr(QUERY_CODE, 9)
        append_code(QUERY_CODE)
        if( HAS_PATH == true){
            append_code( "local path >/dev/null 2>&1" )
            append_code( "path=$___x_cmd_param_path" )
        }
    }

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

    arg_arr_len = arg_arr[ L ]
    i = 1
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
                    option_name     = option_arr[ option_id S OPTION_NAME ]

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

        option_argc     = option_arr[ option_id L ]
        option_m        = option_arr[ option_id S OPTION_M ]
        option_name     = option_arr[ option_id S OPTION_NAME ]
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

    if (final_rest_argv[ L ] < arg_arr_len - i + 1) {
        final_rest_argv[ L ] = arg_arr_len - i + 1
    }

    #Remove the processed arg_arr and move the arg_arr back forward
    for ( j=i; j<=arg_arr_len; ++j ) {
        arg_arr[ j-i+1 ] = arg_arr[j]
    }
    arg_arr[ L ]=arg_arr[ L ]-i+1

    handle_arguments_restargv()
}

END{

    if (EXIT_CODE == "000") {
        print_code()
    }
    if (EXIT_CODE == 0) {
        handle_arguments()
        # debug( CODE )
        print_code()
    }
}
# EndSection
