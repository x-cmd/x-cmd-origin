

BEGIN {
    
}

# Section: Global data
BEGIN {

    KSEP = "\001"

    if (available_row == "") {
        available_row = 10
    }

    max_row_in_page = available_row

    start_row = 1
    
    cur_col = 1
    cur_row = 0

    table_col = 0

    max_col_size = -1
    max_row_size = -1

    # data
    # data_wlen
    # data_highlight
    # col_max
}
# EndSection

# Section

BEGIN {
    BUFFER = ""
}

function bufferln(data){
    if (BUFFER == "") BUFFER = data
    else BUFFER = BUFFER "\n" data
}

function buffer_append(data){
    BUFFER = BUFFER data
}

function buffer_clear(          buf){
    buf = BUFFER
    BUFFER = ""
    return buf
}

function update_view_print_cell(logic_row_i, row_i, col_i,       h, _size){
    cord = row_i KSEP col_i

    if (cur_col == col_i) h = 1

    # if (highlight[ cord ]) h = 1

    if (h == 1) buffer_append( sprintf("%s",UI_TEXT_BOLD UI_FG_BLUE UI_TEXT_REV ) )

    if (logic_row_i == cur_row) {
        buffer_append( sprintf("%s", UI_FG_GREEN UI_TEXT_REV) )
    }
    buffer_append( sprintf( "%s", str_pad_right( data[ cord ], col_max[ col_i ], data_wlen[ cord ] ) ) )
    buffer_append( sprintf( "%s", "  " ) )

    # if ((h == 1) && (highrow[ row_i ] != 1)) printf( UI_END )

    if ((h == 1) && ( logic_row_i != cur_row )) buffer_append( sprintf( UI_END ) )
    buffer_append( sprintf( UI_END ) )
}

BEGIN{
    NEWLINE = "\001"
    counter = 1
}

function update_view(           row_i, col_i, start_row){
    start_row = int( (cur_row - 2) / max_row_in_page) * max_row_in_page + 2

    buffer_append( sprintf("FILTER: %s" NEWLINE, filter[cur_col]) )

    buffer_append( sprintf("%s %s %s" NEWLINE, counter++, cur_row, cur_col) )
    buffer_append( sprintf("%s     ", UI_TEXT_UNDERLINE UI_TEXT_BOLD) )
    for (col_i=1; col_i<=table_col; col_i++) {
        # update_view_print_cell( 1, col_i )
        buffer_append( sprintf( "%s  ", str_pad_right( data[ 1 KSEP col_i ], col_max[ col_i ], data_wlen[ 1 KSEP col_i ] ) ) )
    }
    buffer_append( sprintf("%s", UI_END) )
    buffer_append( sprintf( NEWLINE ) )

    for (row_i = start_row; row_i <= start_row + max_row_in_page; row_i ++) {
        if (row_i > table_row) break
        buffer_append( sprintf("%s", str_pad_right(row_i-1, 5)) )
        for (col_i=1; col_i<=table_col; col_i++) {
            update_view_print_cell( row_i, row_i, col_i )
            buffer_append( sprintf( "%s", "  " ) )
        }
        buffer_append( sprintf("%s" NEWLINE, UI_END) )
    }
    # printf( NEWLINE )

    send_msg_update( buffer_clear() )
    BUFFER = ""
}

# EndSection

# Section: logical table

function update_logical_table(  _cord, _elem, row_i, col_i){
    logic_table[1] = 1
    logic_table_row = 1
    for (row_i = 2; row_i <= table_row; row_i++) {
        _ok = true
        for (col_i = 1; col_i <= table_col; col_i++) {
            _cord = row_i KSEP col_i
            _elem = data[ _cord ]
            _filter = filter[ col_i ]
            if (_filter == "") continue
            if (index(_elem, _filter) < 1) {
                _ok = false
                break
            }
        }
        if ( _ok == true ) {
            logic_table_row = logic_table_row + 1
            logic_table[ logic_table_row ] = row_i
        }
    }
    cur_row = 2
}

function update_logic_view(           logic_row_i, row_i, col_i, start_row){
    start_row = int( (cur_row - 2) / max_row_in_page) * max_row_in_page + 2
    
    buffer_append( sprintf("FILTER: %s" NEWLINE, filter[cur_col]) )
    
    # buffer_append( sprintf("%s %s %s" NEWLINE, counter++, cur_row, cur_col) )
    buffer_append( sprintf("%s     ", UI_TEXT_UNDERLINE UI_TEXT_BOLD) )
    for (col_i=1; col_i<=table_col; col_i++) {
        buffer_append( sprintf( "%s  ", str_pad_right( data[ 1 KSEP col_i ], col_max[ col_i ], data_wlen[ 1 KSEP col_i ] ) ) )
    }
    buffer_append( sprintf("%s", UI_END) )
    buffer_append( sprintf( NEWLINE ) )

    for (logic_row_i = start_row; logic_row_i <= start_row + max_row_in_page; logic_row_i ++) {
        if (logic_row_i > logic_table_row) break
        row_i = logic_table[ logic_row_i ]
        buffer_append( sprintf("%s", str_pad_right(row_i-1, 5)) )
        for (col_i=1; col_i<=table_col; col_i++) {
            update_view_print_cell( logic_row_i, row_i, col_i )
            # buffer_append( sprintf( "%s", "  " ) )
        }
        buffer_append( sprintf("%s" NEWLINE, UI_END) )
    }
    # printf( NEWLINE )

    send_msg_update( buffer_clear() )
    BUFFER = ""
}


# EndSection

function parse_data(text, 
    row_i, col_i,
    elem, elem_wlen){
    gsub(/^[ \t\n\b\v\002\001]+/, "", text)
    gsub(/[ \t\b\n\v\002\001]+$/, "", text)

    table_row = split(text, lines, "\002")
    
    for (row_i = 1; row_i <= table_row; row_i ++) {
        line = lines[row_i]   # Skip the first line
        arr_len = split(line, arr, "\003")
        if (table_col < arr_len) table_col = arr_len

        for (col_i=1; col_i<=arr_len; col_i++) {
            elem = arr[col_i]
            elem = str_trim(elem)

            if (elem ~ /^B%/) {
                elem = substr(elem, 3)
                data_highlight[ row_i KSEP col_i ] = 1
            }

            data[ row_i KSEP col_i ] = elem
            elem_wlen = wcswidth( elem )
            data_wlen [ row_i KSEP col_i ] = elem_wlen

            if (col_max[ col_i ] == "") col_max[ col_i ] = elem_wlen
            if (col_max[ col_i ] < elem_wlen) col_max[ col_i ] = elem_wlen
        }
    }

    update_logical_table()
}

function send_msg(channel, msg){
    # gsub("\n", "\001", msg)
    print(channel)
    print(msg)
    fflush()
}

function send_msg_update(msg){
    # gsub("\n", "\001", msg)
    print("UPDATE " max_col_size)
    print(msg)
    fflush()
}

# Section: Get data
NR==1 {
    parse_data($0)
    # update_view()
}

# EndSection


BEGIN {
    last_command = ""
    filter_edit_state = false

    # filter
}

# Section: handle the view

NR>1 {
    command = $1
    command = str_trim( command )

    if (command == "VIEW") {
        max_row_size = $2
        max_col_size = $3
        max_row_in_page = max_row_size - 10
        # TIDO: if row less than 10 rows, we should exit.
        update_logic_view()
    } else if (filter_edit_state == true) {

        if (command == "FILTER_EDIT_END") {
            filter_edit_state = false
            update_logical_table()
        } else if (command == "INPUT") {
            type = $2
            char = $3
            if (type == "ascii-delete") {
                cur_filter = filter[ cur_col ]
                filter[ cur_col ] = substr(cur_filter, 1, length(cur_filter) - 1)
                # trigger filter: invocation cost much...
            } else {
                cur_filter = filter[ cur_col ]
                filter[ cur_col ] = cur_filter char
            }
        } else {

        }

    } else {

        if (command == "UP") {
            cur_row = cur_row - 1
            if (cur_row <= 1) cur_row = logic_table_row
        } else if (command == "DN") {
            if (cur_row <= 1) {
                cur_row = 2
            } else {
                cur_row = cur_row + 1
                if (cur_row > logic_table_row) cur_row = 2
            }
        } else if (command == "LEFT" ) {
            # debug_file("RECV" command)
            cur_col = cur_col - 1
            if (cur_col <= 0) cur_col = table_col
        } else if (command == "RIGHT") {
            if (cur_col <= 0) {
                cur_col = 1
            } else {
                cur_col = cur_col + 1
                if (cur_col > table_col) cur_col = 1
            }
        } else if (command == "PREV-PAGE") {
            cur_row = cur_row + max_row_in_page
            cur_row = ((cur_row - 2) % logic_table_row + 2)
        } else if (command == "NEXT-PAGE") {
            cur_row = cur_row - max_row_in_page
            cur_row = ((cur_row - 2) % logic_table_row + 2)
            cur_row = ((cur_row + logic_table_row - 2) % logic_table_row +2 )
        } else if (command == "CREATE") {
            last_command = command
        } else if (command == "REFRESH") {
            last_command = command
        } else if (command == "UPDATE") {
            last_command = command
        } else if (command == "DELETE") {
            last_command = command
        } else if (command == "ENTER") {
            last_command = command
        } else if (command == "FILTER_EDIT_BEGIN") {
            filter_edit_state = true
        } else {
            # debug_file("CMD-exit: " command " " $0)
            # exit(0)
        } 
    }
}

END {
    send_msg( "RESULT", last_command " " cur_row " " cur_col " " lines[cur_row])
}

# EndSection
