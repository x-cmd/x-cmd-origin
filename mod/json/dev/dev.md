# 设计理念

## 采用OrderDict的方式来实现

key-value，采用数组对来实现

修改数组通过遍历来实现。

One obj for all store

obj["next" key1]
obj["next" key2]
obj["next" key3]

obj["type" key1]
obj["type" key2]
obj["type" key3]

obj["type" key4]
obj["type" key5]
obj["type" key6]


json_parse(o, str)

json_set(o, "k1" SUBSEP "k2", v1)
json_set(o, "k1" SUBSEP "k3", v2)
json_set(o, "k1" SUBSEP "k4", v3)
json_get(o, "k1" SUBSEP "k2")

json_stringify(o)

重写逻辑：

为了确保性能，我们分开不同的数组进行编写

最小化修改

1. TOKEN ARRAY：TOKENIZE json string，变成一个TOKEN Array



1. OBJECT TREE，表达多个层级的内容
2. NEXT, BEFORE: 表达前驱和后驱
3. BROTHERS


js language

``
a = {
    a: 3
    b: 4
}
``

```
json <<<'
{
    a: 3
    b: 4
}
'

jo c <<<'
{
    a: 3
    b: 4
}
'

jstr c
```

# Using DSL

```
jo '
    

'
```

我们是否采用bash原生来实现？

Parsing 采用awk方案
构建的object放置在bash内
对bash object进行stringify或者yml

```

jo abc de 3
jo abc dea 5
jo abc de 6

jo.new a
a.put errorcode 3
a.put msg "Hello"
a.put msg 1 c

a.put work data <<< '{
    a: 3
    b: [1, 2, 3]
}'

a.get work
a.get work data b
a.get work data c

a.read a b <<<A
.work.data.b
.work.data.b
A
```

