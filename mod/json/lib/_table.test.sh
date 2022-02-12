# ___json_awk_tokenize <<A


function table(){
    local IFS
    IFS="$(printf "\001")"
    local keyname="$1"; shift
    local keylist
    SEP1="\n" SEP2=" " ___json_awk_table_stream "$keyname" "$*"
}

table .table.abc name age gender math=score.math <<A
{
    "table": {
        "abc": [
            {
                "name": "Edwin",
                "age": 31,
                "gender": "male",
                "score": {
                    "math": 100
                }
            },
            {
                "name": "Li Junhao",
                "age": 30,
                "gender": "male",
                "score": {
                    "math": 95
                }
            },
            {
                "name": "Junhao",
                "age": 30,
                "gender": "male",
                "score": {
                    "math": 900
                }
            }

        ]
    }

}

A