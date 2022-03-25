
# Param 设计


我决定快刀沾乱麻。
接口设计就丑一点，但也灵活一点，对于脚本开发者来说，读懂虽然耗时，但少写代码多实现功能就很让人愉快了。

支持如下功能：

1. git-config风格，修改直接作用文件，然后命令会按照顺序来加载参数文件
2. 命令会自动加载参数文件，但修改作用在环境变量上，但也提供直接写文件的方式（变成功能1）
3. 命令不会自动加载参数文件，提供接口让用户自己手动加载


----------

: <<comment
1. 一体化设计不容易造成运行环境污染
2. 分体设计，可读性更好，更容易理解
3. 一体化设计整体性更好，但DSL字符串给人感觉还是很差

# Using env is OK.

```bash
@param title "Provide title"
@param text "Provide text"
@param orientation=0 \
    "button orientation 0 = vertical, 1=horizontal, default is 0" \
    =int 0 1
@param singleTitle "Provide singleTitle"
@param singleURL "Provide url to jump"
@param.parse
```

一体式设计一旦出来，上述设计总体上其实并无优势：

1. 有一定可读性
2. 简洁，除了param
3. 整体性更强
4. 对环境的副作用控制到最小

```bash
param '
    title "Provide title"
    text "Provide text"
    orientation=0 "button orientation 0 = vertical, 1=horizontal, default is 0" int 0 1
    singleTitle "Provide singtalTitle"
    singleURL "Provide url to jump"
'
```

```bash
param \
    -- title "Provide title" \
    -- text "Provide text" \
    -- orientation=0 "button orientation 0 = vertical, 1=horizontal, default is 0" \
        int 0 1 \
    -- singleTitle "Provide singtalTitle" \
    -- singleURL "Provide url to jump"
```
