wget https://github.com/prajwalsaokar/dmd_scripts/archive/main/dmd_scripts.tar.gz 
tar -xf dmd_scripts.tar.gz 
rm dmd_scripts.tar.gz 
mv dmd_scripts-main/* ./ 
rm -Rf dmd_scripts-main
rm README.md  
alias dmd="bash dmd.sh"
rm  script_download.sh 