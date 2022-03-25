

```bash

# Ideal design

xman example gitee -- \
    "List all repos" \
    "gitee repos list"

xman gitee
=> xman exmaple gitee
=> gitee --help

# gitee xman

gitee(){
    param_default gitee $O
    param <<A
SYMPOSIS:
    <:cmd> [--options]
    <:cmd> [subcommand]
    <:cmd> [--options] [subcommand]

OPTIONS:
    --help|-h <section name>        "Provide repo name"
    --debug|-D                      "Open DEBUG"
    -c <config file>                ""

SUBCOMMANDS:
    repo    "repo command"
    user    "user command"

ARGS:
    #1 <repo name>      "repo name"
    #2 <work name>      "work name"
    #n <n name>         "user name"
A

    if [ $debug ]; then
        :
    fi

    eval "$PARAN_SUBCMD_CODE"
}

```

```bash

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

    --repo2|-r2:
        <repo-1>: 
            type: ""
            default: ""
        <repo-2>: 
            type: ""
            default: ""
        desc: Provide two repos

    # 更倾向于下面两种
    --repo|-r:   <repo>:repo_type=""  "Provide repo name"

    --repo|-r:
        - <repo name 1>:repo_type=""   
        - "Provide repo name 2"

    --repo2|-r2:   <repo1>:repo_type=""  <repo2>:repo_type=""  "Provide repo name"

    --repo2|-r2:
        - <repo name 1>:repo_type=""        
        - <repo name 2>:repo_type=""        
        - "Provide repo name 2"

subcommand:
    repo:   ""
    user:   ""

arguments:
    #1      <repo name>=""          "Repo Name"
    #n      <repo name>=""          "Repo Name"

param_gen gitee_repo_create gitee $O <<A
OPTIONS:
    --help|-h <section name>                 "Provide repo name"
        =~  [A-Za-z0-9]
    --debug|-D                        "Open DEBUG"  =FLAG
    --repo|-r       ""              :repo-type              "repo name"
    --user|-u                       :user-type              "user name"
    --volume|-v|m                   :volume-type            "volume name"
"
A



param_gen gitee_repo_create gitee $O <<A
OPTIONS:
    --debug|-D  "Open DEBUG"
    
    --help|-h   <session name>=[default value]  =~ [A-Za-z0-9]
                        "Provide repo name"     
    --help|-h   <session name>=[default value]  :session-type
                        "Provide repo name"
    --help|-h   <session name>  :session-type
                        "Provide repo name"
    --help|-h   <session name> :session-type
    --help|-h           :session-type
    


    --help|-h  :session-type
    --help|-h  :session-type=[default value]                    "Defined description"
    --help|-h  <manual section>:session-type=[default value]    "Defined description"
    --help|-h  <manual section>=[default value]

    --help|-h  <session name>:session-type=[default value]      "Provide repo name"

    --help|-h  :session-type=[default value]
    
    --help|-h  <session name>:session-type=[default value]      "Provide repo name"
    --help|-h  <session name>=[default value]  =~ [A-Za-z0-9]
                        "Provide repo name"

    --help|-h  <session name> :session-type
    
    --pair|-p
        <session name 1>=[default value]  =~ [A-Za-z0-9]
        <session name 2>=[default value]  =~ [A-Za-z0-9]
        "Pair information"

    --pair|-p           "Pair information"
        <session name 1>=[default value]  :session-type

    --repo|-r    
        <repo name>=[default value]     =~ ""
        "Provide repo name"
    --repo|-r       "" 
        <repo name>:repo-type
        "repo name"  
"
A



gitee_repo_create_param(){

}

```
