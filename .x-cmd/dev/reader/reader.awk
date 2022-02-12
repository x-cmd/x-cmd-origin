
BEGIN {
    LEN = "length"
    option_list[ LEN ] = 0 
    option_selected = 1

    headline_no = 1
    article = ""
    width = 60
    column = 30

    TRUE = 1
    FALSE = 0
}

BEGIN{
    CURSOR_SAVE="\0337"
    CURSOR_RESTORE="\0338"
    
    CURSOR_SHOW="\033[34l"
    CURSOR_NORM="\033[34h\033[?25h"
    CURSOR_HIDE="\033[?25l"

    SCREEN_SAVE="\033[?1049h"
    SCREEN_RESTORE="\033[?1049l"

    line_count = 0
    
    printf(CURSOR_SAVE)
    printf(CURSOR_HIDE)
}

function ___ui_resotre_newline(article){
    gsub("\001", "\n", article)
}

function goto_cursor(row, column){
    printf "\033[" row ";" column "dh"
}

function goto_cursor0(){
    printf "\033[1;1dh"
}

function transform(article){
    gsub(/\033\[([0-9]+;)*[0-9]+m/, "\n&", article)
    article_line_list[ LEN ] = split(article, article_line_list, /\n/)
}


function paintAll(){
    
}

function paintOption(){
    goto_cursor0()

    len = option_list[ LEN ]
    for (i=1; i<=len; ++i) {
        if (i == option_selected) {
            printf "\033[7m%s\033[0m\n" option_list[i]
        } else {
            printf "\033[0;41m%s\033[0m\n" option_list[i]
        }
    }
}

BEGIN{
    article_starting_col = 20
    article_starting_row = 1

    article_ending_col = 60
    article_ending_row = 60

    article_line_len = article_ending_row - article_starting_row + 1
}

function newrow(next_row, col){
    if (next_row > column) return FALSE
    goto_cursor(new_row, col)
    return TRUE
}

function painArticle(i, line, lineno, width){
    goto_cursor(article_starting_row, article_starting_col)
    lineno=1
    alr_len = 0
    for ( i=1; i<=article_line_list[LEN]; ++i ) {
        line = article_line_list[i]
        match(line,  /^\033\[([0-9]+;)*[0-9]+m/)
        if (RLENGTH > 0) {
            if (lineno < headline_no) {
                printf( substr(line, 1, RLENGTH) )
                continue
            }
        } else {
            lineno = lineno + 1
            if (lineno < headline_no) continue
            if ( FALSE == newrow(lineno - headeline_no + article_starting_row, article_starting_col) ) break 
            alr_len = 0
        }

        while (alr_len + length(line) > article_line_len) {
            printf("%s", substr(line, 1, width - rest))

            if ( FALSE == newrow(lineno - headeline_no + article_starting_row, article_starting_col) ) break
            alr_len = 0

            line = substr(line, article_line_len - alr_len + 1)
        }
        
        if (alr_len + length(line) > 0) {
            printf("%s", line)
            alr_len = alr_len + length(line)
        }
    }
}

{
    # update=
}