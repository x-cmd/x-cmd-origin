


printf "\e[2m%s\n" "step 1. go"
printf "\e[2m%s\n" "step 2. go1"
printf "\e[2m%s\n" "step 3. ggpd"

tput cuu 3

sleep 1s
printf "\e[0m\e[1m%s\n" "step 1. go"
sleep 1s
printf "\e[1m%s\n" "step 2. go1"
sleep 1s
printf "\e[1m%s\n" "step 3. ggpd"

