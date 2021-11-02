
themes=$(cat <<!
amora
0: #28222d
1: #ed3f7f
2: #a2baa8
3: #eacac0
4: #9985d1
5: #e68ac1
6: #aabae7
7: #dedbeb
8: #302838
9: #fb5c8e
10: #bfd1c3
11: #f0ddd8
12: #b4a4de
13: #edabd2
14: #c4d1f5
15: #edebf7
background: #2a2331
foreground: #dedbeb
cursorColor: #dedbeb
!
)

apply() {
	echo "$themes"| awk -F": " -v target="$1" '
		function tmuxesc(s) { return sprintf("\033Ptmux;\033%s\033\\", s) }
		function normalize_term() {
			# Term detection voodoo

			if(ENVIRON["TERM_PROGRAM"] == "iTerm.app")
				term="iterm"
			else if(ENVIRON["TMUX"]) {
				"tmux display-message -p \"#{client_termname}\"" | getline term
				is_tmux++
			} else
				term=ENVIRON["TERM"]
		}

		BEGIN {
			normalize_term()

			if(term == "iterm") {
				bgesc="\033]Ph%s\033\\"
				fgesc="\033]Pg%s\033\\"
				colesc="\033]P%x%s\033\\"
				curesc="\033]Pl%s\033\\"
			} else {
				#Terms that play nice :)

				fgesc="\033]10;#%s\007"
				bgesc="\033]11;#%s\007"
				curesc="\033]12;#%s\007"
				colesc="\033]4;%d;#%s\007"
			}

			if(is_tmux) {
				fgesc=tmuxesc(fgesc)
				bgesc=tmuxesc(bgesc)
				curesc=tmuxesc(curesc)
				colesc=tmuxesc(colesc)
			}
		}

		$0 == target {found++}

		found && /^foreground:/ {fg=$2}
		found && /^background:/ {bg=$2}
		found && /^[0-9]+:/ {colors[int($1)]=$2}
		found && /^cursorColor:/ {cursor=$2}

		found && /^ *$/ { exit }

		END {
			if(found) {
				for(c in colors)
					printf colesc, c, substr(colors[c], 2) > "/dev/tty"

				printf fgesc, substr(fg, 2) > "/dev/tty"
				printf bgesc, substr(bg, 2) > "/dev/tty"
				printf curesc, substr(cursor, 2) > "/dev/tty"

				f=ENVIRON["THEME_HISTFILE"]
				if(f) {
					while((getline < f) > 0)
						if($0 != target)
							out = out $0 "\n"
					close(f)

					out = out target
					print out > f
				}
			}
		}
	'
}