BEGIN {
    LEN = "\001"

    KSEP = "\034"

    false = 0
    FALSE = 0
    true = 1
    TRUE = 1
}

# function debug(msg){
# 	print msg > "/dev/stderr"
# }

function debug(msg){
    if (0 != DEBUG)     print msg > "/dev/stderr"
}

BEGIN {
    EXIT_CODE = -1
}

function exit_now(code){
    EXIT_CODE = code    # You still need to check EXIT_CODE in end block
    exit code
}


