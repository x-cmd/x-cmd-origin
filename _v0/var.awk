
function var_quote1(str){
    # gsub("\\", "\\\\", str) # This is wrong in case: # print str_quote1("h'a\\\'")
    gsub(/\\/, "\\\\", str)
    gsub(/'/, "\\'", str)
    return "'" str "'"
}

function var_set(name, value){
    return sprintf("%s=%s", name, var_quote1(value))
}
