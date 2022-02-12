
function alen(text){
    # gsub(/\033\[[0-9]+m/, "", text)
    gsub(/\033\[([0-9]+;)*[0-9]+m/, "", text)
    return length(text)
}

BEGIN{
    print "\033[31;41;1m hi \033[0m"
    print alen("\033[1m hi \033[0m")
}
