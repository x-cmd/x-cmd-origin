
{
    if (NR>1) {
        # if ($0 != "") jiparse(obj, $0)
        if ($0 != "") jiparse_after_tokenize(obj, $0)
    } else {
        prepare_argarr( $0 )
    }
}

END{
    if (EXIT_CODE == 0) {
        # enhance_argument_parser( obj )
        parse_args_to_env( parsed_argarr, parsed_arglen, obj, "", genv_table, lenv_table )
        # showing candidate code
    }
    printf( "offset=%s\n%s", OFFSET, CODE)
}

# Section: prepare argument
function prepare_argarr( argstr,        i, _arg ){
    if ( argstr == "" ) argstr = "" # "." "\002"

    gsub("\n", "\001", argstr)
    parsed_arglen = split(argstr, parsed_argarr, "\002")

    for (i=1; i<=parsed_arglen; ++i) {
        _arg = parsed_argarr[i]
        gsub("\001", "\n", _arg)
        parsed_argarr[i] = _arg
    }
}

# EndSection

# Section: parse argument into env table

# Complete Rest Argument
# Complete Option Name Or RestArgument
# Complete Option Argument

function env_table_set_true( key, keypath ){
    env_table_set( key, keypath, 1 )
}

function env_table_set( key, keypath, value ){
    genv_table[ keypath ] = value
    lenv_table[ key ] = value
}

function parse_args_to_env___option( obj, obj_prefix, args, argl, arg, arg_idx, genv_table, lenv_table,
    _optarg_id, _optargc, k ){

    _optarg_id = aobj_get_id_by_name( obj, obj_prefix, arg )
    if (_optarg_id == "") return false

    _optargc = aobj_get_optargc( obj, obj_prefix, _optarg_id )
    if (_optargc == 0) {    # This is a flag
        env_table_set_true( _optarg_id, obj_prefix SUBSEP _optarg_id )
        return arg_idx
    }
    for (k=1; k<=_optargc; ++k)  {
        if ( arg_idx >= argl ) {
            advise_complete_option_value( args[ arg_idx ], genv_table, lenv_table, obj, obj_prefix, _optarg_id, k )
            return ++arg_idx # Not Running at all .. # TODO
        }
        env_table_set( _optarg_id, obj_prefix SUBSEP _optarg_id SUBSEP k, args[ arg_idx++ ] )
    }
    return arg_idx
}

function parse_args_to_env( args, argl, obj, obj_prefix, genv_table, lenv_table,    i, j, _subcmdid, _optarg_id, _arg_arrl, _optargc, _rest_argc, rest_argc_max, rest_argc_min ){

    obj_prefix = SUBSEP "\"1\""   # Json Parser

    i = 1;
    while ( i<argl ) {
        arg = args[ i ];    i++

        _subcmdid = aobj_get_subcmdid_by_name( obj, obj_prefix, arg )
        if (_subcmdid != "") {
            if ( ! aobj_option_all_set( lenv_table, obj, obj_prefix ) ) {
                # TODO: show message that it is wrong ...
                panic("All required options should be set")
            }
            obj_prefix = obj_prefix SUBSEP _subcmdid
            delete lenv_table
            continue
        }

        if (arg ~ /^--/) {
            j = parse_args_to_env___option( obj, obj_prefix, args, argl, arg, i, genv_table, lenv_table )
            if (j > argl) return        # Not Running at all
            else if (j !=0) { i = j; continue }
            else break
        } else if (arg ~ /^-/) {
            j = parse_args_to_env___option( obj, obj_prefix, args, argl, arg, i, genv_table, lenv_table )
            if (j > argl) return            # Not Running at all
            else if (j != 0) { i = j; continue }

            _arg_arrl = split(arg, _arg_arr, "")
            for (j=2; j<=_arg_arrl; ++j) {
                _optarg_id = aobj_get_id_by_name( obj, obj_prefix, "-" _arg_arr[j] )
                assert( _optarg_id == "", "Fail at parsing: " arg ". Not Found: -" _arg_arr[j] )
                _optargc = aobj_get_optargc( obj, obj_prefix, _optarg_id )
                if (_optargc == 0) {
                    env_table_set_true( _optarg_id, obj_prefix SUBSEP _optarg_id )
                    continue
                }

                assert( j<_arg_arrl, "Fail at parsing: " arg ". Accept at least one argument: -" _arg_arr[j] )

                for (k=1; k<=_optargc; ++k)  {
                    if ( i>=argl ) {
                        advise_complete_option_value( args[i], genv_table, lenv_table, obj, obj_prefix, _optarg_id, k )
                        return  # Not Running at all .. # TODO
                    }
                    env_table_set( _optarg_id, obj_prefix SUBSEP _optarg_id SUBSEP k, args[ i++ ] )
                }
            }
            continue
        }
        i = i - 1 # subcmd complete
        break
    }
    # handle it into argument
    # for (j=1; i+j-1 < argl; ++j) {
    #     rest_arg[ j ] = args[ i+j-1 ]
    # }
    # _rest_argc = j - 1
    OFFSET = i

    for (j=0; i+j < argl; ++j) {
        rest_arg[ j ] = args[ i+j ]
    }
    _rest_argc = j

    if (_rest_argc == 0) {
        advise_complete_option_name_or_argument_value( args[ argl ], genv_table, lenv_table, obj, obj_prefix )
        return
    }

    rest_argc_min = aobj_get_minimum_rest_argc( obj, obj_prefix )
    rest_argc_max = aobj_get_maximum_rest_argc( obj, obj_prefix )

    if (_rest_argc == rest_argc_max) {
        # No Advise
    } else if (_rest_argc > rest_argc_max) {
        # No Advise. Show it is wrong.
    } else {
        advise_complete_argument_value( args[ argl ], genv_table, lenv_table, obj, obj_prefix, _rest_argc+1 )
    }

}
# EndSection
