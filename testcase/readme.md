# testcase

## test table

- **centos**: bash/gawk
- **ubuntu**: dash/mawk
- **alpine**: ash/BusyBox awk
- **macOS**: zsh/nawk

| feature\env | bash5 |bash4|bash3|zsh| dash  |ash|  gawk| mawk | BusyBox awk | nawk |
|---|---|---|---|---|---|---|---|---|---|---|
|subfolder<br>`cd ...`|✔|✔|✔|✔|✔|✔|✔|✔|✔|✔|
|last folder<br>`cd -`|✔|✔|✔|✔|✔|✔|✔|✔|✔|✔|
|latest folder contain ddd<br>`cd ddd`|✔|✔|✔|✔|✔|✔|✔|✔|✔|✔|
| show history<br>`cd -%` |✔|✔|✔|✔|✔|✔|✔|✔|✔|✔|
| clear history<br>`cd -/`|✔|✔|✔|✔|✔|✔|✔|✔|✔|✔|
| go forward<br>`cd ./ff` |✔|✔|✔|✔|✔|✔|✔|✔|✔|✔|
|go backward<br>`cd ../cc`|✔|✔|✔|✔|✔|✔|✔|✔|✔|✔|
|in short<br>`cd /u/b`|✔|✔|✔|✔|✔|✔|✔|✔|✔|✔|
|go with find<br>`cd :bin`|✔|✔|✔|✔|✔|✔|✔|✔|✔|✔|
