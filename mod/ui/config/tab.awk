

BEGIN{
    map["auto"]         = "在启动时或键入了 mount -a 命令时自动挂载"
    map["noauto"]       = "只在你的命令下被挂载。"
    map["exec"]         = "允许执行此分区的二进制文件。"
    map["noexec"]       = "不允许执行此文件系统上的二进制文件。"
    map["ro"]           = "以只读模式挂载文件系统。"
    map["rw"]           = "以读写模式挂载文件系统。"
    map["user"]         = "允许任意用户挂载此文件系统，若无显示定义，隐含启用 noexec, nosuid, nodev 参数。"
    map["users"]        = "允许所有 users 组中的用户挂载文件系统."
    map["nouser"]       = "只能被 root 挂载。"
    map["owner"]        = "允许设备所有者挂载."
    map["sync"]         = "I/O 同步进行。"
    map["async"]        = "I/O 异步进行。"
    map["dev"]          = "解析文件系统上的块特殊设备。"
    map["nodev"]        = "不解析文件系统上的块特殊设备。"
    map["suid"]         = "允许 suid 操作和设定 sgid 位。这一参数通常用于一些特殊任务，使一般用户运行程序时临时提升权限。"
    map["nosuid"]       = "禁止 suid 操作和设定 sgid 位。"
    map["noatime"]      = "不更新文件系统上 inode 访问记录，可以提升性能(参见 atime 参数)。"
    map["nodiratime"]   = "不更新文件系统上的目录 inode 访问记录，可以提升性能(参见 atime 参数)。"
    map["relatime"]     = "实时更新 inode access 记录。只有在记录中的访问时间早于当前访问才会被更新。（与 noatime 相似，但不会打断如 mutt 或其它程序探测文件在上次访问后是否被修改的进程。），可以提升性能(参见 atime 参数)。"
    map["flush"]        = "vfat 的选项，更频繁的刷新数据，复制对话框或进度条在全部数据都写入后才消失。"
    map["defaults"]     = "使用文件系统的默认挂载参数，例如 ext4 的默认参数为:rw, suid, dev, exec, auto, nouser, async."
}

# refer: https://wiki.archlinux.org/title/Fstab

function dump(bit){
    if (bit == 0) {
        return "dump=" "\033[31;1m" "NO" "\033[0m"
    } else {
        return "dump=" "\033[32;1m" "YES" "\033[0m"
    }
}

function fsck(bit){
    if (bit == 0) {
        return "fsck=" "\033[31;1m" "NO" "\033[0m"
    } else if (bit == 1) {
        return "fsck=" "\033[32;1m" "HIGH" "\033[0m"
    } else {
        return "fsck=" "\033[32;1m" "LOW" "\033[0m"
    }
}


{
    # gsub(/^\s+/, "", $3)

    printf("\033[32;1m")
    printf("%-15s  %-10s", $1, $3) 
    printf("%s", "\033[34m")
    printf("%-30s", $2 "\033[0m") 
    printf("%s\n", dump($5) "\t" fsck($6))
    printf("\033[;2m")

    arr_len = split($4, arr, ",")
    for (i=1; i<=arr_len; ++i) {
        printf("  %-20s%s\n", arr[i], "\t" map[arr[i]])
    }
    printf("\033[;0m")
}