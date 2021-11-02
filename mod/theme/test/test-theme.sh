# shellcheck shell=sh
# shellcheck disable=SC2039
xrc json
scm_prompt_info() {
	local SCM SCM_GIT='git' SCM_P4='p4' SCM_HG='hg' SCM_SVN='svn'
		scm_prompt_char
		scm_prompt_info_common
}

scm() {
	local GIT_EXE=$(which git 2>/dev/null || true)
	local P4_EXE=$(which p4 2>/dev/null || true)
	local HG_EXE=$(which hg 2>/dev/null || true)
	local SVN_EXE=$(which svn 2>/dev/null || true)
	
	if [ -f .git/HEAD ] && [ -x "$GIT_EXE" ]; then
		SCM=$SCM_GIT
	elif [ -x "$GIT_EXE" ] && [ -n "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
		SCM=$SCM_GIT
	elif [ -x "$P4_EXE" ] && [ -n "$(p4 set P4CLIENT 2>/dev/null)" ]; then
		SCM=$SCM_P4
	elif [ -d .hg ] && [ -x "$HG_EXE" ]; then
		SCM=$SCM_HG
	elif [ -x "$HG_EXE" ] && [ -n "$(hg root 2>/dev/null)" ]; then
		SCM=$SCM_HG
	elif [ -d .svn ] && [ -x "$SVN_EXE" ]; then
		SCM=$SCM_SVN
	elif [ -x "$SVN_EXE" ] && [ -n "$(svn info --show-item wc-root 2>/dev/null)" ]; then
		SCM=$SCM_SVN
	else
		SCM='NONE'
	fi
}

scm_prompt_char() {
	scm
	if [[ $SCM == "$SCM_GIT" ]]; then
		SCM_CHAR='±'
	elif [[ $SCM == "$SCM_P4" ]]; then
		SCM_CHAR='⌛'
	elif [[ $SCM == "$SCM_HG" ]]; then
		SCM_CHAR='☿'
	elif [[ $SCM == "$SCM_SVN" ]]; then
		SCM_CHAR='⑆'
	else
		SCM_CHAR='○'
	fi
}

scm_prompt_info_common() {
	local SCM_BRANCH
	local SCM_GIT_SHOW_MINIMAL_INFO=${SCM_GIT_SHOW_MINIMAL_INFO:=true}
	if [[ ${SCM} == "${SCM_GIT}" ]]; then
		printf  "$(_git_friendly_ref)"
		return
	fi

	# TODO: consider adding minimal status information for hg and svn
	{ [[ ${SCM} == "${SCM_P4}" ]] && p4_prompt_info && return; } || true
	{ [[ ${SCM} == "${SCM_HG}" ]] && hg_prompt_info && return; } || true
	{ [[ ${SCM} == "${SCM_SVN}" ]] && svn_prompt_info && return; } || true
}

scm_char() {
	local SCM
	scm_prompt_char
	printf "${SCM_CHAR}"
}

_git_friendly_ref(){
	case "$1" in
		branch)
			git symbolic-ref -q --short HEAD 2> /dev/null || return 1
			;;
		tag)
			git describe --contains --all 2> /dev/null
			;;
		commit)
			git rev-parse --short HEAD
			;;
		*)
    		_git_friendly_ref branch || _git_friendly_ref tag || _git_friendly_ref commit
			;;
	esac
}

case $TERM in
xterm*)
    TITLEBAR="\e[033;007]"
    ;;
*)
    TITLEBAR=""
    ;;
esac

modern_scm_prompt() {
    local CHAR SCM_NONE_CHAR='○'
    CHAR=$(scm_char)
    if [ "$CHAR" = "$SCM_NONE_CHAR" ]; then
        return
    else
	printf "[$(scm_prompt_info)]"
    fi
}

chroot() {
    if [ -n "$debian_chroot" ]; then
       local my_ps_chroot="\[\e[36;1m\]$debian_chroot\[\e[0m\]"
        echo "($my_ps_chroot)"
    fi
}

prompt() {
    local my_ps_host="\e[0;32m\]\h\e[0m\]"
    local my_ps_host_root="\[\e[0;32m\]\h\[\e[0m\]"
    local my_ps_host_time="\t"

    case "$(id -u)" in
    0)
        PS1="${TITLEBAR}┌─$(chroot)[${my_ps_host_time}][$my_ps_host_root]$(modern_scm_prompt)[\[\e[0;36m\]\w\[\e[0m\]]
└─▪ "
        ;;
    *)
        PS1="${TITLEBAR}┌─$(chroot)[${my_ps_host_time}][$my_ps_host]$(modern_scm_prompt)[\[\e[0;36m\]\w\[\e[0m\]]
└─▪ "
        ;;
    esac
}
PS2="└─▪ "

prompt