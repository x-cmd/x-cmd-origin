
# Section: view

BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("ENTER", "for enter")
}

function view_help(){
    return sprintf("%s", th_help_text( ctrl_help_get() ) )
}
function view_ls_info(         _selected_index_of_focus_column, _item_index, _file_type, _file_size, _last_access, _last_modify, _last_change, _access_rights, _uid, _gid, _data){
    _selected_index_of_focus_column = ctrl_win_val( data, FOCUS_COL )
    _item_index = FOCUS_COL L _selected_index_of_focus_column

    _file_type          =   data_info_file_type[ _item_index ]
    _file_size          =   data_info_size[ _item_index ]
    _last_access        =   data_info_time_of_last_access[ _item_index ]
    _last_modify        =   data_info_time_of_last_modify[ _item_index ]
    _last_change        =   data_info_time_of_last_change[ _item_index ]
    _access_rights      =   data_info_access_rights[ _item_index ]
    _uid                =   data_info_uid[ _item_index ]
    _gid                =   data_info_gid[ _item_index ]
    _data =       sprintf("  Name: %s  Size: %s  Type: %s\n", data[ _item_index ], _file_size, _file_type)
    _data = _data sprintf("Access: %s  Uid: ( %s )  Gid: ( %s )\n", _access_rights, _uid, _gid)
    _data = _data sprintf("Access: %s\n", _last_access)
    _data = _data sprintf("Modify: %s\n", _last_modify, _id)
    _data = _data sprintf("Change: %s\n", _last_change, _id)
    return _data
}

function view_env_info(){
    _selected_index_of_focus_column = ctrl_win_val( data, FOCUS_COL )
    _item_index = FOCUS_COL L _selected_index_of_focus_column
    return sprintf("INFO: %s", data_info_env[ _item_index ])
}


function view_body(         i, j, _i_for_this_column, _offset_for_this_column, _selected_index_of_this_column, _max_column_size, _tmp, _data ){
    for (j=WIN_BEGIN; j<=WIN_END; ++j) {
        _offset_for_this_column = ctrl_win_begin( data, j )
        _max_column_size = data[ j S ] + 2
        _selected_index_of_this_column = ctrl_win_val( data, j )

        for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) {
            _i_for_this_column = _offset_for_this_column + i - 1
            if ( _i_for_this_column > data[ j L ] ) {
                _data[ i ] = _data[ i ] ui_str_rep(" ", _max_column_size + 1)
                continue
            }
            _tmp = " " str_pad_right( data[ j L _i_for_this_column ], _max_column_size)
            if (j == FOCUS_COL) {
                STYLE_CATEGORYSELECT_SELECTED      =   TH_CATEGORYSELECT_ITEM_FOCUSED_SELECT
                STYLE_CATEGORYSELECT_UNSELECTED    =   TH_CATEGORYSELECT_ITEM_FOCUSED_UNSELECT
            } else {
                STYLE_CATEGORYSELECT_SELECTED      =   TH_CATEGORYSELECT_ITEM_UNFOCUSED_SELECT
                STYLE_CATEGORYSELECT_UNSELECTED    =   TH_CATEGORYSELECT_ITEM_UNFOCUSED_UNSELECT
            }
            if ( _selected_index_of_this_column == _i_for_this_column ) _tmp = th(STYLE_CATEGORYSELECT_SELECTED, _tmp)
            else _tmp = th(STYLE_CATEGORYSELECT_UNSELECTED, _tmp)
            if ( data_info_file_type[ j L _i_for_this_column ] == "regular file" ) _tmp = th(TH_CATEGORYSELECT_UNDIRECTORY, _tmp)
            _data[ i ] = _data[ i ] _tmp
        }
    }

    _tmp = ""
    for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) _tmp = _tmp UI_END "\n" "  " _data[ i ]
    return _tmp
}

function view_calcuate_geoinfo(){
    if ( VIEW_BODY_ROW_SIZE >= MAX_DATA_ROW_NUM ) return
    if ( ctrl_help_toggle_state() == true ) {
        VIEW_BODY_ROW_SIZE = max_row_size - 9 -1
    } else {
        VIEW_BODY_ROW_SIZE = max_row_size - 8 -1
    }
}

function view(      _component_help, _component_header, _component_body){
    view_calcuate_geoinfo()

    _component_help         = view_help()
    _component_info         = (LS_INFO_VAR == true) ? view_ls_info() : view_env_info()
    _component_body         = view_body()

    send_update( _component_help "\n" _component_info _component_body  )
}

# EndSection

# Section: ctrl
function calculate_offset_from_end( end,       i, s, t ){
    # if (end == "")  end = MAX_DATA_COL_NUM
    s = 0
    for (i=end; i>=1; --i) {
        s += data[ i S ] + 3 # 3 is column width
        if (s > max_col_size) return i+1
    }
    return 1
}


function ctrl_cal_colwinsize_by_focus( col,            _selected_keypath ){
    if (data[ col L ] <= 0) {
        WIN_END = col - 1
    } else {
        WIN_END = col
    }
    # WIN_END = col
    # WIN_BEGIN might be WIN_END + 1
    WIN_BEGIN = calculate_offset_from_end( WIN_END )
}

function ctrl(char_type, char_value){
    exit_if_detected( char_value, ",q,ENTER," )

    if (char_value == "h")                                              return ctrl_help_toggle()

    if (char_value == "UP")                                             ctrl_win_rdec( data, FOCUS_COL )
    else if (char_value == "DN")                                        ctrl_win_rinc( data, FOCUS_COL )
    else if ((char_value == "LEFT") && (FOCUS_COL != 1))                -- FOCUS_COL
    else if ((char_value == "RIGHT") && (FOCUS_COL < input_level))      ++ FOCUS_COL
    else                                                                return

    return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
}

# EndSection

# Section: cmd source
# update

BEGIN{
    INPUT_STATE_DATA = 0
    INPUT_STATE_CTRL = 1
    input_state = INPUT_STATE_CTRL
    FOCUS_COL=1
    LS_INFO_VAR=0
    ENV_INFO_VAR=0
}

function reinit_selected_index( col     ,l) {
    # TODO: 10 reserve space
    VIEW_BODY_ROW_SIZE = max_row_size - 10
    if ( VIEW_BODY_ROW_SIZE > MAX_DATA_ROW_NUM )     VIEW_BODY_ROW_SIZE = MAX_DATA_ROW_NUM
    l = data[ col L ]
    if ( l == 0 ) return
    ctrl_win_init( data, col, 1, l, VIEW_BODY_ROW_SIZE)
}

function consume_ctrl(){
    if ($0 == "---") return
    if ($1 == "---") {
        input_level = $2
        data[ input_level L ] = ($3 == -1) ? -1 : 0

        ctrl_win_set(data, 1, input_level)
        _maxcollen[ input_level ] = 0
        input_state = INPUT_STATE_DATA
        return
    }

    if (try_update_width_height( $0 ) == true)  return
    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    view()
}

function consume_data(){
    if ($0 == "---") {
        data[ input_level S ] = _maxcollen[ input_level ]
        input_state = INPUT_STATE_CTRL
        ctrl_cal_colwinsize_by_focus( input_level )
        reinit_selected_index( input_level )
        view()
        return
    } else if ($1 == "---") {
        if ($2 == "env") {
            ENV_INFO_VAR = 1
            data_info_env[ input_level L l ] = substr($0, 9)
        } else {
            LS_INFO_VAR = 1
            split(substr($0, 8), data_info_arr, "\006")
            data_info_file_type[ input_level L l ]                  = data_info_arr[1]
            data_info_size[ input_level L l ]                       = data_info_arr[2]
            data_info_time_of_last_access[ input_level L l ]        = data_info_arr[3]
            data_info_time_of_last_modify[ input_level L l ]        = data_info_arr[4]
            data_info_time_of_last_change[ input_level L l ]        = data_info_arr[5]
            data_info_access_rights[ input_level L l ]              = data_info_arr[6]
            data_info_uid[ input_level L l ]                        = data_info_arr[7]
            data_info_gid[ input_level L l ]                        = data_info_arr[8]
        }
        return
    } else {
        if ($0 == "") return
        l = data[ input_level L ] + 1
        data[ input_level L ] = l
        if (l > MAX_DATA_ROW_NUM)   MAX_DATA_ROW_NUM = l
        # elem = str_trim($0)
        elem_len = wcswidth($0)
        if (_maxcollen[ input_level ] < elem_len)  _maxcollen[ input_level ] = elem_len
        data[ input_level L l ] = $0
    }
}

input_state==INPUT_STATE_DATA{
    consume_data()
}

input_state==INPUT_STATE_CTRL{
    consume_ctrl()
}
# EndSection

END {
    if ( exit_is_with_cmd() == true ) {
        for (i=1; i<=FOCUS_COL; i++) {
            _key_path = _key_path L data[ i L ctrl_win_val( data, i ) ]
        }
        send_env( "___X_CMD_UI_CATEGORYSELECT_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_UI_CATEGORYSELECT_CURRENT_ITEM",         _key_path )
    }
}

