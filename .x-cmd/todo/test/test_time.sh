
test_1(){
    local SSS="$(cat ./lib/default.awk ./lib/json.awk ./lib/jiter.awk)"
    # cat .x-cmd/test/data/git_tokenize.json | awk "$SSS"'
    cat .x-cmd/test/data/git.json | mawk "$SSS"'
{
    jiparse_after_tokenize( obj, $0)
    # jiparse( obj, $0)
}
# END{
#     print jstr(obj)
# }
'
}

time (test_1)

# qiakai ubuntu: 56K json data
#     jiparse and tokenize
#         gawk 32ms
#         mawk 25ms
#         busybox awk 26 - 37ms

#     jiparse
#         gawk 11ms
#         mawk 6 - 7ms
#         busybox awk 12ms
