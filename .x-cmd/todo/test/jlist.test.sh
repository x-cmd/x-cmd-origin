xrc awk

SSS="$(cat default.awk)$(cat json.awk jiter.awk)"


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
    jlist_push(jobj, jpath("1.4.c"), "aaa")
    jlist_rm(jobj, jpath("1.4.c"), "4")
    print jstr(jobj)

    print jlist_str12arr(jobj, jpath("1"), "1:3:1", arr)
    for (i in arr) {
        print arr[i]
    }

    print jlist_join(",", jobj, jpath("1.4.c"), "1:5:1")
    print jlist_join(",", jobj, jpath("1.4.c"))
    # arrgl = jlist_grep_to_arr(jobj, "1.4.c", "[5-7]", arrg)
    arrgl = jgrep_to_arr(jobj, "1.4.c", "[5-7]", arrg)
    for( i=1; i<=arrgl; ++i){
        print arrg[i]
    }

}

' <<A
$data
A

}

time (json_join)

# f(){

#     awk '
# function f2(arr3, arr4){
#     arr4[1]=arr3[1]
# }
# function f1(arr1, arr2){
#     f2(arr1,arr2)
# }
# {
#     a=$0
#     split(a, obj1, "b")
#     f1(obj1, obj2)
#     print obj2[1]
# }
# '
# }
# echo "aabbccdd" | f

