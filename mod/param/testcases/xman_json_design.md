# Design

option_map

```json
{
    "--repo|-b": {
        "desc": "Provide two repo name",
        "optarg" :[
            {
                "match": "[0-9A-Z]*",
                "op": "=~",
                "val_name": "repo1"
            },
            {
                "match": "[0-9]*",
                "op": "=~",
                "val_name": "repo2"
            }
        ],
        "multiple": true,
        "default": "0",
    },
    "--flag1|-f" : {
        "desc": "Flag demo",
        "optarg" :[],
        "multiple": false,
        "default": null,
    },
    "#1|--namelist" : {
        "desc": "Name list demo",
        "optarg" :[
            {
                "match": "[0-9]*",
                "op": "=~",
                "val_name": "repo2"
            }
        ],
        "multiple": false,
        "default": null,
    }
}
```

subcmd

```json
{
    "subcmd": {
        "desc": "Provide two repo name"
    }
}
```
