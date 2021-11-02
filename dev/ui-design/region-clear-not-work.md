```bash
tput ed
```

我当初认为这个命令可以清除从光标开始到屏幕的所有字符，但事实上并没有做到
我尝试了两种办法
1. 先预先用空白字符刷掉原来的输出 -- 带来频闪的感觉
2. 在新的输出的行尾加入空格占位
    1. 如果输出行数小于上一次输出，要输出空格字符串
    2. 字符串的长度会包括颜文字的长度
3. 在新的输出的行尾加入清除到行尾命令


```bash
ui_region_clear.1(){
    local end_row begin_row maxw space

    maxw="$(tput cols)"
    space="$(seq -f " " -s '' "$maxw")"

    ui_cursor_read end_row
    tput rc # restore to the last cursor position
    # tput ed # clr_eos: clear the characters until the end of screen
    ui_cursor_read begin_row
    echo "$end_row $begin_row" >./debug.txt

    for i in $(seq $(( end_row - begin_row )) ); do
        echo "$space"
    done
    
    tput rc
}
```
