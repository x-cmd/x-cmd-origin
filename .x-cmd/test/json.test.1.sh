. ./latest
. ./lib/awk
. ./lib/generator

___x_cmd_json_var aa <<A
[
    { "a": [1], "b": 2 }
]
A

___x_cmd_json_push "aa.[0].a" "2"
___x_cmd_json_push aa '{"name": ["Edwin"],"age": 31,"gender": "male","score": {"math": 100}}'
___x_cmd_json_push aa "ccc"

echo "aa: $aa"
___x_cmd_json_var bb "{a:1}"
___x_cmd_json_put bb.b "{b1:bbb,b2:[1,2,22,33]}"

x json color bb

___x_cmd_json_pop bb.b.b2           # del end
___x_cmd_json_push bb.b.b2 33       # add end and no printf
___x_cmd_json_shift bb.b.b2         # del head
___x_cmd_json_prepend bb.b.b2 11    # add head
___x_cmd_json_del "bb.b.b2.[1]"

___x_cmd_json_values bb.b.b2
___x_cmd_json_keys bb.b
___x_cmd_json_length bb.b

___x_cmd_json_query "bb.b.b2.[1]"
___x_cmd_json_query bb.b

# ___x_cmd_json_unescape ___x_cmd_json_query bb.b
