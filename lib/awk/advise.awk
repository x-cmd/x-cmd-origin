BEGIN{  SSS = "\n";  }
function AJADD( s ){    ADVISE_JSON = ADVISE_JSON s SSS;    }
function CDADD( s ){    CODE = CODE s "\n"; }

function swrap( s ){  return "\"" s "\""; }

function generate_advise_json_value_candidates_by_rules( optarg_id, advise_map,        op ){
    AJADD("{");
    AJADD( swrap("#desc") ); AJADD( ":" ); AJADD( swrap(option_desc_get( optarg_id )) );

    if (advise_map[ optarg_id ] != "")  {
        AJADD(","); AJADD( swrap("#exec") ); AJADD(":");                        AJADD( swrap(advise_map[ optarg_id ]) );
    }

    op = oparr_get( optarg_id, 1 )
    if (op == "=~") {
        AJADD(","); AJADD( swrap("#regex") ); AJADD(":")                        AJADD("["); AJADD( oparr_join_wrap( optarg_id, SSS "," SSS ) ); AJADD("]")
    }

    if (op == "=") {
        AJADD(","); AJADD( swrap("#cand") ); AJADD(":");                        AJADD("["); AJADD( oparr_join_wrap( optarg_id, SSS "," SSS ) ); AJADD("]")
    }

    AJADD("}");
}

function generate_advise_json_subcmd(       i, subcmd_funcname, subcmd_invocation, _name_arr, _ret ){
    for ( i=1; i<=subcmd_len(); ++i ) {
        split(subcmd_id( i ), _name_arr, "|") # get the subcmd name list
        if( subcmd_map[ _name_arr[ 1 ], SUBCMD_FUNCNAME ] != "" )   subcmd_funcname = subcmd_map[ _name_arr[ 1 ], SUBCMD_FUNCNAME ] "_" _name_arr[ 1 ]
        else                                                        subcmd_funcname = "${X_CMD_ADVISE_FUNC_NAME}_" _name_arr[ 1 ]

        subcmd_invocation = sprintf("\\$( PARAM_SUBCMD_DEF=''; X_CMD_ADVISE_FUNC_NAME=%s %s _x_cmd_advise_json %s)", subcmd_funcname, subcmd_funcname, qu1( subcmd_desc(i) ) )

        _ret = "'," SSS swrap(subcmd_id( i )) SSS ":" SSS "'"
        ADVISE_JSON = ADVISE_JSON SSS "A=\"\\${A}\"" _ret "\"" subcmd_invocation "\""
    }
}

function generate_advise_json_init_advise_map(advise_map,   i, tmp, _option_id, tmp_len){
    for ( i=1; i<=advise_len(); ++i ) {
        tmp_len = split(advise_get( i ), tmp)
        _option_id = tmp[1];     if ( option_alias_2__option_id[ _option_id ] != "" )  _option_id = option_alias_2__option_id[ _option_id ]
        advise_map[ _option_id ] = str_trim( str_join( " ", tmp, "", 2, tmp_len ) )
    }
}

function generate_advise_json_except_subcmd(      i, j, _option_id, _option_argc, advise_map ){
    generate_advise_json_init_advise_map( advise_map )

    AJADD( "{" )

    AJADD( swrap("#desc") ); AJADD( ":" ); AJADD( swrap( arg_arr[2] ) );

    for (i=1; i <= namedopt_len(); ++i) {
        _option_id       = namedopt_get( i )
        _option_argc     = option_arr[ _option_id L ]

        AJADD(","); AJADD( swrap(get_option_key_by_id(_option_id)) ); AJADD( ":" );
        AJADD( "{" );
        AJADD( swrap("#desc") ); AJADD(":"); AJADD( swrap( option_desc_get( _option_id ) ) )
        for ( j=1; j<=_option_argc; ++j ) {
            AJADD(",")
            AJADD( swrap( "#" j ) ); AJADD(":");                                generate_advise_json_value_candidates_by_rules( _option_id SUBSEP j );
        }
        AJADD( "}" );
    }

    for (i=1; i <= flag_len() && _option_id = flag_get( i ); ++i) {
        AJADD(","); AJADD( swrap(_option_id) ); AJADD(":");                     AJADD("{"); AJADD( swrap("#desc") ); AJADD(":"); AJADD( swrap(option_desc_get( _option_id )) ); AJADD("}")
    }

    for (i=1; i <= restopt_len() && _option_id = restopt_get( i ); ++i) {
        AJADD(","); AJADD( swrap( _option_id ) );  AJADD( ":" );                generate_advise_json_value_candidates_by_rules(_option_id, advise_map )
    }

    gsub("'", "'\\''", ADVISE_JSON );   ADVISE_JSON = "'" ADVISE_JSON "'"
}

function generate_advise_json(){
    generate_advise_json_except_subcmd()
    generate_advise_json_subcmd( )
    AJADD( "'\n}';" )
    CDADD( " A=" ADVISE_JSON )

    gsub("\"", "\\\"", CODE)
    CODE = sprintf("( set -o errexit; %s printf \\\"%%s\\\" \\\"\\$A\\\"; )", CODE  )
    CODE = "eval \"" CODE "\""
    printf("%s", CODE)
}

NR==4{   generate_advise_json();     exit_now(1);    }
