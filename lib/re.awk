
# [:alnum:]
# [:alpha:]
# [:space:]
# [:blank:]
# [:upper:]
# [:lower:]
# [:digit:] [0-9]
# [:xdigit:]
# [:punct:]
# [:cntrl:]
# [:graph:]
# [:print:]

# - to reprenset a ch in bracket must be the last ch

function re( p0, ch ){
    return "(" p0 ")" ch
}

BEGIN{
    RE_OR = "|"

    RE_SPACE = "[ \t\v\n]+"

    RE_NUMBER = "^[-+]?[0-9]+$"
    RE_NUM = "[-+]?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?"
    RE_REDUNDANT = "([ \t]*[\n]+)+"

    # RE_TRIM = re_or( "^" RE_SPACE, RE_SPACE "$" )
    RE_TRIM = "^" RE_SPACE RE_OR RE_SPACE "$"

    # RE_TRIM = re_or( "^[\n]+", "[\n]+$" )
}

BEGIN {
    RE_EMAIL = "[[:alnum:]_-]+@[[:alnum:]][A-Za-z0-9-]+.[[:alnum:]]+"    # Check this out ...
    RE_DIGIT = "[0-9]"      # [:digit:]
    RE_DIGITS = "[0-9]+"    # [:digit:]+

    RE_INT = "[+-]?([1-9][0-9]*)|0"
    RE_INT0 = "[+-]?[0-9]+"
    RE_FLOAT = RE_INT "(.[0-9]*)*"

    RE_UTF8_HAN = ""
    RE_UTF8_NON_ASCII = ""

    RE_033 = "\033\\[([0-9]+;)*[0-9]+m"

    RE_IP = ""

    RE_IP_A = ""
    RE_IP_B = ""
    RE_IP_C = ""
    RE_IP_D = ""
    RE_IP_E = ""

    RE_IP_SUBNET = ""
}

BEGIN{
    # /"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./
    # RE_STR2_ORGINAL = "\"[^\"\\\\\001-\037]*((\\\\[^u\001-\037]|\\\\u[0-9a-fA-F]{4})[^\"\\\\\001-\037]*)*\""

    RE_QUOTE_CONTROL_OR_UNICODE = re( "\\\\[^u\001-\037]" RE_OR "\\\\u[0-9a-fA-F]{4}" )

    RE_NOQUOTE1 = "[^'\\\\\001-\037]*"
    RE_STR1 = "'"  RE_NOQUOTE1 re( RE_QUOTE_CONTROL_OR_UNICODE RE_NOQUOTE1, "*")  "'"

    RE_NOQUOTE2 = "[^\"\\\\\001-\037]*"
    RE_STR2 = "\"" RE_NOQUOTE2 re( RE_QUOTE_CONTROL_OR_UNICODE RE_NOQUOTE2, "*" ) "\""

    # RE_STR0 = "[^ \\t\\v\\n]*" "((\\\\[ ])[^ \\t\\v\\n]*)*"
    RE_STR0 = "(\\\\[ ])*[^ \t\v\n]+"  "((\\\\[ ])[^ \t\v\n]*)*"
}

# awk 'BEGIN{ match("-b+cd", "[[:alnum:][:punct:]]*"); print RLENGTH " " RSTART; }'
