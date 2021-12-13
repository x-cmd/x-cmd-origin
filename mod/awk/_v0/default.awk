BEGIN {
    LEN = "\001"
    L = LEN

    KSEP = "\034"
    S = KSEP

    T = "\002"

    false = 0
    FALSE = 0
    true = 1
    TRUE = 1
}

function debug(msg){
	print msg > "/dev/stderr"
}

# function debug(msg){
#     if (0 != DEBUG)     print msg > "/dev/stderr"
# }

function debug_file(msg, file){
    if (file == "") {
        file = "./awk.default.debug.log"
    }
    print msg > file
}

BEGIN {
    EXIT_CODE = -1
}

function exit_now(code){
    EXIT_CODE = code    # You still need to check EXIT_CODE in end block
    exit code
}


