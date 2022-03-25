

# Section: View

BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("ENTER", "for enter")
    # S = " S "
    # L = " L "
}

function view_help(){
    return sprintf("%s\n", th_help_text( ctrl_help_get() ) )
}
function view_header(){
    return sprintf("%s", th(TH_SELECTN_HEADER_NORMAL, data_header) )
}

# function view_body(         i, _key_fa, data, _i_for_this_column, _offset_for_this_column, _selected_index_of_this_column, _value_of_this_column ){
#     for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) {
#         for (j=WIN_BEGIN; j<=WIN_END; ++j) {
#             _key_fa = SELECTED_KEYPATH_STACK[ j-1 ]
#             _offset_for_this_column = ctrl_win_begin( SELECTED_IDX, _key_fa )
#             _i_for_this_column = _offset_for_this_column + i - 1
#             _value_of_this_column = str_pad_right( DATA[ _key_fa L _i_for_this_column ], data_maxcollen(j) + 3)
#             _selected_index_of_this_column = ctrl_win_val( SELECTED_IDX, _key_fa )
#             if ( _selected_index_of_this_column == _i_for_this_column ) {
#                 if (j == FOCUS_COL) data = data UI_TEXT_REV
#                 data = data UI_FG_GREEN _value_of_this_column UI_END
#             } else {
#                 data = data _value_of_this_column
#             }
#         }
#         data = data "\n" UI_END
#     }
#     return data
# }

function view_body(         i, j, _key_fa, data, _i_for_this_column, _offset_for_this_column, _selected_index_of_this_column, _value_of_this_column, _max_column_size, _tmp, _data ){
    for (j=WIN_BEGIN; j<=WIN_END; ++j) {
        _key_fa = SELECTED_KEYPATH_STACK[ j-1 ]
        _offset_for_this_column = ctrl_win_begin( SELECTED_IDX, _key_fa )
        _max_column_size = data_maxcollen(j) + 3

        _selected_index_of_this_column = ctrl_win_val( SELECTED_IDX, _key_fa )

        for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) {
            _i_for_this_column = _offset_for_this_column + i - 1
            _tmp = str_pad_right( DATA[ _key_fa L _i_for_this_column ], _max_column_size )
            if (j == FOCUS_COL) {
                STYLE_SELECTN_SELECTED      =   TH_SELECTN_ITEM_FOCUSED_SELECT
                STYLE_SELECTN_UNSELECTED    =   TH_SELECTN_ITEM_FOCUSED_UNSELECT
            } else {
                STYLE_SELECTN_SELECTED      =   TH_SELECTN_ITEM_UNFOCUSED_SELECT
                STYLE_SELECTN_UNSELECTED    =   TH_SELECTN_ITEM_UNFOCUSED_UNSELECT
            }
            if ( _selected_index_of_this_column == _i_for_this_column ) _tmp = th(STYLE_SELECTN_SELECTED, _tmp)
            else _tmp = th(STYLE_SELECTN_UNSELECTED, _tmp)
            _data[ i ] = _data[ i ] _tmp
        }
    }

    _tmp = ""
    for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) _tmp = _tmp UI_END "\n" "  " _data[ i ]
    return _tmp
}

function view_calcuate_geoinfo(){
    if ( VIEW_BODY_ROW_SIZE > MAX_DATA_ROW_NUM ) return
    if ( ctrl_help_toggle_state() == true ) {
        VIEW_BODY_ROW_SIZE = max_row_size - 9
    } else {
        VIEW_BODY_ROW_SIZE = max_row_size - 8
    }
}

function view(      _component_help, _component_header, _component_body){
    if (DATA_HAS_CHANGED == false)    return
    DATA_HAS_CHANGED = false
    view_calcuate_geoinfo()

    _component_help         = view_help()
    _component_header       = view_header()
    _component_body         = view_body()

    send_update( _component_help "\n" _component_header  _component_body  )
    # print "\n" _component_help "\n" _component_body >> "bbb"
}

# EndSection

# Section: ctrl
function calculate_offset_from_end( end,       i, s, t ){
    if (end == "")  end = MAX_DATA_COL_NUM
    s = 0
    for (i=end; i>=1; --i) {
        s += data_maxcollen(i) + 3 # 3 is column width
        if (s > max_col_size) return i+1
    }
    return 1
}

BEGIN {
    FOCUS_COL = 1
}

function ctrl_cal_colwinsize_by_focus( col,            _selected_keypath ){
    _selected_keypath = SELECTED_KEYPATH_STACK[ col ]

    if (DATA[ _selected_keypath L ] > 0) {
        WIN_END = col + 1
    } else {
        WIN_END = col
    }
    # WIN_BEGIN might be WIN_END + 1
    WIN_BEGIN = calculate_offset_from_end( WIN_END )
}

function ctrl(char_type, char_value,      i, _selected_keypath_fa ){
    exit_if_detected( char_value, ",q,ENTER," )

    if (char_value == "UP")  {
        _selected_keypath_fa = SELECTED_KEYPATH_STACK[ FOCUS_COL - 1 ]
        i = ctrl_win_dec( SELECTED_IDX, _selected_keypath_fa )
        SELECTED_KEYPATH_STACK[ FOCUS_COL ] = _selected_keypath_fa S DATA[ _selected_keypath_fa L i ]

        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }
    if (char_value == "DN") {
        _selected_keypath_fa = SELECTED_KEYPATH_STACK[ FOCUS_COL - 1 ]
        i = ctrl_win_inc( SELECTED_IDX, _selected_keypath_fa )
        SELECTED_KEYPATH_STACK[ FOCUS_COL ] = _selected_keypath_fa S DATA[ _selected_keypath_fa L i ]
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }

    if (char_value == "LEFT" )  {
        if (FOCUS_COL == 1)     return
        -- FOCUS_COL
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }

    if (char_value == "RIGHT") {
        _selected_keypath_fa = SELECTED_KEYPATH_STACK[ FOCUS_COL ]
        if (FOCUS_COL == MAX_DATA_COL_NUM || DATA[ _selected_keypath_fa L ] == "") return
        i = ctrl_win_val( SELECTED_IDX, _selected_keypath_fa )

        ++ FOCUS_COL
        SELECTED_KEYPATH_STACK[ FOCUS_COL ] = _selected_keypath_fa S DATA[ _selected_keypath_fa L i ]
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }
    if (char_value == "h")                          return ctrl_help_toggle()
}

# EndSection

# Section: data
BEGIN{
    DATA_MODE_DATA = 1
    DATA_MODE_CTRL = 2
    DATA_MODE = DATA_MODE_DATA

    MAX_DATA_COL_NUM = 0
    MAX_DATA_ROW_NUM = 0
}

NR==1 {  update_width_height( $2, $3 );  }

# TODO: more encapsulation on data model
function data_maxcollen( idx ){
    return DATA[ idx ]
}

function data_maxcollen_set( idx, value ){
    DATA[ idx ] = value
}

BEGIN{
    VIEW_BODY_ROW_SIZE = 0
    IS_SKIP = false
}

function reinit_selected_index() {
    # TODO: 10 reserve space
    VIEW_BODY_ROW_SIZE = max_row_size - 10
    if ( VIEW_BODY_ROW_SIZE > MAX_DATA_ROW_NUM )     VIEW_BODY_ROW_SIZE = MAX_DATA_ROW_NUM
    reinit_selected_index_( VIEW_BODY_ROW_SIZE )
}

function reinit_selected_index_( size, keypath,      l, i ){
    l = DATA[ keypath L ]
    ctrl_win_init( SELECTED_IDX, keypath, 1, l, size)
    for (i=1; i<=l; ++i) {
        reinit_selected_index_( size, keypath S DATA[ keypath L i ] )
    }
}

function handle_item(           i, j, l, _len, k){
    _key = ""
    if (NF > MAX_DATA_COL_NUM)  MAX_DATA_COL_NUM = NR
    for (i=1; i<=NF; ++i) {
        # TODO:
        for (k=1; k<=DATA[ _key L]; ++k){
            if ($i == DATA[ _key L k ]) {
                IS_SKIP = true
                break
            }
        }
        if (IS_SKIP == true){
            IS_SKIP = false
            _key = _key S $i
            continue
        }

        l = DATA[ _key L ] + 1
        DATA[ _key L ] = l
        if (l > MAX_DATA_ROW_NUM)   MAX_DATA_ROW_NUM = l

        DATA[ _key L l ] = $i
        _len = length( $i )
        if (_len > data_maxcollen( i ) ) {
            data_maxcollen_set( i, _len )
        }
        _key = _key S $i
    }
}

function consume_ctrl(  _cmd){
    if (try_update_width_height( $0 ) == true) {
        if ( is_height_change() == true )  reinit_selected_index()
        return
    }

    DATA_HAS_CHANGED = true

    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    view()
}
NR==2 {  data_header = str_trim($0) }
NR>2 {
    if (DATA_MODE == DATA_MODE_DATA) {
        if ($0 != "---")    {
            handle_item()
        } else{
            DATA_MODE = DATA_MODE_CTRL
            reinit_selected_index()
            ctrl_cal_colwinsize_by_focus(FOCUS_COL)
            SELECTED_KEYPATH_STACK[0] = ""
            SELECTED_KEYPATH_STACK[1] = S DATA[L 1]
        }
    } else {
        consume_ctrl()
    }
}
END {
    if ( exit_is_with_cmd() == true ) {
        _key_fa = SELECTED_KEYPATH_STACK[ FOCUS_COL-1 ]
        i = ctrl_win_val( SELECTED_IDX, _key_fa )
        _key_path = _key_fa S DATA[ _key_fa L i]
        gsub(S, ".", _key_path)
        send_env( "___X_CMD_UI_SELECTN_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_UI_SELECTN_CURRENT_ITEM",         _key_path )
    }
}
# EndSection
