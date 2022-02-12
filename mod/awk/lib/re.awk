
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

# - to reprenset a char in bracket must be the last char

BEGIN {
    RE_EMAIL = "[[:alnum:]_-]+@[[:alnum:]][A-Za-z0-9-]+.[[:alnum:]]+"    # Check this out ...
    RE_DIGIT = "[0-9]"      # [:digit:]
    RE_DIGITS = "[0-9]+"    # [:digit:]+

    RE_INT = "[+-]?([1-9][0-9]*)|0"
    RE_INT0 = "[+-]?[0-9]+"
    RE_FLOAT = RE_INT "(.[0-9]*)*"

    RE_UTF8_HAN = ""
    RE_UTF8_NON_ASCII = ""

    RE_033 = "\033\[([0-9]+;)*[0-9]+m"

    RE_IP = ""

    RE_IP_A = ""
    RE_IP_B = ""
    RE_IP_C = ""
    RE_IP_D = ""
    RE_IP_E = ""

    RE_IP_SUBNET = ""
}

# awk 'BEGIN{ match("-b+cd", "[[:alnum:][:punct:]]*"); print RLENGTH " " RSTART; }'

function re(){

}

