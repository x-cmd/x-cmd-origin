# CascadiaForPowerline

- Like powerline font install to set Cascadia code for **powerline** font
- Cascadia code is monospaced font that looks very nice in windows terminal
- base: [Cascadia](https://github.com/microsoft/cascadia-code)

> 下载方式和powerline font类似，但我做了一键化处理，故只用跑一条脚本即可获得相应信息

# Cascadia code

[Cascadia](https://github.com/microsoft/cascadia-code) is a fun new coding font that comes bundled with Windows Terminal, and is now the default font in Visual Studio as well.
> 在windows环境中最舒服的终端等宽字体，是微软官方推出的字体，但默认环境是没有powerline符号的需要手动安装
<img src="https://tva2.sinaimg.cn/large/6ccee0e1gy1gx0ozz1x1pj20dc064q3s.jpg" alt="16385175925746" width="480" data-width="480" data-height="220">

## Install

> use github. base curl and git

```sh
eval "$(curl https://raw.githubusercontent.com/Zhengqbbb/CascadiaForPowerline/main/install.sh)"
```

### Use gitee install | 国内gitee安装源

> use gitee. base curl and git

```sh
eval "_REMOTE=gitee _G_USER=AAAben" "$(curl https://gitee.com/AAAben/CascadiaForPowerline/raw/main/install.sh)"
```

#### PS: Windows Install and set Windows Terminal

- Windows need to find the ttf file and right click to install font, so I hope you use **git bash**
- I personally think that in addition to the windows environment, for example, the use of Monaco fonts in the mac environment is the best. Patch fonts supported by powerline symbols. I also integrated his download method: Monaco installation repo.[Monaco installation repo](https://github.com/Zhengqbbb/MonacoForPowerline).

> windows系统需要找到ttf资源文件手动右键安装字体,我希望你是使用git bash去运行本脚本这样你会获得相应的提示
> 个人觉得除了windows环境，比如mac环境下使用Monaco字体是最好看的，有powerline符号的支持的补丁字体，我也集成了他的下载方式。[Monaco installation repo](https://github.com/Zhengqbbb/MonacoForPowerline).

---

## Set the font

- Windows Terminal: Open settings,Find the default value in the right column, select the appearance, and then select the font "Cascadia Code PL"
- Mac Terminal: Use `command + ,` And then find font, Choose: "Cascadia Code PL"
- Ubuntu Terminal: Use mouse right click to open the setting(P), Find text, And then choose: "Cascadia Code PL"
- VSCode: Editor `setting.json` add json item "terminal.integrated.fontFamily": "Cascadia Code PL"
- iTerm2: Use `command + ,` Find Profiles - Text - Font, And then choose: "Cascadia Code PL"

> More settings: https://github.com/Zhengqbbb/MonacoForPowerline/issues/1
> 字体安装完成后是需要手动设置终端软件的字体设置的。

#### If you think my installation script is nice, you can give me a star

> 如果你觉得安装脚本写的不错的话，可以给我一个star哦！~