# shellcheck shell=bash

dir="$(dirname "${BASH_SOURCE[0]}")"


test123(){
    local fp="${1:-filepath}"; shift
    echo "-----"  1>&2
    echo "Before awk: $*"  1>&2
    local IFS=$'\002' # IFS="$(printf "\002")"

    s="$*"

    {
        cat "$fp"
        printf "\034%s\034" "$s"  # printf "\034${s}\034"
    } | awk -f "$dir/../../v0.awk" # 2>/dev/null

    echo -e "-----\n" 1>&2
}


# time test123 "$dir/3.json" r
# test123 test-data2.json work r

# time test123 "$dir/21.json" repo ""
# time test123 "$dir/21.json" user create --username ""
# time test123 "$dir/21.json" user create --username "c:"
# cat "$dir/21.json"
# time test123 "$dir/21.json" "+"

# time test123 "$dir/21.json" --value ""
# time test123 "$dir/21.json" --value "+"

# time test123 "$dir/21.json" --value +a ""

# time test123 "$dir/21.json" --value +a :a repo

# time test123 "$dir/21.json" @
# time test123 "$dir/21.json" abc ""

a="$(test123 "$dir/21.json" abc "")"
# echo "--~~~~ > $a"
a="${a#\#\>\ }"

eval "$a"

# time test123 "$dir/3.json" repo --debug --repo abc --
# time test123 "$dir/3.json" repo --debug --repo abc -
# time test123 "$dir/3.json" repo --debug --repo abc 1 ""
# time test123 "$dir/3.json" repo --debug --repo abc 1 2 ""
# time test123 "$dir/3.json" repo --debug --repo abc ""
# time test123 "$dir/3.json" repo --debug -r3 3 ""

# time test123 "$dir/3.json" user create ""
# time test123 "$dir/3.json" repo --repo2 ""
# time test123 "$dir/3.json" repo --repo2 "abc" ""
# time test123 "$dir/3.json" user create1 ""


