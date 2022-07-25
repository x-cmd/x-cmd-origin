{

    w = $2
    w = tolower(w)

    word = w
    gsub(/j|(ch)|(sh)/, 6, word)
    gsub(/t|d/, 1, word)
    gsub(/n/, 2, word)
    gsub(/m/, 3, word)
    gsub(/r/, 4, word)
    gsub(/l/, 5, word)
    gsub(/k|g/, 7, word)
    gsub(/f|v/, 8, word)
    gsub(/p|b/, 9, word)
    gsub(/z|s/, 0, word)
    gsub(/[a-z-]/, "", word)

    # if (word ~ /^[0]+$/) {
    #     print  0 "\t" $1 "\t" w
    # } else

    if (word != ""){
        # gsub(/^0+/, "", word)

        if (word ~ /^[0-9]+$/) {
            print  word "\t" $1 "\t" w
        }
    }
}