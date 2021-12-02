


str.unescape(){
    awk "$(cat ./str)
    { print str_unescape(\$0) }
" -
}

str.escape(){
    awk "$(cat ./str)
    { print str_escape(\$0) }
" -
}

str.unescape.test(){
    echo 'hi\nadf' | str.escape
}

str.escape.test(){
    echo -e 'hi\t"abc' | str.escape
}
