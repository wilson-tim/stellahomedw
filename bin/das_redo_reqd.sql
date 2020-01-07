col season_year format a12 trunc
col season_type format a12 trunc
col last_redo format a26 trunc heading 'LAST_REDO_DATETIME'
select season_year,season_type,to_char(last_redo_datetime,'dd-Mon-yyyy: hh24:mi:ss') last_redo
from season
where das_redo_reqd='Y'
order by season_year,season_type;
exit
