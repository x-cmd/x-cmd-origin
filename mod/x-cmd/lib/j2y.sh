
f1(){
command awk -f default.awk -f json.awk -f jqparse.awk -f j2y.awk -f j2y.test.awk <<A
{
    "a": 3,
    "b": 4,
    "c": 6,
    "d": [ 1, 2, "jhi", {
        "a": 1,
        "b": 2
    } ],
    "e": { "a": 1 }
    "f": [
        [1, 2, 3]
    ]
}
{
    "a": 1
}
[
    [1, 2, 3]
]
A
}


command awk -f default.awk -f json.awk -f yml.awk -f ji2y.awk -f ji2y.test.awk <<A
{
    "a": 3,
    "b": 4,
    "c": 6,
    "d": [ 1, 2, "jhi", {
        "a": 1,
        "b": 2
    } ],
    "e": { "a": 1 }
}
{
    "a": 1
}
[
    [1, 2, 3]
]
A
