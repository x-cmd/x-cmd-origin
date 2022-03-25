# work

line1: Global Types
line2: Config Lines
line3: Default dict, according to 'scope:' attributes
line4: argument lines

```json
{
    "--repo:-r": [ "abc", "cde", "def" ],
    "--repo2:-r2:m:1": [ "abc", "cde", "def" ],
    "--repo2:-r2:m:2": [ "cde", "def" ],
    "--priviledge:-p": [  ],
    "repo": {
        "--priviledge:-p": [  ],
        "repo2": "",
        "user2": "",
    },
    "user": "work_user",
}
```
