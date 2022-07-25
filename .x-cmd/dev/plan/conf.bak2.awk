
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

function prepare_arg( no,   _root, _exec, _ret ){
    _root = DFS[ no, "root" ]
    _ret = " -c " _root
    _exec = DFS[ no, "exec" ]
    _ret = _ret _exec
    return _ret
}

function prepare_window( i,     _name, _root, _exec,_code, _kp ){
    _kp = SUBSEP jqu("1") SUBSEP jqu( "windows" ) SUBSEP jqu(i)
    dfs_panel( _kp, 0 )

    _name = obj[ _kp, jqu("name") ]

    _code = tmux("new-windows")
    if ( _name != "")       _code = _code " -n " _name " "
    _code = _code prepare_arg( 0 )

    code_append( _code )

    biggest_panel_id = prepare_panel( _kp SUBSEP jqu("panes"), 0 )
    print "Panel Number: " total_panel >"/dev/stderr"

}

function dfs_panel( kp, panel_id ){
    if (obj[ kp, jqu("panes") ] != "[") {
        DFS[ kp ] = panel_id ++
        _name = ""
        _root = ""
        _exec = obj[ kp ]
        if (_exec == "{") {
            _name = obj[ _kp, jqu("name") ]
            _root = obj[ kp, jqu( "root" ) ]
            _exec = obj[ kp, juq( "exec" ) ]
        }
        DFS[ panel_id, "name" ] = _name
        DFS[ panel_id, "root" ] = _root
        DFS[ panel_id, "exec" ] = _exec
    } else {
        l = obj[ kp, jqu("panes") L ]
        for (i=1; i<=l; ++i) {
            DFS[ kp, i ] = panel_id
            panel_id = dfs_panel( kp SUBSEP jqu("panes"), panel_id)
        }
    }
    return panel_id
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
        if (obj[ kp, jqu(i), jqu("panes") ] == "[") {
            pane_id = prepare_panel( kp SUBSEP jqu(i) SUBSEP jqu("panes"), pane_id )
        }
    }

    return pane_id
}


