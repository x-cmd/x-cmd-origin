O=:asdfafaffasdfasffasdfasf


for i in $(seq 50000); do
    [ "${O#:}" = "$O" ] >/dev/null
done

dict cli <<A
    +put     adfaf
    +put     adfa
    +put     adfasdf
A
