################################################################################################
# BENCHMARK_SQL.KSH Benchmark sql statement statements stored into benchmark_sql table         #
#                                                                                              #
#----------------------------------------------------------------------------------------------#
# Change                                                                                       #
# ------                                                                                       #
#                                                                                              #
# Date          Who      Description                                                           #
# ----          ---      -----------                                                           #
# 29/06/2004    Jyoti R. initial Version                                                       #
#                                                                                              #
################################################################################################
#
#
################################################################################################
#                 Set Variables used withiin Shell                                             #
################################################################################################


. /home/dw/bin/set_oracle_variables.ksh

l_uptime=`uptime | awk '{print $11}' | sed 's/,//'`
passwd=`cat /home/dw/DWLIVE/passwords/jutil.txt`

#
#######################################################################
#                    Start of Shell Script                            #
#######################################################################

function report
{
   echo `date +%Y/%m/%d---%H:%M:%S` $*
}

report "About to start Benchmarking Sql Script"
report "--------------------------------------"
report ""

echo  "execute p_performance_stats.benchmark_sql($l_uptime)"|sqlplus -s jutil/procs

report "end of Program "
