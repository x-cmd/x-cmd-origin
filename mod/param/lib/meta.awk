# Section: 4-Arguments and intercept for help and advise            5-DefaultValues
function print_optarg( option_id, optarg_idx,            _option_default, _oparr_keyprefix, _op, k ){
    _option_default = option_arr[ option_id S optarg_idx S OPTARG_DEFAULT ]
    # Notice: Adding "\006" to distinguish whether _option_default is "" or null
    if (_option_default != "" && _option_default != OPTARG_DEFAULT_REQUIRED_VALUE)  printf("%s", "\006" _option_default)
    printf("\n")

    _oparr_keyprefix = option_id S optarg_idx S OPTARG_OPARR
    _op = option_arr[ _oparr_keyprefix S 1 ]
    if ( _op == "=~" || _op == "=" ) {
        printf( "%s", _op )
        for ( k=2; k<=option_arr[ _oparr_keyprefix L ]; ++k ) {
            printf("%s", "\006" option_arr[ _oparr_keyprefix S k ] )
        }
    }
    printf("\n")
}

function ls_option(         i, j, _tmp_len, _option_id, _tmp, _option_argc){
    for (i=1; i<=advise_arr[ L ]; ++i) {
        # TODO: Can be optimalize.
        _tmp_len=split(advise_arr[ i ], _tmp)
        _option_id = _tmp[1]
        advise_map[ _option_id ] = str_trim( advise_map[ _option_id ] " " str_join( " ", _tmp, "", 2, _tmp_len ) )
    }

    for (i=1; i<=option_id_list[ L ]; ++i) {
        _option_id = option_id_list[i]
        printf("%s\n%s\n", _option_id, option_arr[ _option_id S OPTION_DESC ])

        _option_argc = option_arr[ _option_id L ]
        if( _option_argc == 0 )  printf("\n\n")
        for(j=1; j<=_option_argc; ++j)   print_optarg( _option_id, j )

        printf("%s\n", (advise_map[ _option_id ] != "") ? advise_map[_option_id] : "")
    }

    for (i=1; i <= rest_option_id_list[ L ]; ++i) {
        _option_id = rest_option_id_list[ i ]
        printf("%s\n", _option_id)
        printf("%s\n", option_arr[ _option_id S OPTION_DESC ])

        print_optarg( _option_id, 1 )

        printf("%s\n", (advise_map[ _option_id ] != "") ? advise_map[_option_id] : "")
    }
}

function ls_option_name(         i, j, _option_id, _option_name, _option_argc){
    for (i=1; i<=option_id_list[ L ]; ++i) {
        _option_id = option_id_list[i]
        _option_argc = option_arr[ _option_id L ]
        for(j=1; j<=_option_argc; ++j){
            _option_name = option_arr[ _option_id S OPTION_NAME ]
            gsub("-","",_option_name)
            printf("%s\n", _option_name)
        }
    }
}

function ls_subcmd(         i,_cmd_name){
    for (i=1; i <= subcmd_arr[ L ]; ++i) {
        _cmd_name = subcmd_arr[ i ]
        printf("%s\n%s\n", _cmd_name, str_unquote( subcmd_map[ _cmd_name ] ))
    }
}

function _param_list_subcmd(         i){
    for (i=1; i <= subcmd_arr[ L ]; ++i) {
        gsub(/\|/, "\n", subcmd_arr[ i ])
        printf("%s\n", subcmd_arr[ i ] )
    }
}

NR==4{
    if( arg_arr[1] == "_param_has_subcmd" ){
        for(i=1; i<=subcmd_arr[ L ]; ++i) if( subcmd_arr[i] == arg_arr[2] ) exit 0
        exit 1
    }
    else if( arg_arr[1] == "_param_list_subcmd" )                                         _param_list_subcmd()
    else if( arg_arr[1] == "_ls_subcmd" )                                                 ls_subcmd()
    else if( arg_arr[1] == "_ls_option" )                                                 ls_option()
    else if( arg_arr[1] == "_ls_option_name" )                                            ls_option_name()
    else if( arg_arr[1] == "_ls_option_subcmd" ){
        ls_option()
        printf("---------------------\n")
        ls_subcmd()
        printf("---------------------\n")
        for(i=1; i <= arg_arr[ L ]; ++i)      printf("%s\n", arg_arr[i])
    }
    else exit 1

    exit 0
}
