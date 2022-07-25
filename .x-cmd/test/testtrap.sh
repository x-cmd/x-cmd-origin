f(){
    trap 'echo 100' INT
    sleep 3s
}

g(){

     trap 'echo 2' INT
    f
}

(
    g
)
