
BEGIN{
    TMUX_COMMAND = "command tmux "
}

function tmux( args ){
    return TMUX_COMMAND " " args
}

{
    # text = text "\n" $0
    if ($0 != "") jiparse_after_tokenize(obj, $0)
}

END{
    # load(text)
    generate_code( obj )

    print CODE
}

# function load( text , arr ){
#     obj = jtokenize( text )
#     jparse( obj, arr )


#     # generate_code( arr )
# }

function code_append( code ){
    CODE = CODE "\n" code
}

function generate_code( obj,        _name, _root, l, i, _panel, _window_root, _kp ){
    _name = jget( obj, "1.name" )
    _root = jget( obj, "1.root" )

    code_append( "!" tmux("attach -t " _name ) " || return 0" )

    _kp = SUBSEP jqu("1") SUBSEP jqu( "windows" )
    l = obj[ _kp L ]
    for (i=1; i<=l; ++i) prepare_window( i )
}

function prepare_window( i,     _name, _root, _exec,_code, _kp ){
    _kp = SUBSEP jqu("1") SUBSEP jqu( "windows" ) SUBSEP jqu(i)

    _name = obj[ _kp, jqu("name") ]
    _root = obj[ _kp, jqu("root") ]
    _exec = obj[ _kp, jqu("before") ]

    _code = tmux("new-windows")
    if ( _root != "")       _code = _code " -c " _root " "
    if ( _name != "")       _code = _code " -n " _name " "
    if ( _exec != "" )      _code = _code " " _exec

    delete PANE_EXEC

    code_append( _code )
    biggest_panel_id = prepare_panel( _kp SUBSEP jqu("panes"), 0 )
    print "Panel Number: " total_panel >"/dev/stderr"

    # execute( biggest_panel_id )
}

function prepare_panel( kp, pane_id,   _code, _pane , l, i, _exec, _root, _start_pane_id, PANE_EXEC_LOCAL ){
    l = obj[ kp L ]

    if (pane_id != "") _pane = " -t:." pane_id " "

    for (i=1; i<=l; ++i) {
        _root = ""
        _exec = obj[ kp, jqu(i) ]
        if (_exec == "{") {
            _root = obj[ kp, jqu(i), jqu("root") ]
            _exec = obj[ kp, jqu(i), jqu("exec") ]
        }
        PANE_EXEC_LOCAL[ i ] = _exec

        if (i>1) {
            _code = tmux( "split-window" )
            if ( _root != "")       _code = _code " -c " _root " "
            if ( _exec != "")       _code = _code " " _exec " "
            code_append( _code )
        } else {
            FIRST_EXEC = _exec
        }
    }


    for (i=1; i<=l; ++i) {
        if (i>1) pane_id = pane_id + 1
        PANE_EXEC[ pane_id ] = PANE_EXEC_LOCAL[ i ]
        if (obj[ kp, jqu(i), jqu("panes") ] == "[") {
            pane_id = prepare_panel( kp SUBSEP jqu(i) SUBSEP jqu("panes"), pane_id )
        }
    }

    return pane_id
}

function execute( biggest_panel_id,    i ){
    for (i=0; i<=biggest_panel_id; ++i) {
        code_append( tmux( "select-panel -t ." i ))
        code_append( PANE_EXEC[i] " # Command " i )
    }
}

