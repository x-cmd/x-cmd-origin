
# 过滤

```bash
x test -2-*
x test -1-*

x test +2-os -2*
```

# 日志

可以在testcase上写log，输出到tty上。

```
@debug 'Debug log in testcase'
@info 'info log in testcase'
@warn 'warn log in testcase'
@error 'error log in testcase'
```

