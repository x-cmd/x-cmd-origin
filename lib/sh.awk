
function shqu( s ){
    gsub(/\\/, "\\\001\\", s)
    gsub("\001", "", s)
    gsub(/\$/, "\\$", s)
    gsub("\"", "\\\"", s)
    return "\"" s "\""
}

function shuq( s ){
    gsub(/\\\$/, "$", s)
    gsub(/\\"/, "\"", s)
    gsub(/\\\\/, "\\", s)
    return substr(s, 2, length(s) - 2)
}

function shqu1( s ){
    gsub("'", "'\\''", s)
    return "'" s "'"
}

function shuq1( s ){
    gsub(/'\\''/, "'", s)
    return substr(s, 2, length(s) - 2)
}

function shexec( cmd,  _line, _ret, i ){
    i = 0
    while ((cmd | getline _line) > 0)   _ret = ("" == _ret) ? _line : (_ret "\n" _line)
    return _ret
}

function sh_code_eval( code ){
    code = shqu( code )
    return "eval " code
}

function sh_code_varset( name, value ){
    return name "=" shqu1(value)
}

