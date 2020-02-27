#!/bin/bash

echo -e "\033[33mWarning! This operation may cover your file! Please make sure that your files have been back-up!\033[0m"
read -p 'Are you sure? [y/n] ' begin
case $begin in
    y)
        ;;
    Y)
        ;;
    *)
        exit 1
esac

cd $(realpath $(dirname $0))

echo Start installing...
echo ------D-E-P-E-N-D-E-N-C-Y------
list=$(apt list --installed 2>/dev/null)
if [[ -z $(echo $list | grep libtool) || -z $(echo $list | grep make) || -z $(echo $list | grep automake) || -z $(echo $list | grep clang) ]]; then
    pkg install libtool make automake clang -y
fi
echo ------S-Y-M-L-I-N-K------
PA_AUTOMAKE=$PREFIX/share/automake-1.*
PA_LIBTOOL=$PREFIX/share/libtool/build-aux
ln -sf $PA_AUTOMAKE/depcomp depcomp
ln -sf $PA_AUTOMAKE/install-sh install-sh
ln -sf $PA_LIBTOOL/ltmain.sh ltmain.sh
echo ------R-E-C-O-N-F--F-I-L-E-N-A-M-E------
mv Makefile.in Makefile.ac
mv configure.in configure.ac
echo ------A-U-T-O-G-E-N------
bash ./autogen.sh
echo ------A-D-D--M-I-S-S-I-N-G------
automake --add-missing
# autoreconf && autoupdate
echo ------C-O-N-F-I-G-U-R-E------
bash ./configure
echo
echo ------M-A-K-E------
make -j4
echo ------C-O-P-Y--F-I-L-E------
if test -e src/adb
then
    cp -f src/adb $PREFIX/bin
fi
if test -e fastboot/fastboot
then
    cp -f fastboot/fastboot $PREFIX/bin
fi

echo Operation complete!
