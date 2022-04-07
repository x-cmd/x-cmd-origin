# jo parse

```json
{
    a: 1,
    b: 2,
    c: {
        d: [1, 2, 3]
    }
}
```

```bash
jo parse . a1=.a c1=.c.d[1]

```


```json
{
    a: 1,
    b: 2,
    c: {
        d: [1, 2, 3]
    }
}
```

```bash
cat a.json | {
    jp a1=a b cd=c.d[3] || return 0
    echo "$a1"
    echo "$b"
    echo "$cd"
}
```


```json
[
    {
        a: 1,
        b: 2,
        c: {
            d: [1, 2, 3]
        }
    },
    {
        a: 1,
        b: 2,
        c: {
            d: [1, 2, 3]
        }
    },
    {
        a: 1,
        b: 2,
        c: {
            d: [1, 2, 3]
        }
    }
]
```

```bash
cat a.json | jo.parse .* | while jp a1=a b cd=c.d[3]; do
    echo "$a1"
    echo "$b"
    echo "$cd"
done
```

```bash
cat a.json | jo.parse .* | while jp -a=a; do
    echo "$a_a"
    echo "$a_b"
    echo "$a_c"
done
```

