#
PATH=$PATH:$HOME/bin

export PATH
umask 022

###################################################################################################
# Filename.......: .profile
# Purpose........: To setup the environment of the Oracle DBA account in a standard way.
# Owner..........: The systems Oracle DBA account
# Author.........: Bill Trigg
# Create Date....: 10/07/2000
# Update Dates...:
# ...............:
# ...............:
# ...............:
###################################################################################################
echo "Welcome to the new box"
export SEPARATE="+-----------------------------------------------------------------------------------------------------------
-----------------------+"
export NMON=cmnktd
export SYSTYPE="`uname -a | cut -c 1-3`"
export time=`date +"%H%M"`
PATH=$PATH:/usr/bin:/etc:/usr/sbin:/usr/ucb:/sbin:/sbin/usr/sbin:
export PATH
export ORACLE_SID=DWL
alias "jobs=ps -ef | grep $USER | grep -v kproc"
EPC_DISABLED=TRUE

export EPC_DISABLED

ORAENV_ASK='NO';. oraenv;ORAENV_ASK=''
tty -s
set -o vi

