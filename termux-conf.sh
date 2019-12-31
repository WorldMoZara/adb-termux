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

PA_AUTOMAKE=$PREFIX/share/automake-1.*
PA_LIBTOOL=$PREFIX/share/libtool/build-aux

ln -sf $PA_AUTOMAKE/depcomp depcomp
ln -sf $PA_AUTOMAKE/install-sh install-sh
ln -sf $PA_LIBTOOL/ltmain.sh ltmain.sh

sed -i 's/AM_INIT_AUTOMAKE(test\,\ 1.0)/AM_INIT_AUTOMAKE(test\,\ 1.16)/' configure.in
sed -i 's/2.4.2/2.4.6/' aclocal.m4

automake --add-missing
bash ./autogen.sh
bash ./autogen.sh
bash ./configure
make -j4
cp -f src/adb fastboot/fastboot $PREFIX/bin

echo Operation complete!
