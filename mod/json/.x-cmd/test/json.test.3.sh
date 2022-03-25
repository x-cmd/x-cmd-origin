. ./latest
. ./lib/awk


time ______x_cmd_json_awk_get a1=.1.a b1=.1.b  <<A
[
    { "a": 1, "b": 2 }
]
A

# echo "a1: $a1
# b1: $b1"


time ALREADY_TOKENIZED=1 ______x_cmd_json_awk_get aa1=.1.a b1=.1.b <<A
[
{
"a"
:
1
,
"b"
:
2
}
]
A
