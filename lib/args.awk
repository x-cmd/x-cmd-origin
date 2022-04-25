
NR==1{
    argl = split($0, argv, "\001")

    for (i=1; i<=argl; ++i) {
        gsub("\002", "\n", argv[i])
        gsub(/\\/, "\\\\\\", argv[i])
        gsub("\"", "\\\"", argv[i])
        # TODO: Awk will have a warning about "$" and the solution: throw it to "2>/dev/null"
        gsub(/\$/, "\\\$", argv[i])
        argv[i] = "\\\"" argv[i] "\\\""
        if (argstr == "") argstr = argv[i]
        else argstr = argstr " " argv[i]
    }
    print argstr
}

function printcode( len ){
    count = 0
    code=""
    for (j=1; j<=len; ++j) {
        e = result[j]
        gsub("\"", "\\\"", e)
        code = code " " "\"" e "\""
    }
    print code
}

NR>1{
    arrl = split($0, arr, /[ \t]+/)
    for (i=1; i<=arrl; ++i) {
        count ++
        result[ count ] = arr[i]
        if (count == every) {
            printcode( every )
        }
    }
}

END {
    if (count > 0) printcode( count )
}