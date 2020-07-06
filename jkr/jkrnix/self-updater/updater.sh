#!/bin/bash
jkrnix_install() 
{
wget -qO ${jkr}/tmp/jkrnix.tar.gz ${jkrnixrepo} || exit 1
tar -xzf ${jkr}/tmp/jkrnix.tar.gz --strip-components=1 -C ~/ && rm ${jkr}/tmp/jkrnix.tar.gz
wget -qO ${jkrnix}/self-updater/currentVersion.flat ${jkrnixrepoversion} --header="Accept: application/vnd.github.VERSION.sha"
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

for dot in $(find ${jkrnix}/dot/ -type f -name ".*" ! -name "*.swp")
do
	ln -sf ${dot} ${jkr}dot/
done

if [ ! -z ${NIP_LOGNAME} ] ;
        then
            ln -sf ${jkrnix}jkr.cfg ~/etc/jkr.cfg
fi

}

jkrnix_install
jkrnix_symlinks