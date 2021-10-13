#! /usr/bin/env sh

# /pd/build/"${PYPY_DIR}"/bin/python /pd/test.py "${CONTAINER} is ok"
# # wget https://bootstrap.pypa.io/get-pip.py
# /pd/build/"${PYPY_DIR}"/bin/python /pd/get-pip.py
uname -a

# if have no curl then install curl
if ! command -v curl > /dev/null; then
    echo "install curl"
    # if have no apt-get then use apk
    if command -v apt-get > /dev/null; then
        apt-get update > /dev/null && apt-get install -y curl > /dev/null
    elif command -v apk > /dev/null; then
        apk add curl  > /dev/null
    elif command -v yum > /dev/null; then
        yum install curl  > /dev/null
    elif command -v zypper > /dev/null; then
        zypper install -y curl > /dev/null
    else
        echo "package tool not found"
    fi
fi

command -v curl
eval "$(curl https://get.x-cmd.com)"


# patch for x-cmd
. /pd/v0
. /pd/_v0/python
xrc os/v0
os arch

x py /pd/test/test.py 