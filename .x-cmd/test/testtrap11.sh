f(){
    trap 'echo f-outer >>final.txt' INT
    {
        trap 'echo inner-2 >>final.txt' INT
        {
            for i in $(seq 3); do
                echo cal "$i" >>sleep.txt
                sleep 3
            done
        } &
        sleep 3s
        # cat
        echo 1: $? >>a.txt
        kill $!
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
