# All

## 关于分支

1. 能够用 `x ifelse` 和 `x case` 尽量用 `ifelse`: `x a=if '[ -z $c ]' 1 2`
2. 只有一种场景可用短路求值：`[ condiction ] || { do something }` -- 理解为 assert condiction or dosthing
3. 其它比上述复杂情况，一律用if else语句

