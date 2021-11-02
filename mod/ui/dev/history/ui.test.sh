#! /usr/bin/env bash

. "$HOME/.x-cmd/boot" 2>/dev/null || eval "$(curl https://get.x-cmd.com/script)"

# xrc ./ui
. ./v0

# $(ui_cowsay "$(ui_style info -- "$text")")
# $(ui_cowsay "$(ui_style info -- "Hi Good work")" )
# $(ui_cowsay "$text")
# $(ui_cowsay "$(ui_style info -- "Hi Good work")" )
# $(ui_cowsay "$(ui_style info -- "Hi Good work")" )

xrc cowsay

update_ui(){
    cat <<A
$(ui_seperator)
$(ui_style $style -- Initializing the storage)
$(ui_style info -- Prepare the UI "$percentage")
$(ui_progress "$percentage" "$symbol")

$(ui_style bold black -- Initializing the storage)
$(cowsay "$(ui_style warn -- "Hi Good work")" )
$(cowsay Hi Good work)
$(ui_style info -- "$text")
$(ui_seperator)
A
}

main(){

    local percentage text
    ui_region_init

    for ((percentage=0; percentage+=4; percentage < 100)); do

        # Do the logic
        case $(( percentage / 10 % 2 )) in
            0) 
            style=warn
            text="Important to say: Percentage is even.
1
2"
;;
            1) 
            style=error
            text="Hia hia. Percentage is odd.
hi";;
        esac

        # Update the UI
        ui_region_update \
            symbol="*" update_ui

        if [ "$percentage" -ge 100 ]; then
            break
        fi

        sleep 0.01s
    done

}

main


