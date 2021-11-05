BEGIN{
    CURSOR_SAVE="\0337"
    CURSOR_RESTORE="\0338"
    
    CURSOR_SHOW="\033[34l"
    CURSOR_NORM="\033[34h\033[?25h"
    CURSOR_HIDE="\033[?25l"

    line_count = 0
    
    printf(CURSOR_SAVE)
    printf(CURSOR_HIDE)
}

function str_rep(char, number, _i, _s) {
    for (   _i=1; _i<=number; ++_i  ) _s = _s char
    return _s
}


function len_without_color(text){
    # gsub(/\033\[[0-9]+m/, "", text)
    gsub(/\033\[([0-9]+;)*[0-9]+m/, "", text)
    return length(text)
}

function cal_empty_line(line_count, width, 
    i, ret){

    ret = ""
    for (i=1; i<=line_count; i=i+1) {
        ret = ret str_rep(" ", width) "\n"
    }
    return ret
}

BEGIN{
    LAST_OUTPUT_LINE_COUNT = 0
    OUTPUT_LINE_COUNT = 0
}
function output(text, width, 
    line_arr, line_arr_len, return_text){
    
    return_text = ""

    line_arr_len = split(text, line_arr, "\n")
    OUTPUT_LINE_COUNT = 0
    for (i=1; i<=line_arr_len; i++) {
        line = line_arr[i]
        line_len = len_without_color(line)
        if (line_len == 0) {
            OUTPUT_LINE_COUNT = OUTPUT_LINE_COUNT + 1
            return_text = return_text str_rep(" ", width) "\n"
        } else {
            line_count = int(line_len / width)
            rest = line_len - (line_count * width)
            OUTPUT_LINE_COUNT = OUTPUT_LINE_COUNT + line_count
            if (rest > 0) OUTPUT_LINE_COUNT = OUTPUT_LINE_COUNT + 1
            return_text = return_text line str_rep(" ", width - rest) "\n"  # Fill with white space
        }
    }

    if (OUTPUT_LINE_COUNT < LAST_OUTPUT_LINE_COUNT) {
        return_text = return_text cal_empty_line(LAST_OUTPUT_LINE_COUNT - OUTPUT_LINE_COUNT, width)
    }

    return return_text
}

BEGIN {
    output_test = ""
    last_output_test = ""
}


function update(text, width){
    # printf(CURSOR_RESTORE)
    # printf(CURSOR_SAVE)
    # printf "\033[%sA"

    LAST_OUTPUT_LINE_COUNT = OUTPUT_LINE_COUNT

    last_output_test = output_text
    
    output_text = output(text, width)

    printf(CURSOR_RESTORE)
    # printf(CURSOR_SAVE)

    if (LAST_OUTPUT_LINE_COUNT < OUTPUT_LINE_COUNT) {
        # printf( "%s", 
        #     last_output_test cal_empty_line(OUTPUT_LINE_COUNT - LAST_OUTPUT_LINE_COUNT, width) )
        printf( "%s", str_rep("\n", OUTPUT_LINE_COUNT))
        printf("\033[" (OUTPUT_LINE_COUNT ) "A")
        printf(CURSOR_SAVE)
    }

    printf("%s", output_text)
    
}

BEGIN{
   LAST_WIDTH=0 
}

{
    if (op == "UPDATE") {
        op = ""
        gsub("\001", "\n", $0)
        LAST_WIDTH=op2
        update($0, op2)
    } else if ($1 == "UPDATE") {
        op = $1
        op2 = $2
    } else {   

    }

}

END {
    printf(CURSOR_RESTORE)
    printf( "%s", cal_empty_line(LAST_OUTPUT_LINE_COUNT, LAST_WIDTH))
    printf(CURSOR_RESTORE)

    printf(CURSOR_NORM)
}
