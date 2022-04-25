# 引入的概念

```bash
K -- 当前的key原始数据，带""
V -- 当前的value原始数据，若是字符串带""
KP -- 当前的key链用"\034"来连接

k() -- 能够获得去quote的key
v() -- 能够获得去quote的val

q() -- 对数据加quote和转义
uq() -- q的逆运算

e(var, val) -- 生成用来赋值的代码, 变量名为var
e_(var, val) -- e(_, val)

keq(p1, p2) -- 用来匹配keypath
km(p1, p2, p3) -- 用正则表达式匹配keypath
```

```bash
g(k1, k2, ..., kn) -- 获得数据
len(k1, k2, ..., kn) -- 获得数组或者dict的长度
```
