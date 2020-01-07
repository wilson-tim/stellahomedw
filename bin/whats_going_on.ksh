#!/bin/ksh
#
# What's going on.....
# What is running, waiting to run, and not ready.
#
# Gavin Bravery 24/3/99
echo Whats running
sqlplus -s dw/dbp @$HOME/DWLIVE/integration/gav_running
echo Whats yet to run
sqlplus -s dw/dbp @$HOME/DWLIVE/integration/gav_to_run
#echo Whats not even ready yet
#sqlplus -s dw/dbp @$HOME/DWLIVE/integration/gav_completed
