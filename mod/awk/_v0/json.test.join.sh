#shellcheck shell=bash

data='[
    { "a": 1, "b": 2, "c": [1,2,3] },
    { "a": 2, "b": 2, "c": 3 },
    { "a": 3, "b": 2, "c": 3 },
    { "a": 4, "b": 2, "c": 3 },
    { "a": 5, "b": 2, "c": 3 }
]'

json_join(){
    awk "$(cat ./json.awk)"'
{
    jiter_after_tokenize(jobj, $0)
}

END{
    print json_handle_jpath("1.1.a")
    print jget(jobj, "1.1.c")
    print json_handle_jpath("1")
    print jjoin(jobj, "1", "1:5:1", "\n", "a\001c\001b", "\t")
    print jjoin(jobj, "1", "1:5:1", "\002", "a\001c", "\003")
    print jjoin_to_table(jobj, "1", "", "\n", "a\001b\001c", "\t")
}

' <<A
$data
A

}

json_join
