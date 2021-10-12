# shellcheck shell=sh disable=SC2039,SC2142,SC3043
# xrc param/v0
. ./v0

########

# PARAM_ARGS=$li
# $@

# gitee.repo.create -a public a1 a2 a3

w(){
    echo "-------"
    param_default get "gitee_$O" repo
    echo "-------"

    param <<A
    default     gitee___$O
    --repo      "Provide repo name"             =~      [一-龥a-zA-Z0-9]+
    --user=el   -u  "Provide user name"         =~      [A-Za-z0-9]+
    --access    -a  "Access Priviledge"         =       public private
    --verbose   -v  "Display in verbose mode"   =FLAG
    #1          "test#"                         =~      [A-Za-z0-9\n]+
    ...         "test..."                       =~      [A-Za-z0-9\n]+
A

    param_example \
        "list all members, using argument" \
        "gt_repo_member_list x-bash/std" \
        "list all members, using naming argument" \
        "gt_repo_member_list --repo x-bash/std"

    echo "----"
    local verbose=${verbose:-false}

    echo "repo: $repo"
    echo "user: $user"
    echo "access: $access"
    echo "verbose: $verbose"

    echo "Other arguments:  $*"
    echo "First argument:   $1"
    echo "help doc : $HELP_DOC"
    echo "param example : $PARAM_EXAMPLE "
}

param_default clear gitee___c
param_default put   gitee___c repo xk1
# O=c w -a private hi

# w --repo hi

ff(){
    O=OBJECT_NAME w -a private --user "7777" work a b 
}

ff
