f(){
    trap 'echo f-outer >>final.txt' INT
    {
        sleep 3s
        cat
        echo 1: $? >>a.txt
    } | {
        # trap 'echo HERE>>b1.txt' INT
        trap 'echo inner-2 >>final.txt' INT
        trap 'echo pipe>b3.txt' PIPE
        cat
        echo 2: $? >>b2.txt
    } | {
        trap 'echo inner-3 >>final.txt' INT
        cat
        echo 3: $? >>c2.txt
    }
}



(
    f
)
