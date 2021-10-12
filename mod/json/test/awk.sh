
# Checking Busy Box
( awk 2>&1 | grep -q BusyBox ) && echo This is busybox

# Checking Mawk
(awk -W version 2>&1 | grep -q mawk) && This is mawk

# Checking Gawk
(awk --version 2>&1 | grep -q GNU) && This is gawk

# Bsd
(awk --version) && This is BSD-AWK

awk_version(){
    if awk 2>&1 | grep -q BusyBox; then
        echo busybox
    elif awk -W version 2>&1 | grep -q mawk; then
        echo mawk
    elif awk --version 2>&1 | grep -q GNU; then
        echo gawk
    else
        echo bad
    fi
}

