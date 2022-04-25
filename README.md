# log

## 你只需要注意一点

```bash
<module>:warn 'Exit code is $?'  # Alwasy print out 'Exit code is 1'
```

这个问题背后是因为效率 ~ 为了引入参数的惰性计算不得不做的妥协

```bash
x log init worker
worker:debug "Curl Body is $(curl https://get.x-cmd.com)"       # curl will never happened
```

## `x log :<mod> [level]` VS `<mod>:<level>` 的区别

log模块当前最大设计问题是:

```bash
x log init worker
true
worker:log "Exit code is $?"        # 'Exit code is 1'
```

```bash
true
x log :worker "Exit code is $?"     # 'Exit code is 0'
```

这个问题背后是另一个特性

```bash
x log init worker
worker:debug "Curl Body is $(curl https://get.x-cmd.com)"       # curl will never happened
```

```bash
true
x log :worker "Curl Body is $(curl https://get.x-cmd.com)"      # curl will happen
```

## submodule的问题

```bash
true
x log :yanfa

function yanfa_release_add(){
    x:trace yanfa/release/add
    yanfa:log info hi
}

```
