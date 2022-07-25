BEGIN {
    NAME = ""
    WIDTH = 12
    SEP="\001"
    count = 0
}

function handle(name){
    if (pat == "" || match(name, pat)) {
        printf("\033[33m%-12s\t\033[34;1m%s\033[0m\n",   name,        data[name SEP "desc"])
        printf("%-12s\t%s\n",   " ",         ">    " data[name SEP "cmd"])
        printf("%-12s\t%s\033[32;3m%s\033[0m\n",   " ",         "ref: ",  data[name SEP "reference"])
        count = count + 1
    }
}

$0!~/^[ ]*#/{
    leading_space = match($0, /^[ ]+/)
    leading_space_len = RLENGTH

    if (leading_space_len == -1) {
        if (NAME != "") {
            handle(NAME)
        }
        NAME = $0
        gsub(/:$/, "", NAME)
        gsub(/[ ]+$/, "", NAME)
        gsub(/^[ ]+/, "", NAME)
    } else if (leading_space_len == 4) {
        kw = $1
        if (kw ~ /:$/) {
            gsub(/:$/, "", kw)
        }

        $1 = ""
        s = $0
        gsub(/[ ]+$/, "", s)
        gsub(/^[ ]+/, "", s)
        data[NAME SEP kw] = s
    }
}

END{
    if (NAME != "") {
        handle(NAME)
    }

    if (pat != "") {
        if (count == 0) exit(1)
        if (count == 1) exit(0)
        exit(0) # success
    }
}