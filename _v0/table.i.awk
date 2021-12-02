BEGIN {
    RS = "\002"
    KSEP = ","


    LEN = "len"
    # data 

    # col_max = 0
    col_num = 0

    if (HIGHROW != 0) {
        arr_len = split(HIGHROW, arr, ",")
        for (i=1; i<=arr_len; ++i) {
            highrow[ arr[i] ] = 1 
        }
    } 

    if (HIGHCOL != 0) {
        arr_len = split(HIGHCOL, arr, ",")
        for (i=1; i<=arr_len; ++i) {
            highcol[ arr[i] ] = 1
        }
    } 
}

# TODO: Provide raw data
# TODO: Provide all information to control to view, i j
# TODO: Printout the final column and final row

NR > 1{
    line_idx = NR - 1

    data[ LEN ] = line_idx
    
    # TODO: Problably have to deal with \n
    arr_len = split($0, arr, "\003")

    if (col_num < arr_len)  col_num = arr_len

    for (i=1; i<=arr_len; i+=1) {
        elem = arr[i]
        if (elem ~ /^B%/) {
            elem = substr(elem, 3)
            highlight[ line_idx KSEP i ] = 1
        }

        data[ line_idx KSEP i ] = elem
        arr_i_len = wcswidth( elem )

        datal[ line_idx KSEP i ] = arr_i_len
        if (col_max[i] < arr_i_len) col_max[i] = arr_i_len
    }

}

function fixout(size, str, _wcswidth){
    # printf("%-" size "s", str)
    # if (_wcswidth == 0)  _wcswidth = wcswidth(str)
    size = size - _wcswidth
    printf("%s", str sprintf("%" size "s", ""))
}

function printCell(i, j,  h,    _size){
    if (highlight[ i KSEP j ]) h = 1

    if (highrow[i] == 1)  h = 1
    if (highcol[j] == 1)  h = 1

    if (h == 1) printf("\033[7m")

    _size = col_max[j] - datal[i KSEP j]
    printf("%s", data[i KSEP j] sprintf("%" _size "s", ""))

    if ((h == 1) && (highrow[i] != 1)) printf("\033[0m")
    # printf("%s", sprintf("%s", ""))
}

function col_max_sum(   i, sum){
    sum = 0
    for (i=1; i<=col_num; ++i) {
        sum += col_max[i]
    }
    return sum
}

function style0(    i, j){
    printf "\033[4m"
    for (i=1; i<=data[LEN]; ++i) {
        for (j=1; j<=col_num; ++j) {
            # fixout(col_max[j] + 3, data[i KSEP j], datal[i KSEP j])
            printCell(i, j)
            printf("%s", "   ")
        }
        printf "\033[0m\n"
    }
}

function style1(    i, j){
    printf "\033[7m"
    for (i=1; i<=data[LEN]; ++i) {
        for (j=1; j<=col_num; ++j) {
            # fixout(col_max[j] + 3, data[i KSEP j], datal[i KSEP j])
            printCell(i, j)
            printf("%s", "   ")
        }

        printf "\033[0m"
        # if ( i == data[LEN]-1 ) {
        #     printf "\033[4m"
        # } else {
        #     printf "\033[0m"
        # }
        printf "\n"
    }
}



END{
    style0()
}


