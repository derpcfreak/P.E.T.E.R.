#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
	echo "configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
fi

# machine must not be running to execute this script
# check if machine is already running. If so quit
if eval machinectl --no-legend --value list | grep -q "${MACHINE}"; then
 echo -e "[${RED}FAIL${NC}] machine '${MACHINE}' is running. Script will quit here! Use 'machinectl stop ${MACHINE}' first."
 exit
fi

###################################################################
# create a script in /etc/profile.de to set bash prompt color
###################################################################
read -r -d '' bashprompt <<-'EOF'
# /etc/profile.d/prompt-orange.sh
# Sets a global orange background + black text prompt for interactive Bash shells.

# Only proceed for interactive shells
case $- in
  *i*) ;;
  *) return ;;
esac

# Only for bash (avoid breaking other shells that source profile.d)
[ -n "$BASH_VERSION" ] || return

# Don’t clobber if user deliberately disables or sets their own PS1 later
# (Admins can comment this guard if they need to force it.)
if [ -n "${PROMPT_COMMAND_ORANGE_DONE}" ]; then
  return
fi

# Detect color capability
_supports_256_colors() {
  # Prefer tput if available
  if command -v tput >/dev/null 2>&1; then
    colors=$(tput colors 2>/dev/null || echo 0)
    [ "${colors:-0}" -ge 256 ] && return 0
  fi
  # Heuristic on TERM
  case "$TERM" in
    xterm-kitty|tmux-256color|*-256color) return 0 ;;
  esac
  return 1
}

if _supports_256_colors; then
  # 256‑color: orange background (208) and black foreground (16)
  ORANGE_BG='\[\e[48;5;208m\]'
  BLACK_FG='\[\e[38;5;16m\]'
else
  # Fallback (no true orange in basic 8 colors): use yellow background (43) + black text (30)
  ORANGE_BG='\[\e[43m\]'
  BLACK_FG='\[\e[30m\]'
fi

RESET_ALL='\[\e[0m\]'

# Build a readable prompt: username@host:cwd with orange bg/black fg
# Wrap non-printing sequences in \[ \] so Bash can calculate line length correctly.
# Example: [user@host:~/dir]$
PS1="${ORANGE_BG}${BLACK_FG} \u@\h:\w ${RESET_ALL}\\$ "

# Mark as done to avoid reapplying
export PROMPT_COMMAND_ORANGE_DONE=1
EOF

if ! systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	echo \"${bashprompt}\" >/etc/profile.d/prompt-orange.sh
	exit
";then
	echo -e "[${RED}FAIL${NC}] setting orange bash prompt failed."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] setting orange bash prompt succeeded."
fi
