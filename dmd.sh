source dmd.config
source $compiler_variables_path

print_help() {
  cat <<EOF
  dmd.sh

  Usage:
    dmd.sh --setup
    dmd.sh --run
  Options:
    --setup : Download and set peptide parameters for the simulation
    --run : Use the defined temperature and collision number to run the simulation

EOF
}

setup() {
  wget -O PRIME.tar.gz https://www.dropbox.com/s/7odjjse2fxf3ujd/PRIME.tar.gz?dl=1
  mkdir "PRIME_$project_name"
  tar -xvzf PRIME.tar.gz -C "PRIME_$project_name"
  rm PRIME.tar.gz
  cd "PRIME_$project_name"

  cp -f ../identity1.config genconfig/inputs/identity1.inp
  cp -f ../identity2.config genconfig/inputs/identity2.inp

  sed -i "s/nb=88/nb=$number_beads_peptide_1/" genconfig/gen_config_random-SQZ.f90
  sed -i "s/nb2=84/nb2=$number_beads_without_glycines_peptide_1/" genconfig/gen_config_random-SQZ.f90
  sed -i "s/chnln=22/chnln=$chain_length_peptide_1/" genconfig/gen_config_random-SQZ.f90
  sed -i "s/nc=12/nc=$chain_number_peptide_1/" genconfig/gen_config_random-SQZ.f90
  sed -i "s/nb3=88/nb3=$number_beads_peptide_2/" genconfig/gen_config_random-SQZ.f90
  sed -i "s/nb4=84/nb4=$number_beads_without_glycines_peptide_2/" genconfig/gen_config_random-SQZ.f90
  sed -i "s/chnln2=22/chnln2=$chain_length_peptide_2/" genconfig/gen_config_random-SQZ.f90
  sed -i "s/nc2=12/nc2=$chain_number_peptide_2/" genconfig/gen_config_random-SQZ.f90
  sed -i "s/boxl=159.0D0/boxl=${box_length}D0/" genconfig/gen_config_random-SQZ.f90
  cd genconfig
  ifort gen_config_random-SQZ.f90
  ./a.out
  cd ../

  cp -r genconfig/parameters/. parameters/
  cp -r genconfig/results/. results/d
  sed -i "s/boxl = 159.0d0/boxl = ${box_length}d0/" code/inputinfo.f
  sed -i "s|source /usr/local/bin/setupics|source $compiler_variables_path|" qfile/subscript.sh
  sed -i "s/dmd/$project_name/g" qfile/subscript.sh

  sed -i "s/Dnop1=1008/Dnop1=$(echo $number_beads_without_glycines_peptide_1*$chain_number_peptide_1 | bc)/" qfile/subscript.sh 
  sed -i "s/Dnop2=1008/Dnop2=$(echo $number_beads_without_glycines_peptide_2*$chain_number_peptide_2 | bc)/" qfile/subscript.sh
  sed -i "s/Dchnln1=22/Dchnln1=$chain_length_peptide_1/" qfile/subscript.sh
  sed -i "s/Dchnln2=22/Dchnln2=$chain_length_peptide_2/" qfile/subscript.sh
  sed -i "s/Dnumbeads1=84/Dnumbeads1=$number_beads_without_glycines_peptide_1/" qfile/subscript.sh
  sed -i "s/Dnumbeads2=84/Dnumbeads2=$number_beads_without_glycines_peptide_2/" qfile/subscript.sh 

}

run() {
  cd "PRIME_$project_name"
  sed -i "s/temp_0195/temp_0$(echo $reduced_temperature_value*1000 / 1 | bc)/" qfile/subscript.sh
  sed -i "s/out_0195/out_0$(echo reduced_temperature_value*1000 | bc)/" qfile/subscript.sh
  sed -i "s/600/$number_of_runs/" qfile/subscript.sh

  printf "%s\n" ${reduced_temperature_value}D0 $number_collisions > temp_0$(echo $reduced_temperature_value*1000 / 1 | bc)
  cd qfile
  bash subscript.sh
}

case "$1" in
  --setup)
    setup
    ;;
  --run)
    run
    ;;
  *)
    print_help
    ;;
esac