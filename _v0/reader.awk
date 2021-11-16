
BEGIN {
    LEN = "length"
    option_list[ LEN ] = 0 
    option_selected = 1

    headline_no = 1
    article = ""
    width = 60
    column = 30
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

function painArticle(i, line, lineno){
    goto_cursor(1, 20)
    lineno=1
    newline=0
    for ( i=1; i<=article_line_list[LEN]; ++i ) {
        line = article_line_list[i]
        if (line ~ /^\033\[([0-9]+;)*[0-9]+m/) {
            newline=0
            printf( line )
        } else {
            if (newline==1) {
                printf("\n")
            }
            newline=1
            if (lineno < headline_no) continue
            printf(headline_no)
        }
    }
}

{
    update=
}