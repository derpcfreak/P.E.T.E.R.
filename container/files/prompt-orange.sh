# /etc/profile.d/prompt-orange.sh
# Sets a global orange background + black text prompt for interactive Bash shells.


# Custom orange prompt for interactive shells only
if [[ $- == *i* ]]; then
    export PS1="\[\e[48;5;208m\e[30m\][\u@\h \W]\$\[\e[0m\] "
fi

# Don’t clobber if user deliberately disables or sets their own PS1 later
# (Admins can comment this guard if they need to force it.)
if [ -n  ]; then
  return
fi

RESET_ALL='\[\e[0m\]'
