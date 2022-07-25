
BEGIN{
    LOG_COLOR_INFO  = "\033[32;1m"
    LOG_COLOR_WARN  = "\033[33;1m"
    LOG_COLOR_ERROR = "\033[31;1m"
    LOG_COLOR_DEBUG = "\033[31;2m"
}

function log_info( mod, msg ){
    log_level( LOG_COLOR_INFO, "INF", mod, msg )
}

function log_warn( mod, msg ){
    log_level( LOG_COLOR_WARN, "WRN", mod, msg )
}

function log_error( mod, msg ){
    log_level( LOG_COLOR_ERROR, "ERR", mod, msg )
}

function log_debug( mod, msg ){
    log_level( LOG_COLOR_DEBUG, "DBG", mod, msg )
}

function log_level( color, level, mod, msg ){
    # printf("[%s] <%s> : %s", level, mod, msg) >"/dev/stderr"
    printf("%s[%s] <%s> :\033[0m %s\n", color, level, mod, msg) >"/dev/stderr"
}
