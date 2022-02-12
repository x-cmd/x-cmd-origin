. ./v0

res="$(___json_awk_end '
END {
    print jget(_, ".1.a")
    print jget(_, ".1.b")
}
' <<A
[
    { "a": 1, "b": 2 }
]
A
)"

echo "$res"

___json_var a b <<A
$res
A

echo "a: $a"
echo "b: $b"


time ___json_awk_get a1=.1.a b1=.1.b <<A
[
    { "a": 1, "b": 2 }
]
A

echo "a1: $a1
b1: $b1"

time ALREADY_TOKENIZED=1 ___json_awk_get a1=.1.a b1=.1.b <<A
[
{
"a"
:
1
,
"b"
:
2
}
]
A
