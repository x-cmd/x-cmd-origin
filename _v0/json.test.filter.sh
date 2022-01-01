

xrc awk

# DSL: json_get(_, ".b")

SSS="$(cat default.awk)$(cat json.awk)"

f1(){
    awk "$SSS"'
    BEGIN{

    }
    {
        if ($0 != "") {
            jiter(_, $0)
            # print ($0)
        }
    }
    END{
        # print json_stringify_format(_, ".", 4)

        print json_filter(_, "1", ".name", "v1.0.2")
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
        "name": "v1.0.2",
        "message": "",
        "commit": {
            "sha": "17b952bbc9fa014ac33dc732510aaaa2d616c5eb",
            "date": "2021-08-01T10:44:41+00:00"
        }
    },
    {
        "commit": {
            "sha": "088ffaaf2808e34a4c108a5103e385ef5d853392",
            "date": "2021-08-01T07:32:52+00:00"
        }
    },
    {
        "name": "v1.0.0",
        "aaa": {
            "a1": "www",
            "a2": "www",
            "a3": "www",
            "a4": "www",
            "a5": "www",
            "b1": ["eee1", "eee2"]
        },
        "message": null,
        "commit": {
            "sha": "088ffaaf2808e34a4c108a5103e385ef5d853392",
            "date": "2021-08-01T07:32:52+00:00"
        }
    }
]
A
}

time f # >/dev/null

# echo '[
#     {
#         "name": "v1.0.2",
#         "message": "",
#         "commit": {
#             "sha": "17b952bbc9fa014ac33dc732510aaaa2d616c5eb",
#             "date": "2021-08-01T10:44:41+00:00"
#         }
#     },
#     {
#         "name": "v1.0.0",
#         "commit": {
#             "sha": "088ffaaf2808e34a4c108a5103e385ef5d853392",
#             "date": "2021-08-01T07:32:52+00:00"
#         }
#     },
#     {
#         "aaa": {
#             "a1": "www",
#             "a2": "www",
#             "a3": "www",
#             "a4": "www",
#             "a5": "www",
#             "b1": ["eee1", "eee2"]
#         },
#         "name": "v1.0.1",
#         "message": null,
#         "commit": {
#             "sha": "088ffaaf2808e34a4c108a5103e385ef5d853392",
#             "date": "2021-08-01T07:32:52+00:00"
#         }
#     }
# ]' |jq '.[] | select(.name == "v1.0.2")'