
# Section: handle expression

BEGIN {
    MAX_INT = 4294967295
}

# 1:2:3
function handle( astr, obj, idx,    arr, arrl ){
    arrl = split(astr, arr, ":")
    # print "astr: " idx "\t" astr "\t" arr[1] "\t" arr[2] "\t" arr[3]

    if (arrl == 1) {
        obj[ idx "S" ] = arr[1]
        obj[ idx "E" ] = arr[1] + 1
        obj[ idx "P" ] = 1
    } else {
        obj[ idx "S" ] = arr[1]
        obj[ idx "E" ] = (arr[2] == "") ? MAX_INT : arr[2]
        obj[ idx "P" ] = (arr[3] == "") ? 1 : arr[3]
    }
}

BEGIN{
    if ( ROW ~ "^-?$" ) {
        rowl = 1
        row[ rowl "S" ] = 1
        row[ rowl "E" ] = MAX_INT
        row[ rowl "P" ] = 1
    } else {
        rowl = split(ROW, row, ",")
        for (i=1; i<=rowl; ++i) {
            handle( row[i], row, i )
            if ( (row[i "E"] != "") && (row[i "E"] < 0) )  BUFFER_MODE = 1
        }
    }
}

BEGIN {
    if ( COL ~ "^-?$" ) {
        coll = 1
        col[ coll "S" ] = 1
        col[ coll "E" ] = MAX_INT
        col[ coll "P" ] = 1
    } else {
        coll = split(COL, col, ",")
        for (i=1; i<=coll; ++i)     handle( col[i], col, i )
    }
}

# EndSection

# Section: handle data

function foreachrow(        i, j, _first, _start, _end, _sep ){
    _add_comma = 0
    for (i=1; i<=coll; ++i) {
        _start   = col[ i "S" ]
        _end     = col[ i "E" ]
        _sep     = col[ i "P" ]
        if (_end < 0 ) _end = NF + _end + 1

        for (j=_start; j<_end && j<=NF; j+=_sep) {
            if (_add_comma == 0) {
                _add_comma=1;       printf("%s", $j)
            } else                  printf("\t%s", $j)
        }
    }
    printf("\n")
}

function foreachline( lineno ){
    for (i=1; i<=rowl; ++i) {
        row_start   = row[ i "S" ]
        row_end     = row[ i "E" ]
        row_sep     = row[ i "P" ]
        # print row_start ":\t" row_end "=\t" row_sep

        if ( (lineno < row_start) || (lineno >= row_end) )  continue
        if ( (row_sep != 1) &&  ( (lineno - row_start) % row_sep != 0 ) )   continue

        if (coll == 0)      print $0
        else                foreachrow( )
    }
}

{
    if (BUFFER_MODE == 1)   data[ NR ] = $0
    else                    foreachline( NR )
}

_end {
    for (i=1; i<=rowl; ++i) {
        row_end     = row[ i "E" ]
        if (row_end < 0)    row[ i "E" ] = row_end + NR + 1
    }

    for (j=1; j<=NR; ++j) {
        $0 = data[ j ]
        foreachline( j )
    }
}
# EndSection
