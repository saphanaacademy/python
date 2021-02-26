#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo 'Usage:'
    echo 'create-python-runtime.sh [release] [suffix]'
    echo 'run as <sid>adm'
    echo 'See https://www.python.org/downloads/source/'   
    echo 'Examples:'
    echo 'create-python-runtime.sh 3.7.2'
    echo 'create-python-runtime.sh 3.7.2 rc1'
    echo 'create-python-runtime.sh 3.8.0 a1'    
    exit 0
fi

checkLastProcessCallResult(){
  ret=$?
  if [  $ret -gt 0 ]
  then
    echo "##########################################################"
    echo "ERROR: Last process call ended with $ret. Check stdout ..."
    echo "##########################################################"
    exit 1;
  fi
}

check_packages(){
        packageList="tk-devel tcl-devel libffi-devel openssl-devel readline-devel sqlite3-devel ncurses-devel xz-devel zlib-devel libbz2-devel libuuid-devel"
        counter=0
  for packageName in $packageList; do
    if [[ "$(rpm --query --whatprovides  $packageName)" == "no package provides $packageName" ]]; then
          echo -e "[ \e[31mFAILED\e[0m ]\t$packageName is NOT installed completely! Please install it...\n"
          counter=$[counter +1]
    else
       	  echo -e "[ \e[32mSUCCESSFUL\e[0m ]\t$packageName is installed.\n"
    fi
  done

  if [ $counter -gt 0 ]
  then
        echo -e "\e[1mPlease install all missing packages and rerun the script again.\n\e[0m"
	exit 1;
  else
        echo -e "All required packages are installed.\n"
  fi
}

echo -e "Check if all required packages to build the Python runtime are installed...\n"
check_packages
#read -p "Press [Enter] to continue or [Ctrl]+[C] to exit."

echo -e "Prepare directories...\n"
cd ~ ; mkdir -p builds source Downloads

echo -e "Download Python sources $1$2...\n"
wget -P ~/Downloads -N https://www.python.org/ftp/python/$1/Python-$1$2.tgz
#read -p "Press [Enter] to continue or [Ctrl]+[C] to exit."
checkLastProcessCallResult

echo -e "Extract Python sources $1$2...\n"
tar xzf ~/Downloads/Python-$1$2.tgz -C ~/source
#read -p "Press [Enter] to continue..."
checkLastProcessCallResult

unset PYTHONHOME
unset PYTHONPATH

echo -e "Run configure...\n"
cd ~/source/Python-$1$2
./configure \
--prefix=/usr/sap/$SAPSYSTEMNAME/home/builds/Python-$1$2 \
--exec-prefix=/usr/sap/$SAPSYSTEMNAME/home/builds/Python-$1$2 \
--enable-optimizations
checkLastProcessCallResult
#read -p "Press [Enter] to continue..."

echo -e "Run make...\n"
make altinstall clean
checkLastProcessCallResult
#read -p "Press [Enter] to continue..."

xs create-runtime -p ~/builds/Python-$1$2
checkLastProcessCallResult

xs runtimes

echo -e "\e[1mPython runtime $1$2 created successfully.\n\e[0m"
