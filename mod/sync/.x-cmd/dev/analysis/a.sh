
work(){
    local cmd=${1:?"Provide command"}
    local title="${2:-OPTION}"

    eval "$cmd" | awk '

$1~/^-/{
    # print $0
    arrlen = split($0, arr, /,\ /)
    for (i=1; i<=arrlen; ++i) {
        e = arr[i]
        gsub(/^[[:space:]]+/, "", e)
        # print e
        esl = split(e, es)
        es1 = es[1]
        # gsub(/^[[:space:]]+/, "", es1)
        # gsub(/[[:space:]]+$/, "", es1)
        gsub(/^[^-A-Za-z0-9_]+/, "", es1)
        gsub(/[^-A-Za-z0-9_]+$/, "", es1)
        if (match(es1, /--?[-A-Za-z0-9_]+=/)) {
            # print es1
            print "+\t" substr(es1, 1, RLENGTH-1)
        } else {
            if (match(es1, /--?[\[\]\-A-Za-z0-9_]+/)) {
                print "---> \t" es1 "|=" length(es1) "|=" RLENGTH
                word = substr(es1, 1, RLENGTH) # Word is wrong !!!!
                if (es[2] ~ /^</) {
                    print "+\t" es1
                } else {
                    print "-\t" es1
                } 
            } else {
                # print "fff: " es1 "|=" length(es1)
                # if (match(es1, /^--?[-A-Za-z0-9_]+/)) { 
                #     print "hi" 
                # }
                # else {
                #     print "fuc"
                # }
            }
        }
    }
}

'

}

work "git clone --help"
