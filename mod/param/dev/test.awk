{
    LEN = "len"
}

function panic_error(msg){
    print msg > "/dev/stderr"
    exit 1
}

# output certain kinds of array
function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
}

function str_trim_left(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    return astr
}



function tokenize_argument_into_TOKEN_ARRAY(astr,
    len, tmp ){

    original_astr = astr

    gsub(/\\\\/,    "\001", astr)
    gsub(/\\\"/,    "\002", astr) # "
    gsub("\"",      "\003", astr) # "
    gsub(/\\\ /,     "\004", astr)

    astr = str_trim(astr)

    print "|" astr "|"
    TOKEN_ARRAY[LEN] = 0
    while (length(astr) > 0){
        if (match(astr, /^\003[^\003]+\003/)) {
            len = TOKEN_ARRAY[LEN] + 1
            tmp = substr(astr, 1, RLENGTH)
            gsub("\004", " ",   tmp)      # Unwrap
            gsub("\003", "",    tmp)       # Unwrap
            gsub("\002", "\"",  tmp)     
            gsub("\001", "\\",  tmp)     # Unwrap
            TOKEN_ARRAY[len] = tmp
            TOKEN_ARRAY[LEN] = len
            astr = substr(astr, RLENGTH+1)

            print "expect here 1: " TOKEN_ARRAY[len]

        } else if ( match(astr, /^[^ \n\t\v\003]+/) ){ #"
            
            len = TOKEN_ARRAY[LEN] + 1
            tmp = substr(astr, 1, RLENGTH)
            gsub("\004", " ",       tmp)
            gsub("\003", "",        tmp)
            gsub("\002", "\"",      tmp)
            gsub("\001", "\\\\",    tmp)   # Notice different
            TOKEN_ARRAY[len] = tmp
            TOKEN_ARRAY[LEN] = len
            astr = substr(astr, RLENGTH+1)

            if ( match(astr, /^\003[^\003]+\003/) ) {
                tmp = substr(astr, 1, RLENGTH)
                gsub("\004", " ",   tmp)      # Unwrap
                gsub("\003", "",    tmp)      # Unwrap
                gsub("\002", "\"",  tmp)
                gsub("\001", "\\",  tmp)     # Unwrap
                TOKEN_ARRAY[len] = TOKEN_ARRAY[len] tmp


                astr = substr(astr, RLENGTH+1)
            }
            print "expect here: " TOKEN_ARRAY[len]
        } else {
            panic_error("Fail to tokenzied following line:\n" original_astr "\n" astr)
        }

        astr = str_trim_left(astr)
    }
}

{

    print $0

    tokenize_argument_into_TOKEN_ARRAY($0)

    print TOKEN_ARRAY[ LEN ]
    print TOKEN_ARRAY[1]
    print TOKEN_ARRAY[2]
}

# echo 'abc  "basf"' | awk -f "test.awk"
# echo 'abc  "b\ asf"' | awk -f "test.awk"
echo '<abc>:abc="adf\ s\ adfaf" ccc' | awk -f "test.awk"
