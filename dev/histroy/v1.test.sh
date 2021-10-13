# shellcheck shell=bash

test123(){
    local fp="${1:-filepath}"; shift
    echo "-----"
    echo "Before awk: $*"
    local IFS=$'\002' # IFS="$(printf "\002")"

    s="$*"

    {
        cat "$fp"
        printf "\034%s\034" "$s"  # printf "\034${s}\034"
    } | awk -f v1.awk 2>/dev/null

    echo -e "-----\n"
}

# test123 test-data2.json work ""

time test123 test.2.json work --host=abc ""
# test123 test-data2.json work --host=abc -sv abc ""

# test123 test-data2.json work --host=abc -version -v repo create --has_wiki a
# test123 test-data2.json work --host=abc -v repo create --has_wiki
# test123 test-data2.json work --host=abc -v ""

