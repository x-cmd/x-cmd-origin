
function control(){

}

BEGIN {
    
}

# Section: Global data
BEGIN {

    if (available_row == "") {
        available_row = 10
    }

    max_row_in_page = available_row

    start_row = 1
    
    cur_col = 0
    cur_row = 0

    col = -1
    row = -1

    # data
    # data_wlen
    # data_highlight
    # col_max
}
# EndSection

# Section

function update_view_print_cell(row_i, col_i,       h, _size){
    cord = row_i KSEP col_i

    if (highlight[ cord ]) h = 1

    if (highrow[i] == 1)  h = 1
    if (highcol[j] == 1)  h = 1

    if (h == 1) printf( TEXT_REV )

    printf("%s", str_pad_right(data[ cord ], col_max[j], data_wlen[ cord ]))
    # _size = col_max[j] - data_wlen[ cord ]
    # printf("%s", data[ cord ] sprintf("%" _size "s", ""))

    if ((h == 1) && (highrow[i] != 1)) printf( UI_END )
}

function update_view(row_i){
    start_row = int( (cur_row - 2) / max_row_in_page) * max_row_in_page + 2

    printf("%s", TEXT_UNDERLINE)
    for (col_i=1; col_i<=col; col_i++) {
        update_view_print_cell( 1, col_i )
        printf("%s", "  ")
    }
    printf("\n")

    for (row_i = start_row; row_i <= start_row + max_row_in_page; row_i ++) {
        for (col_i=1; col_i<=col; col_i++) {
            update_view_print_cell( row_i, col_i )
            printf("%s", "  ")
        }
        printf("%s\n", UI_END)
    }
}

# EndSection

function parse_data(text, 
    row_i, col_i,
    elem, elem_wlen){

    row = split(text, lines, "\002")

    for (row_i = 1; row_i < row; row_i ++) {
        line = lines[row_i]
        arr_len = split(line, arr, "\003")
        if (col < arr_len) col = arr_len

        for (col_i=1; col_i<=arr_len; col_i++) {
            elem = arr[i]
            if (elem ~ /^B%/) {
                elem = substr(elem, 3)
                data_highlight[ row_i KSEP col_i ] = 1
            }

            data[ row_i KSEP col_i ] = elem

            elem_wlen = wcswidth( elem )
            data_wlen [ row_i KSEP col_i ] = elem_wlen
            if (col_max[ col_i ] < elem_wlen) col_max[ col_i ] = col_max[ col_i ] = elem_wlen
        }
    }
}



# Section: Get data
NR==1 {
    parse_data($0)
    update_view()
}

# EndSection


# Section: handle the view

NR>1 {
    command = $1

    if (
        (command == "CREATE") || (command == "UPDATE") || (command == "REFRESH") || (command == "ENTER")
    ) {
        print(cur_col, cur_row)
        exit(0)
    } else if (command == "UP") {
        cur_row = cur_row - 1
        if (cur_row <= 0) cur_row = row
    } else if (command == "DN") {
        if (cur_row <= 0) cur_row = 1
        cur_row = cur_row + 1
        if (cur_row > row) cur_row = 1
    } else if (command == "LFET" ) {
        cur_col = cur_col - 1
        if (cur_col <= 0) cur_col = col
    } else if (command == "RIGHT") {
        if (cur_col <= 0) cur_col = 1
        cur_col = cur_col + 1
        if (cur_col > col) cur_col = 1
    } else if (command == "PREV-PAGE") {

    } else if (command == "NEXT-PAGE") {
        
    } else if (command == "VIEW") {
        
    } else {
        return
    }

    update_view()
}

# EndSection
