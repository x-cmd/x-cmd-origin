

```bash

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
    --repo: list_repo
    --repo2:
        - list_repo
        - list_repo
    #1: list_repo

types:
    repo_type: =~ [A-Za-z0-9]

defaults:
    scope: $O

options:
    --repo|-r:
        <repo-1>: 
            type: ""
            default: ""
        desc: Provide two repos

    --repo|-r:   <repo>:repo_type=""  "Provide repo name"

    --repo|-r:
        - <repo name 1>:repo_type=""   
        - "Provide repo name 2"

    --repo2|-r2:
        <repo-1>: 
            type: ""
            default: ""
        <repo-2>: 
            type: ""
            default: ""
        desc: Provide two repos

    --repo2|-r2:   <repo1>:repo_type=""  <repo2>:repo_type=""  "Provide repo name"

    --repo2|-r2:
        - <repo name 1>:repo_type=""
        - <repo name 2>:repo_type=""        
        - "Provide repo name 2"

subcommand:
    repo:   ""
    user:   ""

arguments:
    1:  <repo name>:repo_type=""    "Repo Name"
    n:  <repo name>:repo_type=""    "Repo Name"
A


    eval "$PARAM_SUBCMD"

}


```


```yaml
advises:
    --repo: list_repo
    --repo2:
       - list_repo1
       - list_repo2
    1: list_repo

types:
    repo_type: =~ [A-Za-z0-9]

defaults:
    scope: $O

options:
    --repo|-r:      <repo>:repo_type=""  "Provide repo name"
    --repo2|-r2:    <repo1>:repo_type=""  <repo2>:repo_type=""  "Provide repo name"

subcommand:
    repo:   ""
    user:   ""

arguments:
    1:  <repo name>:repo_type=""    "Repo Name"
    n:  <repo name>:repo_type=""    "Repo Name"
```

