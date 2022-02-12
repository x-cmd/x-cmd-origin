xrc awk

SSS="$(cat default.awk)$(cat json.awk jparse.awk jiter.awk jdict.awk jlist.awk)"


data='[
    { "a": 1, "b": 2, "c": 5 },
    { "a": 2, "b": 2, "c": 3 },
    { "a": 3, "b": 2, "c": 3 },
    { "a": 4, "b": 2, "c": [3,4,5,6,7,8] },
    { "a": 5, "b": 2, "c": 3 },
]'

json_join(){
    awk "$SSS"'
{
    jiparse_after_tokenize(jobj, $0)
}

END{
    print jlist_str2arr(jobj, jpath("1"), "1:3:1", arr)
    for (i in arr) {
        print arr[i]
    }

    print jlist_join(",", jobj, jpath("1.4.c"), "1:5:1")
    print jlist_join(",", jobj, jpath("1.4.c"))
    print jlist_grep(jobj, "1", "a", "[1-3]")

    # print jpath("1.1.a")
    # print jget(jobj, "1.1.c")
    # print jpath("1")
    # print jjoin(jobj, "1", "::-1", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", "4:1", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", "4:1:-2", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", "1::1", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", "1:5:1", "\002", "a\001c", "\003")
    # print jjoin(jobj, "1", "-2:", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", ":-2", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", ":-3:-1", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", ":-3:1", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", "-3::-1", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", ":-6:", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", ":-6:-1", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", "-20:2:1", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", ":", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", "1.2:5:1", "\n", "a\001c\001b", "\t")
    # print jjoin(jobj, "1", "1::-1", "\n", "a\001c\001b", "\t")

    # print jjoin(jobj, "1", "::", "\n", "", "\t")
    # print jjoin_to_table(jobj, "1", "", "\n", "a\001b\001c", "\t")
}

' <<A
$data
A

}

json_join

