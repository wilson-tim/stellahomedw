#This is newer.ksh. For finding files newer than a given datetime
#Run the program with something like:-  newer.ksh   07  31  03  45
# Above parameters are Month  Day  Hour  Minute. Leading zeros are essential
#
# Below creates a file stamped with the entered datetime
touch  -t  $1$2$3$4  compare.dat
#
#Below finds files newer than campare.dat (not including compare.dat itself) 
#and puts results in newtemp1.lis               
find  .  -type f  -newer compare.dat|grep -v compare>newtemp1.lis
#
#Below changes ./ (which prefixes the results) to a colon (:) because cut only
#allow single character delimiters. And puts results in newtemp2.lis
sed "s#./#:#g"<newtemp1.lis>newtemp2.lis
rm newtemp1.lis
#
#Below cuts the second field of newtemp2.lis - which is the one after the delimiter (:)
#This being the files in the current directory (plus some other rubbish) and 
#puts results in newtemp3.lis
cut -f2 -d: newtemp2.lis>newtemp3.lis
rm newtemp2.lis
#
#Below deletes newtemp4.lis. This 'purge' is essential since the do loop below piles in
#the lines and we would otherwise be showing old lines too
rm newtemp4.lis
#
#Below creates a normal directory listing of the contents of newtemp3.lis
cat newtemp3.lis|while read  x
do
ls -ltr $x>>newtemp4.lis
done
rm  newtemp3.lis
#
#Below clears the screen and lists the files (excepting the work-files - which contain the string "new") in time order 
# sandwiched between zigzag lines
clear
echo "__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__"
cat newtemp4.lis|grep -v new|sort -k8
echo "__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__"
rm newtemp4.lis
