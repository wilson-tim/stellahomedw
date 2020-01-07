#!/bin/csh
set prompt='[\!]% '
set history=30
alias h   history
alias ll  'ls -lF'
alias dir 'ls -lF'
set filec
stty erase "^?"
umask 022
setenv EXINIT 'set ai sm ts=8 dir=/oracle/tmp sh=/bin/csh'

