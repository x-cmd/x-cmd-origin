BEGIN {
    FG_BLACK = "\033[30m"
    FG_RED = "\033[31m"
    FG_GREEN = "\033[32m"
    FG_YELLOW = "\033[33m"
    FG_BLUE = "\033[34m"
    FG_MAGENTA = "\033[35m"
    FG_CYAN = "\033[36m"
    FG_WHITE = "\033[37m"

    BG_BLACK = "\033[40m"
    BG_RED = "\033[41m"
    BG_GREEN = "\033[42m"
    BG_YELLOW = "\033[43m"
    BG_BLUE = "\033[44m"
    BG_MAGENTA = "\033[45m"
    BG_CYAN = "\033[46m"
    BG_WHITE = "\033[47m"

    TEXT_BOLD = "\033[1m"
    TEXT_ITALIC = "\033[3m"
    TEXT_UNDERLINE = "\033[4m"
    TEXT_REV = "\033[7m"


    CURSOR_SAVE = "\0337"
    CURSOR_RESTORE = "\0338"

    CURSOR_NORMAL = "\033[34h\033[?25h"
    CURSOR_SHOW = "\033[34l"
    CURSOR_HIDE = "\033[?25l"

    SCREEN_SAVE = "\033[?1049h"
    SCREEN_RESTORE = "\033[?1049l"

    EL =  "\033[K"
    EL1 = "\033[1K"

    UI_END = "\033[0m"
}


function CURSOR_move_up(number){
    return "\033[" number "A"
}

function uitem(str){
    return str "\033[0m"
}

# BEGIN {
#     print uitem( TEXT_REV FG_RED "hi")
#     print uitem( TEXT_BOLD BG_WHITE FG_CYAN "hi")
# }
