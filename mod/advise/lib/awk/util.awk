# Section: utils
BEGIN{
    false = 0
    true = 1

    EXIT_CODE = 0
}

function panic(msg){
    print "_message_str='\033[33;1m[PANIC]: " msg "'\033[0m"
    EXIT_CODE = 1
    exit(1)
}

function assert(condition, msg){
    if (condition == 1) {
        panic(msg)
    }
}

## EndSection