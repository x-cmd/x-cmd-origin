
___x_cmd_test_bench_all(){
    local i
    for i in echo plus strim trim varget get file command; do
        ___x_cmd_test_bench "$i"
    done
}

___x_cmd_test_bench_run(){
    local name="$1"
    [ "${name#___x_cmd_test_bench}" = "$name" ] && name="___x_cmd_test_bench_${name}_inner"

    local display="${name#___x_cmd_test_bench_}"
    printf "%-10s" "${display%_inner}"
    local cycle="$2"
    ( time "$name" "$cycle" >/dev/null ) 2>&1 \
        | tee /dev/stdout | awk -v cycle="$cycle" 'NR==2{
            c = $2
            gsub("s$", "", c)
            split(c, arr, "m")
            s = ( arr[1] * 60 + arr[2] ) * 1000
            t = s / cycle
            printf("%s\t%s\t%5s", s,  t  " ms", int(1 / t))
            exit(0);
        }'
    printf "\n"
}

___x_cmd_test_bench_plus_inner(){
    local i
    t=1
    for i in $(seq 1 "$1"); do
        let t=t+1
    done
}


# Section: arrget

___x_cmd_test_bench_get_inner(){
    local i
    for i in $(seq 1 "$1"); do
        printf "%s" "${dataarr[12]}"
        #  printf "%s" "${dataarr[ $(( i % 12 )) ]}"
    done
} >/dev/null

dataarr=(
advise
ali
assert
awk
boot
cat
ccmd
cd
convert
cowsay
cp
dev
dict
el
env
ff
ffmpeg
gh
go
gt
http
hub
install
java
jo
job
json
license
list
ll
log
ls
magick
man
mv
node
nvm
op
os
p7zip
pandoc
param
pdf
perl
proxy
ps1env
python
rm
shall
static-build
str
sync
tab
terraform
tesseract
test
theme
tldr
trap
ui
x-cmd
x_fs
xdk
xrc
zuz
)


# EndSection


