#!/bin/bash
jkrnix_install() 
{
wget -qO ~/jkrnix.tar.gz https://github.com/JWKoster/JKRnix/tarball/master || exit 1
tar -xzf ~/jkrnix.tar.gz --strip-components=1 -C ~/ && rm ~/jkrnix.tar.gz
wget -qO currentVersion.flat https://api.github.com/repos/JWKoster/JKRnix/commits/master --header="Accept: application/vnd.github.VERSION.sha"
}

jkrnix_symlinks() 
{
for sh in ${jkrnix}bin/*.sh
do
if [ -f ${sh} ]
	then
		ln -sf ${sh} ${jkr}bin/
fi
done

for shlib in ${jkrnix}lib/*.shlib
do
if [ -f ${shlib} ]
        then
                ln -sf ${shlib} ${jkr}lib/
fi
done
}

jkrnix_install
jkrnix_symlinks
