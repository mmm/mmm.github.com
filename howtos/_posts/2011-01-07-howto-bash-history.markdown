---
layout: post
title: tweak bash history
tags: ['howto']
---

not sure what's best here... playing around with:

    
    # don't put duplicate lines in the history. See bash(1) for more options
    # ... or force ignoredups and ignorespace
    HISTCONTROL=ignoredups:ignorespace

    # append to the history file, don't overwrite it
    shopt -s histappend

    #HISTFILE=$HOME/.bash/history/$$

    # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
    HISTSIZE=1000
    HISTFILESIZE=2000

    PROMPT_COMMAND="history -a; history -n"
    #PROMPT_COMMAND="history -a $HISTFILE ; history -n"

or 

    unset INPUTRC
    export EDITOR=vi
    export HISTSIZE=10000000
    export HISTFILESIZE=10000000
    export HISTTIMEFORAMT="%c"
    export PROMPT_COMMAND='history -a && history -c && history -r'
    set -o vi

