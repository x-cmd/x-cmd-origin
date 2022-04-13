# Section: advise

function generate_advise_json_value_candidates(oparr_keyprefix,
    oparr_string, optarg_name, k, op ){

    op = option_arr[ oparr_keyprefix S 1 ]

    oparr_string = ""
    if (op == "=") {
        op_arr_len = option_arr[ oparr_keyprefix L ]
        for ( k=2; k<=op_arr_len; ++k ) {
            oparr_string = oparr_string "\"" option_arr[ oparr_keyprefix S k ] "\"" ", "
        }
        oparr_string = "[ " substr(oparr_string, 1, length(oparr_string)-2) " ],"
    } else if (op == "=~") {
        optarg_name = option_arr[ option_id S OPTARG_NAME ]
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
    for (i=1; i<=advise_arr[ L ]; ++i) {
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
    for (i=1; i<=option_id_list[ L ]; ++i) {

        option_id       = option_id_list[ i ]
        option_argc     = option_arr[ option_id L ]

        if (option_argc == 0) {
            ADVISE_JSON = ADVISE_JSON "\n" indent_str "  \"" option_id "\": \"--- " option_arr[ option_id S OPTION_DESC ] " \","
        } else {
            ADVISE_JSON = ADVISE_JSON "\n" indent_str "  \"" option_id "\": " "{\n  "
        }

        for ( j=1; j<=option_argc; ++j ) {
            oparr_keyprefix = option_id S j S OPTARG_OPARR
            oparr_string    = generate_advise_json_value_candidates(oparr_keyprefix)
            oparr_string    = indent_str "  \"#" j "\": " oparr_string "\n  "

            ADVISE_JSON = ADVISE_JSON oparr_string
        }

        if (option_argc > 0) {
            ADVISE_JSON = ADVISE_JSON indent_str "  \"#desc\": \"" option_arr[ option_id S OPTION_DESC ] "\"\n  " indent_str "},"
        }
    }

    # Rules for rest options
    for (i=1; i <= rest_option_id_list[ L ]; ++i) {
        option_id       = rest_option_id_list[ i ]

        # Rules in DSL's advise section
        if (advise_map[ option_id ] != "") {
            ADVISE_JSON = ADVISE_JSON "\n" indent_str "  \"" option_id "\": \"" advise_map[option_id] "\","
            continue
        }
        oparr_keyprefix = option_id S "1" S OPTARG_OPARR
        oparr_string    = generate_advise_json_value_candidates(oparr_keyprefix)
        ADVISE_JSON     = ADVISE_JSON "\n" indent_str "  \"" option_id "\": " oparr_string
    }

    for (i=1; i <= subcmd_arr[ L ]; ++i) {
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

# TODO: make it end
NR==4{
    generate_advise_json()
    exit_now(1)
}

