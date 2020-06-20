#!/bin/bash
jkrnix_install() 
{
wget -qO ~/jkrnix.tar.gz ${jkrnixrepo} || exit 1
tar -xzf ~/jkrnix.tar.gz --strip-components=1 -C ~/ && rm ~/jkrnix.tar.gz
wget -qO currentVersion.flat ${jkrnixrepoversion} --header="Accept: application/vnd.github.VERSION.sha"
}

jkrnix_symlinks() 
{
for sh in $(find ${jkrnix}/bin/ -type f -name "*.sh" ! -name "*.swp")
do
	ln -sf ${sh} ${jkr}bin/
done

for shlib in $(find ${jkrnix}/lib/ -type f -name "*.shlib" ! -name "*.swp")
do
	ln -sf ${shlib} ${jkr}lib/
done

if [ ${NIP_LOGNAME} = 'jkr' ] ;
        then
            ln -sf ${jkrnix}jkr.cfg ~/etc/jkr.cfg
fi

for dot in $(find ${jkrnix}/dot/ -type f -name ".*" ! -name "*.swp")
do
	ln -sf ${dot} ${jkr}dot/
done
}
jkrnix_install
jkrnix_symlinks