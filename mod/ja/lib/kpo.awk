BEGIN {
    false = 0
    FALSE = 0
    true = 1
    TRUE = 1
    S = SUBSEP
    T = "\002"
    L = "\003"
}



# Section: jiter
# function jiter_init( keypath_prefix ) {
BEGIN {
    JITER_FA_KEYPATH    = keypath_prefix
    JITER_STATE         = T_ROOT
    JITER_LAST_KP       = ""
    l                   = 0
    JITER_CURLEN        = 0

    JITER_OFFSET_FULLKP = 10000
}

function jiter( item,  _res ) {
    if (item ~ /^[,:]*$/) return
    if (item ~ /^[tfn"0-9+-]/) #"   # (item !~ /^[\{\}\[\]]$/) {
    {
        if ( JITER_LAST_KP != "" ) {
            _res = JITER_FA_KEYPATH S JITER_LAST_KP
            key = JITER_LAST_KP
            JITER_LAST_KP = ""
            return _res
        }
        JITER_CURLEN = JITER_CURLEN + 1
        _[ l ] = item
        if ( JITER_STATE != "{" ) {
            return JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        }
        JITER_LAST_KP = item
        # return JITER_FA_KEYPATH S JITER_CURLEN
    } else if (item ~ /^[\[\{]$/) { # }
        if ( JITER_STATE != "{" ) {
            JITER_CURLEN = JITER_CURLEN + 1
            _[ JITER_FA_KEYPATH L ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
            _[ ++ l ] = JITER_CURLEN
            key = JITER_CURLEN
        } else {
            _[ JITER_FA_KEYPATH L ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            _[ ++ l ] = JITER_LAST_KP
            key = JITER_LAST_KP
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        _[ JITER_FA_KEYPATH ] = item
        _[ l + JITER_OFFSET_FULLKP ] = JITER_FA_KEYPATH
        return JITER_FA_KEYPATH
    } else {
        _[ JITER_FA_KEYPATH L ] = JITER_CURLEN

        _res = JITER_FA_KEYPATH
        _[ l ] = item
        key = _[ --l ]
        JITER_FA_KEYPATH = _[ l + JITER_OFFSET_FULLKP ]
        JITER_STATE = _[ JITER_FA_KEYPATH ]
        JITER_CURLEN = _[ JITER_FA_KEYPATH L ]

        return _res
    }
    return ""
}
# EndSection

{
    if ( (kp = jiter( $0 )) == "" ) next
    K=key
    V=$0
    _v = ""
    _k = ""
}
