# shellcheck shell=bash


. ./v0

# advise compt
advise compt "./test/3.json"

compt1(){
    if [ "${1}" = "_param_advise_json_items" ]; then
        cat <<A
{
  "repo": {
    "--repo|-r|r": [ "abc", "cde", "def" ],
    "--repo2|-r2|m|1": [ "m1-a", "m1-b", "m1-c" ],
    "--repo2|-r2|m|2": [ "m2-a", "m2-b", "m2-c" ],
    "--repo3|-r3|m": [ "m3-a", "m3-b", "m3-c" ],
    "--priviledge|-p": [ "private", "public" ],
    "--debug": null,
    "repo": "ls",
    "#1": "ls",
    "#2": ["#2-1", "#2-2", "#2-3"],
    "#n": ["#n-1", "#n-2", "#n-3"]
  },
  "user": {
    "create": {
      "--username|-u": [  ]
    },
    "create1": null,
    "create2": null,
    "create3": null,
    "create4": null
  }
}
A
    return 126
    fi
}

if [ -n "${BASH_VERSION}${ZSH_VERSION}" ] && [ "${-#*i}" != "$-" ]; then
    # TODO: using global variable
# if xrc advise status; then
    xrc advise
    advise compt1
fi
