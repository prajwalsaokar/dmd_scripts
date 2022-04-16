source dmd.config

cd "PRIME_$project_name"
sed -i "s/temp_0195/temp_0$(echo $reduced_temperature_value*1000 / 1 | bc)" qfile/subscript.sh
sed -i "s/out_0195/out_0$(echo reduced_temperature_value*1000 | bc)" qfile/subscript.sh
sed -i "s/600/$number_of_runs/" qfile/subscript.sh

printf "%s\n" ${reduced_temperature_value}D0 $number_of_runs > temp_0$(echo $reduced_temperature_value*1000 / 1 | bc)
cd qfile
./subscript.sh