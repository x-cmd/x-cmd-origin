# Don't use alias and function together

```bash
alias ff=echo
ff(){
    echo "$@"
}

type echo
```

```
echo(){
    echo "$@"
}
```

