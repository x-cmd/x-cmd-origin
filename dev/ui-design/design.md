
```bash
update_ui(){
    ui_seperator
    ui_style info -- Prepare the UI "$percentage"
    ui_progress "$percentage" "$symbol"

    ui_style bold black -- Initializing the storage
    ui_style info -- "$text"
    ui_cowsay Hi Good work
    ui_cowsay "$(ui_style info -- "Hi Good work")"
    ui_seperator
}
```

```bash
update_ui(){
    cat <<A
$(ui_seperator)
$(ui_style info -- Prepare the UI "$percentage")
$(ui_progress "$percentage" "$symbol")

$(ui_style bold black -- Initializing the storage)
$(ui_style info -- "$text")
$(ui_cowsay Hi Good work)
$(ui_cowsay "$(ui_style info -- "Hi Good work")" )
$(ui_seperator)
A
}
```

```bash
update_ui(){
    cat <<A
<seperator/>
<style info> Prepare the UI "$percentage" </style>
<progress :percentage :symbol> </progress>

<style bold black> Initializing the storage </style>
<style info> $text </style>
<cowsay> Hi Good work </cowsay>
<cowsay> <style info> Hi Good work </style> </cowsay>
<seperator/>
A
}
```
