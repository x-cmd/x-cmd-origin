
SSS="$(xrc cat awk/lib/default.awk awk/lib/json.awk awk/lib/jparse.awk)"


f(){
awk -v RS="\t" "$SSS"'

{
    data = $0
}
END{
    jparse(data, arr)
    print jget_unquote(arr, ".")
}

' <<A
["sdasdsds", "ssfsfsf", "1", "scs3", "s4", "sd5"]
A
}

time f
