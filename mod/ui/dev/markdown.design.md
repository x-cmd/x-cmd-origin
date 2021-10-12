# markdown design

Using array 

```bash
s=`
<command-line>$ gh pr checks<command-line>
#command-line: $gh pr checks

All checks were successful
1 failing, 3 successful, and 1 pending checks

- CodeQL 3m43s <url name=url>https://github.com/cli/cli/runs/123</url>

<status v=a1/> build (macos-latest) 4m18s      <url>https://github.com/cli/cli/*</url>
<status v=a2/> build (macos-latest) 4m18s      <url>https://github.com/cli/cli/runs/123$</url>
<status v=a3/> build (ubuntu-latest) 1m23s     <url>https://github.com/cli/cli/runs/123$</url>
<status v=a4/> build (windows-latest) 4m43s    <url>https://github.com/cli/cli/runs/123$</url>
<status v=a5/> lint 47s https://github.com/cli/cli/runs/123
<status v=a5/> lint 47s https://github.com/cli/cli/runs/123
`

work_a1=3
work_a2=4
work_a3=5
markdown.render "$s" sate

while ;
if "" markdown.
a1=0
a2=1
a3=1
markdown.loop "$s"
```

设计原则：降低刷新频率，1s-5s刷新一次

1. 通过改变state来渲染
2. 如果值改变，那么采用高亮，并高亮diff部分

```bash
s=`
$(ui_command-line '$ gh pr checks')
$(ui '$ gh pr checks')

All checks were successful
1 failing, 3 successful, and 1 pending checks

- CodeQL 3m43s $(ui_url https://github.com/cli/cli/runs/123)

$(ui_status a1) build (macos-latest) 4m18s      $(ui_url https://github.com/cli/cli/*)
$(ui_status a2) build (macos-latest) 4m18s      $(ui_url https://github.com/cli/cli/*)
$(ui_status a3) build (ubuntu-latest) 1m23s     $(ui_url https://github.com/cli/cli/*)
$(ui_status a4) build (windows-latest) 4m43s    $(ui_url https://github.com/cli/cli/*)
$(ui_status a5) lint 47s https://github.com/cli/cli/runs/123
$(ui_status a6) lint 47s https://github.com/cli/cli/runs/123

```


