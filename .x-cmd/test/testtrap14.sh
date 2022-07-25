g(){
    trap ' echo interrupt-1>>final.txt' INT
    (
        while read -n 1 ___X_CMD_UI_GETCHAR_CHAR; do
            echo hi >>aa.txt
        done
        # echo "444" >a.txt
    )
}

# s="$( g )"

g

# f()(
#     t="$(g)"
# )

# f

# f()(
#     # stty -echo
#     # trap 'echo f-outer >>final.txt; stty echo' INT
#     # trap ' ' INT
#     t="$(g)"
# )

# f¡

# (
#     f
# )

