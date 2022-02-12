# shellcheck shell=sh disable=SC2039,SC1090,SC3043

if [ -n "$RELOAD" ] || [ -z "$X_BASH_SRC_PATH" ]; then

    if curl --version 1>/dev/null 2>&1; then
        [ -n "$KSH_VERSION" ] && alias local=typeset
        _xrc_http_get(){
            curl --fail "${1:?Provide target URL}"; 
            local code=$?
            [ $code -eq 28 ] && return 4
            return $code
        }
    elif [ "$(x author 2>/dev/null)" = "ljh & LTeam" ]; then
        [ -n "$KSH_VERSION" ] && alias local=typeset
        alias _xrc_http_get="x cat"
    else
        printf "boot[ERR]: Cannot found curl or x-cmd binary for web resource downloader." >&2
        return 1 || exit 1
    fi

    xrc_curl(){
        local REDIRECT="&1"
        if [ -n "$CACHE" ]; then
            if [ -z "$UPDATE" ] && [ -f "$CACHE" ]; then
                xrc_log debug "Function xrc_curl() terminated. Because local cache existed with update flag unset: $CACHE"
                return 0
            fi
            REDIRECT=$TMPDIR.x-bash-temp-download.$RANDOM
        fi

        if _xrc_http_get "$1" 1>"$REDIRECT" 2>/dev/null; then
            if [ -n "$CACHE" ]; then
                xrc_log debug "Copy the temp file to CACHE file: $CACHE"
                mkdir -p "$(dirname "$CACHE")"
                mv "$REDIRECT" "$CACHE"
            fi
        else
            local code=$?
            xrc_log debug "_xrc_http_get $1 return code: $code. Fail to retrieve file from: $1"
            [ -n "$CACHE" ] && rm -f "$REDIRECT"    # In centos, file in "$REDIRECT" is write protected.
            return $code
        fi
    }

    XRC_LOG_COLOR=1
    XRC_LOG_TIMESTAMP=      # "+%H:%M:%S"      # Enable Timestamp.
    _xrc_logger(){
        local logger="${O:-DEFAULT}"
        local IFS=
        local level="${1:?Please provide logger level}"
        local FLAG_NAME=${FLAG_NAME:?WRONG}

        local color="\e[32;2m"
        local level_code=0
        case "$level" in
            debug|DEBUG|verbose)    level="DBG";    shift ;;
            info|INFO)              level="INF";    level_code=1;   color="\e[36m";     shift ;;
            warn|WARN)              level="WRN";    level_code=2;   color="\e[33m";     shift ;;
            error|ERROR)            level="ERR";    level_code=3;   color="\e[31m";     shift ;;
            *)                      level="verbose"           ;;
        esac

        eval "[ $level_code -lt \"\${$FLAG_NAME:-1}\" ]" && return 0
        
        local timestamp=
        [ -n "$XRC_LOG_TIMESTAMP" ] && timestamp=" [$(date "${XRC_LOG_TIMESTAMP}")]"

        if [ -n "$XRC_LOG_COLOR" ]; then

            if [ $# -eq 0 ]; then
                printf "${color}%s[%s]${timestamp}: " "$logger" "$level"
                cat
                printf "\e[0m\n"
            else
                printf "${color}%s[%s]${timestamp}: %s\e[0m\n" "$logger" "$level" "$*"
            fi
        else
            if [ $# -eq 0 ]; then
                printf "%s[%s]${timestamp}: " "$logger" "$level"
                cat
                printf "\n"
            else
                printf "%s[%s]${timestamp}: %s\n" "$logger" "$level" "$*"
            fi
        fi >&2
    }
    
    xrc(){
        [ $# -eq 0 ] && set -- "help"
        case "$1" in
            help)   cat >&2 <<A
xrc     x-bash core function.
        Uasge:  xrc <lib> [<lib>...]
        Notice, builtin command 'source' format is 'source <lib> [argument...]'"
        Please visit following hosting repository for more information:
            https://gitee.com/x-bash/x-bash
            https://github.com/x-bash/x-bash.github.io
            https://gitlab.com/x-bash/x-bash
            https://bitbucket.com/x-bash/x-bash

Subcommand:
        cat|c           Provide cat facility
        which|w         Provide local cache file location
        update|u        Update file
        upgrade         Upgrade xrc from 'https://get.x-cmd.com/script'
        cache           Provide cache filepath
        clear           Clear the cache
        debug|d         Control debug flags.
A
                    return ;;
            c|cat)  shift;
                    eval "$(t="cat" _xrc_source_file_list_code "$@")" ;;
            w|which)  shift;
                    if [ $# -eq 0 ]; then
                        cat >&2 <<A
xrc which  Download lib files and print the local path.
        Uasge:  xrc which <lib> [<lib>...]
        Example: source "$(xrc_which std/str)"
A
                        return 1
                    fi
                    eval "$(t="echo" _xrc_source_file_list_code "$@")"  ;;
            update) shift;  UPDATE=1 xrc which "$@" 1>/dev/null 2>&1    ;;
            upgrade)shift;  eval "$(curl https://get.x-cmd.com/script)" ;;
            cache)  shift;  echo "$X_BASH_SRC_PATH" ;;
            clear)  shift;
                    if ! grep "xrc_clear()" "$X_BASH_SRC_PATH/../boot" >/dev/null 2>&1; then
                        xrc_log debug "'$X_BASH_SRC_PATH/../boot' NOT found. Please manually clear cache folder: $X_BASH_SRC_PATH"
                        return 1
                    fi
                    rm -rf "$X_BASH_SRC_PATH" ;;
            log)    shift;
                    if [ $# -eq 0 ]; then
                        cat >&2 <<A
xrc log     log control facility
        Usage: 
            xrc log init [ module ]
            xrc log [... +module | -module | module/log-level ]
Subcommand:
        init <module>:                  Generate function '<module>_log'
        timestamp < on | off | <format> >:
                                        off, default setting. shutdown the timestamp output in log 
                                        on, default format is +%H:%M:%S
                                        <format>, customized timestamp format like "+%H:%M:%S", "+%m/%d-%H:%M:%S"
Example:
        Enable debug log for module json:
                xrc log +json          or   xrc log json
                xrc log json/verbose   or   xrc log json/v
                xrc log json/debug     or   xrc log json/d
        Dsiable debug log for module json:
                xrc log -json
                xrc log json/info
A
                        return 1
                    fi
                    local var
                    local level_code=0

                    case "$1" in
                        init)
                            shift;
                            for i in "$@"; do
                                var="$(echo "XRC_LOG_LEVEL_${i}" | tr "[:lower:]" "[:upper:]")"
                                eval "${i}_log(){     O=$i FLAG_NAME=$var    _xrc_logger \"\$@\";   }"
                            done 
                            return 0 ;;
                        timestamp)
                            case "$2" in
                                on)     XRC_LOG_TIMESTAMP="+%H:%M:%S";      return 0   ;;
                                off)    XRC_LOG_TIMESTAMP= ;                return 0   ;;
                                *)      printf "Try customized timestamp format wit date command:\n"
                                        if date "$2"; then
                                            XRC_LOG_TIMESTAMP="$2"
                                            return 0
                                        fi
                                        return 1    ;;
                            esac
                    esac

                    local level
                    while [ $# -ne 0 ]; do
                        case "$1" in
                            -*) var="$(echo "XRC_LOG_LEVEL_${1#-}" | tr "[:lower:]" "[:upper:]")"
                                eval "$var=1"   
                                xrc_log info "Level of logger [${1#-} is set to [info]" ;;
                            +*) var="$(echo "XRC_LOG_LEVEL_${1#+}" | tr "[:lower:]" "[:upper:]")"
                                eval "$var=0"   
                                xrc_log info "Level of logger [${1#+}] is set to [debug]" ;;
                            *)
                                level="${1#*/}"
                                var="${1%/*}"
                                case "$level" in
                                    debug|dbg|verbose|v)        level=debug;    level_code=0 ;;
                                    info|INFO|i)                level=info;     level_code=1 ;;
                                    warn|WARN|w)                level=warn;     level_code=2 ;;
                                    error|ERROR|e)              level=error;    level_code=3 ;;
                                    none|n|no)                  level=none;     level_code=4 ;;
                                    *)                          level=debug;    level_code=0 ;;
                                esac
                                xrc_log info "Level of logger [$var] is set to [$level]" 
                                var="$(echo "XRC_LOG_LEVEL_${var}" | tr "[:lower:]" "[:upper:]")"
                                eval "$var=$level_code" ;;
                        esac
                        shift
                    done ;;
            mirror) shift;
                    local fp="$X_BASH_SRC_PATH/.source.mirror.list"
                    if [ $# -ne 0 ]; then
                        mkdir -p "$(dirname "$fp")"
                        local IFS="
";
                        echo "$*" >"$fp"
                        return
                    fi
                    if [ ! -f "$fp" ]; then
                        xrc mirror "https://x-bash.github.io" "https://x-bash.gitee.io" # "https://sh.x-cmd.com"
                    fi
                    cat "$fp"
                    return ;;
            *)      eval "$(t="." _xrc_source_file_list_code "$@")"
        esac
    }

    xrc log init xrc

    X_CMD_SRC_SHELL="sh"
    if      [ -n "$ZSH_VERSION" ];  then    X_CMD_SRC_SHELL="zsh";  setopt aliases
    elif    [ -n "$BASH_VERSION" ]; then    X_CMD_SRC_SHELL="bash"; shopt -s expand_aliases
    elif    [ -n "$KSH_VERSION" ];  then    X_CMD_SRC_SHELL="ksh"
    fi

    TMPDIR=${TMPDIR:-$(dirname "$(mktemp -u)")/}    # It is posix standard. BUT NOT set in some cases.

    xrc_log debug "Setting env X_BASH_SRC_PATH: $X_BASH_SRC_PATH"
    X_BASH_SRC_PATH="$HOME/.x-cmd/x-bash"           # boot will be placed in "$HOME/.x-cmd/boot"
    mkdir -p "$X_BASH_SRC_PATH"
    PATH="$(dirname "$X_BASH_SRC_PATH")/bin:$PATH"

    _xrc_source_file_list_code(){
        local code=""
        while [ $# -ne 0 ]; do
            # What if the _xrc_which_one contains '"'
            if ! code="$code
            ${t:-.} \"$(_xrc_which_one "$1")\""; then
                echo "return 1"
                return 0
            fi
            shift
        done
        echo "$code"
    }

    xrc_log debug "Creating $X_BASH_SRC_PATH/.source.mirror.list"
    xrc mirror "https://x-bash.github.io" "https://x-bash.gitee.io" # "https://sh.x-cmd.com"

    _xrc_curl_gitx(){   # Simple strategy
        local i=1
        local mirror
        local mod="${1:?Provide location like str}"
        local mirror_list
        mirror_list="$(xrc mirror)"
        while IFS= read -r mirror; do    # It is said '-r' not supported in Bourne shell
            xrc_curl "$mirror/$mod"
            case $? in
                0)  if [ "$i" -ne 1 ]; then
                        xrc_log debug "Current default mirror is $mirror"
                        xrc mirror "$mirror" "$(echo "$mirror_list" | awk "NR!=$i{ print \$0 }" )"
                    fi
                    return 0;;
                4)  return 4;;
            esac
            i=$((i+1))  # Support both ash, dash, bash
        done <<A
$mirror_list
A
        return 1
    }

    _xrc_which_one(){
        local RESOURCE_NAME=${1:?Provide resource name};

        if [ "${RESOURCE_NAME#/}" != "$RESOURCE_NAME" ]; then
            xrc_log debug "Resource recognized as local file: $RESOURCE_NAME"
            echo "$RESOURCE_NAME"; return 0
        fi

        if [ "${RESOURCE_NAME#\./}" != "$RESOURCE_NAME" ] || [ "${RESOURCE_NAME#\.\./}" != "$RESOURCE_NAME" ]; then
            xrc_log debug "Resource recognized as local file with relative path: $RESOURCE_NAME"
            local tmp
            if tmp="$(cd "$(dirname "$RESOURCE_NAME")" || exit 1; pwd)"; then
                echo "$tmp/$(basename "$RESOURCE_NAME")"
                return 0
            else
                xrc_log warn "Local file not exists: $RESOURCE_NAME"
                return 1
            fi
        fi

        local TGT
        if [ "${RESOURCE_NAME#http://}" != "$RESOURCE_NAME" ] || [ "${RESOURCE_NAME#https://}" != "$RESOURCE_NAME" ]; then
            xrc_log debug "Resource recognized as http resource: $RESOURCE_NAME"
            TGT="$X_BASH_SRC_PATH/BASE64-URL-$(printf "%s" "$RESOURCE_NAME" | base64 | tr -d '\r\n')"
            if ! CACHE="$TGT" xrc_curl "$RESOURCE_NAME"; then
                xrc_log debug "ERROR: Fail to load http resource due to network error or other: $RESOURCE_NAME "
                return 1
            fi

            echo "$TGT"
            return 0
        fi

        xrc_log debug "Resource recognized as x-bash library: $RESOURCE_NAME"
        local module="$RESOURCE_NAME"
        if [ "${RESOURCE_NAME#*/}" = "$RESOURCE_NAME" ] ; then
            module="$module/latest"         # If it is short alias like str (short for str/latest)
            xrc_log debug "Adding latest tag by default: $module"
        fi
        TGT="$X_BASH_SRC_PATH/$module"

        if [ -f "$TGT" ]; then
            echo "$TGT"
            return
        fi

        xrc_log debug "Dowloading resource=$RESOURCE_NAME to local cache: $TGT"
        if ! CACHE="$TGT" _xrc_curl_gitx "$module"; then
            xrc_log warn "ERROR: Fail to load module due to network error or other: $RESOURCE_NAME"
            return 1
        fi
        echo "$TGT"
    }

    # xrc x comp/xrc comp/x
fi
