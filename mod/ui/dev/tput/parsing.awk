BEGIN{
    FS=", "
}

function str_trim(astr){
    gsub(/^[ \r\t\b\v\n]+/, "", astr)
    gsub(/[ \r\t\b\v\n]+$/, "", astr)
    return astr
}

{
    $0 = str_trim($0)
    # print NR " " str_trim($0)

    arr_len = split($0, arr, /, /)
    for (i=1; i<=arr_len; ++i) {
        if (arr[i] ~ /^[^=]+=[^=]+,?/) {
            if (arr[i] ~ /,$/) {
                print substr(arr[i], 1, length(arr[i])-1)
            } else {
                print arr[i]
            }
        }

    }

}
