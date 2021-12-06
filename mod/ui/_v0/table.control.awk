

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
    
    cur_col = 0
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

function update_view_print_cell(row_i, col_i,       h, _size){
    cord = row_i KSEP col_i

    if (cur_col == col_i) h = 1

    if (highlight[ cord ]) h = 1

    if (h == 1) buffer_append( UI_TEXT_REV )

    if (row_i == cur_row) {
        buffer_append( sprintf("%s", UI_TEXT_REV) )
    }

    buffer_append( sprintf( "%s", str_pad_right( data[ cord ], col_max[ col_i ], data_wlen[ cord ] ) ) )

    # if ((h == 1) && (highrow[ row_i ] != 1)) printf( UI_END )

    if ((h == 1) && ( row_i != cur_row )) buffer_append( sprintf( UI_END ) )
}

BEGIN{
    NEWLINE = "\001"
    counter = 1
}

function update_view(           row_i, col_i, start_row){
    start_row = int( (cur_row - 2) / max_row_in_page) * max_row_in_page + 2

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
            update_view_print_cell( row_i, col_i )
            buffer_append( sprintf( "%s", "  " ) )
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

    gsub(/^[ \t\n\b\v\002]+/, "", text)
    gsub(/[ \t\b\n\v\002]+$/, "", text)

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
}

# Section: handle the view

NR>1 {
    command = $1
    command = str_trim( command )

    if (command == "UP") {
        cur_row = cur_row - 1
        if (cur_row <= 1) cur_row = table_row
    } else if (command == "DN") {
        if (cur_row <= 1) {
            cur_row = 2
        } else {
            cur_row = cur_row + 1
            if (cur_row > table_row) cur_row = 2
        }
    } else if (command == "LEFT" ) {
        debug_file("RECV" command)
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

    } else if (command == "NEXT-PAGE") {
        
    } else if (command == "VIEW") {
        max_row_size = $2
        max_col_size = $3
        max_row_in_page = max_row_size - 10
        # TIDO: if row less than 10 rows, we should exit.
        update_view()
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
    } else {
        # debug_file("CMD-exit: " command " " $0)
        # exit(0)
    } 
}

END {
    send_msg( "RESULT", last_command " " cur_row " " cur_col " " lines[cur_row])
}

# EndSection
