
# depends on wcwidth and ui

function box_handle_text(text, array, _array_prefix) {
    # gsub(/\033\[([0-9]+;)*[0-9]+m/, "\n&", text)
    # array[ LEN ] = split(text, array, /\n/)
}

function box_split(text, array, _array_prefix,
    _tmp_arr ){
    # 1. find the pattern
    # 2. cut down the row

    gsub(/\033\[([0-9]+;)*[0-9]+m/, "\n&", text)
    _tmp_arr[ LEN ] = split(text, _tmp_arr, /\n/)

}

# array should be done.
function box_print(offset_row, offset_col, end_row, array, _array_prefix, _i, _row){
    for (_i = 1; _i <= offset_row; _i ++) {
        printf(array[ _array_prefix _i ])
        _row = offset_row + _i - 1
        ui_goto_cursor(_row, offset_col)
        if (end_row == _row) {
            break
        }
    }
}

function box_watch(){
    #
}



