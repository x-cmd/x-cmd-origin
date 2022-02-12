

xrc awk



# awk -v data='abc
# ' 'END { print data; }' <<< ""

SSS="$(cat default.awk)$(cat json.awk jiparse.awk)"


f(){
awk -v RS="\t" "$SSS"'

{
    # debug(\$0)
    data = $0
}

END{
    json_parse(data, arr)
    print "---:\t|" jpath( "1.2.ssh_url" ) "|"
    print "---\t" arr[jpath( "1.2.ssh_url" )]
    print "---:\t|" length(jpath( "1.2.ssh_url" )) "|"
    print "---:\t|" arr[ jpath( "1.2.ssh_url" ) ]
    print "---:\t" jget(arr, "1.2.ssh_url")
}

' <<A
[
    {
        "id": 9901486,
        "full_name": "x-bash/cloud",
        "human_name": "x-bash/cloud",
        "url": "https://gitee.com/api/v5/repos/x-bash/cloud",
        "namespace": {
            "id": 6191490,
            "type": "group",
            "name": "x-bash",
            "path": "x-bash",
            "html_url": "https://gitee.com/x-bash"
        },
        "path": "cloud",
        "name": "cloud",
        "owner": {
            "id": 5625049,
            "login": "edwinjhlee",
            "type": "User"
        },
        "description": "用于公有云基础设施管理的命令封装库, tccli, aliyun, aws, sae, google-cloud",
        "private": false,
        "public": true,
        "internal": false,
        "assignees": [],
        "testers": []
    },
    {
        "id": 9901471,
        "full_name": "x-bash/cmd",
        "human_name": "x-bash/cmd",
        "url": "https://gitee.com/api/v5/repos/x-bash/cmd",
        "namespace": {
            "id": 6191490,
            "type": "group",
            "name": "x-bash",
            "path": "x-bash",
            "html_url": "https://gitee.com/x-bash"
        },
        "path": "cmd",
        "name": "cmd",
        "owner": {
            "id": 5625049,
            "login": "edwinjhlee",
            "name": "EL",
            "avatar_url": "https://portrait.gitee.com/uploads/avatars/user/1875/5625049_edwinjhlee_1590489033.png",
            "url": "https://gitee.com/api/v5/users/edwinjhlee",
            "html_url": "https://gitee.com/edwinjhlee",
            "received_events_url": "https://gitee.com/api/v5/users/edwinjhlee/received_events",
            "type": "User"
        },
        "description": "常用命令的函数封装库 docker, find, git, 等等",
        "private": false,
        "public": true,
        "internal": false,
        "fork": false,
        "html_url": "https://gitee.com/x-bash/cmd.git",
        "ssh_url": "git@gitee.com:x-bash/cmd.git",
        "assignees_number": 0,
        "testers_number": 0,
        "assignees": [],
        "testers": []
    }
]
A
}

time f
