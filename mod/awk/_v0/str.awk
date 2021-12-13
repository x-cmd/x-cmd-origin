
# Add Code
function str_escape(s) {
    gsub(/\\/, "\\\\", s)   # Must place first line
    gsub(/\b/, "\\b", s)
    gsub(/\t/, "\\t", s)
    gsub(/\n/, "\\n", s)
    gsub(/\r/, "\\r", s)
    gsub(/\n/, "\\n", s)
    gsub(/"/, "\\\"", s)
    gsub(/\//, "\\/", s)
    return "\"" s "\""
}

# print str_quote1("h'a\\\'")
function str_quote1(str){
    # gsub("\\", "\\\\", str) # This is wrong in case: # print str_quote1("h'a\\\'")
    gsub(/\\/, "\\\\", str)
    gsub(/'/, "\\'", str)
    return "'" str "'"
}

function str_unquote1(str){
    gsub(/\\\\/, "\001\001", str)
    gsub(/\\'/, "'", str)
    gsub("\001\001", "\\\\", str)
    return substr(str, 2, length(str)-2)
}


function str_quote2(str){
    gsub(/\\/, "\\\\", str)
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}

function str_unquote2(str){
    gsub(/\\\\/, "\001\001", str)
    gsub(/\\"/, /"/, str)
    gsub("\001\001", "\\\\", str)
    return substr(str, 2, length(str)-2)
}

function str_rep(char, number, _i, _s) {
    for (   _i=1; _i<=number; ++_i  ) _s = _s char
    return _s
}

# function strlen_without_color(text){
#     # gsub(/\033\[[0-9]+m/, "", text)
#     gsub(/\033\[([0-9]+;)*[0-9]+m/, "", text)
#     return length(text)
# }

function str_remove_style(text){
    gsub(/\033\[([0-9]+;)*[0-9]+m/, "", text)
    return text
}

function str_pad_center(str, len,       _len, _len1, _len2) {
    if (_len == "") _len = length(str)
    if (_len < len) {
        _len1 = len - _len
        _len2 = _len1 / 2

        return sprintf("%" _len2 "s", "") str sprintf("%" ( _len1 - _len2 ) "s", "")
    }
    return str
}

function str_pad_left(str, len,   _len) {
    if (_len == "") _len = length(str)
    if (_len < len) {
        return sprintf("%" len - _len "s", "") str
    }
    return str
}

function str_pad_right(str, len,   _len) {
    if (_len == "") _len = length(str)
    if (_len < len) {
        return str sprintf("%" len - _len "s", "")
    }
    return str
}

function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
}

function str_trim_left(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    return astr
}

function str_trim_right(astr){
    gsub(/^[ \t\b\v\n]+$/, "", astr)
    return astr
}

function str_startswith(s, tgt){
    if (substr(s, 1, length(tgt)) == tgt) return true
    return false
}

function str_split_safe(string, array, fieldsep){
    gsub("\n", "\001", string)
    return split(string, array, fieldsep)
}

function str_split_safe_recover(string){
    gsub("\001", "\n", string)
}
