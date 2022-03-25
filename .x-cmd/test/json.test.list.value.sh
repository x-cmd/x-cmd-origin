

xrc awk

# DSL: json_get(_, ".b")

SSS="$(cat default.awk)$(cat json.awk jiter.awk json_demo.awk)"

f1(){
    awk "$SSS"'
    BEGIN{

    }
    {
        if ($0 != "") {
            jiparse(_, $0)
            # print ($0)
        }
    }
    END{
        print json_stringify_format(_, ".", 4)

        print json_get_list_value(_, "1.1.aaa.ccc", ".sha")
        print json_get_list_value(_, "1", ".owner", "format")
        print json_get_list_value(_, "1", "", "compact")
        print json_get_list_value(_, "1", ".aaa.ccc")
    }
    '
}

f(){

{
    awk "$SSS
    {
        printf(\"%s\", json_to_machine_friendly(\$0) )
    }" | f1
} <<A
} <<A
[
    {
        "url": "https://gitee.com/api/v5/repos/x-bash/cloud",
        "aaa": {
            "id": 5625049,
            "login": "edwinjhlee",
            "type": "User",
            "ccc": [
                {
                    "sha": "17b952bbc9fa014ac33dc732510aaaa2d616c5eb",
                    "date": "2021-08-01T10:44:41+00:00"
                },
                {
                    "sha": "17b952bbc9fa014ac33dc732510aaaa2d616c5eb",
                    "date": "2021-08-01T10:44:41+00:00"
                },
                {
                    "sha": "17b952bbc9fa014ac33dc732510aaaa2d616c5eb",
                    "date": "2021-08-01T10:44:41+00:00"
                }
            ]
        }
    },
    {
        "url": "https://gitee.com/api/v5/repos/x-bash/cmd",
        "owner": {
            "id": 5625049,
            "login": "edwinjhlee",
            "type": "User"
        }
    }
]
A
}

time f # >/dev/null



# echo '[
#     {
#         "url": "https://gitee.com/api/v5/repos/x-bash/cloud",
#         "aaa": {
#             "id": 5625049,
#             "login": "edwinjhlee",
#             "type": "User",
#             "ccc": [
#                 {
#                     "sha": "17b952bbc9fa014ac33dc732510aaaa2d616c5eb",
#                     "date": "2021-08-01T10:44:41+00:00"
#                 },
#                 {
#                     "sha": "17b952bbc9fa014ac33dc732510aaaa2d616c5eb",
#                     "date": "2021-08-01T10:44:41+00:00"
#                 },
#                 {
#                     "sha": "17b952bbc9fa014ac33dc732510aaaa2d616c5eb",
#                     "date": "2021-08-01T10:44:41+00:00"
#                 }
#             ]
#         }
#     },
#     {
#         "url": "https://gitee.com/api/v5/repos/x-bash/cmd",
#         "owner": {
#             "id": 5625049,
#             "login": "edwinjhlee",
#             "type": "User"
#         }
#     }
# ]' | jq '.[0].aaa.ccc | .[] | .sha'