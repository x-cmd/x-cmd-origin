# Section: advise
function generate_advise_json_value_candidates_by_rules(optarg_id,       _name, op ){
    op = oparr_get( optarg_id, 1 )

    if (op == "=~") {
        _name = option_name_get( option_id )
        if ( advise_map[ _name ] != "" )    return quote_string( advise_map[ _name ] )
    } else                                  return "[ " oparr_join_wrap( optarg_id, ", " ) " ]"
    return "[  ]"
}

function generate_advise_json_subcmd(indent, indent_str, indent_str2, indent_str4,
    i, subcmd_funcname, subcmd_invocation, _name_arr, _ret){

    for (i=1; i <= subcmd_len(); ++i) {
        split(subcmd_id( i ), _name_arr, "|") # get the subcmd name list

        subcmd_funcname = "${X_CMD_ADVISE_FUNC_NAME}_" _name_arr[ 1 ]
        subcmd_invocation = sprintf("%s=%s %s _x_cmd_advise_json %d 2>/dev/null",
            "X_CMD_ADVISE_FUNC_NAME",
            subcmd_funcname,
            subcmd_funcname,
            (indent + 1) )

        subcmd_invocation = sprintf("%s$( s=$(%s); %s )",
            subcmd_desc(i),
            subcmd_invocation,
            "if [ $? -eq 126 ] && [ ${#s} != " (indent*2+5) " ] ; then printf \002,${s#{}\002 ; else printf '\n" indent_str "  }'; fi" )

        _ret = _ret "\n" indent_str2 sprintf("%s: %s", quote_string( subcmd_id( i ) ),
            "{\n" indent_str4 s_wrap2("#desc") ": " subcmd_invocation      ) ","
    }
    return _ret
}

function generate_advise_json_init_advise_map(advise_map,   i, tmp, option_id, tmp_len){
    for (i=1; i<= advise_len(); ++i) {
        tmp_len = split(advise_get( i ), tmp)

        option_id = tmp[1];     if ( option_alias_2_option_id[ option_id ] != "" )  option_id = option_alias_2_option_id[ option_id ]

        advise_map[ option_id ] = str_trim( str_join( " ", tmp, "", 2, tmp_len ) )
    }
}

function generate_advise_json(      indent, indent_str,
    i, j, option_id, option_argc, advise_map,       indent_str2, indent_str4){

    generate_advise_json_init_advise_map( advise_map )

    indent = arg_arr[2] + 0;  indent_str4 = ( (indent_str2 = (( indent_str = str_rep("  ", indent)) "  " )) "  " )

    ADVISE_JSON = "{"

    for (i=1; i <= namedopt_len(); ++i) {
        option_id       = namedopt_get( i )
        option_argc     = option_arr[ option_id L ]

        ADVISE_JSON = ADVISE_JSON "\n" indent_str2 s_wrap2( option_id ) ": {\n"
        for ( j=1; j<=option_argc; ++j ) {
            ADVISE_JSON = ADVISE_JSON indent_str4 sprintf("%s: %s", quote_string("#" j),
                generate_advise_json_value_candidates_by_rules(option_id SUBSEP j)    \
            ) ",\n"
        }

        ADVISE_JSON = ADVISE_JSON indent_str4 sprintf("%s: %s", s_wrap2("#desc"),
            quote_string(option_desc_get( option_id ))    \
        ) "\n" indent_str2 "},"
    }

    for (i=1; i <= flag_len() && option_id = flag_get( i ); ++i)
        ADVISE_JSON = ADVISE_JSON "\n" indent_str2 sprintf("%s: %s", s_wrap2(option_id),
            quote_string( "--- " option_desc_get( option_id ) ) \
        ) ","

    for (i=1; i <= restopt_len() && option_id = restopt_get( i ); ++i)
        ADVISE_JSON = ADVISE_JSON "\n" indent_str2 sprintf("%s: %s", s_wrap2(option_id),
            (advise_map[ option_id ] != "" ? \
                quote_string( advise_map[option_id] ) : \
                generate_advise_json_value_candidates_by_rules(option_id S "1") ) \
        ) ","

    ADVISE_JSON = ADVISE_JSON generate_advise_json_subcmd( indent, indent_str, indent_str2, indent_str4 )

    if (ADVISE_JSON != "{")     ADVISE_JSON = substr(ADVISE_JSON, 1, length(ADVISE_JSON)-1)  # remove extra comma
    ADVISE_JSON = ADVISE_JSON "\n" indent_str "}"

    ADVISE_JSON = quote_string(ADVISE_JSON)
    gsub(/\002/, "\"", ADVISE_JSON)
    printf("printf %s %s; return 126;", s_wrap2("%s"), ADVISE_JSON)
}
## EndSection

NR==4{  generate_advise_json();     exit_now(1);    }
