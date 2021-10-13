
# xrc的定位

1. xrc是"元模块"，加载了它，便有了可以模块自动能力。
    - 官方:
        - 按需形态
            - 两次ws: `eval "$(curl https://x-cmd.com)"`
            - 单文件：仅仅保留可能性，实际不会使用
        - 独立运行形态:
            - 先下载本地，然后可运行，获得独立运行形态
                - `curl https://x-cmd.com/gh | sh`
                - `curl https://github.io/gh | sh`
                - `curl https://gitee.io/gh | sh`
            - 可以不依赖网络
    - 它的形态：
        - 1. tar中的一部份: `_X_CMD_PATH=std.tar.gz eval "$(tar xvf $_X_CMD_PATH xrc/v0)`
            - 这种设计，一般会让它具备引导头
            - 本地已下载: `. std-v0`
            - 网络: `eval "$(curl https://x-cmd.com)"`
                - 先下载安装脚本（极轻，自托管，带md5）
                - 再下载`std-v0`
                - 设置环境变量，执行`. std-v0`
        - 2. 最小化形态，依赖网络: 单文件： `. xrc`
            - 本地已下载: `. xrc`
            - 网络: `eval "$(curl https://min.x-cmd.com)"`
            - 仅仅保留，作为一种可能，实际上，不可能这么做了
    - 放弃：
        - 2. 可用于流的自解压tar的一部分，用base64的方法编码到字符串( 83KB => 113KB )
            - 这种方法，节省了一次webservice，但是不直观
    - 能够自适应：_X_CMD_PATH
        - 1. 通过 `_X_CMD_PATH` 来获取源文件（ -f ）
        - 2. 通过 `_X_CMD_PATH` 来获取folder（ -d ）
2. boot： 一定要有，这样能够做lazy-loading
3. x-cmd来管理x
    1. init： `eval "$(x init)"`
    2. setup: `eval "$(x setup)"`
4. Root下的安装
    1. 可以释放到本地用户再启动
    2. 也可以用自带标准库完成，在tmp目录缓存
5. 路径
    1. 一般用户：get -> xrc -> xcmd
    2. 安装后：boot -> xrc -> xcmd
    3. xcmd -> xrc -> boot

## boot is a file for xrc module

```bash

# None interactive mode
. "$HOME/.x-cmd/boot" 2>/dev/null || eval "$(curl https://x-cmd.com)"

# interactive mode. Will install in rcfile
. "$HOME/.x-cmd/boot" 2>/dev/null || eval "$(curl https://x-cmd.com)"

D="$HOME/.x-cmd" eval '. "$D/boot" 2>/dev/null || eval "$(curl https://x-cmd.com)"'


eval "$(tar xcf std.tar.gz xrc/v0)"

eval "$(tar xcf work xrc/v0)"
```




