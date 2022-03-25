
. ./lib/awk

f(){
    ______x_cmd_json_awk_parse_stream '
END{
    print jstr(_)
}
'
} <<A
{
    "table": {
        "abc": [
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

time (f)