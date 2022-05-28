# jo

## Query

```json
{
    "classA": [
        {
            "name": "l",
            "score": 100
        },
        {
            "name": "agent-zero",
            "score": 0
        },
        {
            "name": "agent-ten",
            "score": 10
        },
    ],
    "classB": [
        {
            "name": "lb",
            "score": 100
        },
        {
            "name": "agent-zero-b",
            "score": 0
        },
        {
            "name": "agent-ten-b",
            "score": 10
        },
    ]
}
``


```bash
<.data.json x jo .classA .name .score | while x rl name score; do
    eval echo "$name" "$score"
    echo post webservice "https://x-cmd.com/$name/$score"
done

<.data.json x jo .classA .name .score | x rl name score -- '
    echo "$name" "$score"
    echo post webservice "https://x-cmd.com/$name/$score"
'

<.data.json x jo .classA .name .score | x args -n 2 '
    eval echo "$1" "$2"
    echo post webservice "https://x-cmd.com/$1/$2"
'
```

```bash
global_str=
while x jo env .name .score; do
    printf "%s" "${name}${score}"
done <<A
$(x jo .class* <data.json)
A

global_str=
while x rl name score; do
    printf "%s" "${name}${score}"
done <<A
$(x jo env .class* .name .score <data.json)
A

# I am wondering how must cost it is ...
global_str="$(<data.json x jo .class* .name .score -- 'printf "%s" "${name}${score}"')"

global_str="$(
x jo .class* .name .score <data.json | while x rl name score; do
    printf "%s" "${name}${score}"
done
)"

global_str="$(
x jo env .class* .name .score <data.json | while x reval; do
    printf "%s" "${name}${score}"
done
)"

global_str="$(x jo env .class* .name .score <data.json | x reval 'printf "%s" "${name}${score}"')"

# bash only

# https://unix.stackexchange.com/questions/309547/what-is-the-portable-posix-way-to-achieve-process-substitution

global_str
while x jo renv .awk regex=beginRegex fold=autoFold; do
    global_str="${global_str}${regex}${fold}"
done < <(x jo .class* <data.json)
```

# 关于quote的问题

当你选择在 jo-query/jo-env unquote时，数据就有可能是有换行，readline机制可能会被破坏。
但如果你不选择在那里unquote，把问题丢给shell，就变成了每次需要在awk的调用问题了。

我们可以让jo env 做得复杂一点，通过一个复杂的分隔符来处理。

```bash
<.data.json x jo env . n=.name s=.score -- '
    echo "$name" "$score"
    echo post webservice "https://x-cmd.com/$name/$score"
'

# Readline might be a big problem...
<.data.json x jo env . .name .name .score -- '
    echo "$name" "$score"
    echo post webservice "https://x-cmd.com/$name/$score"
'

<.data.json x jo env .classA .name .score | while x readml name score; do
    echo "$name" "$score"
    echo post webservice "https://x-cmd.com/$name/$score"
done

<.data.json x jo .classA .name .score | x jo uq | while x readml name score; do
    echo "$name" "$score"
    echo post webservice "https://x-cmd.com/$name/$score"
done
```


## env

1. Design for oneliner
2. Design to just extract a single attribute with elegance
3. Otherwise, I will recommending you just using combination of query and `reval/rl`


## High Quality

```bash

<.data.json x jo env ".class*" .total .students | while x readml total students; do
    printf "%s\n" "$students" | {
    x jo env .* .name .score -- '
    echo "$name: $(( score / total ))"
'
    printf "%s\n" "--- End: $total"
}
done

<.data.json x jo env ".class*" .total .students | while x readml total students; do
    x jo { total: "$total" }
    printf "%s\n" "$sutdent"
    printf "%s\n" ""
done | {
    x jo env . .name .score .total -- '
    if [ -n "$total" ]; then
        TOTAL="$total"
    elif [ -n "$name" ]; then
        echo "$name: $(( score / TOTAL ))"
    else
        printf "%s\n" "--- End: $total"
    fi
'
```

