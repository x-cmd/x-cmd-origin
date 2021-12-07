# shellcheck shell=sh disable=SC3043,SC2164

# author:       Li Junhao           l@x-cmd.com    edwinjhlee.github.io
# maintainer:   Li Junhao
# license:      GPLv3

# linux

xrc os

case "$(os name)" in
    darwin)
        ___x_cmd_fs_ls_cpu(){
            sysctl -a | grep machdep.cpu | awk -v FS=: '{ 
                gsub("machdep.cpu.", "", $1)
                if (NR % 5 == 0) {
                    printf("\033[34;1m\033[4m%-30s\t\t\033[32m%-50s\033[0m\n", $1, $2)
                } else {
                    printf("\033[34;1m%-30s\t\t\033[32m%-50s\033[0m\n", $1, $2)
                }
            }'
        }        

        ___x_cmd_fs_ls_mem(){
            memory_pressure
        }

        ___x_cmd_fs_ls_net(){
            memory_pressure
        }

        ;;
    *)
        ___x_cmd_fs_ls_cpu(){
            cat /proc/cpuinfo
        }

        ___x_cmd_fs_ls_mem(){
            free
        }

        ___x_cmd_fs_ls_net(){
            memory_pressure
        }
esac


___x_cmd_fs_ls_1(){
    if [ "$#" -eq 1 ]; then
        case "$1" in
            :*.zip)     ;;
            :cpu)       ___x_cmd_fs_ls_cpu && return 0;;
            :mem)       ___x_cmd_fs_ls_mem && return 0;;
        esac
    fi
    return 1
}

___x_cmd_ls(){
    ___x_cmd_fs_ls_1 "$@" || command ls "$@"
}
