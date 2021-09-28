f1() {
    n=0
    while [ "$n" -lt 300 ]; do
        n=$(( n + 1 ))
        awk 'BEGIN{ a = 1+1; }' <<A "8888"
A
    done
}

f2() {
    n=0
    while [ "$n" -lt 300 ]; do
        n=$(( n + 1 ))
        awk -f 'test.awk' <<A "8888"
A
    done
}

time f1
time f2