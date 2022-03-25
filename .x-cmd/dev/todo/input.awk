BEGIN{
    INPUT_STATE_STOP = 0
    INPUT_STATE_ONGOING = 1
    INPUT_STATE = 1 - INPUT_STATE_ONGOING

    INPUT_SECTION = 0
}

function input_consume( ){
    if (INPUT_STATE == INPUT_STATE_ONGOING) {
        if ($0 == "\003\003\003") {
            INPUT_STATE = INPUT_STATE_STOP
        }
        return ++state_idx
    }
    if ($0 == "\001\001\001") {
        state_idx = 0
        INPUT_STATE = INPUT_STATE_ONGOING
        return state_idx
    }
    return ""
}

function input_consume_multi( _tmp ){
    _tmp = input_consume()
    if (_tmp == "" )     return ""
    if ($0 == "\002\002\022") {
        INPUT_SECTION += 1
        state_idx = 0
        return state_idx
    }
    return _tmp
}
