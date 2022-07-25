
# shellcheck shell=bash

# get the candidate value
function advise_get_candidate_code( curval, genv, lenv, obj, kp,        _candidate_code, i, j, l, v, _option_id, _cand_key, _cand_l, _desc, _arr_value, _arr_valuel ) {
    l = obj[ kp L ]
    for (i=1; i<=l; ++i) {
        _option_id = obj[ kp, i ]
        if ( _option_id == "\"#cand\"" ) {
            _cand_key = kp SUBSEP _option_id
            _cand_l = obj[ _cand_key L ]
            for (j=1; j<=_cand_l; ++j) {
                v = juq(obj[ _cand_key, "\"" j "\"" ])
                _desc = ""
                if (match( v, " --- ")) {
                    _desc = ( ZSHVERSION != "" ) ? substr(v, RSTART+RLENGTH) : ""
                    v = substr( v, 1, RSTART-1)
                }
                if( v ~ "^" curval ){
                    if ( _desc != "" ) _candidate_code = _candidate_code shqu1(v ":" _desc) "\n"
                    else _candidate_code = _candidate_code shqu1(v) "\n"
                }
            }
        }
        if ( _option_id ~ "^\"#") continue

        _desc = ( ZSHVERSION != "" ) ? juq(obj[ kp SUBSEP _option_id SUBSEP "\"#desc\"" ]) : ""
        _arr_valuel = split( juq( _option_id ), _arr_value, "|" )
        for ( j=1; j<=_arr_valuel; ++j) {
            v =_arr_value[j]
            if (v ~ "^"curval){
                if ( aobj_istrue( obj, kp SUBSEP _option_id SUBSEP "\"#multiple\"" ) || (lenv[ _option_id ] == "")) {
                    if (( curval == "" ) && ( v ~ "^-" )) if ( ! aobj_istrue(obj, kp SUBSEP _option_id SUBSEP "\"#subcmd\"" ) ) continue
                    if (( curval == "-" ) && ( v ~ "^--" )) continue
                    if ( _desc != "" ) _candidate_code = _candidate_code shqu1(v ":" _desc) "\n"
                    else _candidate_code = _candidate_code shqu1(v) "\n"
                }
            }
        }
    }
    return _candidate_code
}

function advise_complete___generic_value( curval, genv, lenv, obj, kp, _candidate_code,         _exec_val, _regex_key_arr, _regex_key_arrl, _regex_id, i ){

    _candidate_code = _candidate_code advise_get_candidate_code( curval, genv, lenv, obj, kp )

    _exec_val = obj[ kp SUBSEP "\"#exec\"" ]
    if ( _exec_val != "" ) CODE = CODE "candidate_exec=\"" juq(_exec_val) "\";\n"

    _regex_key_arr = kp SUBSEP "\"#regex\""
    _regex_key_arrl = obj[ _regex_key_arr L ]
    for ( i=1; i<=_regex_key_arrl; ++i ) {
        _regex_id = obj[ _regex_key_arr, i ]
        if (curval ~ "^"juq( _regex_id )"$" ) return advise_complete___generic_value(curval, genv, lenv, obj, _regex_key_arr SUBSEP _regex_id , _candidate_code)
    }

    if ( _candidate_code != "" ) CODE = CODE "candidate_arr=(\n" _candidate_code ")\n"
    # TODO: Other code
    return CODE
}

# Just show the value
function advise_complete_option_value( curval, genv, lenv, obj, obj_prefix, option_id, arg_nth ){
    return advise_complete___generic_value( curval, genv, lenv, obj, obj_prefix SUBSEP option_id SUBSEP "\"#" arg_nth "\"")
}

# Just tell me the arguments
function advise_complete_argument_value( curval, genv, lenv, obj, obj_prefix, nth, _candidate_code,      _kp ){

    _kp = obj_prefix SUBSEP "\"#" nth "\""
    if (obj[ _kp ] != "") {
        return advise_complete___generic_value( curval, genv, lenv, obj, _kp, _candidate_code )
    }

    _kp = obj_prefix SUBSEP "\"#n\""
    if (obj[ _kp ] != "") {
        return advise_complete___generic_value( curval, genv, lenv, obj, _kp, _candidate_code )
    }

    return advise_complete___generic_value( curval, genv, lenv, obj, obj_prefix )
}

# Most complicated #1
function advise_complete_option_name_or_argument_value( curval, genv, lenv, obj, obj_prefix,          _candidate_code, i, k, l, _required_options ){

    _candidate_code = advise_get_candidate_code( curval, genv, lenv, obj, obj_prefix )
    if ( ( curval == "" ) || ( curval ~ /^-/ ) || (aobj_option_all_set( lenv, obj, obj_prefix ))) {
        return advise_complete_argument_value( curval, genv, lenv, obj, obj_prefix, 1, _candidate_code)
    }

    l = obj[ obj_prefix L ]
    for (i=1; i<=l; ++i) {
        k = obj[ obj_prefix, i ]
        if (k ~ "^\"[^-]") continue
        if ( aobj_istrue(obj, obj_prefix SUBSEP k SUBSEP "\"#subcmd\"" ) ) continue

        if ( aobj_required(obj, obj_prefix SUBSEP k) ) {
            if ( lenv_table[ k ] == "" ) {
                _required_options = (_required_options == "") ? k : _required_options ", " k
            }
        }
    }
    panic("Required options [ " _required_options " ] should be set")

}
