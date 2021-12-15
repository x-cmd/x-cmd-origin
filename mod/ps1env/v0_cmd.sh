# shellcheck shell=sh

xrc param/v0

. ./v0

cmd(){
    param:dsl <<A
subcommand:
    sub1        "s"
    sub2        "s2"
    sub3        "s3"
A
    param:run

    echo "subcomand: $PARAM_SUBCMD"
}

cmd_ps1env(){
    ps1env init "cmd1"
    ps1env alias ",sub1" "cmd sub1"
    ps1env alias ",sub2" "cmd sub2"
    ps1env alias ",sub3" "cmd sub3"
}
