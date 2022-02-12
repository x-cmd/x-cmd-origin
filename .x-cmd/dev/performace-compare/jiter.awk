# Section: jiparse
BEGIN{
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""   #  keypath
}

function init_jiter(){
    JITER_FA_KEYPATH = ""
    JITER_STATE = T_ROOT
    JITER_LAST_KP = ""
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""
    JITER_CURLEN = 0

    JITER_LAST_KL = ""

    # JTAR = JITER_TARGET
    JTAR_FA_KEYPATH = ""
    JTAR_STATE = T_ROOT
    JTAR_LAST_KP = ""
    JTAR_LEVEL = 0
    JTAR_CURLEN = 0

    JTAR_LAST_KL = ""

}

# Section: target parser
function jiter_target_eq( obj, item, keypath,     _ret ){
    if ( JTAR_LEVEL == 0 ) {
        _ret = jiter( item, JITER_STACK )
        # print "jiter \t " item "\t|" _ret "|\t|" keypath "|"
        if ( _ret == "" ) return false
        if ( _ret != keypath) return false
    }
    ___jiter_target_parse( obj, item )
    if (JTAR_LEVEL == 0) return true
    return false
}

function jiter_target_eq_( item, keypath_regex ){
    return jiter_target_eq( _, item, keypath_regex)
}

function jiter_target_rmatch( obj, item, keypath_regex ){

    if ( JTAR_LEVEL == 0 ) {
        _ret = jiter( item, JITER_STACK )
        if ( _ret == "" ) return false
        match( _ret, keypath_regex )
        if ( RLENGTH <= 0 ) return false
    }
    ___jiter_target_parse( obj, item )
    if (JTAR_LEVEL == 0) return true
    return false
}

function jiter_target_rmatch_( item, keypath_regex ){
    return jiter_target_rmatch( _, item, keypath_regex)
}

function ___jiter_target_parse( obj, item ){
    if (item ~ /^[,:]*$/) {
        return
    }

    if (item ~ /^[tfn"0-9+-]/) #"
    # } else if (item !~ /^[\{\}\[\]]$/) {
    {
        JTAR_CURLEN = JTAR_CURLEN + 1
        if ( JTAR_STATE != T_DICT ) {
            obj[ JTAR_FA_KEYPATH S "\"" JTAR_CURLEN "\"" ] = item
        } else {
            if ( JTAR_LAST_KP != "" ) {
                JTAR_CURLEN = JTAR_CURLEN - 1
                obj[ JTAR_FA_KEYPATH S JTAR_LAST_KP ] = item
                JTAR_LAST_KP = ""
            } else {
                JTAR_LAST_KP = item
                obj[ JTAR_FA_KEYPATH T_KEY ] = obj[ JTAR_FA_KEYPATH T_KEY ] S item
            }
        }
    } else if (item ~ /^\[$/) {
        if ( JTAR_STATE != T_DICT ) {
            JTAR_CURLEN = JTAR_CURLEN + 1
            obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN
            JTAR_FA_KEYPATH = JTAR_FA_KEYPATH S "\"" JTAR_CURLEN "\""
        } else {
            obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN
            JTAR_FA_KEYPATH = JTAR_FA_KEYPATH S JTAR_LAST_KP
            JTAR_LAST_KP = ""
        }

        JTAR_STATE = T_LIST
        JTAR_CURLEN = 0

        obj[ JTAR_FA_KEYPATH ] = T_LIST

        obj[ ++JTAR_LEVEL ] = JTAR_FA_KEYPATH
    } else if (item ~ /^\]$/) {
        obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN

        JTAR_LEVEL --

        JTAR_FA_KEYPATH = obj[ JTAR_LEVEL ]
        JTAR_STATE = obj[ JTAR_FA_KEYPATH ]
        JTAR_CURLEN = obj[ JTAR_FA_KEYPATH T_LEN ]
    } else if (item ~ /^\{$/) {
        if ( JTAR_STATE != T_DICT ) {
            JTAR_CURLEN = JTAR_CURLEN + 1
            obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN
            JTAR_FA_KEYPATH = JTAR_FA_KEYPATH S "\"" JTAR_CURLEN "\""
        } else {
            obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN
            JTAR_FA_KEYPATH = JTAR_FA_KEYPATH S JTAR_LAST_KP
            JTAR_LAST_KP = ""
        }

        JTAR_STATE = T_DICT
        JTAR_CURLEN = 0

        obj[ JTAR_FA_KEYPATH ] = T_DICT
        obj[ ++JTAR_LEVEL ] = JTAR_FA_KEYPATH
    } else if (item ~ /^\}$/) {
        obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN

        JTAR_LEVEL --

        JTAR_FA_KEYPATH = obj[ JTAR_LEVEL ]
        JTAR_STATE = obj[ JTAR_FA_KEYPATH ]
        JTAR_CURLEN = obj[ JTAR_FA_KEYPATH T_LEN ]
    }
}
# EndSection

# Section: jiter core

function jiter( item, stack,  _res ) {
    if (item ~ /^[,:]*$/) {
        return
    } else if (item ~ /^[tfn"0-9+-]/) #"
    # } else if (item !~ /^[\{\}\[\]]$/) {
    {
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE == T_DICT ) {
            if ( JITER_LAST_KP != "" ) {
                JITER_CURLEN = JITER_CURLEN - 1
                _res = JITER_FA_KEYPATH S JITER_LAST_KP
                JITER_LAST_KP = ""
                return _res
            } else {
                JITER_LAST_KP = item
                return JITER_FA_KEYPATH S JITER_CURLEN
            }
        } else {
            return JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        }
    } else if (item ~ /^\[$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_LIST
        JITER_CURLEN = 0

        stack[ JITER_FA_KEYPATH ] = T_LIST

        stack[ ++JITER_LEVEL ] = JITER_FA_KEYPATH

        return JITER_FA_KEYPATH
    } else if (item ~ /^\]$/) {
        stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = stack[ JITER_LEVEL ]
        JITER_STATE = stack[ JITER_FA_KEYPATH ]
        JITER_CURLEN = stack[ JITER_FA_KEYPATH T_LEN ]
    } else if (item ~ /^\{$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_DICT
        JITER_CURLEN = 0

        stack[ JITER_FA_KEYPATH ] = T_DICT

        stack[ ++JITER_LEVEL ] = JITER_FA_KEYPATH

        return JITER_FA_KEYPATH
    } else if (item ~ /^\}$/) {
        stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = stack[ JITER_LEVEL ]
        JITER_STATE = stack[ JITER_FA_KEYPATH ]
        JITER_CURLEN = stack[ JITER_FA_KEYPATH T_LEN ]
    }
    return ""
}
# EndSection

# Section: target handler for print

# There is no jiter_handle_print, because if you want to format the output, pipe to another formatter

function jiter_print1_eq( item, keypath,    _ret ){
    if (JTAR_LEVEL == 0){
        _ret = jiter( item, JITER_STACK )
        if ( _ret == "" ) return false
        if ( _ret != keypath) return false
    }
    ___jiter_print_target_levelcal( item )
    printf("%s", item)
    if (JTAR_LEVEL == 0) {
        printf("\n")
        return true
    }
    return false
}

function jiter_print0_eq( item, keypath ){
    if (JTAR_LEVEL == 0){
        _ret = jiter( item, JITER_STACK )
        if ( _ret == "" ) return false
        if ( _ret != keypath) return false
    }
    ___jiter_print_target_levelcal( item )
    printf("%s\n", item)
    if (JTAR_LEVEL == 0) {
        return true
    }
    return false
}


function jiter_print0_eq_arr( item, jpathl_arrl, jpath_arr ){
    if (JTAR_LEVEL == 0){
        _ret = jiter( item, JITER_STACK )
        if (_ret == "") return
        if ( JITER_LEVEL )
    }
    ___jiter_print_target_levelcal( item )
    printf("%s\n", item)
    if (JTAR_LEVEL == 0) {
        return true
    }
    return false
}


function ___jiter_print_target_levelcal( item ){
    if (item ~ /^[\[\{]$/) {
        JTAR_LEVEL += 1
    } else if (item ~ /^[\]\}]$/) {
        JTAR_LEVEL -= 1
    }
    return JTAR_LEVEL
}

# EndSection

# Section: jiparse
function jiparse( obj, item, _kp ){
    _kp = jiter( item, obj )
    obj[ _kp ] = item
    return _kp
}

function jiparse_( item ){
    return jiparse( _, item )
}
# EndSection

# Section: jiparse
function jileaf( obj, item, sep1, sep2, _kp ){
    _kp = jiter( item, obj )
    if ( item !~ /^[\[\{}]]$/ ) {
        if (JITER_LAST_KP == "") {
            printf("%s%s%s%s", _kp, sep1, item, sep2)
        }
    }
}

# TODO
function jiflat( obj, item, sep1, sep2, _kp ){
    _kp = jiter( item, obj )
    if ( item !~ /^[\[\{}]]$/ ) {
        if (JITER_LAST_KP == "") {
            printf("%s%s%s%s", _kp, sep1, item, sep2)
        }
    }
}
# EndSection

