

COLP() {
    tput setaf "$1"
    shift
    echo -ne "$@"
    tput sgr0
}

COLBP() {
    tput setaf "$1"
    tput bold
    shift
    echo -ne "$@"
    tput sgr0
}

ERROR() { COLBP 1 "$@"; }
WARN() { COLBP 3 "$@"; }
INFO() { COLBP 2 "$@"; }
FINE() { COLBP 4 "$@"; }

@log() { COLBP 4 "$@"; }
@warn() { COLBP 3 "$@"; }
@err() { COLBP 1 "$@"; }
# @info() { COLBP 2 "$@"; }

@echop() {
    [ '' != "$FG" ] && tput setaf "$FG"
    [ '' != "$BG" ] && tput setab "$BG"
    tput bold
    echo "$@"
    tput sgr0
}

# ui
{
    export UI_BLACK=0
    export UI_RED=1
    export UI_GREEN=2
    export UI_YELLOW=3
    export UI_BLUE=4
    export UI_MAGNETA=5
    export UI_CYAN=6
    export UI_BLACK=7
}

# shellcheck disable=SC2155
{
    export UI_BG_BLUE="$(tput setab 4)"
    export UI_BG_BLACK="$(tput setab 0)"
    export UI_FG_GREEN="$(tput setaf 2)"
    export UI_FG_WHITE="$(tput setaf 7)"
}

# Special characters
# https://unix.stackexchange.com/questions/343934/print-check-cross-mark-in-shell-script



ui_color(){
  #  https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
  :
}
