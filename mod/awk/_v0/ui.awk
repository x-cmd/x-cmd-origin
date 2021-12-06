BEGIN {
    UI_FG_BLACK = "\033[30m"
    UI_FG_RED = "\033[31m"
    UI_FG_GREEN = "\033[32m"
    UI_FG_YUI_ELLOW = "\033[33m"
    UI_FG_BLUE = "\033[34m"
    UI_FG_MAGENTA = "\033[35m"
    UI_FG_CYAN = "\033[36m"
    UI_FG_WHITE = "\033[37m"

    UI_BG_BLACK = "\033[40m"
    UI_BG_RED = "\033[41m"
    UI_BG_GREEN = "\033[42m"
    UI_BG_YUI_ELLOW = "\033[43m"
    UI_BG_BLUE = "\033[44m"
    UI_BG_MAGENTA = "\033[45m"
    UI_BG_CYAN = "\033[46m"
    UI_BG_WHITE = "\033[47m"

    UI_TEXT_BOLD = "\033[1m"
    UI_TEXT_ITALIC = "\033[3m"
    UI_TEXT_UNDERLINE = "\033[4m"
    UI_TEXT_REV = "\033[7m"


    UI_CURSOR_SAVE = "\0337"
    UI_CURSOR_RESTORE = "\0338"

    UI_CURSOR_NORMAL = "\033[34h\033[?25h"
    UI_CURSOR_SHOW = "\033[34l"
    UI_CURSOR_HIDE = "\033[?25l"

    UI_SCREEN_SAVE = "\033[?1049h"
    UI_SCREEN_RESTORE = "\033[?1049l"

    UI_EL =  "\033[K"
    UI_EL1 = "\033[1K"

    UI_END = "\033[0m"
}


function UI_CURSOR_move_up(number){
    return "\033[" number "A"
}

function uitem(str){
    return str "\033[0m"
}

# BEGIN {
#     print uitem( UI_TEXT_REV UI_FG_RED "hi")
#     print uitem( UI_TEXT_BOLD UI_BG_WHITE UI_FG_CYAN "hi")
# }