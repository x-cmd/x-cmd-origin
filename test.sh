g(){
    echo hi >/dev/null
}

# ___x_cmd_log init abc

f(){
    for i in `seq 1000`; do
        # ___x_cmd_log :http debug hello
        # ___x_cmd_log_logger_func http debug hello
        # g
        # abc:debug hi 2>/dev/stderr
        echo hi >&2
        # eval [ $i -gt 1000 ]
        # eval "[ 0 -ge \"\${___X_CMD_LOG_LEVEL_OF_LOGGER_${O}:-1}\" ]"
    done
}

time f