
```bash
: <<A


x ff convert a.mp4 a.mp3 <<A
{
    begin: +1min,
    enduration: 3min,
    loglevel: debug,
    audio: {

    }
}

x ff convert a.mp4 <<A
{
    "a.mp3": {
        begin: +1min,
        enduration: 3min,
        loglevel: debug,
        audio: {
            
        }
    },
    "b.mp3": {

    }
}

x ff convert a1.mp4,a2.mp4,a3.mp4 a.mp3

x ff convert <<A
{
    input: [ a1.mp4, a2.mp4, a3.mp4 ],
    output: a5.mp4
}

x ff convert <<A
{
    input: [ a1.mp4, a2.mp4, a3.mp4 ],
    output: a5.mp4,
}

x ff convert <<A
{
    input: {
        a1.mp4: {

        },
        a2.mp4: {

        },
        a3.mp4: {

        }
    }
    output: {
        a5.mp4: {

        }
    }
}
A

```
