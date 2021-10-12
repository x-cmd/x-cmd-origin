


```bash

param typedef repo-type =~ [A-Za-z0-9]+
param typedef user-type =~ [A-Za-z][A-Za-z0-9_]+

param new gitee.param # param make gitee; O=gitee param
# alias gitee.param="O=gitee param"


gitee.param default set "key" "value"
gitee.param default set "a" "b"

gitee.param typedef repo-type =~ [A-Za-z0-9]+


# param => cmd
# param.def

# gitee.param
# gitee.param

param new gitee.param

gitee.param_default set "scope" "key" "value"
gitee.param_default set "scope" "a" "b"

gitee.param_type repo-type =~ [A-Za-z0-9]+


create_repo(){

    # # lazy load
    # gitee.param_default lazy_load ".../.config" "~/.config" "/etc/config"

    # gitee.param_default use "$O"
    gitee.param <<A
advises:
    --repo      >
    --repo2     
        > list_repo
        > list_repo
    #1          >

types:
    repo_type =~ [A-Za-z0-9]

defaults:
    scope   gitee $O
    file    ".../.config" "~/.config" "/etc/config"

options:
    --repo|-r   <repo name>=""                  "Provide repo name"
    --repo|-r   <repo name>:repo_type=""        "Provide repo name"
    --repo2|-r
        <repo name 1>:repo_type=""        
        <repo name 2>:repo_type=""        "Provide repo name 2"

subcommand:
    repo

arguments:
    #1      <repo name>=""          "Repo Name"
    #n      <repo name>=""          "Repo Name"
A


    eval "$PARAM_SUBCMD"

}


```



```bash
param typedef repo-type =~ [A-Za-z0-9]+
param typedef user-type =~ [A-Za-z][A-Za-z0-9_]+


# param_default github
param_typedef repo_type =~ [A-Za-z0-9]+

param create_repo github <<A
--repo|-r   <repo name>=""       "Provide repo name"
--repo|-r   <repo name>:create_repo_repo_type=""       "Provide repo name"
A

create_repo(){

    

}


```

