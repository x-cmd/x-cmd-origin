BEGIN{
    # application/json
    # application/text
    # application/xml
    # application/yml
    # application/json;charset=utf-8

    code=""
    arrl = split(query, arr, ",")
    for (i=1; i<=arrl; ++i) {
        e = arr[i]
        if (e ~ /(json)|(text)|(xml)|(yml)/) {
            code = "application/" e
            # break
        }
    }

    for (i=1; i<=arrl; ++i) {
        e = arr[i]
        if (e ~ /(utf(-?8)*)/) {
            code = code";charset=utf-8"
            # break
        }
    }

    print code
    exit(0)
}

END {

}
