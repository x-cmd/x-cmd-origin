BEGIN {
    false = 0
    FALSE = 0
    true = 1
    TRUE = 1
    S = "\001"
    T = "\002"
    L = "\003"
}

# Section: debug
function debug(msg){
    # print msg > "/dev/stderr"
	print "\033[31m" msg "\033[0m" > "/dev/stderr"
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
# EndSection

# Section: exit
BEGIN {
    EXIT_CODE = -1
}

function exit_now(code){
    EXIT_CODE = code    # You still need to check EXIT_CODE in end block
    exit code
}
# EndSection

# Section: exit
function var_quote1(str){
    # gsub("\\", "\\\\", str) # This is wrong in case: # print str_quote1("h'a\\\'")
    gsub(/\\/, "\\\\", str)
    gsub(/'/, "\\'", str)
    return "'" str "'"
}

function var_set(name, value){
    return sprintf("%s=%s", name, var_quote1(value))
}
# EndSection

