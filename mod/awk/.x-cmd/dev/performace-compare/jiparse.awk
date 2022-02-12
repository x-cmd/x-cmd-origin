
# Section: jiparse after tokenized
function jiparse_after_tokenize(jobj, text,       _arr, _arrl, _i){
    _arrl = split( json_to_machine_friendly(text), _arr, "\n" )
    for (_i=1; _i<=_arrl; ++_i) {
        jiparse( jobj, _arr[_i] )
    }
}

function jiparse_after_tokenize_(text) {
    jiparse_after_tokenize(_, text)
}
# EndSection

# Section: jiparse_
function init_jiparse_(){
    init_jiparse()
}

function jiparse_( item ){
    # efficiency defect 1%
    jiparse( _, item )
}
# EndSection

# Section: jiparse
BEGIN{
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""   # keypath
}

function init_jiparse(){
    JITER_FA_KEYPATH = ""
    JITER_STATE = T_ROOT
    JITER_LAST_KP = ""
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""
    JITER_CURLEN = 0

    JITER_LAST_KL = ""
}

function jiparse( obj, item ){

    if (item ~ /^[,:]*$/) {
        return
    } else if (item ~ /^[tfn"0-9+-]/) { #"
    # } else if (item !~ /^[\{\}\[\]]$/) {
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != T_DICT ) {
            obj[ JITER_FA_KEYPATH S "\"" JITER_CURLEN "\"" ] = item
        } else {
            if ( JITER_LAST_KP != "" ) {
                JITER_CURLEN = JITER_CURLEN - 1
                obj[ JITER_FA_KEYPATH S JITER_LAST_KP ] = item
                JITER_LAST_KP = ""
            } else {
                JITER_LAST_KP = item
                obj[ JITER_FA_KEYPATH T_KEY ] = obj[ JITER_FA_KEYPATH T_KEY ] S item
            }
        }
    } else if (item ~ /^\[$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_LIST
        JITER_CURLEN = 0

        obj[ JITER_FA_KEYPATH ] = T_LIST
        # TODO: consider it. so we can distinguish ...
        # obj[ JITER_FA_KEYPATH T_KEY ] = \001

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else if (item ~ /^\]$/) {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    } else if (item ~ /^\{$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_DICT
        JITER_CURLEN = 0

        obj[ JITER_FA_KEYPATH ] = T_DICT

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else if (item ~ /^\}$/) {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    }
}

# EndSection
